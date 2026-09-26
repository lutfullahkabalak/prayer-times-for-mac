import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let code: Int
    let message: String
    let data: T
}

enum DiyanetAPIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(String)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Invalid API URL"
        case .invalidResponse: "Invalid server response"
        case .serverError(let message): message
        case .decodingError(let error): error.localizedDescription
        }
    }
}

struct DiyanetAPI: Sendable {
    static let baseURL = URL(string: "https://ezanvakti.imsakiyem.com")!
    private let session: URLSession

    init(session: URLSession = DiyanetAPI.defaultSession) {
        self.session = session
    }

    private static let defaultSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 12
        configuration.timeoutIntervalForResource = 20
        configuration.waitsForConnectivity = false
        return URLSession(configuration: configuration)
    }()

    func fetchCountries() async throws -> [Country] {
        if let cached = await LocationResponseCache.shared.countries() {
            return cached
        }
        let loaded: [Country] = try await get(path: "/api/locations/countries")
        await LocationResponseCache.shared.setCountries(loaded)
        return loaded
    }

    func fetchProvinces(countryId: String) async throws -> [Province] {
        if let cached = await LocationResponseCache.shared.provinces(countryId: countryId) {
            return cached
        }
        let loaded: [Province] = try await get(path: "/api/locations/states", query: ["countryId": countryId])
        await LocationResponseCache.shared.setProvinces(loaded, countryId: countryId)
        return loaded
    }

    func fetchDistricts(stateId: String) async throws -> [District] {
        if let cached = await LocationResponseCache.shared.districts(stateId: stateId) {
            return cached
        }
        let loaded: [District] = try await get(path: "/api/locations/districts", query: ["stateId": stateId])
        await LocationResponseCache.shared.setDistricts(loaded, stateId: stateId)
        return loaded
    }

    func searchDistricts(query: String) async throws -> [District] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return try await get(path: "/api/locations/search/districts", query: ["q": encoded])
    }

    func fetchMonthlyPrayerTimes(districtId: String) async throws -> [DayTimes] {
        try await get(path: "/api/prayer-times/\(districtId)/monthly")
    }

    func fetchDailyPrayerTimes(districtId: String) async throws -> [DayTimes] {
        try await get(path: "/api/prayer-times/\(districtId)/daily")
    }

    private func get<T: Decodable>(path: String, query: [String: String] = [:]) async throws -> T {
        var components = URLComponents(url: Self.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        if !query.isEmpty {
            components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = components?.url else { throw DiyanetAPIError.invalidURL }

        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse else {
            throw DiyanetAPIError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            if let apiError = try? JSONDecoder().decode(APIErrorBody.self, from: data) {
                throw DiyanetAPIError.serverError(apiError.message)
            }
            throw DiyanetAPIError.serverError("HTTP \(http.statusCode)")
        }

        do {
            let decoded = try JSONDecoder().decode(APIResponse<T>.self, from: data)
            guard decoded.success else {
                throw DiyanetAPIError.serverError(decoded.message)
            }
            return decoded.data
        } catch let error as DiyanetAPIError {
            throw error
        } catch {
            throw DiyanetAPIError.decodingError(error)
        }
    }
}

private struct APIErrorBody: Decodable {
    let message: String
}

private actor LocationResponseCache {
    static let shared = LocationResponseCache()

    private var cachedCountries: [Country]?
    private var cachedProvinces: [String: [Province]] = [:]
    private var cachedDistricts: [String: [District]] = [:]

    func countries() -> [Country]? { cachedCountries }
    func setCountries(_ value: [Country]) { cachedCountries = value }

    func provinces(countryId: String) -> [Province]? { cachedProvinces[countryId] }
    func setProvinces(_ value: [Province], countryId: String) { cachedProvinces[countryId] = value }

    func districts(stateId: String) -> [District]? { cachedDistricts[stateId] }
    func setDistricts(_ value: [District], stateId: String) { cachedDistricts[stateId] = value }
}
