//
//  ClaudeHookMonitor.swift
//  NotchTerminal
//
//  Receives Claude Code hook events from the Unix socket server
//  and publishes the current activity state for the notch UI.
//

import Foundation
import Combine
import PostHog

@MainActor
final class ClaudeHookMonitor: ObservableObject {
    @Published private(set) var activity: ClaudeActivity = .idle

    private let server = HookSocketServer.shared

    func startMonitoring() {
        server.start { [weak self] event in
            Task { @MainActor in
                self?.handle(event)
            }
        }
    }

    func stopMonitoring() {
        server.stop()
    }

    private func handle(_ event: HookEvent) {
        activity = event.activity
        PostHogSDK.shared.capture("hook_activity", properties: ["provider": "claude", "status": event.status])
    }
}
