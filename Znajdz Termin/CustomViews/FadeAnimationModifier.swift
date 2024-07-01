//
//  FadeAnimationModifier.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 01/07/2024.
//

import SwiftUI

struct FadeAnimation: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var isReduceMotionEnabled
    func body(content: Content) -> some View {
        if !isReduceMotionEnabled {
            content
                .phaseAnimator([0.5, 0.75, 1]) { view, phase in
                    view
                        .scaleEffect(phase)
                        .opacity(phase == 1 ? 1 : 0)
                }
        } else {
            content
        }
    }
}

extension View {
    func fadeAnimation() -> some View {
        modifier(FadeAnimation())
    }
}
