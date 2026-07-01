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

    @discardableResult
    func setupNotchWindow() -> NotchWindowController? {
        guard let screen = NSScreen.builtin ?? NSScreen.main else { return nil }

        windowController?.window?.orderOut(nil)
        windowController?.window?.close()
        windowController = nil

        windowController = NotchWindowController(screen: screen)
        windowController?.showWindow(nil)
        return windowController
    }
}
