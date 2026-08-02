import Foundation

enum RTLHelper {
    private static let rtlLanguageCodes: Set<String> = ["ar", "fa", "ur"]

    static var isRTL: Bool {
        isRTL(for: L10n.effectiveLanguageCode)
    }

    static func isRTL(for languageCode: String) -> Bool {
        rtlLanguageCodes.contains(languageCode)
    }
}
