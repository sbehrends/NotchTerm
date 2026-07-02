//
//  NotchTermApp.swift
//  NotchTerm
//

import SwiftUI
import PostHog

/// PostHog analytics configuration.
///
/// The project token is injected at build time from `Config/Secrets.xcconfig`
/// (gitignored) via the `POSTHOGProjectToken` Info.plist key, so it never lives in
/// source. A `POSTHOG_PROJECT_TOKEN` environment variable overrides it for local
/// runs. When no token is present (e.g. a contributor without the secrets file),
/// `projectToken` is nil and analytics are left disabled.
enum PostHogEnv {
    static var projectToken: String? {
        if let env = ProcessInfo.processInfo.environment["POSTHOG_PROJECT_TOKEN"], !env.isEmpty {
            return env
        }
        let fromPlist = Bundle.main.object(forInfoDictionaryKey: "POSTHOGProjectToken") as? String
        return fromPlist.flatMap { $0.isEmpty ? nil : $0 }
    }

    static var host: String {
        ProcessInfo.processInfo.environment["POSTHOG_HOST"] ?? "https://us.i.posthog.com"
    }
}

@main
struct NotchTermApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        guard let token = PostHogEnv.projectToken else { return }
        let config = PostHogConfig(apiKey: token, host: PostHogEnv.host)
        config.captureApplicationLifecycleEvents = true
        // Respect the persisted opt-out (Settings pane) before any events fire.
        config.optOut = !AnalyticsPreference.isEnabled
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
