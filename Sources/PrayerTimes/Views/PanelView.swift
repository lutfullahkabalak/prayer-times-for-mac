import AppKit
import SwiftUI

struct PrayerCard: View {
    let prayer: Prayer
    let time: String
    let isActive: Bool
    let remaining: TimeInterval?

    private var palette: SkyPalette {
        SkyPalette.palette(for: prayer)
    }

    var body: some View {
        ZStack {
            SkyScene(prayer: prayer, animate: isActive)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            HStack(spacing: 12) {
                Text(prayer.localizedName)
                    .font(.system(size: isActive ? 18 : 15, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isActive, let remaining {
                    VStack(alignment: .center, spacing: 2) {
                        Text(remaining.countdownText)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .monospacedDigit()
                        Text(L10n.text("label.remaining"))
                            .font(.system(size: 10, weight: .medium))
                            .opacity(0.85)
                    }
                }

                Text(time)
                    .font(.system(size: isActive ? 18 : 15, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .foregroundStyle(palette.textInk)
            .shadow(color: palette.textShadow, radius: 2, x: 0, y: 1)
            .padding(.horizontal, 14)
        }
        .frame(minHeight: isActive ? 64 : 48, maxHeight: .infinity)
        .opacity(isActive ? 1 : 0.45)
        .saturation(isActive ? 1 : 0.6)
        .overlay {
            if isActive {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(palette.textInk.opacity(0.65), lineWidth: 1.5)
                    .shadow(color: palette.textInk.opacity(0.35), radius: 6)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isActive)
    }
}

struct PanelView: View {
    @Bindable var store: PrayerStore
    @Bindable private var language = LanguageManager.shared
    @Bindable private var panelLayout = PanelLayout.shared

    private let settingsHeight: CGFloat = 580

    private var panelWidth: CGFloat {
        if panelLayout.showSettings { return 420 }
        switch panelLayout.viewStyle {
        case .list: return 300
        default: return 420
        }
    }

    private var bodyHeight: CGFloat {
        if panelLayout.showSettings { return settingsHeight }
        switch panelLayout.viewStyle {
        case .cards: return 500
        case .list: return 300
        case .tiles: return 170
        case .grid: return 360
        }
    }

    private var contentExpandsVertically: Bool {
        if panelLayout.showSettings { return true }
        switch panelLayout.viewStyle {
        case .cards, .grid: return true
        case .list, .tiles: return false
        }
    }

    var body: some View {
        Group {
            if panelLayout.showSettings {
                SettingsView(
                    store: store,
                    locationResolver: AppCoordinator.shared.locationResolver
                )
            } else {
                mainPanel
            }
        }
        .frame(width: panelWidth, height: bodyHeight)
        .background(Color(nsColor: .windowBackgroundColor))
        .onExitCommand {
            if panelLayout.showSettings {
                panelLayout.showSettings = false
            } else {
                MenuBarController.shared.closePopover()
            }
        }
        .onChange(of: panelLayout.viewStyle) { _, _ in
            MenuBarController.shared.syncPopoverSize()
        }
        .onChange(of: panelLayout.showSettings) { _, _ in
            MenuBarController.shared.syncPopoverSize()
        }
        .id("\(language.currentCode)-\(panelLayout.viewStyle.rawValue)-\(panelLayout.showSettings)")
    }

    private var mainPanel: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(0.35)
            mainPanelContent
            Divider().opacity(0.35)
            footer
        }
    }

    @ViewBuilder
    private var mainPanelContent: some View {
        if contentExpandsVertically {
            content.frame(maxHeight: .infinity)
        } else {
            content
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                    Text(store.location?.displayName ?? L10n.text("label.no_location"))
                        .font(.system(size: 14, weight: .semibold))
                }
                if let today = store.today {
                    Text(formattedDates(for: today))
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button {
                panelLayout.showSettings = true
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
            .help(L10n.text("settings.title"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var content: some View {
        if store.isLoading && store.today == nil {
            ProgressView(L10n.text("label.loading"))
                .frame(maxWidth: .infinity, minHeight: 360)
                .padding()
        } else if let error = store.errorMessage, store.today == nil {
            VStack(spacing: 12) {
                Text(error)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Button(L10n.text("label.retry")) {
                    Task { await store.refresh(force: true) }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 360)
            .padding()
        } else if let today = store.today {
            prayerTimesContent(for: today)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .top)
        }
    }

    @ViewBuilder
    private func prayerTimesContent(for today: DayTimes) -> some View {
        switch panelLayout.viewStyle {
        case .cards:
            VStack(spacing: 8) {
                ForEach(Prayer.allCases) { prayer in
                    PrayerCard(
                        prayer: prayer,
                        time: today.times.time(for: prayer),
                        isActive: isPrayerActive(prayer),
                        remaining: activeRemaining(for: prayer)
                    )
                }
            }
        case .list:
            VStack(spacing: 2) {
                ForEach(Prayer.allCases) { prayer in
                    PrayerListRow(
                        prayer: prayer,
                        time: today.times.time(for: prayer),
                        isActive: isPrayerActive(prayer),
                        remaining: activeRemaining(for: prayer)
                    )
                }
            }
        case .tiles:
            PrayerTilesRow(
                today: today,
                isPrayerActive: isPrayerActive,
                activeRemaining: activeRemaining
            )
        case .grid:
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                spacing: 8
            ) {
                ForEach(Prayer.allCases) { prayer in
                    PrayerGridCell(
                        prayer: prayer,
                        time: today.times.time(for: prayer),
                        isActive: isPrayerActive(prayer),
                        remaining: activeRemaining(for: prayer)
                    )
                }
            }
        }
    }

    private func isPrayerActive(_ prayer: Prayer) -> Bool {
        PrayerTimeCalculator.isCardActive(
            prayer: prayer,
            activePrayer: store.activeState?.prayer
        )
    }

    private func activeRemaining(for prayer: Prayer) -> TimeInterval? {
        isPrayerActive(prayer) ? store.activeState?.remaining : nil
    }

    private var footer: some View {
        HStack {
            Text(L10n.text("label.source"))
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
            }
            .buttonStyle(.plain)
            .help(L10n.text("label.quit"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private func formattedDates(for day: DayTimes) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: L10n.effectiveLanguageCode)
        let gregorian = formatter.string(from: day.date)
        if let hijri = day.hijriDate?.fullDate {
            return "\(gregorian) · \(hijri)"
        }
        return gregorian
    }
}

struct SettingsView: View {
    @Bindable var store: PrayerStore
    @Bindable private var panelLayout = PanelLayout.shared
    @ObservedObject var locationResolver: LocationResolver

    @State private var countries: [Country] = []
    @State private var provinces: [Province] = []
    @State private var districts: [District] = []
    @State private var selectedCountry: Country?
    @State private var selectedProvince: Province?
    @State private var selectedDistrict: District?
    @State private var locationMode: LocationMode = SettingsStore.locationMode
    @State private var notificationsEnabled = SettingsStore.notificationsEnabled
    @State private var notificationPrefs = SettingsStore.notificationPreferences
    @State private var launchAtLogin = SettingsStore.launchAtLogin
    @State private var selectedLanguage = AppLanguage.from(storageValue: SettingsStore.appLanguage)
    @State private var viewStyle = PanelViewStyle.from(storageValue: SettingsStore.panelViewStyle)
    @State private var menuBarIconStyle = MenuBarIconStyle.from(storageValue: SettingsStore.menuBarIconStyle)
    @State private var menuBarShowName = SettingsStore.menuBarShowPrayerName
    @State private var menuBarTimeDisplay = MenuBarTimeDisplay.from(storageValue: SettingsStore.menuBarTimeDisplay)
    @State private var detectedLocation: SavedLocation?
    @State private var isInitialized = false

    private var displayedLocation: SavedLocation? {
        detectedLocation ?? store.location ?? SettingsStore.savedLocation
    }

    var body: some View {
        VStack(spacing: 0) {
            settingsHeader
            Divider().opacity(0.35)
            Form {
                Section(L10n.text("settings.location")) {
                        Picker(L10n.text("settings.location_mode"), selection: $locationMode) {
                            Text(L10n.text("settings.automatic")).tag(LocationMode.automatic)
                            Text(L10n.text("settings.manual")).tag(LocationMode.manual)
                        }
                        .pickerStyle(.segmented)
                        .foregroundStyle(.primary)
                        .onChange(of: locationMode) { _, newValue in
                            guard isInitialized else { return }
                            persistLocationMode(newValue)
                        }

                        if locationMode == .automatic {
                            Button {
                                Task { await detectLocation() }
                            } label: {
                                HStack {
                                    if locationResolver.isResolving {
                                        ProgressView()
                                            .controlSize(.small)
                                    }
                                    Text(
                                        locationResolver.isResolving
                                            ? L10n.text("settings.detecting_location")
                                            : L10n.text("settings.detect_location")
                                    )
                                    .foregroundStyle(.primary)
                                }
                            }
                            .disabled(locationResolver.isResolving)

                            if let location = displayedLocation {
                                HStack(spacing: 8) {
                                    Image(systemName: "location.fill")
                                        .foregroundStyle(.secondary)
                                    Text(location.fullDisplayName)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(10)
                                .background(
                                    Color(nsColor: .controlBackgroundColor),
                                    in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                                )
                            }

                            if let error = locationResolver.errorMessage {
                                Text(error)
                                    .foregroundStyle(.red)
                                    .font(.caption)
                            }
                        } else {
                            Picker(L10n.text("settings.country"), selection: $selectedCountry) {
                                Text("—").tag(Optional<Country>.none)
                                ForEach(countries) { country in
                                    Text(country.name).tag(Optional(country))
                                }
                            }
                            .foregroundStyle(.primary)
                            .onChange(of: selectedCountry) { _, country in
                                guard isInitialized else { return }
                                Task { await loadProvinces(for: country) }
                            }

                            Picker(L10n.text("settings.state"), selection: $selectedProvince) {
                                Text("—").tag(Optional<Province>.none)
                                ForEach(provinces) { province in
                                    Text(province.name).tag(Optional(province))
                                }
                            }
                            .foregroundStyle(.primary)
                            .disabled(selectedCountry == nil)
                            .onChange(of: selectedProvince) { _, province in
                                guard isInitialized else { return }
                                Task { await loadDistricts(for: province) }
                            }

                            Picker(L10n.text("settings.district"), selection: $selectedDistrict) {
                                Text("—").tag(Optional<District>.none)
                                ForEach(districts) { district in
                                    Text(district.name).tag(Optional(district))
                                }
                            }
                            .foregroundStyle(.primary)
                            .disabled(selectedProvince == nil)
                            .onChange(of: selectedDistrict) { _, district in
                                guard isInitialized else { return }
                                Task { await applyManualLocationIfComplete(district: district) }
                            }
                        }
                    }

                    Section(L10n.text("settings.notifications")) {
                        Toggle(L10n.text("settings.enable_notifications"), isOn: $notificationsEnabled)
                            .toggleStyle(.switch)
                            .tint(.accentColor)
                            .foregroundStyle(.primary)
                            .onChange(of: notificationsEnabled) { _, enabled in
                                guard isInitialized else { return }
                                SettingsStore.notificationsEnabled = enabled
                                Task { await updateNotifications() }
                            }

                        if notificationsEnabled {
                            VStack(alignment: .leading, spacing: 6) {
                                prayerNotificationHeaderRow
                                ForEach(Prayer.notifiablePrayers) { prayer in
                                    prayerNotificationRow(for: prayer)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }

                    Section(L10n.text("settings.general")) {
                        Picker(L10n.text("settings.view_style"), selection: $viewStyle) {
                            ForEach(PanelViewStyle.allCases) { style in
                                Text(style.displayName).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)
                        .foregroundStyle(.primary)
                        .onChange(of: viewStyle) { _, style in
                            guard isInitialized else { return }
                            SettingsStore.panelViewStyle = style.rawValue
                            panelLayout.viewStyle = style
                        }

                        Picker(L10n.text("settings.menubar_icon"), selection: $menuBarIconStyle) {
                            ForEach(MenuBarIconStyle.allCases) { style in
                                Text(style.displayName).tag(style)
                            }
                        }
                        .foregroundStyle(.primary)
                        .onChange(of: menuBarIconStyle) { _, style in
                            guard isInitialized else { return }
                            SettingsStore.menuBarIconStyle = style.rawValue
                            MenuBarController.shared.refresh()
                        }

                        Toggle(L10n.text("settings.menubar_show_name"), isOn: $menuBarShowName)
                            .toggleStyle(.switch)
                            .tint(.accentColor)
                            .foregroundStyle(.primary)
                            .onChange(of: menuBarShowName) { _, enabled in
                                guard isInitialized else { return }
                                SettingsStore.menuBarShowPrayerName = enabled
                                MenuBarController.shared.refresh()
                            }

                        Picker(L10n.text("settings.menubar_time"), selection: $menuBarTimeDisplay) {
                            ForEach(MenuBarTimeDisplay.allCases) { display in
                                Text(display.displayName).tag(display)
                            }
                        }
                        .foregroundStyle(.primary)
                        .onChange(of: menuBarTimeDisplay) { _, display in
                            guard isInitialized else { return }
                            SettingsStore.menuBarTimeDisplay = display.rawValue
                            MenuBarController.shared.refresh()
                        }

                        Picker(L10n.text("settings.language"), selection: $selectedLanguage) {
                            ForEach(AppLanguage.allCases) { language in
                                Text(language.displayName).tag(language)
                            }
                        }
                        .foregroundStyle(.primary)
                        .onChange(of: selectedLanguage) { _, language in
                            guard isInitialized else { return }
                            LanguageManager.shared.apply(language)
                        }

                        Toggle(L10n.text("settings.launch_at_login"), isOn: $launchAtLogin)
                            .toggleStyle(.switch)
                            .tint(.accentColor)
                            .foregroundStyle(.primary)
                            .onChange(of: launchAtLogin) { _, enabled in
                                guard isInitialized else { return }
                                SettingsStore.launchAtLogin = enabled
                                LaunchAtLogin.isEnabled = enabled
                            }
                    }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .padding(.horizontal, -8)
            .frame(maxHeight: .infinity)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .foregroundStyle(.primary)
        .frame(maxHeight: .infinity)
        .task {
            await loadCountries()
            prefillFromSavedLocation()
            isInitialized = true
        }
    }

    private var settingsHeader: some View {
        ZStack {
            HStack {
                Button {
                    panelLayout.showSettings = false
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text(L10n.text("label.back"))
                    }
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)
            }

            Text(L10n.text("settings.title"))
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func loadCountries() async {
        do {
            countries = try await DiyanetAPI().fetchCountries()
        } catch {
            countries = []
        }
    }

    private func loadProvinces(for country: Country?) async {
        provinces = []
        districts = []
        selectedProvince = nil
        selectedDistrict = nil
        guard let country else { return }
        do {
            provinces = try await DiyanetAPI().fetchProvinces(countryId: country.id)
        } catch {
            provinces = []
        }
    }

    private func loadDistricts(for province: Province?) async {
        districts = []
        selectedDistrict = nil
        guard let province else { return }
        do {
            districts = try await DiyanetAPI().fetchDistricts(stateId: province.id)
        } catch {
            districts = []
        }
    }

    private func prefillFromSavedLocation() {
        guard let saved = SettingsStore.savedLocation ?? store.location else { return }
        detectedLocation = saved
        selectedCountry = saved.country
        selectedProvince = saved.province
        selectedDistrict = saved.district
        Task {
            await loadProvinces(for: saved.country)
            await loadDistricts(for: saved.province)
            selectedProvince = saved.province
            selectedDistrict = saved.district
        }
    }

    private func detectLocation() async {
        guard let resolved = await locationResolver.resolveAutomaticLocation() else { return }
        let withTZ = await locationResolver.resolveTimeZone(for: resolved)
        detectedLocation = withTZ
        selectedCountry = withTZ.country
        selectedProvince = withTZ.province
        selectedDistrict = withTZ.district
        SettingsStore.locationMode = .automatic
        locationMode = .automatic
        await store.applyLocation(withTZ)
        await NotificationService.shared.reschedule(with: store.cache)
    }

    private func persistLocationMode(_ mode: LocationMode) {
        SettingsStore.locationMode = mode
    }

    private func applyManualLocationIfComplete(district: District?) async {
        guard let country = selectedCountry,
              let province = selectedProvince,
              let district else { return }

        var location = SavedLocation(
            country: country,
            province: province,
            district: district,
            displayName: district.name.capitalized(with: Locale.current),
            timeZoneIdentifier: nil
        )
        location = await locationResolver.resolveTimeZone(for: location)
        detectedLocation = location
        SettingsStore.locationMode = .manual
        await store.applyLocation(location)
        await NotificationService.shared.reschedule(with: store.cache)
    }

    private func updateNotifications() async {
        if notificationsEnabled {
            _ = await NotificationService.shared.requestAuthorization()
        }
        await NotificationService.shared.reschedule(with: store.cache)
    }

    private var prayerNotificationHeaderRow: some View {
        HStack(spacing: 8) {
            Color.clear.frame(width: 56, alignment: .leading)
            notificationColumnLabel(L10n.text("settings.col_enabled"), width: 36)
            notificationColumnLabel(L10n.text("settings.notify_at_time"), width: 72)
            notificationColumnLabel(L10n.text("settings.pre_alert_enabled"), width: 72)
            notificationColumnLabel(L10n.text("settings.col_minutes"), width: 64)
        }
    }

    private func notificationColumnLabel(_ text: String, width: CGFloat) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .semibold))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.75)
            .frame(width: width)
    }

    private func prayerNotificationRow(for prayer: Prayer) -> some View {
        let pref = notificationPrefs[prayer.rawValue] ?? .makeDefault()
        let controlsActive = pref.enabled

        return HStack(spacing: 8) {
            Text(prayer.localizedName)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(width: 56, alignment: .leading)

            Toggle("", isOn: preferenceBinding(for: prayer, keyPath: \.enabled))
                .toggleStyle(.switch)
                .labelsHidden()
                .controlSize(.mini)
                .tint(.accentColor)
                .frame(width: 36)
                .help(L10n.text("settings.col_enabled"))

            Toggle("", isOn: preferenceBinding(for: prayer, keyPath: \.notifyAtTime))
                .toggleStyle(.switch)
                .labelsHidden()
                .controlSize(.mini)
                .tint(.accentColor)
                .frame(width: 72)
                .disabled(!controlsActive)
                .opacity(controlsActive ? 1 : 0.35)
                .help(L10n.text("settings.notify_at_time"))

            Toggle("", isOn: preferenceBinding(for: prayer, keyPath: \.preAlertEnabled))
                .toggleStyle(.switch)
                .labelsHidden()
                .controlSize(.mini)
                .tint(.accentColor)
                .frame(width: 72)
                .disabled(!controlsActive)
                .opacity(controlsActive ? 1 : 0.35)
                .help(L10n.text("settings.pre_alert_enabled"))

            HStack(spacing: 2) {
                Text("\(pref.preAlertMinutes)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .frame(width: 20, alignment: .trailing)
                Stepper("", value: preferenceMinutesBinding(for: prayer), in: 5...60, step: 5)
                    .labelsHidden()
                    .controlSize(.mini)
            }
            .frame(width: 64)
            .disabled(!controlsActive || !pref.preAlertEnabled)
            .opacity(controlsActive && pref.preAlertEnabled ? 1 : 0.35)
            .help(L10n.format("settings.pre_alert_minutes", pref.preAlertMinutes))
        }
        .padding(.vertical, 2)
    }

    private func preferenceBinding(
        for prayer: Prayer,
        keyPath: WritableKeyPath<PrayerNotificationPreference, Bool>
    ) -> Binding<Bool> {
        Binding(
            get: {
                (notificationPrefs[prayer.rawValue] ?? .makeDefault())[keyPath: keyPath]
            },
            set: { newValue in
                guard isInitialized else { return }
                var pref = notificationPrefs[prayer.rawValue] ?? .makeDefault()
                pref[keyPath: keyPath] = newValue
                notificationPrefs[prayer.rawValue] = pref
                SettingsStore.setPreference(pref, for: prayer)
                Task { await NotificationService.shared.reschedule(with: store.cache) }
            }
        )
    }

    private func preferenceMinutesBinding(for prayer: Prayer) -> Binding<Int> {
        Binding(
            get: {
                (notificationPrefs[prayer.rawValue] ?? .makeDefault()).preAlertMinutes
            },
            set: { newValue in
                guard isInitialized else { return }
                var pref = notificationPrefs[prayer.rawValue] ?? .makeDefault()
                pref.preAlertMinutes = PrayerNotificationPreference.clampedMinutes(newValue)
                notificationPrefs[prayer.rawValue] = pref
                SettingsStore.setPreference(pref, for: prayer)
                Task { await NotificationService.shared.reschedule(with: store.cache) }
            }
        )
    }
}
