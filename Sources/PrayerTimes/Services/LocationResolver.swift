import CoreLocation
import Foundation

final class LocationResolver: NSObject, ObservableObject, CLLocationManagerDelegate {
    @MainActor @Published private(set) var isResolving = false
    @MainActor @Published private(set) var errorMessage: String?

    private let manager = CLLocationManager()
    private let api = DiyanetAPI()
    private let geocoder = CLGeocoder()
    private nonisolated(unsafe) var continuation: CheckedContinuation<CLLocation?, Never>?
    private nonisolated(unsafe) var authContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    @MainActor
    func resolveAutomaticLocation() async -> SavedLocation? {
        guard CLLocationManager.locationServicesEnabled() else {
            errorMessage = L10n.text("error.location_disabled")
            return nil
        }

        isResolving = true
        errorMessage = nil
        defer { isResolving = false }

        let auth = await waitForAuthorization()
        guard auth == .authorizedAlways || auth == .authorized else {
            errorMessage = L10n.text("error.location_denied")
            return nil
        }

        guard let location = await requestLocation() else {
            errorMessage = L10n.text("error.location_unavailable")
            return nil
        }

        return await matchLocation(location)
    }

    @MainActor
    private func waitForAuthorization() async -> CLAuthorizationStatus {
        let current = manager.authorizationStatus
        if current != .notDetermined {
            return current
        }

        return await withCheckedContinuation { continuation in
            self.authContinuation = continuation
            manager.requestWhenInUseAuthorization()
        }
    }

    @MainActor
    private func requestLocation() async -> CLLocation? {
        await withCheckedContinuation { continuation in
            self.continuation = continuation

            Task { @MainActor in
                try? await Task.sleep(for: .seconds(8))
                if self.continuation != nil {
                    self.continuation?.resume(returning: nil)
                    self.continuation = nil
                }
            }

            manager.requestLocation()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        continuation?.resume(returning: locations.first)
        continuation = nil
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(returning: nil)
        continuation = nil
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let continuation = authContinuation else { return }
        let status = manager.authorizationStatus
        guard status != .notDetermined else { return }
        authContinuation = nil
        continuation.resume(returning: status)
    }

    @MainActor
    func matchLocation(_ location: CLLocation) async -> SavedLocation? {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            guard let placemark = placemarks.first else {
                errorMessage = L10n.text("error.location_unavailable")
                return nil
            }

            let countryName = placemark.country ?? ""
            let provinceName = placemark.administrativeArea ?? placemark.locality ?? ""
            let districtName = placemark.subAdministrativeArea ?? placemark.locality ?? provinceName

            let countries = try await api.fetchCountries()
            guard let countryObj = CountryNameMapper.matchCountry(
                isoCode: placemark.isoCountryCode,
                countryName: countryName,
                in: countries
            ) else {
                errorMessage = L10n.text("error.location_match_failed")
                return nil
            }

            let provinces = try await api.fetchProvinces(countryId: countryObj.id)
            guard let province = fuzzyMatch(provinceName, in: provinces.map(\.name)) else {
                errorMessage = L10n.text("error.location_match_failed")
                return nil
            }
            let provinceObj = provinces.first { $0.name == province }!

            let districts = try await api.fetchDistricts(stateId: provinceObj.id)
            guard let district = fuzzyMatch(districtName, in: districts.map(\.name)) else {
                if let fallback = districts.first(where: { $0.name == provinceObj.name }) ?? districts.first {
                    return makeSavedLocation(country: countryObj, province: provinceObj, district: fallback, placemark: placemark)
                }
                errorMessage = L10n.text("error.location_match_failed")
                return nil
            }
            let districtObj = districts.first { $0.name == district }!

            return makeSavedLocation(country: countryObj, province: provinceObj, district: districtObj, placemark: placemark)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    @MainActor
    func resolveTimeZone(for location: SavedLocation) async -> SavedLocation {
        var updated = location
        if updated.timeZoneIdentifier != nil { return updated }

        let query = "\(location.district.name), \(location.province.name), \(location.country.name)"
        if let placemarks = try? await geocoder.geocodeAddressString(query),
           let timeZone = placemarks.first?.timeZone?.identifier {
            updated.timeZoneIdentifier = timeZone
        }
        return updated
    }

    @MainActor
    private func makeSavedLocation(
        country: Country,
        province: Province,
        district: District,
        placemark: CLPlacemark
    ) -> SavedLocation {
        SavedLocation(
            country: country,
            province: province,
            district: district,
            displayName: district.name.capitalized(with: Locale.current),
            timeZoneIdentifier: placemark.timeZone?.identifier
        )
    }

    @MainActor
    private func fuzzyMatch(_ input: String, in candidates: [String]) -> String? {
        let normalizedInput = normalize(input)
        if let exact = candidates.first(where: { normalize($0) == normalizedInput }) {
            return exact
        }
        return candidates.first { normalize($0).contains(normalizedInput) || normalizedInput.contains(normalize($0)) }
    }

    private func normalize(_ string: String) -> String {
        string
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "İ", with: "i")
            .replacingOccurrences(of: "I", with: "i")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
