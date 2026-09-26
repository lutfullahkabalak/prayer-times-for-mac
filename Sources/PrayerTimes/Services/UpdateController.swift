import AppKit
import Sparkle

/// Sparkle updater for the menu-bar app.
/// Checks once on every launch, then again every 24 hours while the app stays open.
@MainActor
final class UpdateController: NSObject, @MainActor SPUStandardUserDriverDelegate {
    static let shared = UpdateController()

    private var controller: SPUStandardUpdaterController?

    private override init() {
        super.init()
    }

    func start() {
        guard controller == nil else { return }
        let controller = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: self
        )
        self.controller = controller
        if controller.updater.automaticallyChecksForUpdates {
            controller.updater.checkForUpdatesInBackground()
        }
    }

    func checkForUpdates() {
        MenuBarController.shared.closePopover()
        showUpdateUI()
        controller?.checkForUpdates(nil)
    }

    func standardUserDriverWillShowModalAlert() {
        showUpdateUI()
    }

    func standardUserDriverWillHandleShowingUpdate(
        _ handleShowingUpdate: Bool,
        forUpdate update: SUAppcastItem,
        state: SPUUserUpdateState
    ) {
        if handleShowingUpdate {
            showUpdateUI()
        }
    }

    func standardUserDriverWillFinishUpdateSession() {
        NSApp.setActivationPolicy(.accessory)
    }

    private func showUpdateUI() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}
