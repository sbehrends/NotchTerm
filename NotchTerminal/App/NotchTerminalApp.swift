//
//  NotchTerminalApp.swift
//  NotchTerminal
//

import SwiftUI
import PostHog

enum PostHogEnv: String {
    case projectToken = "POSTHOG_PROJECT_TOKEN"
    case host = "POSTHOG_HOST"

    var value: String {
        guard let value = ProcessInfo.processInfo.environment[rawValue] else {
            fatalError("Set \(rawValue) in the Xcode scheme environment variables.")
        }
        return value
    }
}

@main
struct NotchTerminalApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        let config = PostHogConfig(apiKey: PostHogEnv.projectToken.value, host: PostHogEnv.host.value)
        config.captureApplicationLifecycleEvents = true
        PostHogSDK.shared.setup(config)
    }

    var body: some Scene {
        // All UI lives in the custom NotchPanel window managed by AppDelegate.
        // Settings scene with EmptyView satisfies @main App conformance requirements.
        Settings {
            EmptyView()
        }
    }
}
