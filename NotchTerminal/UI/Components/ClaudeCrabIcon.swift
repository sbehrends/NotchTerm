//
//  ClaudeCrabIcon.swift
//  NotchTerminal
//
//  Pixel-art Claude crab icon and processing spinner — adapted from claude-island.
//

import Combine
import SwiftUI

// MARK: - Crab Icon

struct ClaudeCrabIcon: View {
    let size: CGFloat
    let color: Color
    var animateLegs: Bool = false

    @State private var legPhase: Int = 0

    private let legTimer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()

    init(
        size: CGFloat = 16,
        color: Color = Color(red: 0.85, green: 0.47, blue: 0.34),
        animateLegs: Bool = false
    ) {
        self.size = size
        self.color = color
        self.animateLegs = animateLegs
    }

    var body: some View {
        Canvas { context, canvasSize in
            let scale = size / 52.0  // Original viewBox height is 52
            let xOffset = (canvasSize.width - 66 * scale) / 2

            // Left antenna
            let leftAntenna = Path { p in
                p.addRect(CGRect(x: 0, y: 13, width: 6, height: 13))
            }.applying(CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: xOffset / scale, y: 0))
            context.fill(leftAntenna, with: .color(color))

            // Right antenna
            let rightAntenna = Path { p in
                p.addRect(CGRect(x: 60, y: 13, width: 6, height: 13))
            }.applying(CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: xOffset / scale, y: 0))
            context.fill(rightAntenna, with: .color(color))

            // Legs — alternating up/down for walking effect
            let baseLegPositions: [CGFloat] = [6, 18, 42, 54]
            let baseLegHeight: CGFloat = 13
            let legHeightOffsets: [[CGFloat]] = [
                [3, -3, 3, -3],
                [0, 0, 0, 0],
                [-3, 3, -3, 3],
                [0, 0, 0, 0],
            ]
            let currentOffsets = animateLegs
                ? legHeightOffsets[legPhase % 4]
                : [CGFloat](repeating: 0, count: 4)

            for (index, xPos) in baseLegPositions.enumerated() {
                let legHeight = baseLegHeight + currentOffsets[index]
                let leg = Path { p in
                    p.addRect(CGRect(x: xPos, y: 39, width: 6, height: legHeight))
                }.applying(CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: xOffset / scale, y: 0))
                context.fill(leg, with: .color(color))
            }

            // Main body
            let body = Path { p in
                p.addRect(CGRect(x: 6, y: 0, width: 54, height: 39))
            }.applying(CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: xOffset / scale, y: 0))
            context.fill(body, with: .color(color))

            // Eyes
            let leftEye = Path { p in
                p.addRect(CGRect(x: 12, y: 13, width: 6, height: 6.5))
            }.applying(CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: xOffset / scale, y: 0))
            context.fill(leftEye, with: .color(.black))

            let rightEye = Path { p in
                p.addRect(CGRect(x: 48, y: 13, width: 6, height: 6.5))
            }.applying(CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: xOffset / scale, y: 0))
            context.fill(rightEye, with: .color(.black))
        }
        .frame(width: size * (66.0 / 52.0), height: size)
        .onReceive(legTimer) { _ in
            if animateLegs {
                legPhase = (legPhase + 1) % 4
            }
        }
    }
}

// MARK: - Processing Spinner

struct ProcessingSpinner: View {
    @State private var phase: Int = 0

    private let symbols = ["·", "✢", "✳", "∗", "✻", "✽"]
    private let color = Color(red: 0.85, green: 0.47, blue: 0.34)

    private let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(symbols[phase % symbols.count])
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(color)
            .frame(width: 12, alignment: .center)
            .onReceive(timer) { _ in
                phase = (phase + 1) % symbols.count
            }
    }
}
