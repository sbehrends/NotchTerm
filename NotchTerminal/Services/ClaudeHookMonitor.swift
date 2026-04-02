//
//  ClaudeHookMonitor.swift
//  NotchTerminal
//
//  Receives Claude Code hook events from the Unix socket server
//  and publishes the current activity state for the notch UI.
//

import Foundation
import Combine

@MainActor
final class ClaudeHookMonitor: ObservableObject {
    @Published private(set) var activity: ClaudeActivity = .idle

    private let server = HookSocketServer.shared

    func startMonitoring() {
        server.start { [weak self] event in
            Task { @MainActor [weak self] in
                self?.handle(event)
            }
        }
    }

    func stopMonitoring() {
        server.stop()
    }

    private func handle(_ event: HookEvent) {
        activity = event.activity
    }
}
