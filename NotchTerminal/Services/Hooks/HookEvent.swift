//
//  HookEvent.swift
//  NotchTerminal
//
//  Event model received from Claude Code hooks via Unix socket
//

import Foundation

struct HookEvent: Codable, Sendable {
    let sessionId: String
    let cwd: String
    let event: String
    let status: String
    let pid: Int?
    let tool: String?
    let notificationType: String?

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case cwd, event, status, pid, tool
        case notificationType = "notification_type"
    }

    /// Whether Claude is actively doing work (show crab/spinner)
    var isProcessing: Bool {
        switch status {
        case "processing", "running_tool", "compacting", "waiting_for_approval":
            return true
        default:
            return false
        }
    }
}
