//
//  NotchWindowController.swift
//  NotchTerm
//
//  Controls the notch window positioning and lifecycle
//

import AppKit
import Combine
import SwiftUI

final class NotchWindowController: NSWindowController {
    let viewModel: NotchViewModel
    let sessionManager: TerminalSessionManager
    private var cancellables = Set<AnyCancellable>()
    private nonisolated(unsafe) var keyMonitor: Any?

    /// Normal level: floats above the menu bar so the pill is always visible.
    private let elevatedLevel: NSWindow.Level = .mainMenu + 3
    /// Yielded level: drops below system dialogs (TCC / folder-access prompts)
    /// so they're not covered by an expanded panel.
    private let loweredLevel: NSWindow.Level = .normal

    init(screen: NSScreen) {
        let screenFrame = screen.frame
        let notchSize = screen.notchSize

        let windowHeight: CGFloat = 650
        let windowFrame = NSRect(
            x: screenFrame.origin.x,
            y: screenFrame.maxY - windowHeight,
            width: screenFrame.width,
            height: windowHeight
        )

        let deviceNotchRect = CGRect(
            x: (screenFrame.width - notchSize.width) / 2,
            y: 0,
            width: notchSize.width,
            height: notchSize.height
        )

        self.viewModel = NotchViewModel(
            deviceNotchRect: deviceNotchRect,
            screenRect: screenFrame,
            windowHeight: windowHeight,
            hasPhysicalNotch: screen.hasPhysicalNotch
        )

        self.sessionManager = TerminalSessionManager()

        let notchWindow = NotchPanel(
            contentRect: windowFrame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        super.init(window: notchWindow)

        let hostingController = NotchViewController(
            viewModel: viewModel,
            sessionManager: sessionManager
        )
        notchWindow.contentViewController = hostingController
        notchWindow.setFrame(windowFrame, display: true)

        viewModel.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self, weak notchWindow] status in
                guard let self, let notchWindow else { return }
                // Any status change restores elevation; a system dialog only
                // lowers us transiently via appDidResignActive.
                notchWindow.level = self.elevatedLevel
                switch status {
                case .opened:
                    notchWindow.ignoresMouseEvents = false
                    NSApp.activate(ignoringOtherApps: false)
                    notchWindow.makeKey()
                case .closed:
                    notchWindow.ignoresMouseEvents = true
                }
            }
            .store(in: &cancellables)

        notchWindow.ignoresMouseEvents = true
        setupKeyboardShortcuts()
        setupSystemDialogYielding()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.viewModel.performBootAnimation()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
        }
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - System dialog yielding (Option B)

    /// When macOS shows a system dialog (e.g. a folder-access / TCC prompt) it
    /// takes foreground on behalf of a system agent. We watch the workspace's
    /// frontmost application (reliable cross-process, unlike our own
    /// active/resign notifications for an accessory + nonactivating panel):
    /// when something other than us is frontmost and the panel is expanded, we
    /// drop below system dialogs; when we're frontmost again, we restore.
    private func setupSystemDialogYielding() {
        let wsCenter = NSWorkspace.shared.notificationCenter
        wsCenter.addObserver(
            self,
            selector: #selector(frontmostAppChanged(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
        // App-level fallbacks in case activation does fire.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidResignActive),
            name: NSApplication.didResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func frontmostAppChanged(_ note: Notification) {
        let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
        let isSelf = app?.processIdentifier == ProcessInfo.processInfo.processIdentifier

        if isSelf {
            setYielded(false)
        } else if viewModel.status == .opened {
            setYielded(true)
        }
    }

    @objc private func appDidResignActive() {
        guard viewModel.status == .opened else { return }
        setYielded(true)
    }

    @objc private func appDidBecomeActive() {
        setYielded(false)
    }

    private func setYielded(_ yielded: Bool) {
        window?.level = yielded ? loweredLevel : elevatedLevel
    }

    // MARK: - Keyboard shortcuts

    private func setupKeyboardShortcuts() {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }

            // ESC steps back: settings → terminal first, then closes the panel
            if event.keyCode == 53 {
                if self.viewModel.status == .opened, self.viewModel.panelContent == .settings {
                    self.viewModel.closeSettings()
                } else {
                    self.viewModel.notchClose()
                }
                return nil
            }

            // All other shortcuts only active when panel is open
            guard self.viewModel.status == .opened else { return event }

            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            guard flags == .command,
                  let chars = event.charactersIgnoringModifiers else { return event }

            if chars == "," {
                self.viewModel.toggleSettings()
                return nil
            }

            // Tab shortcuts only apply while the terminal pane is showing
            guard self.viewModel.panelContent == .terminal else { return event }

            switch chars {
            case "t":
                self.sessionManager.addSession()
                return nil
            case "w":
                if let active = self.sessionManager.activeSession {
                    self.sessionManager.removeSession(active)
                }
                return nil
            case "1": self.sessionManager.activateTab(at: 0); return nil
            case "2": self.sessionManager.activateTab(at: 1); return nil
            case "3": self.sessionManager.activateTab(at: 2); return nil
            case "4": self.sessionManager.activateTab(at: 3); return nil
            case "5": self.sessionManager.activateTab(at: 4); return nil
            case "6": self.sessionManager.activateTab(at: 5); return nil
            case "7": self.sessionManager.activateTab(at: 6); return nil
            case "8": self.sessionManager.activateTab(at: 7); return nil
            case "9": self.sessionManager.activateTab(at: 8); return nil
            default: break
            }

            return event
        }
    }
}
