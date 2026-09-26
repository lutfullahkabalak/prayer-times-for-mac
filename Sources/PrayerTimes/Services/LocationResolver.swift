import CoreLocation
import Foundation

final class LocationResolver: NSObject, ObservableObject, CLLocationManagerDelegate {
    @MainActor @Published private(set) var isResolving = false
    @MainActor @Published private(set) var errorMessage: String?

    private let manager = CLLocationManager()
    private let api = DiyanetAPI()
    private let geocoder = CLGeocoder()
    private nonisolated(unsafe) var locationResume: ResumeOnce<CLLocation?>?
    private nonisolated(unsafe) var authResume: ResumeOnce<CLAuthorizationStatus>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    @MainActor
    func resolveAutomaticLocation(reportErrors: Bool = true, ignoreRecentFix: Bool = false) async -> SavedLocation? {
        guard CLLocationManager.locationServicesEnabled() else {
            if reportErrors {
                errorMessage = L10n.text("error.location_disabled")
            }
            return nil
        }

        guard !isResolving else { return nil }

        isResolving = true
        if reportErrors {
            errorMessage = nil
        }
        defer { isResolving = false }

        let countriesTask = Task { try? await api.fetchCountries() }

        let auth = await waitForAuthorization()
        guard auth == .authorizedAlways || auth == .authorized else {
            countriesTask.cancel()
            if reportErrors {
                errorMessage = L10n.text("error.location_denied")
            }
            return nil
        }

        guard let location = await requestLocation(ignoreRecentFix: ignoreRecentFix) else {
            countriesTask.cancel()
            if reportErrors {
                errorMessage = L10n.text("error.location_unavailable")
            }
            return nil
        }

        let countries = await countriesTask.value
        return await matchLocation(location, prefetchedCountries: countries, reportErrors: reportErrors)
    }

    @MainActor
    private func report(_ message: String, enabled: Bool) {
        guard enabled else { return }
        errorMessage = message
    }

    @MainActor
    private func waitForAuthorization() async -> CLAuthorizationStatus {
        let current = manager.authorizationStatus
        if current != .notDetermined {
            return current
        }

        let resume = ResumeOnce<CLAuthorizationStatus>()
        authResume = resume
        return await withCheckedContinuation { continuation in
            resume.set(continuation)
            manager.requestWhenInUseAuthorization()
            let fallback = manager.authorizationStatus
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(15))
                resume.resume(fallback)
            }
        }
    }

    @MainActor
    private func requestLocation(ignoreRecentFix: Bool = false) async -> CLLocation? {
        if !ignoreRecentFix, let recent = manager.location,
           recent.horizontalAccuracy >= 0,
           recent.horizontalAccuracy <= 5_000,
           Date().timeIntervalSince(recent.timestamp) < 10 * 60 {
            return recent
        }

        let resume = ResumeOnce<CLLocation?>()
        locationResume = resume
        return await withCheckedContinuation { continuation in
            resume.set(continuation)
            manager.requestLocation()
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(8))
                resume.resume(nil)
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationResume?.resume(locations.first)
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationResume?.resume(nil)
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        guard status != .notDetermined else { return }
        authResume?.resume(status)
    }

    @MainActor
    func matchLocation(
        _ location: CLLocation,
        prefetchedCountries: [Country]? = nil,
        reportErrors: Bool = true
    ) async -> SavedLocation? {
        do {
            guard let placemark = await reverseGeocode(location) else {
                report(L10n.text("error.location_unavailable"), enabled: reportErrors)
                return nil
            }

            let countryName = placemark.country ?? ""
            let provinceName = placemark.administrativeArea ?? placemark.locality ?? ""
            let districtName = placemark.subAdministrativeArea ?? placemark.locality ?? provinceName

            let countries = if let prefetchedCountries {
                prefetchedCountries
            } else {
                try await api.fetchCountries()
            }
            guard let countryObj = CountryNameMapper.matchCountry(
                isoCode: placemark.isoCountryCode,
                countryName: countryName,
                in: countries
            ) else {
                report(L10n.text("error.location_match_failed"), enabled: reportErrors)
                return nil
            }

            let provinces = try await api.fetchProvinces(countryId: countryObj.id)
            guard let province = fuzzyMatch(provinceName, in: provinces.map(\.name)) else {
                report(L10n.text("error.location_match_failed"), enabled: reportErrors)
                return nil
            }
            let provinceObj = provinces.first { $0.name == province }!

            let districts = try await api.fetchDistricts(stateId: provinceObj.id)
            guard let district = fuzzyMatch(districtName, in: districts.map(\.name)) else {
                if let fallback = districts.first(where: { $0.name == provinceObj.name }) ?? districts.first {
                    return makeSavedLocation(country: countryObj, province: provinceObj, district: fallback, placemark: placemark)
                }
                report(L10n.text("error.location_match_failed"), enabled: reportErrors)
                return nil
            }
            let districtObj = districts.first { $0.name == district }!

            return makeSavedLocation(country: countryObj, province: provinceObj, district: districtObj, placemark: placemark)
        } catch {
            report(error.localizedDescription, enabled: reportErrors)
            return nil
        }
    }

    @MainActor
    private func reverseGeocode(_ location: CLLocation) async -> CLPlacemark? {
        let geocode = Task { @MainActor () -> CLPlacemark? in
            (try? await self.geocoder.reverseGeocodeLocation(location))?.first
        }
        let watchdog = Task { @MainActor in
            try? await Task.sleep(for: .seconds(8))
            geocode.cancel()
            self.geocoder.cancelGeocode()
        }
        let placemark = await geocode.value
        watchdog.cancel()
        return placemark
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
            displayName: LocationName.display(district.name),
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

/// Resumes a continuation at most once, from whichever callback arrives first.
private final class ResumeOnce<T: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<T, Never>?
    private var fired = false

    func set(_ continuation: CheckedContinuation<T, Never>) {
        lock.lock()
        self.continuation = continuation
        lock.unlock()
    }

    func resume(_ value: T) {
        lock.lock()
        guard !fired else {
            lock.unlock()
            return
        }
        fired = true
        let continuation = self.continuation
        self.continuation = nil
        lock.unlock()
        continuation?.resume(returning: value)
    }
}
