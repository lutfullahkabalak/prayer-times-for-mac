import Foundation
import Observation

@MainActor
@Observable
final class PanelLayout {
    static let shared = PanelLayout()

    var showSettings = false
    var viewStyle: PanelViewStyle = PanelViewStyle.from(storageValue: SettingsStore.panelViewStyle)
}
