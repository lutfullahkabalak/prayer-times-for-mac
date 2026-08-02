import Foundation

enum PrayerTimeCalculator {
    static func parseTime(_ time: String, on day: Date, timeZone: TimeZone) -> Date? {
        let parts = time.split(separator: ":")
        guard parts.count == 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]) else { return nil }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: day)
        var components = DateComponents()
        components.year = dayComponents.year
        components.month = dayComponents.month
        components.day = dayComponents.day
        components.hour = hour
        components.minute = minute
        components.second = 0
        return calendar.date(from: components)
    }

    static func activePrayer(
        now: Date = Date(),
        days: [DayTimes],
        timeZone: TimeZone
    ) -> ActivePrayerState? {
        let boundaries = buildBoundaries(days: days, timeZone: timeZone)
        guard !boundaries.isEmpty else { return nil }

        guard let nextIndex = boundaries.firstIndex(where: { $0.date > now }) else {
            return nil
        }

        let next = boundaries[nextIndex]
        let previous = nextIndex > 0 ? boundaries[nextIndex - 1] : nil
        let active = activePrayerPeriod(after: previous)

        return ActivePrayerState(
            prayer: active,
            remaining: next.date.timeIntervalSince(now),
            nextBoundary: next.date
        )
    }

    private struct Boundary: Equatable {
        let marker: Prayer
        let date: Date
    }

    private static func buildBoundaries(days: [DayTimes], timeZone: TimeZone) -> [Boundary] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        let sortedDays = days.sorted { $0.date < $1.date }
        var boundaries: [Boundary] = []

        for day in sortedDays {
            let dayStart = calendar.startOfDay(for: day.date)
            for prayer in Prayer.allCases {
                guard let date = parseTime(day.times.time(for: prayer), on: dayStart, timeZone: timeZone) else {
                    continue
                }
                boundaries.append(Boundary(marker: prayer, date: date))
            }
        }

        if let lastDay = sortedDays.last,
           let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: lastDay.date)),
           let tomorrowImsak = parseTime(lastDay.times.imsak, on: tomorrow, timeZone: timeZone) {
            boundaries.append(Boundary(marker: .imsak, date: tomorrowImsak))
        }

        return boundaries.sorted { $0.date < $1.date }
    }

    private static func activePrayerPeriod(after previous: Boundary?) -> Prayer {
        guard let previous else { return .yatsi }

        switch previous.marker {
        case .yatsi:
            return .yatsi
        case .imsak, .gunes:
            return .imsak
        case .ogle:
            return .ogle
        case .ikindi:
            return .ikindi
        case .aksam:
            return .aksam
        }
    }

    static func isCardActive(prayer: Prayer, activePrayer: Prayer?) -> Bool {
        guard let activePrayer else { return false }
        switch prayer {
        case .gunes:
            return false
        case .imsak:
            return activePrayer == .imsak
        default:
            return activePrayer == prayer
        }
    }

    static func todayDay(from days: [DayTimes], now: Date, timeZone: TimeZone) -> DayTimes? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return days.first { calendar.isDate($0.date, inSameDayAs: now) }
            ?? days.sorted { $0.date < $1.date }.first
    }
}

extension TimeInterval {
    var countdownText: String {
        let total = max(0, Int(self))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d", hours, minutes)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    var menuBarCountdownText: String {
        let total = max(0, Int(self))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d", hours, minutes)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }
}
