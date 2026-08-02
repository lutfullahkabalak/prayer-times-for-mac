import Foundation

enum PanelViewStyle: String, CaseIterable, Identifiable, Sendable {
    case cards
    case list
    case tiles
    case grid

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cards: L10n.text("settings.view_style_cards")
        case .list: L10n.text("settings.view_style_list")
        case .tiles: L10n.text("settings.view_style_tiles")
        case .grid: L10n.text("settings.view_style_grid")
        }
    }

    static func from(storageValue: String?) -> PanelViewStyle {
        guard let storageValue, let style = PanelViewStyle(rawValue: storageValue) else {
            return .cards
        }
        return style
    }
}
