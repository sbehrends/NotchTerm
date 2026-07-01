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
        terminalView = nil
        isAlive = false
    }
}
