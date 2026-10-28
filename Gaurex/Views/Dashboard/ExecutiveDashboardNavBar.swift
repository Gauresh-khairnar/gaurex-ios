//
//  ExecutiveDashboardNavBar.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Executive Navigation Bar with Gyroscope Gold Light Sweep, Neo AI Crest & Biometric Halo
//

import SwiftUI
import CoreMotion

public struct ExecutiveDashboardNavBar: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var neo = NeoCoFounderService.shared
    @ObservedObject private var bioAuth = BiometricAuthService.shared
    @Environment(\.colorScheme) private var colorScheme
    
    // Gyroscope Motion Tracking
    @State private var motionManager = CMMotionManager()
    @State private var gyroRoll: Double = 0.0
    @State private var gyroPitch: Double = 0.0
    @State private var goldSheenOffset: CGFloat = 0.5
    
    // AI Crest Breathing
    @State private var crestRippleScale: CGFloat = 1.0
    @State private var crestRippleOpacity: Double = 0.6
    @State private var crestRotation: Double = 0.0
    
    // Biometric Halo Orbit Animation
    @State private var haloRotation: Double = 0.0
    @State private var haloPulse: Bool = false
    
    public var onAvatarTap: () -> Void
    public var onBellTap: () -> Void
    
    private let deepPurple = Color.gaurexDeepPlum
    private let goldAccent = Color.gaurexWarmGold
    
    public init(onAvatarTap: @escaping () -> Void, onBellTap: @escaping () -> Void) {
        self.onAvatarTap = onAvatarTap
        self.onBellTap = onBellTap
    }
    
    // Check if founder has closed a high-value contract today (>= ₹25,000)
    private var hasHighValueContractToday: Bool {
        store.invoices.contains { inv in
            Calendar.current.isDateInToday(inv.createdAt) && inv.totalAmount >= 25000
        }
    }
    
    // Check if Neo has an urgent war-room insight (overdue invoices or high pending collection)
    private var hasUrgentInsight: Bool {
        store.overdueInvoicesCount > 0 || store.outstandingPayments > 20000
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // MARK: - Left: GAUREX Typography with Gyroscope-Driven Gold Light Sweep
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    HStack(spacing: 0) {
                        Text("G")
                            .font(.pjs(24, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                        
                        // 🪞 Gyroscope-Driven Gold Letter "A" with Specular Light Reflection
                        Text("A")
                            .font(.pjs(24, weight: .black))
                            .foregroundStyle(
                                LinearGradient(
                                    stops: [
                                        .init(color: goldAccent, location: 0.0),
                                        .init(color: Color.white.opacity(0.9), location: max(0.05, min(0.95, goldSheenOffset))),
                                        .init(color: goldAccent, location: 1.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: goldAccent.opacity(0.55), radius: 6, x: 0, y: 1)
                        
                        Text("UREX")
                            .font(.pjs(24, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                    }
                    .tracking(2.0)
                    
                    // MARK: - ✨ Neo Holographic AI Crest (Audio & Insight Breathing)
                    Button {
                        MotionTokens.impact(style: .medium)
                        if neo.isSpeaking {
                            neo.stopSpeaking()
                        } else {
                            neo.greetFounderOnLaunch(force: true)
                        }
                    } label: {
                        ZStack {
                            // Autonomous Warning / Breathing Ripple
                            if hasUrgentInsight || neo.isSpeaking {
                                Circle()
                                    .stroke(goldAccent.opacity(crestRippleOpacity), lineWidth: 1.4)
                                    .frame(width: 28, height: 28)
                                    .scaleEffect(crestRippleScale)
                            }
                            
                            // Central Holographic Crest Disc
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            deepPurple,
                                            Color(red: 0.16, green: 0.05, blue: 0.22)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [goldAccent, goldAccent.opacity(0.3)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.2
                                        )
                                )
                                .shadow(color: goldAccent.opacity(0.4), radius: 4, x: 0, y: 1)
                            
                            // Sparkles Glyph with Cadence Rotation
                            Image(systemName: neo.isSpeaking ? "waveform" : "sparkles")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(goldAccent)
                                .rotationEffect(.degrees(crestRotation))
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                Text("Executive Dashboard")
                    .font(.pjs(12, weight: .medium))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // MARK: - Stealth Privacy Shield Button
                Button {
                    store.toggleStealthPrivacy()
                } label: {
                    ZStack {
                        Circle()
                            .fill(colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.22) : Color.white)
                            .frame(width: 42, height: 42)
                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                        
                        Image(systemName: store.isStealthPrivacyActive ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(store.isStealthPrivacyActive ? Color.red : goldAccent)
                    }
                }
                .buttonStyle(.plain)
                
                // MARK: - Bell Notifications Button
                Button(action: onBellTap) {
                    ZStack(alignment: .topTrailing) {
                        Circle()
                            .fill(colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.22) : Color.white)
                            .frame(width: 42, height: 42)
                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                        
                        Image(systemName: "bell")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                            .frame(width: 42, height: 42)
                        
                        if hasUrgentInsight {
                            Circle()
                                .fill(goldAccent)
                                .frame(width: 8, height: 8)
                                .offset(x: -6, y: 8)
                        }
                    }
                }
                .buttonStyle(.plain)
                
                // MARK: - 🛡️ Biometric Halo Security Ring (On the GK Avatar)
                Button(action: onAvatarTap) {
                    ZStack {
                        // 360° Hairline Status Halo Ring
                        if store.isStealthPrivacyActive {
                            // Deep Plum Stealth Pulse (Ghost Mode Active)
                            Circle()
                                .stroke(
                                    AngularGradient(
                                        gradient: Gradient(colors: [deepPurple, Color.red.opacity(0.8), deepPurple]),
                                        center: .center
                                    ),
                                    lineWidth: 2.4
                                )
                                .frame(width: 48, height: 48)
                                .scaleEffect(haloPulse ? 1.08 : 0.98)
                                .opacity(haloPulse ? 0.85 : 0.5)
                        } else if hasHighValueContractToday {
                            // Radiant Gold Orbit (High-Value Contract Closed Today)
                            Circle()
                                .stroke(
                                    AngularGradient(
                                        gradient: Gradient(colors: [goldAccent, Color.white, goldAccent]),
                                        center: .center,
                                        startAngle: .degrees(haloRotation),
                                        endAngle: .degrees(haloRotation + 360)
                                    ),
                                    lineWidth: 2.2
                                )
                                .frame(width: 48, height: 48)
                                .shadow(color: goldAccent.opacity(0.6), radius: 6, x: 0, y: 0)
                        } else {
                            // Glowing Emerald Green Ring (Biometrics & Vault Verified)
                            Circle()
                                .stroke(
                                    AngularGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.15, green: 0.85, blue: 0.45),
                                            Color(red: 0.05, green: 0.60, blue: 0.30),
                                            Color(red: 0.15, green: 0.85, blue: 0.45)
                                        ]),
                                        center: .center
                                    ),
                                    lineWidth: 2.0
                                )
                                .frame(width: 48, height: 48)
                                .shadow(color: Color.green.opacity(0.4), radius: 4, x: 0, y: 0)
                        }
                        
                        // Inner Monogram Avatar Base
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        deepPurple,
                                        Color(red: 0.14, green: 0.07, blue: 0.22)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 42, height: 42)
                            .overlay(Circle().stroke(goldAccent.opacity(0.35), lineWidth: 1.0))
                            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                        
                        Text("GK")
                            .font(.pjs(14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
                // Long-Press for Instant Stealth Lockout
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.45)
                        .onEnded { _ in
                            GaurexSoundEffectsService.shared.playStealthModeClick()
                            store.toggleStealthPrivacy()
                        }
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .onAppear {
            startGyroscopeMotion()
            startBreathingAnimations()
        }
        .onDisappear {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    // MARK: - Gyroscope Motion Updates
    private func startGyroscopeMotion() {
        guard motionManager.isDeviceMotionAvailable else {
            // Fallback subtle ambient oscillation if gyro unavailable
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                goldSheenOffset = 0.9
            }
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 0.03
        motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            guard let motion = motion else { return }
            withAnimation(.interactiveSpring(response: 0.18, dampingFraction: 0.75)) {
                self.gyroRoll = motion.attitude.roll
                self.gyroPitch = motion.attitude.pitch
                // Normalize roll to 0.05 ... 0.95 specular sheen
                let normalizedRoll = CGFloat((motion.attitude.roll + 1.2) / 2.4)
                self.goldSheenOffset = max(0.05, min(0.95, normalizedRoll))
            }
        }
    }
    
    // MARK: - Micro-Animations
    private func startBreathingAnimations() {
        // AI Crest breathing ripple
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
            crestRippleScale = 1.35
            crestRippleOpacity = 0.15
            crestRotation = 180
        }
        
        // Status Halo Continuous Rotation & Pulse
        withAnimation(.linear(duration: 6.0).repeatForever(autoreverses: false)) {
            haloRotation = 360
        }
        withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
            haloPulse = true
        }
    }
}
