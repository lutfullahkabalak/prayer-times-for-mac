import SwiftUI

struct LocationSettingsSection: View {
    let location: SavedLocation?
    let isResolving: Bool
    let errorMessage: String?
    let countries: [Country]
    let provinces: [Province]
    let districts: [District]
    let isLoadingPlaces: Bool
    let selectedCountry: Country?
    let browsingProvince: Province?
    let browse: LocationBrowse
    @Binding var cityQuery: String
    let onDetect: () -> Void
    let onShowCountries: () -> Void
    let onBackToProvinces: () -> Void
    let onSelectCountry: (Country) -> Void
    let onSelectProvince: (Province) -> Void
    let onSelectDistrict: (District) -> Void

    @State private var provincesExpanded = false

    private var showsPlaceList: Bool {
        switch browse {
        case .provinces: provincesExpanded
        case .countries, .districts: true
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            searchField
            selectedCard

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Text(L10n.text("settings.manual_selection"))
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)

            countryRow
            if browse == .provinces {
                provinceRow
            }
            if showsPlaceList {
                listHeader
                placeList
            }
        }
        .padding(.vertical, 4)
        .onChange(of: cityQuery) { _, query in
            let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
            if browse == .provinces, !trimmed.isEmpty {
                provincesExpanded = true
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(L10n.text("settings.search_city"), text: $cityQuery)
                .textFieldStyle(.plain)
            if !cityQuery.isEmpty {
                Button {
                    cityQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var selectedCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.accentColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.text("settings.selected_location"))
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    Text(placeTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                    if !placeSubtitle.isEmpty {
                        Text(placeSubtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 0)
            }

            Divider()

            Button(action: onDetect) {
                HStack(spacing: 8) {
                    if isResolving {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "location.fill")
                    }
                    Text(
                        isResolving
                            ? L10n.text("settings.detecting_location")
                            : L10n.text("settings.use_my_location")
                    )
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(.plain)
            .disabled(isResolving)

            Text(L10n.text("settings.location_privacy"))
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var countryRow: some View {
        Button(action: onShowCountries) {
            HStack(spacing: 8) {
                Text(L10n.text("settings.country"))
                    .foregroundStyle(.primary)
                Spacer(minLength: 8)
                Text(countryTitle)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .font(.system(size: 13))
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var provinceRow: some View {
        Button {
            provincesExpanded.toggle()
        } label: {
            HStack(spacing: 8) {
                Text(L10n.text("settings.state"))
                    .foregroundStyle(.primary)
                Spacer(minLength: 8)
                Text(provinceTitle)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Image(systemName: provincesExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .font(.system(size: 13))
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var listHeader: some View {
        switch browse {
        case .provinces:
            EmptyView()
        case .countries:
            backHeader(L10n.text("settings.country"))
        case .districts:
            backHeader(LocationName.display(browsingProvince?.name ?? ""))
        }
    }

    private func backHeader(_ title: String) -> some View {
        Button(action: onBackToProvinces) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                Text(title)
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
    }

    private var placeList: some View {
        VStack(spacing: 0) {
            if isLoadingPlaces && currentRowsEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                switch browse {
                case .countries:
                    ForEach(filteredCountries) { country in
                        LocationPickerRow(
                            title: LocationName.display(country.name),
                            detail: nil,
                            showsChevron: false,
                            isSelected: country.id == selectedCountry?.id
                        ) {
                            onSelectCountry(country)
                        }
                        if country.id != filteredCountries.last?.id {
                            Divider().padding(.leading, 12)
                        }
                    }
                case .provinces:
                    ForEach(filteredProvinces) { province in
                        LocationPickerRow(
                            title: LocationName.display(province.name),
                            detail: nil,
                            showsChevron: true,
                            isSelected: false
                        ) {
                            onSelectProvince(province)
                        }
                        if province.id != filteredProvinces.last?.id {
                            Divider().padding(.leading, 12)
                        }
                    }
                case .districts:
                    ForEach(filteredDistricts) { district in
                        LocationPickerRow(
                            title: LocationName.display(district.name),
                            detail: nil,
                            showsChevron: false,
                            isSelected: district.id == location?.district.id
                        ) {
                            onSelectDistrict(district)
                        }
                        if district.id != filteredDistricts.last?.id {
                            Divider().padding(.leading, 12)
                        }
                    }
                }
            }
        }
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var currentRowsEmpty: Bool {
        switch browse {
        case .countries: filteredCountries.isEmpty
        case .provinces: filteredProvinces.isEmpty
        case .districts: filteredDistricts.isEmpty
        }
    }

    private var countryTitle: String {
        guard let selectedCountry else { return "—" }
        return LocationName.display(selectedCountry.name)
    }

    private var provinceTitle: String {
        guard let name = location?.province.name else { return "—" }
        return LocationName.display(name)
    }

    private var placeTitle: String {
        guard let location else { return L10n.text("label.no_location") }
        return LocationName.display(location.district.name)
    }

    private var placeSubtitle: String {
        guard let location else { return "" }
        let district = LocationName.display(location.district.name)
        let province = LocationName.display(location.province.name)
        let country = LocationName.display(location.country.name)
        if district.compare(province, options: .caseInsensitive, locale: LocationName.locale) == .orderedSame {
            return country
        }
        return "\(province), \(country)"
    }

    private var filteredCountries: [Country] {
        countries.filter { matches($0.name) }
    }

    private var filteredProvinces: [Province] {
        provinces.filter { matches($0.name) }
    }

    private var filteredDistricts: [District] {
        districts.filter { matches($0.name) }
    }

    private func matches(_ name: String) -> Bool {
        let query = cityQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }
        return LocationName.display(name).localizedStandardContains(query)
            || name.localizedStandardContains(query)
    }
}

private struct LocationPickerRow: View {
    let title: String
    let detail: String?
    let showsChevron: Bool
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Spacer(minLength: 8)
                if let detail {
                    Text(detail)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                }
                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isHovering ? Color.primary.opacity(0.06) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}
