//
//  TerminalSession.swift
//  NotchTerm
//
//  Represents one terminal tab — owns a shell process lifecycle
//

import AppKit
import Combine
import SwiftTerm

@MainActor
final class TerminalSession: ObservableObject, Identifiable {
    let id = UUID()
    @Published var title: String = "Terminal"
    @Published var isAlive: Bool = true

    // Strong reference keeps the PTY and process alive across tab switches
    var terminalView: LocalProcessTerminalView?

    init(title: String = "Terminal") {
        self.title = title
    }

    func terminate() {
        // Explicitly kill the child before dropping the view: deinit alone
        // relies on PTY-close → SIGHUP, which lingers if anything else briefly
        // retains the view (SwiftUI transition snapshots) or the child ignores
        // SIGHUP. The shell is the PTY session leader, so signal its whole
        // process group first.
        if let process = terminalView?.process, process.shellPid > 0 {
            kill(-process.shellPid, SIGHUP)
            kill(-process.shellPid, SIGTERM)
            process.terminate()
        }
        terminalView = nil
        isAlive = false
    }
}
