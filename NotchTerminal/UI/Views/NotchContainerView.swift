//
//  NotchContainerView.swift
//  NotchTerminal
//
//  Single expanding shape — mirrors the claude-island NotchView approach.
//
//  Closed: hardware notch dimensions, NotchShape(top:6, bottom:14)
//  Opened: 760×504 expanded panel, NotchShape(top:19, bottom:24)
//  The shape animates corner radii + size in one unified spring animation.
//

import SwiftUI

private let openedTopRadius: CGFloat    = 19
private let openedBottomRadius: CGFloat = 24
private let closedTopRadius: CGFloat    = 6
private let closedBottomRadius: CGFloat = 14

struct NotchContainerView: View {
    @ObservedObject var viewModel: NotchViewModel
    @ObservedObject var sessionManager: TerminalSessionManager
    @StateObject private var activityMonitor = ClaudeHookMonitor()
    @State private var showContent = false

    private var isOpened: Bool { viewModel.status == .opened }

    // MARK: - Dimensions

    private var notchW: CGFloat {
        isOpened ? viewModel.openedSize.width : viewModel.deviceNotchRect.width
    }
    private var notchH: CGFloat {
        isOpened ? (viewModel.closedPillHeight + viewModel.openedSize.height)
                 : viewModel.deviceNotchRect.height
    }
    /// Width of sidebar icons (crab / spinner) scaled to the hardware notch height
    private var sideW: CGFloat {
        max(0, viewModel.deviceNotchRect.height - 12) + 10
    }

    // MARK: - Shape radii

    private var topRadius: CGFloat    { isOpened ? openedTopRadius    : closedTopRadius    }
    private var bottomRadius: CGFloat { isOpened ? openedBottomRadius : closedBottomRadius }

    // MARK: - Body

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .top) {
                VStack(spacing: 0) {
                    // ── Header row – always visible ──────────────────────────
                    headerRow
                        .frame(
                            width: notchW,
                            height: isOpened ? viewModel.closedPillHeight
                                             : viewModel.deviceNotchRect.height
                        )

                    // ── Terminal panel – only when opened ────────────────────
                    // The NotchShape's straight sides run at x = openedTopRadius (19pt)
                    // from each edge, so the usable content width is openedW - 2*19.
                    // We size the terminal to that width and offset it with padding so
                    // the terminal fills exactly the visible area without being clipped.
                    if isOpened {
                        let contentW = viewModel.openedSize.width - 2 * openedTopRadius
                        TerminalTabsView(
                            sessionManager: sessionManager,
                            panelWidth: contentW,
                            onClose: { viewModel.notchClose() }
                        )
                        .frame(
                            width: contentW,
                            height: viewModel.openedSize.height
                        )
                        .padding(.horizontal, openedTopRadius)
                        .opacity(showContent ? 1 : 0)
                        .animation(viewModel.openAnimation, value: showContent)
                        .transition(.asymmetric(
                            insertion: .identity,
                            removal: .opacity.animation(.easeOut(duration: 0.12))
                        ))
                    }
                }
                // Clip the whole shape — covers both header and terminal panel
                .background(Color.black)
                .clipShape(
                    NotchShape(
                        topCornerRadius: topRadius,
                        bottomCornerRadius: bottomRadius
                    )
                )
                // 1px black strip at the very top bridges the hardware notch seam
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 1)
                        .padding(.horizontal, topRadius)
                }
                .shadow(
                    color: isOpened ? Color.black.opacity(0.65) : Color.clear,
                    radius: 8, y: 4
                )
                // Single animation drives width, height, and shape corner radii together
                .animation(
                    isOpened ? viewModel.openAnimation : viewModel.closeAnimation,
                    value: viewModel.status
                )
                .animation(.smooth, value: activityMonitor.isActive)
            }
            .preferredColorScheme(.dark)
            .onAppear  { activityMonitor.startMonitoring()  }
            .onDisappear { activityMonitor.stopMonitoring() }
            .onChange(of: viewModel.status) { _, newStatus in
                if newStatus == .opened {
                    Task {
                        try? await Task.sleep(for: .milliseconds(40))
                        showContent = true
                    }
                } else {
                    showContent = false
                }
            }
    }

    // MARK: - Header Row

    @ViewBuilder
    private var headerRow: some View {
        ZStack {
            if activityMonitor.isActive {
                HStack(spacing: 0) {
                    ClaudeCrabIcon(size: 14, animateLegs: true)
                        .frame(width: sideW)
                    Spacer(minLength: 0)
                    ProcessingSpinner()
                        .frame(width: sideW)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.88)))
            } else if viewModel.isHovering && !isOpened {
                Image(systemName: "terminal.fill")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                    .transition(.opacity.animation(.easeIn(duration: 0.1)))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
