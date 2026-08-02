import Foundation

enum PrayerCache {
    private static let fileName = "prayer-cache.json"

    static func cacheURL() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = appSupport.appendingPathComponent("PrayerTimes", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent(fileName)
    }

    static func load() -> CachedPrayerData? {
        let url = cacheURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(CachedPrayerData.self, from: data)
        } catch {
            return nil
        }
    }

    static func save(_ cache: CachedPrayerData) throws {
        let url = cacheURL()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(cache)
        try data.write(to: url, options: .atomic)
    }

    static func clear() {
        try? FileManager.default.removeItem(at: cacheURL())
    }
}

struct PrayerNotificationPreference: Codable, Equatable, Sendable {
    var enabled: Bool
    var notifyAtTime: Bool
    var preAlertEnabled: Bool
    var preAlertMinutes: Int

    static func makeDefault(preAlertMinutes: Int = 10) -> PrayerNotificationPreference {
        PrayerNotificationPreference(
            enabled: true,
            notifyAtTime: true,
            preAlertEnabled: true,
            preAlertMinutes: Self.clampedMinutes(preAlertMinutes)
        )
    }

    static func clampedMinutes(_ minutes: Int) -> Int {
        let stepped = ((max(5, min(60, minutes)) + 2) / 5) * 5
        return max(5, min(60, stepped))
    }
}

@MainActor
enum SettingsStore {
    private static let defaults = UserDefaults.standard

    enum Key {
        static let locationMode = "locationMode"
        static let savedLocation = "savedLocation"
        static let notificationsEnabled = "notificationsEnabled"
        static let preAlertMinutes = "preAlertMinutes"
        static let notificationPreferences = "notificationPreferences"
        static let launchAtLogin = "launchAtLogin"
        static let appLanguage = "appLanguage"
        static let panelViewStyle = "panelViewStyle"
        static let menuBarIconStyle = "menuBarIconStyle"
        static let menuBarShowPrayerName = "menuBarShowPrayerName"
        static let menuBarTimeDisplay = "menuBarTimeDisplay"
    }

    static var locationMode: LocationMode {
        get {
            guard let raw = defaults.string(forKey: Key.locationMode),
                  let mode = LocationMode(rawValue: raw) else {
                return .automatic
            }
            return mode
        }
        set { defaults.set(newValue.rawValue, forKey: Key.locationMode) }
    }

    static var savedLocation: SavedLocation? {
        get {
            guard let data = defaults.data(forKey: Key.savedLocation) else { return nil }
            return try? JSONDecoder().decode(SavedLocation.self, from: data)
        }
        set {
            if let newValue {
                let data = try? JSONEncoder().encode(newValue)
                defaults.set(data, forKey: Key.savedLocation)
            } else {
                defaults.removeObject(forKey: Key.savedLocation)
            }
        }
    }

    static var notificationsEnabled: Bool {
        get {
            if defaults.object(forKey: Key.notificationsEnabled) == nil { return true }
            return defaults.bool(forKey: Key.notificationsEnabled)
        }
        set { defaults.set(newValue, forKey: Key.notificationsEnabled) }
    }

    /// Per-prayer notification prefs, keyed by `Prayer.rawValue`.
    static var notificationPreferences: [String: PrayerNotificationPreference] {
        get {
            if let data = defaults.data(forKey: Key.notificationPreferences),
               let decoded = try? JSONDecoder().decode([String: PrayerNotificationPreference].self, from: data) {
                return normalizePreferences(decoded)
            }

            let legacyRaw = defaults.object(forKey: Key.preAlertMinutes) == nil
                ? 10
                : defaults.integer(forKey: Key.preAlertMinutes)
            let legacyMinutes = legacyRaw == 0 ? 10 : legacyRaw
            let migrated = makeDefaultPreferences(preAlertMinutes: legacyMinutes)
            persistPreferences(migrated)
            return migrated
        }
        set {
            persistPreferences(normalizePreferences(newValue))
        }
    }

    static func preference(for prayer: Prayer) -> PrayerNotificationPreference {
        notificationPreferences[prayer.rawValue] ?? .makeDefault()
    }

    static func setPreference(_ preference: PrayerNotificationPreference, for prayer: Prayer) {
        var prefs = notificationPreferences
        var next = preference
        next.preAlertMinutes = PrayerNotificationPreference.clampedMinutes(next.preAlertMinutes)
        prefs[prayer.rawValue] = next
        notificationPreferences = prefs
    }

    static var launchAtLogin: Bool {
        get { defaults.bool(forKey: Key.launchAtLogin) }
        set { defaults.set(newValue, forKey: Key.launchAtLogin) }
    }

    static var appLanguage: String {
        get { defaults.string(forKey: Key.appLanguage) ?? AppLanguage.system.storageValue }
        set { defaults.set(newValue, forKey: Key.appLanguage) }
    }

    static var panelViewStyle: String {
        get { defaults.string(forKey: Key.panelViewStyle) ?? PanelViewStyle.cards.rawValue }
        set { defaults.set(newValue, forKey: Key.panelViewStyle) }
    }

    static var menuBarIconStyle: String {
        get { defaults.string(forKey: Key.menuBarIconStyle) ?? MenuBarIconStyle.prayer.rawValue }
        set { defaults.set(newValue, forKey: Key.menuBarIconStyle) }
    }

    static var menuBarShowPrayerName: Bool {
        get {
            if defaults.object(forKey: Key.menuBarShowPrayerName) == nil { return true }
            return defaults.bool(forKey: Key.menuBarShowPrayerName)
        }
        set { defaults.set(newValue, forKey: Key.menuBarShowPrayerName) }
    }

    static var menuBarTimeDisplay: String {
        get { defaults.string(forKey: Key.menuBarTimeDisplay) ?? MenuBarTimeDisplay.remaining.rawValue }
        set { defaults.set(newValue, forKey: Key.menuBarTimeDisplay) }
    }

    private static func makeDefaultPreferences(preAlertMinutes: Int) -> [String: PrayerNotificationPreference] {
        var prefs: [String: PrayerNotificationPreference] = [:]
        for prayer in Prayer.notifiablePrayers {
            prefs[prayer.rawValue] = .makeDefault(preAlertMinutes: preAlertMinutes)
        }
        return prefs
    }

    private static func normalizePreferences(
        _ prefs: [String: PrayerNotificationPreference]
    ) -> [String: PrayerNotificationPreference] {
        var normalized = prefs
        for prayer in Prayer.notifiablePrayers {
            if var existing = normalized[prayer.rawValue] {
                existing.preAlertMinutes = PrayerNotificationPreference.clampedMinutes(existing.preAlertMinutes)
                normalized[prayer.rawValue] = existing
            } else {
                normalized[prayer.rawValue] = .makeDefault()
            }
        }
        return normalized
    }

    private static func persistPreferences(_ prefs: [String: PrayerNotificationPreference]) {
        if let data = try? JSONEncoder().encode(prefs) {
            defaults.set(data, forKey: Key.notificationPreferences)
        }
    }
}
