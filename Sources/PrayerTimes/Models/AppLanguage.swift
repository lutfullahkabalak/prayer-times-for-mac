import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case system
    case en, tr, ar, fa, ur, id, ms, bs, sq, az, de, fr, nl, ru

    var id: String { rawValue }

    var storageValue: String { rawValue }

    /// Shown in the language picker (native name).
    var displayName: String {
        switch self {
        case .system: L10n.text("settings.language_system")
        case .en: "English"
        case .tr: "Türkçe"
        case .ar: "العربية"
        case .fa: "فارسی"
        case .ur: "اردو"
        case .id: "Bahasa Indonesia"
        case .ms: "Bahasa Melayu"
        case .bs: "Bosanski"
        case .sq: "Shqip"
        case .az: "Azərbaycan"
        case .de: "Deutsch"
        case .fr: "Français"
        case .nl: "Nederlands"
        case .ru: "Русский"
        }
    }

    static func from(storageValue: String?) -> AppLanguage {
        guard let storageValue, let language = AppLanguage(rawValue: storageValue) else {
            return .system
        }
        return language
    }
}
