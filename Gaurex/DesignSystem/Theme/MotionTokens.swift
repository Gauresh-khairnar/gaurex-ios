//
//  MotionTokens.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public enum MotionTokens {
    // Standard Durations
    public static let fast: Double = 0.16
    public static let standard: Double = 0.28
    public static let smooth: Double = 0.42
    public static let deliberate: Double = 0.60
    
    // Spring Specifications
    public static let interactiveSpring = Animation.spring(response: 0.32, dampingFraction: 0.76, blendDuration: 0)
    public static let snappySpring = Animation.spring(response: 0.22, dampingFraction: 0.70, blendDuration: 0)
    public static let gentleSpring = Animation.spring(response: 0.45, dampingFraction: 0.82, blendDuration: 0)
    public static let sheetSpring = Animation.spring(response: 0.38, dampingFraction: 0.80, blendDuration: 0)
    
    // Press Scaling Factors
    public static let buttonPressScale: CGFloat = 0.97
    public static let cardPressScale: CGFloat = 0.985
    public static let tabItemPressScale: CGFloat = 0.92
    
    // Stagger Delays
    public static let staggerInterval: Double = 0.04
    
    // Haptic Triggers
    public static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    public static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    public static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}

// Reusable View Modifier for Press Scale & Tactile Feedback
public struct TactilePressModifier: ViewModifier {
    @State private var isPressed: Bool = false
    public var scale: CGFloat
    public var hapticOnRelease: Bool
    
    public init(scale: CGFloat = MotionTokens.buttonPressScale, hapticOnRelease: Bool = true) {
        self.scale = scale
        self.hapticOnRelease = hapticOnRelease
    }
    
    public func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .animation(MotionTokens.snappySpring, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            MotionTokens.impact(style: .rigid)
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        if hapticOnRelease {
                            MotionTokens.impact(style: .light)
                        }
                    }
            )
    }
}

extension View {
    public func tactilePress(scale: CGFloat = MotionTokens.buttonPressScale) -> some View {
        self.modifier(TactilePressModifier(scale: scale))
    }
}
