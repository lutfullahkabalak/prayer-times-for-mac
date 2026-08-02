import Foundation
import Observation

@MainActor
@Observable
final class PrayerStore {
    private(set) var cache: CachedPrayerData?
    private(set) var activeState: ActivePrayerState?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var now = Date()

    var location: SavedLocation? { cache?.location }
    var days: [DayTimes] { cache?.days ?? [] }
    var timeZone: TimeZone { cache?.location.timeZone ?? .current }

    var today: DayTimes? {
        PrayerTimeCalculator.todayDay(from: days, now: now, timeZone: timeZone)
    }

    private let api = DiyanetAPI()
    private var refreshTask: Task<Void, Never>?
    private var timerTask: Task<Void, Never>?
    private var panelOpen = false

    func start(panelOpen: Bool = false) {
        self.panelOpen = panelOpen
        loadCache()
        startTimer()
    }

    func setPanelOpen(_ open: Bool) {
        panelOpen = open
        restartTimer()
    }

    func refreshIfNeeded() {
        refreshTask?.cancel()
        refreshTask = Task {
            await refresh(force: false)
        }
    }

    func refresh(force: Bool) async {
        if isLoading, !force { return }
        if isLoading, force {
            refreshTask?.cancel()
        }

        if !force, let cache, !cache.isStale, !days.isEmpty {
            updateActiveState()
            return
        }

        guard let location = SettingsStore.savedLocation ?? cache?.location else {
            errorMessage = L10n.text("error.no_location")
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let fetched = try await api.fetchMonthlyPrayerTimes(districtId: location.district.id)
            let days = mergeDays(previous: cache?.days ?? [], fetched: fetched, timeZone: location.timeZone)
            let newCache = CachedPrayerData(
                location: location,
                days: days,
                fetchedAt: Date(),
                districtId: location.district.id
            )
            cache = newCache
            try PrayerCache.save(newCache)
            updateActiveState()
            NotificationCenter.default.post(name: .prayerTimesUpdated, object: nil)
        } catch {
            if cache == nil {
                errorMessage = error.localizedDescription
            }
            updateActiveState()
        }
    }

    func applyLocation(_ location: SavedLocation) async {
        SettingsStore.savedLocation = location
        cache = nil
        await refresh(force: true)
    }

    private func loadCache() {
        cache = PrayerCache.load()
        updateActiveState()
    }

    private func updateActiveState() {
        now = Date()
        activeState = PrayerTimeCalculator.activePrayer(now: now, days: days, timeZone: timeZone)
    }

    private func startTimer() {
        restartTimer()
    }

    private func restartTimer() {
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                updateActiveState()
            }
        }
    }

    private func mergeDays(previous: [DayTimes], fetched: [DayTimes], timeZone: TimeZone) -> [DayTimes] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        var byDay: [String: DayTimes] = [:]

        for day in previous + fetched {
            let key = AppDateFormatters.dayKey.string(from: calendar.startOfDay(for: day.date))
            byDay[key] = day
        }

        return byDay.values.sorted { $0.date < $1.date }
    }
}

extension Notification.Name {
    static let prayerTimesUpdated = Notification.Name("prayerTimesUpdated")
}
