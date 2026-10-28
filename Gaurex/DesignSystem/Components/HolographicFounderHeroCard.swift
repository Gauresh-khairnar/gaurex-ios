//
//  HolographicFounderHeroCard.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  3D Holographic Gyroscope-Reactive Executive Hero Card with Gold Foil Refraction
//

import SwiftUI
import CoreMotion

public struct HolographicFounderHeroCard: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var pitch: Double = 0.0
    @State private var roll: Double = 0.0
    @State private var sheenOffset: CGFloat = -1.2
    @State private var motionManager = CMMotionManager()
    @State private var sparklinePulse: Bool = false
    
    private let deepPurple = Color.gaurexDeepPlum
    private let goldAccent = Color.gaurexWarmGold
    
    public var onTap: () -> Void
    
    public init(onTap: @escaping () -> Void) {
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: {
            MotionTokens.impact(style: .medium)
            onTap()
        }) {
            ZStack(alignment: .topTrailing) {
                // 1. Physical Titanium & Glass Base Surface
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: colorScheme == .dark
                                ? [Color(red: 0.16, green: 0.08, blue: 0.18), Color(red: 0.10, green: 0.05, blue: 0.12)]
                                : [Color.white, Color(red: 0.96, green: 0.94, blue: 0.97)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: deepPurple.opacity(colorScheme == .dark ? 0.45 : 0.12), radius: 20, x: 0, y: 10)
                
                // 2. Holographic Specular Gold Foil Reflection Streak
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: goldAccent.opacity(0.18), location: 0.45),
                                .init(color: Color.white.opacity(0.35), location: 0.50),
                                .init(color: goldAccent.opacity(0.18), location: 0.55),
                                .init(color: .clear, location: 1.0)
                            ],
                            startPoint: UnitPoint(x: sheenOffset - 0.4, y: 0),
                            endPoint: UnitPoint(x: sheenOffset + 0.4, y: 1)
                        )
                    )
                    .allowsHitTesting(false)
                
                // 3. Precision Edge Border with Golden Micro-Bevel
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                goldAccent.opacity(0.7),
                                Color.white.opacity(0.3),
                                deepPurple.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
                
                // 4. Card Content
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 10) {
                        // Title Row
                        HStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(deepPurple.opacity(0.12))
                                    .frame(width: 38, height: 38)
                                    .overlay(
                                        Image(systemName: "chart.bar.xaxis")
                                            .font(.system(size: 17, weight: .bold))
                                            .foregroundColor(deepPurple)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Net Operating Cashflow")
                                    .font(.pjs(13, weight: .semibold))
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                                
                                Text("Founder Edition • Real-Time Ledger")
                                    .font(.pjs(10, weight: .bold))
                                    .foregroundColor(goldAccent)
                            }
                        }
                        
                        // Amount Display with Privacy Blur
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            if store.isStealthPrivacyActive {
                                Text("••••••••")
                                    .font(.pjs(28, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                    .blur(radius: 2)
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(goldAccent)
                            } else {
                                Text(FinancialCalculator.shared.formatCurrency(store.netOperatingRevenue, symbol: store.settings.currencySymbol))
                                    .font(.pjs(28, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                            }
                        }
                        
                        // Live Inflow vs Outflow Cash Radar
                        HStack(spacing: 8) {
                            HStack(spacing: 3) {
                                Image(systemName: "arrow.down.left")
                                    .font(.system(size: 10, weight: .bold))
                                Text("In: \(store.formatPrivacyCurrency(store.revenueCollected))")
                                    .font(.pjs(11, weight: .semibold))
                            }
                            .foregroundColor(Color(red: 0.06, green: 0.72, blue: 0.44))
                            
                            Text("•")
                                .foregroundColor(Color(uiColor: .tertiaryLabel))
                            
                            HStack(spacing: 3) {
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 10, weight: .bold))
                                Text("Exp: -\(store.formatPrivacyCurrency(store.allOperationalExpenses))")
                                    .font(.pjs(11, weight: .semibold))
                            }
                            .foregroundColor(Color(red: 0.92, green: 0.28, blue: 0.28))
                        }
                    }
                    
                    Spacer()
                    
                    // Liquid Bezier Wave Sparkline
                    ZStack {
                        HeroSparklineWave()
                            .stroke(
                                LinearGradient(
                                    colors: [deepPurple, goldAccent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 2.4
                            )
                            .frame(width: 120, height: 58)
                        
                        // Inflection Node
                        Circle()
                            .fill(goldAccent)
                            .frame(width: 8, height: 8)
                            .shadow(color: goldAccent.opacity(0.9), radius: sparklinePulse ? 8 : 2)
                            .offset(x: 18, y: -18)
                    }
                }
                .padding(22)
                
                // Top-Right Live Sync Pill
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color(red: 0.06, green: 0.72, blue: 0.44))
                        .frame(width: 6, height: 6)
                        .scaleEffect(sparklinePulse ? 1.2 : 0.8)
                    Text("3D Live Sync")
                        .font(.pjs(10.5, weight: .bold))
                        .foregroundColor(Color(red: 0.06, green: 0.72, blue: 0.44))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(red: 0.06, green: 0.72, blue: 0.44).opacity(0.12))
                .clipShape(Capsule())
                .padding(14)
            }
            .frame(maxWidth: .infinity)
            // 3D Perspective Gyro Tilt Transformations
            .rotation3DEffect(.degrees(pitch), axis: (x: 1, y: 0, z: 0))
            .rotation3DEffect(.degrees(roll), axis: (x: 0, y: 1, z: 0))
            // Interactive Drag Gesture Tilt for Instant Touch Delight
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let maxAngle: Double = 12.0
                        withAnimation(.interactiveSpring) {
                            pitch = Double(-value.translation.height / 10).clamped(to: -maxAngle...maxAngle)
                            roll = Double(value.translation.width / 10).clamped(to: -maxAngle...maxAngle)
                            sheenOffset = CGFloat(value.translation.width / 180)
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                            pitch = 0
                            roll = 0
                            sheenOffset = 1.4
                        }
                    }
            )
        }
        .buttonStyle(.plain)
        .onAppear {
            startGyroscopeUpdates()
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                sparklinePulse = true
            }
            withAnimation(.linear(duration: 3.5).repeatForever(autoreverses: false)) {
                sheenOffset = 2.0
            }
        }
        .onDisappear {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    private func startGyroscopeUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 0.04
        motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            guard let motion = motion else { return }
            withAnimation(.interactiveSpring) {
                // Pitch and Roll mapped smoothly to gentle degrees
                self.pitch = (motion.attitude.pitch * 9.0).clamped(to: -10...10)
                self.roll = (motion.attitude.roll * 9.0).clamped(to: -10...10)
            }
        }
    }
}

private struct HeroSparklineWave: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: 0, y: h * 0.75))
        path.addCurve(
            to: CGPoint(x: w * 0.35, y: h * 0.68),
            control1: CGPoint(x: w * 0.15, y: h * 0.95),
            control2: CGPoint(x: w * 0.25, y: h * 0.58)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.70, y: h * 0.24),
            control1: CGPoint(x: w * 0.45, y: h * 0.78),
            control2: CGPoint(x: w * 0.58, y: h * 0.18)
        )
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.08),
            control1: CGPoint(x: w * 0.82, y: h * 0.28),
            control2: CGPoint(x: w * 0.92, y: h * 0.12)
        )
        return path
    }
}

private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
