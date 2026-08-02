import AppKit
import Foundation

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        Task { @MainActor in
            MenuBarController.shared.setup()
            await AppCoordinator.shared.bootstrapIfNeeded()
            MenuBarController.shared.refresh()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        Task { @MainActor in
            MenuBarController.shared.teardown()
        }
    }
}
