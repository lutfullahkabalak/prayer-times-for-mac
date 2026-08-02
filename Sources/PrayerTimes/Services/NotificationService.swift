import Foundation
import ServiceManagement
import UserNotifications

@MainActor
enum LaunchAtLogin {
    static var isEnabled: Bool {
        get { SettingsStore.launchAtLogin }
        set {
            SettingsStore.launchAtLogin = newValue
            updateRegistration(enabled: newValue)
        }
    }

    static func syncWithStoredPreference() {
        updateRegistration(enabled: SettingsStore.launchAtLogin)
    }

    private static func updateRegistration(enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            // Launch at login may fail without proper code signing in dev builds.
        }
    }
}

@MainActor
final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    func reschedule(with cache: CachedPrayerData?) async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        guard SettingsStore.notificationsEnabled, let cache else { return }

        let timeZone = cache.location.timeZone
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        let now = Date()
        let preferences = SettingsStore.notificationPreferences
        var scheduled = 0
        let limit = 60

        for day in cache.days.sorted(by: { $0.date < $1.date }) {
            let dayStart = calendar.startOfDay(for: day.date)
            for prayer in Prayer.notifiablePrayers {
                let pref = preferences[prayer.rawValue] ?? .makeDefault()
                guard pref.enabled else { continue }

                guard let boundary = PrayerTimeCalculator.parseTime(day.times.time(for: prayer), on: dayStart, timeZone: timeZone),
                      boundary > now else { continue }

                if pref.notifyAtTime {
                    await schedule(
                        id: "prayer-\(prayer.rawValue)-\(Int(boundary.timeIntervalSince1970))",
                        title: L10n.format("notification.prayer_title", prayer.localizedName),
                        body: L10n.text("notification.prayer_body"),
                        date: boundary,
                        center: center
                    )
                    scheduled += 1
                    if scheduled >= limit { return }
                }

                if pref.preAlertEnabled {
                    let minutes = PrayerNotificationPreference.clampedMinutes(pref.preAlertMinutes)
                    let alertDate = boundary.addingTimeInterval(-Double(minutes * 60))
                    if alertDate > now {
                        await schedule(
                            id: "pre-\(prayer.rawValue)-\(Int(boundary.timeIntervalSince1970))",
                            title: L10n.format("notification.pre_alert_title", prayer.localizedName),
                            body: L10n.format("notification.pre_alert_body", minutes),
                            date: alertDate,
                            center: center
                        )
                        scheduled += 1
                        if scheduled >= limit { return }
                    }
                }
            }
        }
    }

    private func schedule(
        id: String,
        title: String,
        body: String,
        date: Date,
        center: UNUserNotificationCenter
    ) async {
        // Use time-interval triggers (absolute fire date) instead of calendar
        // components — UNCalendarNotificationTrigger can fire ~1 minute late.
        let interval = date.timeIntervalSinceNow
        guard interval > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.interruptionLevel = .timeSensitive

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try? await center.add(request)
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }
}

extension Notification.Name {
    static let openSettings = Notification.Name("openSettings")
}
