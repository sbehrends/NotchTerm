//
//  WindowManager.swift
//  NotchTerm
//
//  Creates and manages the notch window
//

import AppKit

@MainActor
final class WindowManager {
    private(set) var windowController: NotchWindowController?

    /// Owned here (not by the controller) so terminal sessions survive
    /// window rebuilds on screen reconfiguration.
    let sessionManager = TerminalSessionManager()

    private var hasBootedOnce = false
    private var rebuildWorkItem: DispatchWorkItem?

    @discardableResult
    func setupNotchWindow() -> NotchWindowController? {
        guard let screen = NSScreen.builtin ?? NSScreen.main else { return nil }

        windowController?.window?.orderOut(nil)
        windowController?.window?.close()
        windowController = nil

        windowController = NotchWindowController(
            screen: screen,
            sessionManager: sessionManager,
            runBootAnimation: !hasBootedOnce
        )
        hasBootedOnce = true
        windowController?.showWindow(nil)
        return windowController
    }

    /// Debounced rebuild for didChangeScreenParametersNotification, which
    /// often fires 2–3× per display change.
    func scheduleNotchWindowRebuild(after delay: TimeInterval = 0.3) {
        rebuildWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.setupNotchWindow()
        }
        rebuildWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}
