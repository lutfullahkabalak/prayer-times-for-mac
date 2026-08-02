import Foundation

/// Resolves Apple CLGeocoder country names / ISO codes to Diyanet API country names
/// using `Resources/CountryAliases.json`.
enum CountryNameMapper {
    private struct AliasTable: Decodable {
        let iso: [String: String]
        let aliases: [String: String]
    }

    private static let table: AliasTable = {
        guard let url = Bundle.main.url(forResource: "CountryAliases", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(AliasTable.self, from: data) else {
            return AliasTable(iso: [:], aliases: [:])
        }
        return decoded
    }()

    /// Prefer ISO code, then English/localized alias, then direct fuzzy match on API names.
    static func matchCountry(
        isoCode: String?,
        countryName: String?,
        in countries: [Country]
    ) -> Country? {
        if let isoCode,
           let mapped = table.iso[isoCode.uppercased()],
           let country = findCountry(named: mapped, in: countries) {
            return country
        }

        if let countryName, !countryName.isEmpty {
            if let mapped = aliasedDiyanetName(for: countryName),
               let country = findCountry(named: mapped, in: countries) {
                return country
            }

            if let matched = fuzzyMatch(countryName, in: countries.map(\.name)),
               let country = countries.first(where: { $0.name == matched }) {
                return country
            }

            let englishNames = countries.compactMap(\.nameEn)
            if let matched = fuzzyMatch(countryName, in: englishNames),
               let country = countries.first(where: { $0.nameEn == matched }) {
                return country
            }
        }

        return nil
    }

    static func aliasedDiyanetName(for countryName: String) -> String? {
        let key = normalize(countryName)
        if let exact = table.aliases[key] {
            return exact
        }
        // Alias keys are stored lowercase; also try folding-normalized lookup.
        return table.aliases.first { normalize($0.key) == key }?.value
    }

    static func diyanetName(forISOCode isoCode: String) -> String? {
        table.iso[isoCode.uppercased()]
    }

    private static func findCountry(named name: String, in countries: [Country]) -> Country? {
        if let exact = countries.first(where: { $0.name == name }) {
            return exact
        }
        return countries.first { normalize($0.name) == normalize(name) }
    }

    private static func fuzzyMatch(_ input: String, in candidates: [String]) -> String? {
        let normalizedInput = normalize(input)
        guard !normalizedInput.isEmpty else { return nil }
        if let exact = candidates.first(where: { normalize($0) == normalizedInput }) {
            return exact
        }
        return candidates.first {
            let candidate = normalize($0)
            return candidate.contains(normalizedInput) || normalizedInput.contains(candidate)
        }
    }

    private static func normalize(_ string: String) -> String {
        string
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .replacingOccurrences(of: "İ", with: "i")
            .replacingOccurrences(of: "I", with: "i")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
