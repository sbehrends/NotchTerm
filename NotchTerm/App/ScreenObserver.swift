//
//  ScreenObserver.swift
//  NotchTerm
//
//  Monitors screen configuration changes
//

import AppKit

final class ScreenObserver: @unchecked Sendable {
    private var observer: NSObjectProtocol?
    private let onScreenChange: () -> Void

    init(onScreenChange: @escaping () -> Void) {
        self.onScreenChange = onScreenChange
        observer = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.onScreenChange()
        }
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
