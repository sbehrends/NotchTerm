//
//  TerminalTabsView.swift
//  NotchTerm
//
//  Tab chrome + terminal area.
//  panelWidth is passed explicitly to avoid GeometryReader width ambiguity.
//
//  Design: dark tab bar on top, dark terminal below with 8 pt inner margin.
//

import SwiftUI

private let tabBarBackground = Color.black
private let activeTabFill = Color(white: 0.11)

// MARK: - Main view

struct TerminalTabsView: View {
    @ObservedObject var sessionManager: TerminalSessionManager
    let panelWidth: CGFloat
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            TabChrome(
                sessionManager: sessionManager,
                panelWidth: panelWidth,
                onClose: onClose
            )
            .background(tabBarBackground)

            terminalArea
        }
    }

    @ViewBuilder
    private var terminalArea: some View {
        // All session views stay in the hierarchy permanently — removing a view
        // discards its AppKit backing store and empties SwiftTerm's dirtyLines,
        // causing a blank screen when that session is revisited.
        // ZStack keeps every LocalProcessTerminalView alive; only the active
        // one is visible and receives input.
        ZStack {
            ForEach(sessionManager.sessions) { session in
                let isActive = session.id == sessionManager.activeSessionId
                TerminalEmulatorView(session: session)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                    .opacity(isActive ? 1 : 0)
                    .allowsHitTesting(isActive)
            }
        }
    }
}

// MARK: - Tab chrome bar

private struct TabChrome: View {
    @ObservedObject var sessionManager: TerminalSessionManager
    let panelWidth: CGFloat
    let onClose: () -> Void

    private let newTabWidth: CGFloat = 30
    private let closePanelWidth: CGFloat = 38

    private var tabWidth: CGFloat {
        let count = max(1, sessionManager.sessions.count)
        let available = panelWidth - newTabWidth - closePanelWidth
        return max(72, min(200, available / CGFloat(count)))
    }

    var body: some View {
        HStack(spacing: 0) {
            // Tab pills
            HStack(spacing: 0) {
                ForEach(sessionManager.sessions) { session in
                    TabPill(
                        session: session,
                        isActive: session.id == sessionManager.activeSessionId,
                        width: tabWidth,
                        onTap: { sessionManager.activate(session) },
                        onClose: { sessionManager.removeSession(session) }
                    )
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.85, anchor: .leading).combined(with: .opacity),
                            removal: .scale(scale: 0.85, anchor: .leading).combined(with: .opacity)
                        )
                    )
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.85), value: sessionManager.sessions.count)

            // New tab button
            Button(action: { sessionManager.addSession() }) {
                Image(systemName: "plus")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                    .frame(width: newTabWidth, height: 36)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("New Tab  ⌘T")

            Spacer(minLength: 0)

            // Close panel button
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 9.5, weight: .semibold))
                    .foregroundColor(.white.opacity(0.28))
                    .frame(width: closePanelWidth, height: 36)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Close  ⎋")
        }
        .frame(width: panelWidth, height: 36)
    }
}

// MARK: - Individual tab pill

private struct TabPill: View {
    @ObservedObject var session: TerminalSession
    let isActive: Bool
    let width: CGFloat
    let onTap: () -> Void
    let onClose: () -> Void

    @State private var isHovered = false

    private var closeOpacity: Double {
        isActive ? 0.5 : (isHovered ? 0.35 : 0.0)
    }

    private var textColor: Color {
        isActive ? Color.white.opacity(0.85) : Color.white.opacity(isHovered ? 0.65 : 0.38)
    }

    var body: some View {
        ZStack {
            // Active capsule pill background
            if isActive {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(activeTabFill)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 5)
            } else if isHovered {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(Color.white.opacity(0.07))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 5)
            }

            // Label + close button
            HStack(spacing: 0) {
                Text(session.title)
                    .font(.system(size: 11.5, design: .monospaced))
                    .foregroundColor(textColor)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .padding(.leading, 12)
                    .padding(.trailing, 4)
                    .animation(.easeInOut(duration: 0.12), value: isActive)

                Spacer(minLength: 0)

                Button(action: onClose) {
                    ZStack {
                        Circle()
                            .fill((isActive ? Color.black : Color.white).opacity((isHovered || isActive) ? 0.1 : 0))
                            .frame(width: 16, height: 16)
                        Image(systemName: "xmark")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(Color.white.opacity(closeOpacity))
                    }
                    .frame(width: 22, height: 22)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.trailing, 7)
                .opacity(closeOpacity > 0 ? 1 : 0)
                .animation(.easeInOut(duration: 0.12), value: closeOpacity)
            }
            .frame(height: 36)
        }
        .frame(width: width, height: 36)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovered = hovering
            }
        }
    }
}
