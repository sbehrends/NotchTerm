//
//  TerminalSessionManager.swift
//  NotchTerminal
//
//  Manages multiple terminal tab sessions
//

import Combine
import Foundation
import PostHog
import SwiftUI

@MainActor
final class TerminalSessionManager: ObservableObject {
    @Published private(set) var sessions: [TerminalSession] = []
    @Published var activeSessionId: UUID?

    var activeSession: TerminalSession? {
        guard let id = activeSessionId else { return nil }
        return sessions.first { $0.id == id }
    }

    init() {
        addSession()
    }

    func addSession() {
        let session = TerminalSession()
        sessions.append(session)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            activeSessionId = session.id
        }
        // PostHog: Track new tab
        PostHogSDK.shared.capture("tab_added", properties: ["tab_count": sessions.count])
    }

    func removeSession(_ session: TerminalSession) {
        guard sessions.count > 1 else { return }
        let idx = sessions.firstIndex { $0.id == session.id }
        let newActive: UUID? = {
            if activeSessionId == session.id {
                if let idx, idx > 0 { return sessions[idx - 1].id }
                return sessions.last?.id
            }
            return activeSessionId
        }()
        session.terminate()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            sessions.removeAll { $0.id == session.id }
            activeSessionId = newActive
        }
        // PostHog: Track tab removal (sessions.count already reflects the removal)
        PostHogSDK.shared.capture("tab_removed", properties: ["tab_count": sessions.count])
    }

    func activate(_ session: TerminalSession) {
        guard session.id != activeSessionId else { return }
        activeSessionId = session.id
        // PostHog: Track tab switch
        PostHogSDK.shared.capture("tab_switched", properties: ["tab_count": sessions.count])
    }

    func activateTab(at index: Int) {
        guard index < sessions.count else { return }
        let session = sessions[index]
        guard session.id != activeSessionId else { return }
        activeSessionId = session.id
        // PostHog: Track tab switch via keyboard shortcut
        PostHogSDK.shared.capture("tab_switched", properties: ["tab_count": sessions.count])
    }
}
