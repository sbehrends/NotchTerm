//
//  UpdateController.swift
//  NotchTerm
//
//  Sparkle auto-update integration.
//
//  Configuration lives in Info.plist (set via project.yml → target `info`):
//    • SUFeedURL              — raw URL of appcast.xml in the GitHub repo
//    • SUPublicEDKey          — EdDSA public key; updates are verified against it
//    • SUEnableAutomaticChecks / SUScheduledCheckInterval — background check cadence
//
//  Update *integrity* is guaranteed by Sparkle's own EdDSA signature, independent
//  of Apple code signing / notarization. See distribute.sh for the release flow.
//

import AppKit
import Sparkle

/// Owns the Sparkle updater for the app's lifetime.
///
/// The app runs as an `.accessory` (LSUIElement) agent with no menu bar, so there
/// is no standard "Check for Updates…" menu item. Background scheduled checks run
/// automatically; `checkForUpdates()` is exposed for a manual trigger from the UI.
@MainActor
final class UpdateController {
    static let shared = UpdateController()

    private let controller: SPUStandardUpdaterController

    private init() {
        // startingUpdater: true begins scheduled background checks immediately,
        // reading the SU* keys from Info.plist.
        controller = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    /// Starts the updater. Call once at launch; the initializer already begins
    /// scheduled checks, so this just guarantees the singleton is instantiated.
    func start() {
        _ = controller
    }

    /// User-initiated update check. Wire this to a button/menu item in the notch UI.
    /// Activates the app first so Sparkle's window comes to the front (accessory apps
    /// are not active by default).
    func checkForUpdates() {
        NSApp.activate(ignoringOtherApps: true)
        controller.updater.checkForUpdates()
    }

    /// Whether a manual check can currently be started (false while one is in flight).
    var canCheckForUpdates: Bool {
        controller.updater.canCheckForUpdates
    }

    /// The underlying updater, exposed for KVO (e.g. `publisher(for: \.canCheckForUpdates)`).
    var updater: SPUUpdater {
        controller.updater
    }

    /// Background update checks on/off. Sparkle persists this itself
    /// (SUEnableAutomaticChecks in its own defaults) — no mirroring needed.
    var automaticallyChecksForUpdates: Bool {
        get { controller.updater.automaticallyChecksForUpdates }
        set { controller.updater.automaticallyChecksForUpdates = newValue }
    }
}
