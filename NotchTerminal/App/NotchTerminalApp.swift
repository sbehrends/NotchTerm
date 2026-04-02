//
//  NotchTerminalApp.swift
//  NotchTerminal
//

import SwiftUI
import PostHog

enum PostHogEnv: String {
    case projectToken = "POSTHOG_PROJECT_TOKEN"
    case host = "POSTHOG_HOST"

    // TODO: Remove if open sourced, or make configurable by user
    private static let defaults: [String: String] = [
        "POSTHOG_PROJECT_TOKEN": "phc_pMBvNhDDypvkf2rSR2QNnsZrwu2ny3pDhu23cnWHiPHf",
        "POSTHOG_HOST": "https://us.i.posthog.com"
    ]

    var value: String {
        ProcessInfo.processInfo.environment[rawValue] ?? Self.defaults[rawValue]!
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
