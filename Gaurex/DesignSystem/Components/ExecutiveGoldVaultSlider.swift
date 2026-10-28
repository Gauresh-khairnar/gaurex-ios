//
//  ExecutiveGoldVaultSlider.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Slide-to-Disburse Apple Watch Style Fluid Gold Vault Slider with Accelerating Haptics
//

import SwiftUI

public struct ExecutiveGoldVaultSlider: View {
    public var title: String
    public var subtitle: String
    public var icon: String
    public var onComplete: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isCompleted: Bool = false
    @State private var lastHapticStage: Int = 0
    
    private let deepPurple = Color.gaurexDeepPlum
    private let goldAccent = Color.gaurexWarmGold
    
    public init(
        title: String = "Slide to Disburse",
        subtitle: String = "Authorizes transaction",
        icon: String = "banknote.fill",
        onComplete: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.onComplete = onComplete
    }
    
    public var body: some View {
        GeometryReader { geo in
            let trackWidth = geo.size.width
            let buttonSize: CGFloat = 52
            let maxDrag = max(10, trackWidth - buttonSize - 8)
            let progress = min(1.0, max(0.0, dragOffset / maxDrag))
            
            ZStack(alignment: .leading) {
                // Background Track
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.15, green: 0.05, blue: 0.18),
                                Color(red: 0.24, green: 0.08, blue: 0.28)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [goldAccent.opacity(0.6), Color.white.opacity(0.15)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1.2
                            )
                    )
                
                // Active Fill Trail
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [deepPurple, goldAccent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: buttonSize + dragOffset + 4)
                
                // Track Label & Shimmer
                HStack {
                    Spacer()
                    VStack(spacing: 2) {
                        Text(isCompleted ? "VERIFIED & SEALED" : title)
                            .font(.pjs(13, weight: .bold))
                            .foregroundColor(isCompleted ? goldAccent : Color.white.opacity(0.85))
                            .tracking(1.0)
                        
                        Text(subtitle)
                            .font(.pjs(10, weight: .regular))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                    .offset(x: -buttonSize / 3)
                    Spacer()
                }
                .opacity(1.0 - Double(progress * 0.7))
                
                // Draggable Gold Bullion Ingot
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.85, blue: 0.35),
                                    goldAccent,
                                    Color(red: 0.75, green: 0.50, blue: 0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: buttonSize, height: buttonSize)
                        .shadow(color: goldAccent.opacity(0.6), radius: 8, x: 0, y: 3)
                        .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 1.5))
                    
                    Image(systemName: isCompleted ? "checkmark" : icon)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(deepPurple)
                        .rotationEffect(.degrees(Double(progress * 90)))
                }
                .offset(x: 4 + dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            guard !isCompleted else { return }
                            let newOffset = max(0, min(value.translation.width, maxDrag))
                            dragOffset = newOffset
                            
                            // Accelerating Haptic Ticks at 25%, 50%, 75%
                            let currentStage = Int((newOffset / maxDrag) * 4)
                            if currentStage > lastHapticStage {
                                MotionTokens.impact(style: .medium)
                                lastHapticStage = currentStage
                            }
                        }
                        .onEnded { value in
                            guard !isCompleted else { return }
                            if dragOffset >= maxDrag * 0.88 {
                                // Successful Seal!
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                                    dragOffset = maxDrag
                                    isCompleted = true
                                }
                                MotionTokens.notification(type: .success)
                                onComplete()
                                
                                // Auto reset after confirmation
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    withAnimation(.spring()) {
                                        dragOffset = 0
                                        isCompleted = false
                                        lastHapticStage = 0
                                    }
                                }
                            } else {
                                // Snap Back
                                withAnimation(.spring(response: 0.38, dampingFraction: 0.75)) {
                                    dragOffset = 0
                                    lastHapticStage = 0
                                }
                                MotionTokens.impact(style: .light)
                            }
                        }
                )
            }
        }
        .frame(height: 58)
    }
}
