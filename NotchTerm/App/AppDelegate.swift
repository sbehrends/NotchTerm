//
//  AppDelegate.swift
//  NotchTerm
//

import AppKit
import PostHog

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var windowManager: WindowManager?
    private var screenObserver: ScreenObserver?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)

        HookInstaller.installIfNeeded()

        windowManager = WindowManager()
        windowManager?.setupNotchWindow()

        screenObserver = ScreenObserver { [weak self] in
            self?.windowManager?.scheduleNotchWindowRebuild()
        }

        // Sparkle: start auto-update checks (scheduled background + manual).
        UpdateController.shared.start()

        // PostHog: Track app launch
        PostHogSDK.shared.capture("app_launched")
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationWillTerminate(_ notification: Notification) {
        windowManager?.sessionManager.sessions.forEach { $0.terminate() }
    }
}
