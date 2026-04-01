//
//  NotchTerminalApp.swift
//  NotchTerminal
//

import SwiftUI

@main
struct NotchTerminalApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // All UI lives in the custom NotchPanel window managed by AppDelegate.
        // Settings scene with EmptyView satisfies @main App conformance requirements.
        Settings {
            EmptyView()
        }
    }
}
