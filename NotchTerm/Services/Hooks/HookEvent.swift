//
//  HookEvent.swift
//  NotchTerm
//
//  Event model received from Claude Code hooks via Unix socket
//

import Foundation

// MARK: - Activity state

enum ClaudeActivity: Equatable {
    case idle
    case processing         // generating a response, post-tool, compacting
    case runningTool        // PreToolUse — tool is executing
    case waitingForApproval // PermissionRequest — needs user input

    var isActive: Bool { self != .idle }
}

// MARK: - Hook event

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

    var activity: ClaudeActivity {
        switch status {
        case "processing", "compacting": return .processing
        case "running_tool":             return .runningTool
        case "waiting_for_approval":     return .waitingForApproval
        default:                         return .idle
        }
    }
}
