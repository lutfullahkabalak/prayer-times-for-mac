import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class LanguageManager {
    static let shared = LanguageManager()

    private(set) var currentCode: String

    private init() {
        currentCode = L10n.effectiveLanguageCode
    }

    var selectedLanguage: AppLanguage {
        AppLanguage.from(storageValue: SettingsStore.appLanguage)
    }

    var layoutDirection: LayoutDirection {
        RTLHelper.isRTL(for: currentCode) ? .rightToLeft : .leftToRight
    }

    func apply(_ language: AppLanguage) {
        SettingsStore.appLanguage = language.storageValue
        currentCode = L10n.effectiveLanguageCode
    }

    func reload() {
        currentCode = L10n.effectiveLanguageCode
    }
}
