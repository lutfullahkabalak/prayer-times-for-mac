import Foundation

struct Country: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let name: String
    let nameEn: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case nameEn = "name_en"
    }
}

struct Province: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let name: String
    let nameEn: String?
    let countryId: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case nameEn = "name_en"
        case countryId = "country_id"
    }
}

struct District: Codable, Sendable, Identifiable, Hashable {
    let id: String
    let name: String
    let nameEn: String?
    let stateId: String
    let countryId: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case nameEn = "name_en"
        case stateId = "state_id"
        case countryId = "country_id"
    }
}

struct SavedLocation: Codable, Sendable, Equatable {
    var country: Country
    var province: Province
    var district: District
    var displayName: String
    var timeZoneIdentifier: String?

    var timeZone: TimeZone {
        if let timeZoneIdentifier,
           let zone = TimeZone(identifier: timeZoneIdentifier) {
            return zone
        }
        return .current
    }

    var fullDisplayName: String {
        "\(district.name), \(province.name), \(country.name)"
    }

    static let istanbul = SavedLocation(
        country: Country(id: "2", name: "TÜRKİYE", nameEn: "TÜRKİYE"),
        province: Province(id: "539", name: "İSTANBUL", nameEn: "İSTANBUL", countryId: "2"),
        district: District(id: "9541", name: "İSTANBUL", nameEn: "ISTANBUL", stateId: "539", countryId: "2"),
        displayName: "İstanbul",
        timeZoneIdentifier: "Europe/Istanbul"
    )
}

struct CachedPrayerData: Codable, Sendable {
    let location: SavedLocation
    let days: [DayTimes]
    let fetchedAt: Date
    let districtId: String

    var isStale: Bool {
        let threeDays: TimeInterval = 3 * 24 * 60 * 60
        return Date().timeIntervalSince(fetchedAt) > threeDays
    }

    func day(for date: Date, timeZone: TimeZone) -> DayTimes? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let target = calendar.startOfDay(for: date)
        return days.first { calendar.isDate($0.date, inSameDayAs: target) }
    }
}

enum LocationMode: String, Codable, Sendable {
    case automatic
    case manual
}
