//
//  TerminalView.swift
//  NotchTerminal
//
//  NSViewRepresentable wrapping SwiftTerm's LocalProcessTerminalView
//

import AppKit
import SwiftTerm
import SwiftUI

// Renamed to avoid conflict with SwiftTerm.TerminalView (the NSView subclass)
struct TerminalEmulatorView: NSViewRepresentable {
    let session: TerminalSession

    func makeNSView(context: Context) -> LocalProcessTerminalView {
        // Restore existing terminal view (keeps PTY alive across tab switches)
        if let existing = session.terminalView {
            existing.processDelegate = context.coordinator
            return existing
        }

        let tv = LocalProcessTerminalView(frame: .zero)
        let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        let home = FileManager.default.homeDirectoryForCurrentUser.path

        // Pass HOME explicitly and start as a login shell (execName prefixed with "-")
        // so the shell sources its profile and starts in the home directory.
        var env = ProcessInfo.processInfo.environment
        env["HOME"] = home
        env["PWD"] = home
        env["TERM"] = "xterm-256color"
        env["COLORTERM"] = "truecolor"
        let shellName = URL(fileURLWithPath: shell).lastPathComponent
        tv.startProcess(executable: shell, args: [], environment: env.map { "\($0.key)=\($0.value)" }, execName: "-\(shellName)", currentDirectory: home)
        tv.processDelegate = context.coordinator

        // Store strong reference so PTY survives tab switches
        Task { @MainActor in
            session.terminalView = tv
        }

        return tv
    }

    func updateNSView(_ nsView: LocalProcessTerminalView, context: Context) {
        // Defensive redraw: marks the backing layer dirty so any stale pixels
        // from animation are flushed. The real fix for blank-on-reopen is in
        // NotchContainerView — keeping TerminalTabsView always in the hierarchy.
        nsView.needsDisplay = true
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(session: session)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, LocalProcessTerminalViewDelegate {
        var session: TerminalSession

        init(session: TerminalSession) {
            self.session = session
        }

        nonisolated func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}

        nonisolated func setTerminalTitle(source: LocalProcessTerminalView, title: String) {
            guard !title.isEmpty else { return }
            let s = session
            Task { @MainActor in
                s.title = title
            }
        }

        nonisolated func hostCurrentDirectoryUpdate(source: SwiftTerm.TerminalView, directory: String?) {}

        nonisolated func processTerminated(source: SwiftTerm.TerminalView, exitCode: Int32?) {
            let s = session
            Task { @MainActor in
                s.isAlive = false
            }
        }
    }
}
