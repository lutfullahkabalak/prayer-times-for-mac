import Foundation
import Observation

@MainActor
@Observable
final class PanelLayout {
    static let shared = PanelLayout()

    var showSettings = false
    var locationBrowse: LocationBrowse = .provinces
    var viewStyle: PanelViewStyle = PanelViewStyle.from(storageValue: SettingsStore.panelViewStyle)

    /// Esc steps back through the location list, then leaves settings.
    func consumeEscape() -> Bool {
        guard showSettings else { return false }
        if locationBrowse != .provinces {
            locationBrowse = .provinces
            return true
        }
        showSettings = false
        return true
    }
}
