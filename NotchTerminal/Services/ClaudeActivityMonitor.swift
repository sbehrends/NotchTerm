//
//  ClaudeActivityMonitor.swift
//  NotchTerminal
//
//  Detects whether a Claude Code process is actively running.
//  Polls via pgrep every few seconds; publishes isActive for the notch UI.
//

import Foundation
import Combine

@MainActor
final class ClaudeActivityMonitor: ObservableObject {
    @Published private(set) var isActive: Bool = false

    private var timer: Timer?

    func startMonitoring() {
        checkActivity()
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkActivity()
            }
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func checkActivity() {
        Task { @MainActor in
            let running = await Self.claudeIsRunning()
            self.isActive = running
        }
    }

    private static func claudeIsRunning() async -> Bool {
        await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/pgrep")
            process.arguments = ["-f", "claude"]
            process.standardOutput = Pipe()
            process.standardError = Pipe()
            process.terminationHandler = { proc in
                continuation.resume(returning: proc.terminationStatus == 0)
            }
            if (try? process.run()) == nil {
                continuation.resume(returning: false)
            }
        }
    }
}
