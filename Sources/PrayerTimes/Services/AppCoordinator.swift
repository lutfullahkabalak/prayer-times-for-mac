import Foundation
import Observation

@MainActor
@Observable
final class AppCoordinator {
    static let shared = AppCoordinator()

    private(set) var didBootstrap = false
    let store = PrayerStore()
    let locationResolver = LocationResolver()

    func bootstrapIfNeeded() async {
        guard !didBootstrap else { return }
        didBootstrap = true

        LaunchAtLogin.syncWithStoredPreference()
        _ = await NotificationService.shared.requestAuthorization()

        store.start()

        LanguageManager.shared.reload()

        if SettingsStore.savedLocation == nil {
            SettingsStore.savedLocation = SavedLocation.istanbul
            SettingsStore.locationMode = .automatic
            await store.refresh(force: true)
            MenuBarController.shared.refresh()
        }

        if SettingsStore.locationMode == .automatic {
            await refreshAutomaticLocation()
        } else {
            await store.refresh(force: store.cache == nil)
        }

        if store.cache == nil {
            await store.refresh(force: true)
        }

        await NotificationService.shared.reschedule(with: store.cache)
    }

    func handlePrayerTimesUpdated() async {
        await NotificationService.shared.reschedule(with: store.cache)
    }

    /// Automatic mode only. Manual picks stay until the user changes them.
    func refreshLocationAfterWake() async {
        guard didBootstrap else { return }
        guard SettingsStore.locationMode == .automatic else { return }
        try? await Task.sleep(for: .seconds(2))
        await refreshAutomaticLocation(reportErrors: false, ignoreRecentFix: true)
    }

    private func refreshAutomaticLocation(reportErrors: Bool = true, ignoreRecentFix: Bool = false) async {
        guard let resolved = await locationResolver.resolveAutomaticLocation(
            reportErrors: reportErrors,
            ignoreRecentFix: ignoreRecentFix
        ) else { return }
        let withTZ = await locationResolver.resolveTimeZone(for: resolved)
        guard withTZ != SettingsStore.savedLocation else { return }
        await store.applyLocation(withTZ)
        MenuBarController.shared.refresh()
        await NotificationService.shared.reschedule(with: store.cache)
    }
}
