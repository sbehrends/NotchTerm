//
//  NotchViewModel.swift
//  NotchTerminal
//
//  State management for the notch terminal
//

import AppKit
import Combine
import PostHog
import SwiftUI

enum NotchStatus: Equatable {
    case closed
    case opened
}

enum NotchOpenReason {
    case click
    case hover
    case boot
}

@MainActor
class NotchViewModel: ObservableObject {
    // MARK: - Published State

    @Published var status: NotchStatus = .closed
    @Published var openReason: NotchOpenReason = .click
    @Published var isHovering: Bool = false

    // MARK: - Geometry

    let geometry: NotchGeometry
    let hasPhysicalNotch: Bool

    var deviceNotchRect: CGRect { geometry.deviceNotchRect }
    var screenRect: CGRect { geometry.screenRect }
    var windowHeight: CGFloat { geometry.windowHeight }

    /// Terminal panel size (not including the collapsed pill)
    let openedSize = CGSize(width: 760, height: 460)

    /// The always-visible collapsed pill: same width as the panel, tall enough to cover the hardware notch
    let closedPillHeight: CGFloat = 44
    let pillPanelGap: CGFloat = 8

    // MARK: - Animation

    let openAnimation  = Animation.spring(response: 0.42, dampingFraction: 0.82)
    let closeAnimation = Animation.spring(response: 0.35, dampingFraction: 0.9)

    // MARK: - Private

    private var cancellables = Set<AnyCancellable>()
    private let events = EventMonitors.shared
    private var hoverTimer: DispatchWorkItem?

    /// Screen rect of the hardware notch (used for hover / click detection when closed)
    private var closedPillScreenRect: CGRect {
        CGRect(
            x: geometry.screenRect.midX - deviceNotchRect.width / 2,
            y: geometry.screenRect.maxY - deviceNotchRect.height,
            width: deviceNotchRect.width,
            height: deviceNotchRect.height
        )
    }

    /// Screen rect covering the full expanded panel when opened
    private var openedAreaScreenRect: CGRect {
        let totalHeight = closedPillHeight + openedSize.height
        return CGRect(
            x: geometry.screenRect.midX - openedSize.width / 2,
            y: geometry.screenRect.maxY - totalHeight,
            width: openedSize.width,
            height: totalHeight
        )
    }

    // MARK: - Init

    init(deviceNotchRect: CGRect, screenRect: CGRect, windowHeight: CGFloat, hasPhysicalNotch: Bool) {
        self.geometry = NotchGeometry(
            deviceNotchRect: deviceNotchRect,
            screenRect: screenRect,
            windowHeight: windowHeight
        )
        self.hasPhysicalNotch = hasPhysicalNotch
        setupEventHandlers()
    }

    // MARK: - Event Handling

    private func setupEventHandlers() {
        events.mouseLocation
            .throttle(for: .milliseconds(50), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] location in self?.handleMouseMove(location) }
            .store(in: &cancellables)

        events.mouseDown
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.handleMouseDown() }
            .store(in: &cancellables)
    }

    private func handleMouseMove(_ location: CGPoint) {
        let inPill   = status == .closed && closedPillScreenRect.insetBy(dx: -8, dy: -6).contains(location)
        let inOpened = status == .opened && openedAreaScreenRect.insetBy(dx: -4, dy: -4).contains(location)
        let newHovering = inPill || inOpened

        guard newHovering != isHovering else { return }

        withAnimation(newHovering ? .easeOut(duration: 0.18) : .easeIn(duration: 0.14)) {
            isHovering = newHovering
        }

        hoverTimer?.cancel()
        hoverTimer = nil

        if isHovering && status == .closed {
            let workItem = DispatchWorkItem { [weak self] in
                guard let self, self.isHovering else { return }
                self.notchOpen(reason: .hover)
            }
            hoverTimer = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
        }
    }

    private func handleMouseDown() {
        let location = NSEvent.mouseLocation

        switch status {
        case .opened:
            if !openedAreaScreenRect.contains(location) {
                notchClose()
                repostClickAt(location)
            }
        case .closed:
            if closedPillScreenRect.contains(location) {
                notchOpen(reason: .click)
            }
        }
    }

    private func repostClickAt(_ location: CGPoint) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            guard let screen = NSScreen.main else { return }
            let cgPoint = CGPoint(x: location.x, y: screen.frame.height - location.y)

            if let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown,
                                       mouseCursorPosition: cgPoint, mouseButton: .left) {
                mouseDown.post(tap: .cghidEventTap)
            }
            if let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp,
                                     mouseCursorPosition: cgPoint, mouseButton: .left) {
                mouseUp.post(tap: .cghidEventTap)
            }
        }
    }

    // MARK: - Actions

    func notchOpen(reason: NotchOpenReason = .click) {
        hoverTimer?.cancel()
        hoverTimer = nil
        openReason = reason
        withAnimation(openAnimation) {
            status = .opened
        }
        // PostHog: Track notch open
        let reasonString: String
        switch reason {
        case .click: reasonString = "click"
        case .hover: reasonString = "hover"
        case .boot:  reasonString = "boot"
        }
        PostHogSDK.shared.capture("notch_opened", properties: ["open_reason": reasonString])
    }

    func notchClose() {
        withAnimation(closeAnimation) {
            status = .closed
            isHovering = false
        }
        // PostHog: Track notch close
        PostHogSDK.shared.capture("notch_closed")
    }

    func performBootAnimation() {
        notchOpen(reason: .boot)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self, self.openReason == .boot else { return }
            self.notchClose()
        }
    }
}
