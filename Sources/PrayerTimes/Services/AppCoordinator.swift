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
            if let resolved = await locationResolver.resolveAutomaticLocation() {
                let withTZ = await locationResolver.resolveTimeZone(for: resolved)
                if withTZ != SettingsStore.savedLocation {
                    await store.applyLocation(withTZ)
                    MenuBarController.shared.refresh()
                }
            }
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
}
