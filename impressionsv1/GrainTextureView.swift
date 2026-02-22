//
//  GrainTextureView.swift
//  impressionsv1
//
//  A subtle grain/noise texture overlay used to add depth to card surfaces.
//

import SwiftUI

/// Renders a procedural grain texture using a Canvas, configurable by opacity.
struct GrainTextureView: View {
    var opacity: Double = 0.08

    var body: some View {
        Canvas { context, size in
            // Seed a simple deterministic pseudo-random grain pattern
            var rng = SeededRNG(seed: 42)
            let dotSize: CGFloat = 1.5
            let step: CGFloat = 3

            var y: CGFloat = 0
            while y < size.height {
                var x: CGFloat = 0
                while x < size.width {
                    let alpha = rng.nextDouble() * opacity
                    let color = Color.white.opacity(alpha)
                    let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                    context.fill(Path(rect), with: .color(color))
                    x += step
                }
                y += step
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Simple seeded pseudo-random number generator

private struct SeededRNG {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        // xorshift64
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }

    mutating func nextDouble() -> Double {
        Double(next() & 0x000FFFFF) / Double(0x000FFFFF)
    }
}
