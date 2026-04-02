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

/// Space reserved for each activity icon (crab / spinner) beyond the hardware notch
private let iconSlotW: CGFloat = 34

struct NotchContainerView: View {
    @ObservedObject var viewModel: NotchViewModel
    @ObservedObject var sessionManager: TerminalSessionManager
    @StateObject private var activityMonitor = ClaudeHookMonitor()
    @State private var showContent = false

    private var isOpened: Bool { viewModel.status == .opened }

    // MARK: - Dimensions

    private var notchW: CGFloat {
        if isOpened { return viewModel.openedSize.width }
        let base = viewModel.deviceNotchRect.width
        // Active: expand enough to give each icon 36pt of dedicated space
        if activityMonitor.activity.isActive { return base + (2 * iconSlotW) }
        // Hover: subtle lateral expansion
        if viewModel.isHovering              { return base + 24 }
        return base
    }
    private var notchH: CGFloat {
        isOpened ? (viewModel.closedPillHeight + viewModel.openedSize.height)
                 : viewModel.deviceNotchRect.height
    }
    /// Total frame given to each icon in the header row
    private var sideW: CGFloat { iconSlotW + (viewModel.deviceNotchRect.height - 8) / 2 }

    // MARK: - Shape radii

    private var topRadius: CGFloat { isOpened ? openedTopRadius : closedTopRadius }
    private var bottomRadius: CGFloat {
        if isOpened { return openedBottomRadius }
        if activityMonitor.activity.isActive { return 18 }
        return viewModel.isHovering ? 17 : closedBottomRadius
    }

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

                    // ── Terminal panel – fixed size, clip-based reveal ──────────────
                    // The inner .frame fixes the NSView at full height always, so
                    // SwiftTerm never receives a resize (SIGWINCH) during the open/close
                    // animation. Previously the height animated 0→460, causing the shell
                    // to redraw at every animation frame and producing jumpy content.
                    // The outer .frame(height:) + .clipped() controls how much is
                    // revealed in layout without touching the NSView's actual size.
                    let contentW = viewModel.openedSize.width - 2 * openedTopRadius
                    TerminalTabsView(
                        sessionManager: sessionManager,
                        panelWidth: contentW,
                        onClose: { viewModel.notchClose() }
                    )
                    .frame(width: contentW, height: viewModel.openedSize.height)  // fixed; NSView never resizes
                    .frame(height: isOpened ? viewModel.openedSize.height : 0, alignment: .top)
                    .clipped()
                    .padding(.horizontal, openedTopRadius)
                    .opacity(showContent ? 1 : 0)
                    .animation(viewModel.openAnimation, value: showContent)
                }
                // Constrain the VStack to notchW so NotchShape clips to the correct
                // pill width. Without this the always-present TerminalTabsView
                // (openedSize.width wide) would make the VStack always report the
                // full expanded width, keeping the notch stuck at open width.
                .frame(width: notchW)
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
                // Hover expansion: fast ease-out in, slightly slower ease-in out
                .animation(
                    viewModel.isHovering
                        ? .easeOut(duration: 0.18)
                        : .easeIn(duration: 0.22),
                    value: viewModel.isHovering
                )
                // Activity expansion: spring so it feels alive
                .animation(
                    .spring(response: 0.38, dampingFraction: 0.72),
                    value: activityMonitor.activity
                )
            }
            .preferredColorScheme(.dark)
            .onAppear  { activityMonitor.startMonitoring()  }
            .onDisappear { activityMonitor.stopMonitoring() }
            .onChange(of: viewModel.status) { _, newStatus in
                if newStatus == .opened {
                    Task {
                        // Let the shape expand a bit before revealing content — matches
                        // the Dynamic Island feel. 80ms gives the spring a visible head
                        // start without feeling sluggish (full animation is ~420ms).
                        try? await Task.sleep(for: .milliseconds(80))
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
            switch activityMonitor.activity {
            case .processing, .runningTool:
                HStack(spacing: 0) {
                    ClaudeCrabIcon(size: 16, animateLegs: true)
                        .frame(width: sideW)
                    Spacer(minLength: 0)
                    ProcessingSpinner()
                        .frame(width: sideW)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.88)))

            case .waitingForApproval:
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    ApprovalPulse()
                        .frame(width: sideW)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.88)))

            case .idle:
                if viewModel.isHovering && !isOpened {
                    Image(systemName: "terminal.fill")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                        .transition(.opacity.animation(.easeIn(duration: 0.1)))
                }
            }
        }
        .padding(.horizontal, isOpened ? 18 : 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
