import AppKit
import Foundation

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var wakeObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        observeWake()

        Task { @MainActor in
            MenuBarController.shared.setup()
            await AppCoordinator.shared.bootstrapIfNeeded()
            MenuBarController.shared.refresh()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let wakeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(wakeObserver)
            self.wakeObserver = nil
        }
        Task { @MainActor in
            MenuBarController.shared.teardown()
        }
    }

    private func observeWake() {
        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                await AppCoordinator.shared.refreshLocationAfterWake()
            }
        }
    }
}
