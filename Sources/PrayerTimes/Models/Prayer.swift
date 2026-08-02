import Foundation

enum Prayer: String, CaseIterable, Codable, Sendable, Identifiable {
    case imsak
    case gunes
    case ogle
    case ikindi
    case aksam
    case yatsi

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .imsak: L10n.text("prayer.imsak")
        case .gunes: L10n.text("prayer.gunes")
        case .ogle: L10n.text("prayer.ogle")
        case .ikindi: L10n.text("prayer.ikindi")
        case .aksam: L10n.text("prayer.aksam")
        case .yatsi: L10n.text("prayer.yatsi")
        }
    }

    var systemImage: String {
        switch self {
        case .imsak: "moon.stars.fill"
        case .gunes: "sunrise.fill"
        case .ogle: "sun.max.fill"
        case .ikindi: "sun.haze.fill"
        case .aksam: "sunset.fill"
        case .yatsi: "moon.fill"
        }
    }

    /// Prayer periods used for active-prayer / countdown (excludes sunrise).
    static let prayerPeriods: [Prayer] = [.imsak, .ogle, .ikindi, .aksam, .yatsi]

    /// Times that can receive notifications (includes sunrise).
    static let notifiablePrayers: [Prayer] = [.imsak, .gunes, .ogle, .ikindi, .aksam, .yatsi]
}

struct PrayerTimesPayload: Codable, Sendable, Equatable {
    let imsak: String
    let gunes: String
    let ogle: String
    let ikindi: String
    let aksam: String
    let yatsi: String

    func time(for prayer: Prayer) -> String {
        switch prayer {
        case .imsak: imsak
        case .gunes: gunes
        case .ogle: ogle
        case .ikindi: ikindi
        case .aksam: aksam
        case .yatsi: yatsi
        }
    }
}

struct HijriDate: Codable, Sendable, Equatable {
    let day: Int
    let month: Int
    let monthName: String
    let monthNameEn: String
    let year: Int
    let fullDate: String

    enum CodingKeys: String, CodingKey {
        case day, month, year
        case monthName = "month_name"
        case monthNameEn = "month_name_en"
        case fullDate = "full_date"
    }
}

struct DayTimes: Codable, Sendable, Identifiable, Equatable {
    let date: Date
    let times: PrayerTimesPayload
    let hijriDate: HijriDate?

    var id: String {
        AppDateFormatters.dayKey.string(from: date)
    }

    enum CodingKeys: String, CodingKey {
        case date, times
        case hijriDate = "hijri_date"
    }

    init(date: Date, times: PrayerTimesPayload, hijriDate: HijriDate?) {
        self.date = date
        self.times = times
        self.hijriDate = hijriDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        times = try container.decode(PrayerTimesPayload.self, forKey: .times)
        hijriDate = try container.decodeIfPresent(HijriDate.self, forKey: .hijriDate)

        if let dateString = try? container.decode(String.self, forKey: .date) {
            date = AppDateFormatters.apiDate.date(from: dateString)
                ?? AppDateFormatters.dayKey.date(from: String(dateString.prefix(10)))
                ?? Date()
        } else {
            date = Date()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(AppDateFormatters.apiDate.string(from: date), forKey: .date)
        try container.encode(times, forKey: .times)
        try container.encodeIfPresent(hijriDate, forKey: .hijriDate)
    }
}

struct ActivePrayerState: Equatable, Sendable {
    let prayer: Prayer
    let remaining: TimeInterval
    let nextBoundary: Date
}

enum AppDateFormatters {
    nonisolated(unsafe) static let apiDate: Foundation.ISO8601DateFormatter = {
        let formatter = Foundation.ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    nonisolated(unsafe) static let dayKey: Foundation.ISO8601DateFormatter = {
        let formatter = Foundation.ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()
}
