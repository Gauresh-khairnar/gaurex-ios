//
//  VisualEffects.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Apple-Grade Motion, Aurora Mesh Background & Visual Micro-Interactions
//

import SwiftUI

// MARK: - Ambient Living Aurora Background
public struct AuroraLivingBackground: View {
    @ObservedObject private var theme = ThemeManager.shared
    @State private var animateOrbs: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    
    public init() {}
    
    public var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            if !reduceMotion {
                if colorScheme == .light {
                    // Pristine Light Mode Ambient Glow (Subtle Champagne Light)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    theme.accentColor.opacity(0.06),
                                    Color.orange.opacity(0.03),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 260
                            )
                        )
                        .frame(width: 420, height: 420)
                        .offset(x: animateOrbs ? -40 : -90, y: animateOrbs ? -120 : -180)
                        .blur(radius: 60)
                } else {
                    // Executive Dark Mode Ambient Breathing Aurora
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    theme.accentColor.opacity(0.18),
                                    theme.accentColor.opacity(0.06),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 220
                            )
                        )
                        .frame(width: 380, height: 380)
                        .offset(
                            x: animateOrbs ? -80 : -140,
                            y: animateOrbs ? -160 : -220
                        )
                        .blur(radius: 50)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.18, green: 0.42, blue: 0.88).opacity(0.12),
                                    Color.purple.opacity(0.05),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 260
                            )
                        )
                        .frame(width: 440, height: 440)
                        .offset(
                            x: animateOrbs ? 140 : 80,
                            y: animateOrbs ? 60 : 140
                        )
                        .blur(radius: 65)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.45, green: 0.25, blue: 0.75).opacity(0.08),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 280
                            )
                        )
                        .frame(width: 420, height: 420)
                        .offset(
                            x: animateOrbs ? -40 : 40,
                            y: animateOrbs ? 320 : 380
                        )
                        .blur(radius: 70)
                }
            }
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(
                .easeInOut(duration: 9.0)
                .repeatForever(autoreverses: true)
            ) {
                animateOrbs = true
            }
        }
    }
}

// MARK: - Holographic Shimmer Modifier
public struct HolographicShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1.2
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    public func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content
                .overlay(
                    GeometryReader { geo in
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: .white.opacity(0.45), location: 0.5),
                                .init(color: .clear, location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(width: geo.size.width * 0.9)
                        .offset(x: phase * geo.size.width * 1.8)
                        .blendMode(.screen)
                    }
                    .mask(content)
                )
                .onAppear {
                    withAnimation(
                        .linear(duration: 2.8)
                        .repeatForever(autoreverses: false)
                    ) {
                        phase = 1.2
                    }
                }
        }
    }
}

extension View {
    public func holographicShimmer() -> some View {
        self.modifier(HolographicShimmerModifier())
    }
}

// MARK: - Milestone Celebration Particle Burst
public struct MilestoneCelebrationOverlay: View {
    public var title: String
    public var subtitle: String
    public var onDismiss: () -> Void
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @State private var particles: [SparkleParticle] = []
    
    public init(title: String, subtitle: String, onDismiss: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
            
            // Sparkle Particle Field
            ForEach(particles) { p in
                Circle()
                    .fill(p.color)
                    .frame(width: p.size, height: p.size)
                    .scaleEffect(p.scale)
                    .offset(x: p.x, y: p.y)
                    .opacity(p.opacity)
            }
            
            // Central Celebration Card
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.98, green: 0.82, blue: 0.35), Color.orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                        .shadow(color: Color.orange.opacity(0.4), radius: 16, x: 0, y: 6)
                    
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                
                Button {
                    onDismiss()
                } label: {
                    Text("Continue Sprints")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                .padding(.top, 6)
            }
            .padding(26)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.6), Color.orange.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 24, x: 0, y: 12)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            let haptic = UINotificationFeedbackGenerator()
            haptic.notificationOccurred(.success)
            
            spawnParticles()
            
            withAnimation(.spring(response: 0.45, dampingFraction: 0.68, blendDuration: 0.1)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
    
    private func spawnParticles() {
        var items: [SparkleParticle] = []
        let goldColors: [Color] = [
            Color(red: 0.98, green: 0.82, blue: 0.35),
            Color.yellow,
            Color.white,
            Color.orange
        ]
        
        for i in 0..<36 {
            let angle = Double(i) * (360.0 / 36.0) * (.pi / 180.0)
            let distance = Double.random(in: 60...160)
            let targetX = cos(angle) * distance
            let targetY = sin(angle) * distance
            
            items.append(
                SparkleParticle(
                    id: i,
                    x: CGFloat(targetX),
                    y: CGFloat(targetY),
                    size: CGFloat.random(in: 4...9),
                    color: goldColors.randomElement() ?? .yellow,
                    opacity: 0.9,
                    scale: 1.0
                )
            )
        }
        particles = items
    }
}

public struct SparkleParticle: Identifiable {
    public var id: Int
    public var x: CGFloat
    public var y: CGFloat
    public var size: CGFloat
    public var color: Color
    public var opacity: Double
    public var scale: CGFloat
}

// MARK: - Harmonic Siri-Style Pulsing Voice Orb
public struct HarmonicPulsingVoiceOrb: View {
    public var isListening: Bool
    public var isSpeaking: Bool
    @ObservedObject private var theme = ThemeManager.shared
    @State private var phase: CGFloat = 0.0
    
    public init(isListening: Bool, isSpeaking: Bool) {
        self.isListening = isListening
        self.isSpeaking = isSpeaking
    }
    
    public var body: some View {
        ZStack {
            if isListening {
                // Expanding harmonic ripple ring 1
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [theme.accentColor.opacity(0.6), Color.red.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 104, height: 104)
                    .scaleEffect(phase > 0.5 ? 1.25 : 0.95)
                    .opacity(phase > 0.5 ? 0.3 : 0.8)
                    .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: phase)
                
                // Expanding harmonic ripple ring 2
                Circle()
                    .stroke(theme.accentColor.opacity(0.3), lineWidth: 1.5)
                    .frame(width: 128, height: 128)
                    .scaleEffect(phase > 0.5 ? 1.35 : 0.88)
                    .opacity(phase > 0.5 ? 0.15 : 0.6)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: phase)
            }
            
            // Main Glass Glow Orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: isListening
                            ? [Color.red.opacity(0.95), Color.orange.opacity(0.85), Color.red.opacity(0.5)]
                            : [theme.accentColor.opacity(0.95), Color(red: 0.18, green: 0.42, blue: 0.88).opacity(0.85), Color.black.opacity(0.4)],
                        center: .center,
                        startRadius: 5,
                        endRadius: 40
                    )
                )
                .frame(width: 74, height: 74)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1.2)
                )
                .shadow(
                    color: (isListening ? Color.red : theme.accentColor).opacity(0.45),
                    radius: isListening ? 20 : 12,
                    x: 0,
                    y: 6
                )
            
            Image(systemName: isListening ? "waveform" : (isSpeaking ? "speaker.wave.3.fill" : "mic.fill"))
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
                .contentTransition(.symbolEffect(.replace))
        }
        .onAppear {
            phase = 1.0
        }
    }
}
