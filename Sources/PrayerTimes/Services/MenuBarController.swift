import AppKit
import SwiftUI

@MainActor
final class MenuBarController: NSObject, NSPopoverDelegate {
    static let shared = MenuBarController()

    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var updateTimer: Timer?
    private var globalClickMonitor: Any?
    private var nextTimeFormatter: DateFormatter?
    private var nextTimeFormatterLocale: String?
    private var nextTimeFormatterTimeZone: TimeZone?

    private static let fallbackContentSize = NSSize(width: 420, height: 580)
    private static let menuBarIconSize = NSSize(width: 18, height: 18)

    func refresh() {
        updateTitle()
    }

    func syncPopoverSize() {
        guard let popover,
              let hosting = popover.contentViewController as? NSHostingController<MenuBarRootWrapper> else { return }

        hosting.view.layoutSubtreeIfNeeded()
        let size = hosting.preferredContentSize
        guard size.width > 0, size.height > 0 else {
            popover.contentSize = Self.fallbackContentSize
            return
        }
        popover.contentSize = size
    }

    func setup() {
        guard statusItem == nil else { return }

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.target = self
        item.button?.action = #selector(togglePopoverFromButton)
        statusItem = item

        let popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        popover.delegate = self
        let hosting = NSHostingController(
            rootView: MenuBarRootWrapper(store: AppCoordinator.shared.store)
        )
        hosting.sizingOptions = [.preferredContentSize]
        popover.contentViewController = hosting
        popover.contentSize = Self.fallbackContentSize
        self.popover = popover

        updateTitle()
        startUpdateTimer()
    }

    func teardown() {
        updateTimer?.invalidate()
        updateTimer = nil
        stopDismissMonitors()
        popover?.performClose(nil)
        popover = nil
        if let statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
        statusItem = nil
    }

    @objc private func togglePopoverFromButton() {
        togglePopover()
    }

    func togglePopover() {
        guard let button = statusItem?.button, let popover else { return }
        if popover.isShown {
            closePopover()
        } else {
            openPopover(relativeTo: button)
        }
    }

    func openPopover(relativeTo button: NSView) {
        guard let popover else { return }
        syncPopoverSize()
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
        AppCoordinator.shared.store.setPanelOpen(true)
        startDismissMonitors()
        DispatchQueue.main.async { [weak self] in
            self?.syncPopoverSize()
        }
    }

    func closePopover() {
        popover?.performClose(nil)
    }

    func popoverDidClose(_ notification: Notification) {
        stopDismissMonitors()
        PanelLayout.shared.showSettings = false
        AppCoordinator.shared.store.setPanelOpen(false)
    }

    /// Transient alone misses other menu-bar status item clicks; close on any outside-app click.
    private func startDismissMonitors() {
        stopDismissMonitors()
        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor in
                self?.closePopover()
            }
        }
    }

    private func stopDismissMonitors() {
        if let globalClickMonitor {
            NSEvent.removeMonitor(globalClickMonitor)
            self.globalClickMonitor = nil
        }
    }

    private func startUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTitle()
            }
        }
        if let updateTimer {
            RunLoop.main.add(updateTimer, forMode: .common)
        }
    }

    private func updateTitle() {
        guard let button = statusItem?.button else { return }

        let store = AppCoordinator.shared.store
        let iconStyle = effectiveIconStyle(
            iconStyle: MenuBarIconStyle.from(storageValue: SettingsStore.menuBarIconStyle),
            showName: SettingsStore.menuBarShowPrayerName,
            timeDisplay: MenuBarTimeDisplay.from(storageValue: SettingsStore.menuBarTimeDisplay)
        )
        let showName = SettingsStore.menuBarShowPrayerName
        let timeDisplay = MenuBarTimeDisplay.from(storageValue: SettingsStore.menuBarTimeDisplay)

        guard let state = PrayerTimeCalculator.activePrayer(
            now: Date(),
            days: store.days,
            timeZone: store.timeZone
        ) else {
            applyMenuBarAppearance(
                to: button,
                image: fallbackImage(for: iconStyle),
                title: store.isLoading ? " …" : (showName ? " Prayer Times" : ""),
                imageOnly: !showName && !store.isLoading,
                toolTip: "Prayer Times"
            )
            return
        }

        let name = state.prayer.localizedName
        let countdown = state.remaining.menuBarCountdownText
        let nextTime = formattedNextTime(state.nextBoundary, timeZone: store.timeZone)

        var titleParts: [String] = []
        if showName {
            titleParts.append(name)
        }
        if let timeText = timeText(for: timeDisplay, countdown: countdown, nextTime: nextTime) {
            titleParts.append(timeText)
        }

        let title = titleParts.isEmpty ? "" : " \(titleParts.joined(separator: " "))"
        let imageOnly = title.isEmpty && iconStyle != .none

        applyMenuBarAppearance(
            to: button,
            image: menuBarImage(for: iconStyle, prayer: state.prayer),
            title: title,
            imageOnly: imageOnly,
            toolTip: "\(name) · \(countdown) · \(nextTime)"
        )
    }

    private func effectiveIconStyle(
        iconStyle: MenuBarIconStyle,
        showName: Bool,
        timeDisplay: MenuBarTimeDisplay
    ) -> MenuBarIconStyle {
        if iconStyle == .none, !showName, timeDisplay == .none {
            return .prayer
        }
        return iconStyle
    }

    private func timeText(
        for display: MenuBarTimeDisplay,
        countdown: String,
        nextTime: String
    ) -> String? {
        switch display {
        case .none: nil
        case .remaining: countdown
        case .nextTime: nextTime
        }
    }

    private func formattedNextTime(_ date: Date, timeZone: TimeZone) -> String {
        let localeCode = L10n.effectiveLanguageCode
        if nextTimeFormatter == nil
            || nextTimeFormatterLocale != localeCode
            || nextTimeFormatterTimeZone != timeZone {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            formatter.locale = Locale(identifier: localeCode)
            formatter.timeZone = timeZone
            nextTimeFormatter = formatter
            nextTimeFormatterLocale = localeCode
            nextTimeFormatterTimeZone = timeZone
        }
        return nextTimeFormatter?.string(from: date) ?? ""
    }

    private func menuBarImage(for style: MenuBarIconStyle, prayer: Prayer) -> NSImage? {
        switch style {
        case .none:
            nil
        case .prayer:
            NSImage(systemSymbolName: prayer.systemImage, accessibilityDescription: prayer.localizedName)
        case .appMono:
            menuBarImage(from: applicationIconImage(), template: true)
        case .appColor:
            menuBarImage(from: applicationIconImage(), template: false)
        }
    }

    private func fallbackImage(for style: MenuBarIconStyle) -> NSImage? {
        switch style {
        case .none:
            nil
        case .prayer:
            NSImage(systemSymbolName: "moon.stars", accessibilityDescription: nil)
        case .appMono:
            menuBarImage(from: applicationIconImage(), template: true)
        case .appColor:
            menuBarImage(from: applicationIconImage(), template: false)
        }
    }

    private func applicationIconImage() -> NSImage {
        if let mosque = NSImage(named: "Mosque"), mosque.size.width > 0 {
            return mosque
        }
        if let icon = NSApp.applicationIconImage, icon.size.width > 0 {
            return icon
        }
        return NSImage(named: "AppIcon") ?? NSImage(systemSymbolName: "moon.stars.fill", accessibilityDescription: nil)!
    }

    private func menuBarImage(from source: NSImage, template: Bool) -> NSImage {
        let copy = source.copy() as? NSImage ?? source
        copy.isTemplate = template
        copy.size = Self.menuBarIconSize
        return copy
    }

    private func applyMenuBarAppearance(
        to button: NSStatusBarButton,
        image: NSImage?,
        title: String,
        imageOnly: Bool,
        toolTip: String
    ) {
        button.image = image
        button.imagePosition = imageOnly ? .imageOnly : .imageLeading
        button.imageScaling = .scaleProportionallyDown
        button.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        button.title = title
        button.toolTip = toolTip
    }
}

struct MenuBarRootWrapper: View {
    let store: PrayerStore

    var body: some View {
        MenuBarRoot(store: store)
    }
}
