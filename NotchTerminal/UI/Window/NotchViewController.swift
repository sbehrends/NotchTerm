//
//  NotchViewController.swift
//  NotchTerminal
//
//  Hosts the SwiftUI NotchContainerView in AppKit with click-through support
//

import AppKit
import SwiftUI

/// Custom NSHostingView that only accepts mouse events within the panel bounds.
/// Clicks outside the panel pass through to windows behind.
class PassThroughHostingView<Content: View>: NSHostingView<Content> {
    var hitTestRect: () -> CGRect = { .zero }

    override func hitTest(_ point: NSPoint) -> NSView? {
        guard hitTestRect().contains(point) else {
            return nil
        }
        return super.hitTest(point)
    }
}

class NotchViewController: NSViewController {
    private let viewModel: NotchViewModel
    private let sessionManager: TerminalSessionManager
    private var hostingView: PassThroughHostingView<NotchContainerView>!

    init(viewModel: NotchViewModel, sessionManager: TerminalSessionManager) {
        self.viewModel = viewModel
        self.sessionManager = sessionManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        hostingView = PassThroughHostingView(
            rootView: NotchContainerView(viewModel: viewModel, sessionManager: sessionManager)
        )

        hostingView.hitTestRect = { [weak self] in
            guard let self else { return .zero }
            let vm = self.viewModel
            let geometry = vm.geometry
            let windowHeight = geometry.windowHeight
            let screenWidth = geometry.screenRect.width

            switch vm.status {
            case .opened:
                // Cover the full expanded panel with a little horizontal breathing room
                let hitW = vm.openedSize.width + 52
                let hitH = vm.closedPillHeight + vm.openedSize.height
                return CGRect(
                    x: (screenWidth - hitW) / 2,
                    y: windowHeight - hitH,
                    width: hitW,
                    height: hitH
                )
            case .closed:
                // Follow the hardware notch dimensions with a small buffer
                let notchW = vm.deviceNotchRect.width
                let notchH = vm.deviceNotchRect.height
                return CGRect(
                    x: (screenWidth - notchW) / 2,
                    y: windowHeight - notchH - 5,
                    width: notchW,
                    height: notchH + 10
                )
            }
        }

        self.view = hostingView
    }
}
