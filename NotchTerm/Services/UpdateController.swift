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

/// Result of a manual update check, rendered inline in the settings pane
/// (no Sparkle dialogs for check feedback).
enum UpdateCheckStatus: Equatable {
    case idle
    case checking
    case upToDate
    case updateAvailable(version: String)
    case failed
}

/// Owns the Sparkle updater for the app's lifetime.
///
/// The app runs as an `.accessory` (LSUIElement) agent with no menu bar, so there
/// is no standard "Check for Updates…" menu item. Background scheduled checks run
/// automatically; the settings pane triggers manual checks via
/// `checkForUpdatesQuietly()` and shows the outcome from `checkStatus`.
@MainActor
final class UpdateController: NSObject, ObservableObject {
    static let shared = UpdateController()

    @Published private(set) var checkStatus: UpdateCheckStatus = .idle

    private var controller: SPUStandardUpdaterController!

    private override init() {
        super.init()
        // startingUpdater: true begins scheduled background checks immediately,
        // reading the SU* keys from Info.plist.
        controller = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: self,
            userDriverDelegate: nil
        )
    }

    /// Starts the updater. Call once at launch; the initializer already begins
    /// scheduled checks, so this just guarantees the singleton is instantiated.
    func start() {
        _ = controller
    }

    /// Manual check without any Sparkle UI — probes the appcast and reports the
    /// outcome through `checkStatus` for inline display.
    func checkForUpdatesQuietly() {
        guard canCheckForUpdates else { return }
        checkStatus = .checking
        controller.updater.checkForUpdateInformation()
    }

    /// Full update flow with Sparkle's standard UI (download / install window).
    /// Used once a manual check has found an update. Activates the app first so
    /// Sparkle's window comes to the front (accessory apps are not active by default).
    func installUpdate() {
        NSApp.activate(ignoringOtherApps: true)
        controller.updater.checkForUpdates()
    }

    /// Drop a stale "up to date" / "failed" message (e.g. when the settings pane
    /// reopens); a found update stays visible.
    func clearTransientCheckStatus() {
        if checkStatus == .upToDate || checkStatus == .failed {
            checkStatus = .idle
        }
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

// MARK: - SPUUpdaterDelegate

extension UpdateController: SPUUpdaterDelegate {
    // Sparkle invokes delegate callbacks on the main thread; hop explicitly to
    // satisfy strict concurrency.

    nonisolated func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        let version = item.displayVersionString
        Task { @MainActor in
            self.checkStatus = .updateAvailable(version: version)
        }
    }

    nonisolated func updaterDidNotFindUpdate(_ updater: SPUUpdater, error: Error) {
        Task { @MainActor in
            // Only reflect checks the user initiated; scheduled background
            // checks shouldn't surface a message out of nowhere.
            if self.checkStatus == .checking {
                self.checkStatus = .upToDate
            }
        }
    }

    nonisolated func updater(_ updater: SPUUpdater, didFinishUpdateCycleFor updateCheck: SPUUpdateCheck, error: Error?) {
        let failed = error != nil
        Task { @MainActor in
            if failed, self.checkStatus == .checking {
                self.checkStatus = .failed
            }
        }
    }
}
