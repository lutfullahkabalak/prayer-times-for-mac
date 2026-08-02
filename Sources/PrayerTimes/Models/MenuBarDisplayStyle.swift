import Foundation

enum MenuBarIconStyle: String, CaseIterable, Identifiable, Sendable {
    case none
    case prayer
    case appMono
    case appColor

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: L10n.text("settings.menubar_icon_none")
        case .prayer: L10n.text("settings.menubar_icon_prayer")
        case .appMono: L10n.text("settings.menubar_icon_app_mono")
        case .appColor: L10n.text("settings.menubar_icon_app_color")
        }
    }

    static func from(storageValue: String?) -> MenuBarIconStyle {
        guard let storageValue, let style = MenuBarIconStyle(rawValue: storageValue) else {
            return .prayer
        }
        return style
    }
}

enum MenuBarTimeDisplay: String, CaseIterable, Identifiable, Sendable {
    case none
    case remaining
    case nextTime

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: L10n.text("settings.menubar_time_none")
        case .remaining: L10n.text("settings.menubar_time_remaining")
        case .nextTime: L10n.text("settings.menubar_time_next")
        }
    }

    static func from(storageValue: String?) -> MenuBarTimeDisplay {
        guard let storageValue, let style = MenuBarTimeDisplay(rawValue: storageValue) else {
            return .remaining
        }
        return style
    }
}
