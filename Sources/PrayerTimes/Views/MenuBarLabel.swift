import SwiftUI

struct MenuBarRoot: View {
    @Bindable var store: PrayerStore
    @Bindable private var language = LanguageManager.shared

    var body: some View {
        PanelView(store: store)
            .environment(\.layoutDirection, language.layoutDirection)
            .id(language.currentCode)
            .onReceive(NotificationCenter.default.publisher(for: .prayerTimesUpdated)) { _ in
                Task {
                    await AppCoordinator.shared.handlePrayerTimesUpdated()
                }
            }
    }
}
