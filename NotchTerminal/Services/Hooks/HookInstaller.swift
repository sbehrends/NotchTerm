//
//  HookInstaller.swift
//  NotchTerminal
//
//  Copies the hook script to ~/.claude/hooks/ and registers it in ~/.claude/settings.json
//

import Foundation
import PostHog

struct HookInstaller {

    static func installIfNeeded() {
        let claudeDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude")
        let hooksDir = claudeDir.appendingPathComponent("hooks")
        let scriptDest = hooksDir.appendingPathComponent("notch-terminal-hook.py")
        let settings = claudeDir.appendingPathComponent("settings.json")

        try? FileManager.default.createDirectory(at: hooksDir, withIntermediateDirectories: true)

        if let bundled = Bundle.main.url(forResource: "notch-terminal-hook", withExtension: "py") {
            try? FileManager.default.removeItem(at: scriptDest)
            try? FileManager.default.copyItem(at: bundled, to: scriptDest)
            try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptDest.path)
        }

        updateSettings(at: settings)

        // PostHog: Track hook install
        PostHogSDK.shared.capture("hook_installed", properties: ["provider": "claude"])
    }

    private static func updateSettings(at settingsURL: URL) {
        var json: [String: Any] = [:]
        if let data = try? Data(contentsOf: settingsURL),
           let existing = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            json = existing
        }

        let python = detectPython()
        let command = "\(python) ~/.claude/hooks/notch-terminal-hook.py"
        let hookEntry: [[String: Any]] = [["type": "command", "command": command]]
        let withMatcher: [[String: Any]] = [["matcher": "*", "hooks": hookEntry]]
        let withoutMatcher: [[String: Any]] = [["hooks": hookEntry]]
        let preCompactConfig: [[String: Any]] = [
            ["matcher": "auto", "hooks": hookEntry],
            ["matcher": "manual", "hooks": hookEntry],
        ]

        var hooks = json["hooks"] as? [String: Any] ?? [:]

        let hookEvents: [(String, [[String: Any]])] = [
            ("UserPromptSubmit", withoutMatcher),
            ("PreToolUse", withMatcher),
            ("PostToolUse", withMatcher),
            ("Notification", withMatcher),
            ("Stop", withoutMatcher),
            ("SubagentStop", withoutMatcher),
            ("SessionStart", withoutMatcher),
            ("SessionEnd", withoutMatcher),
            ("PreCompact", preCompactConfig),
        ]

        for (event, config) in hookEvents {
            if var existing = hooks[event] as? [[String: Any]] {
                let alreadyPresent = existing.contains { entry in
                    if let entryHooks = entry["hooks"] as? [[String: Any]] {
                        return entryHooks.contains { ($0["command"] as? String ?? "").contains("notch-terminal-hook.py") }
                    }
                    return false
                }
                if !alreadyPresent {
                    existing.append(contentsOf: config)
                    hooks[event] = existing
                }
            } else {
                hooks[event] = config
            }
        }

        json["hooks"] = hooks

        if let data = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]) {
            try? data.write(to: settingsURL)
        }
    }

    private static func detectPython() -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["python3"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 { return "python3" }
        } catch {}
        return "python"
    }
}
