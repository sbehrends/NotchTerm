//
//  SettingsPaneView.swift
//  NotchTerm
//
//  In-notch settings pane — shown in place of the terminal area when the
//  gear in the header row is toggled. Same panelWidth sizing pattern as
//  TerminalTabsView; the terminal views stay mounted (hidden) underneath.
//

import PostHog
import ServiceManagement
import Sparkle
import SwiftUI

// MARK: - Analytics preference

/// Persisted analytics opt-out. Read at launch (NotchTermApp) before the
/// PostHog SDK fires lifecycle events; toggled live from the settings pane.
enum AnalyticsPreference {
    static let key = "analyticsEnabled"

    /// Default is enabled until the user explicitly opts out.
    static var isEnabled: Bool {
        UserDefaults.standard.object(forKey: key) as? Bool ?? true
    }

    static func set(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: key)
        if enabled {
            PostHogSDK.shared.optIn()
        } else {
            PostHogSDK.shared.optOut()
        }
    }
}

// MARK: - Settings pane

struct SettingsPaneView: View {
    let panelWidth: CGFloat

    // SMAppService is the source of truth; re-read on appear so the toggle
    // stays honest if the user changed it in System Settings → Login Items.
    @State private var launchAtLogin = false
    @State private var analyticsEnabled = AnalyticsPreference.isEnabled
    @State private var autoUpdateEnabled = UpdateController.shared.automaticallyChecksForUpdates
    @State private var canCheckForUpdates = true

    private let cardFill = Color(white: 0.11)

    private var versionString: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return "NotchTerm \(short) (\(build))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Settings")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
                .padding(.top, 4)

            VStack(spacing: 0) {
                toggleRow(
                    "Launch at Login",
                    subtitle: "Start NotchTerm automatically when you log in",
                    isOn: $launchAtLogin
                )
                divider
                toggleRow(
                    "Share Anonymous Analytics",
                    subtitle: "Help improve NotchTerm by sending anonymous usage events",
                    isOn: $analyticsEnabled
                )
                divider
                toggleRow(
                    "Check for Updates Automatically",
                    subtitle: "Look for new versions in the background once a day",
                    isOn: $autoUpdateEnabled
                )
            }
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(cardFill))

            Spacer(minLength: 0)

            HStack(spacing: 10) {
                Text(versionString)
                    .font(.system(size: 10.5, design: .monospaced))
                    .foregroundColor(.white.opacity(0.35))

                Spacer(minLength: 0)

                Button("Check for Updates…") {
                    UpdateController.shared.checkForUpdates()
                }
                .buttonStyle(SettingsButtonStyle())
                .disabled(!canCheckForUpdates)

                Button("Quit NotchTerm") {
                    NSApp.terminate(nil)
                }
                .buttonStyle(SettingsButtonStyle(role: .destructive))
                .help("Quit  ⌘Q")
            }
            .padding(.bottom, 4)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
        .frame(width: panelWidth)
        .onAppear {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
        .onChange(of: launchAtLogin) { _, enabled in
            setLaunchAtLogin(enabled)
        }
        .onChange(of: analyticsEnabled) { _, enabled in
            AnalyticsPreference.set(enabled)
        }
        .onChange(of: autoUpdateEnabled) { _, enabled in
            UpdateController.shared.automaticallyChecksForUpdates = enabled
        }
        .onReceive(UpdateController.shared.updater.publisher(for: \.canCheckForUpdates)) {
            canCheckForUpdates = $0
        }
    }

    // MARK: - Rows

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.06))
            .frame(height: 1)
            .padding(.horizontal, 14)
    }

    private func toggleRow(_ title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                Text(subtitle)
                    .font(.system(size: 10.5))
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer(minLength: 12)
            Toggle(title, isOn: isOn)
                .toggleStyle(.switch)
                .controlSize(.mini)
                .labelsHidden()
                .tint(Color(red: 0.85, green: 0.47, blue: 0.34))
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 14)
    }

    // MARK: - Launch at login

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            // PostHog: Track setting change
            PostHogSDK.shared.capture("launch_at_login_changed", properties: ["enabled": enabled])
        } catch {
            // Registration failed (e.g. app not in /Applications) — revert the
            // toggle to the actual system state instead of lying.
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}

// MARK: - Button style

private struct SettingsButtonStyle: ButtonStyle {
    enum Role { case normal, destructive }
    var role: Role = .normal

    @Environment(\.isEnabled) private var isEnabled

    private var textColor: Color {
        switch role {
        case .normal:      return .white.opacity(isEnabled ? 0.75 : 0.3)
        case .destructive: return Color(red: 0.95, green: 0.45, blue: 0.4).opacity(isEnabled ? 0.9 : 0.4)
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.14 : 0.07))
            )
            .foregroundColor(textColor)
            .contentShape(Rectangle())
    }
}
