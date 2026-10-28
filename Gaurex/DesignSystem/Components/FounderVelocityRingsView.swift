//
//  FounderVelocityRingsView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Apple Watch-Inspired 3-Ring Founder Velocity & Interactive Gold Confetti Fountain
//

import SwiftUI

public struct FounderVelocityRingsView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var animateRings: Bool = false
    @State private var showingConfetti: Bool = false
    
    private let deepPurple = Color.gaurexDeepPlum
    private let goldAccent = Color.gaurexWarmGold
    
    public init() {}
    
    private var revenueProgress: Double {
        let target = store.businessGoals.first(where: { $0.metricType == .monthlyRevenue })?.targetValue ?? 1250000.0
        return min(1.0, max(0.04, store.netOperatingRevenue / target))
    }
    
    private var tasksProgress: Double {
        let total = max(1, store.todayTasks.count)
        let done = store.todayTasks.filter { $0.status == .completed }.count
        return min(1.0, max(0.05, Double(done) / Double(total)))
    }
    
    private var healthProgress: Double {
        let overdues = store.overdueInvoicesCount
        return overdues == 0 ? 1.0 : max(0.2, 1.0 - (Double(overdues) * 0.2))
    }
    
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.19) : Color.white)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.04), radius: 10, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
                )
            
            HStack(spacing: 18) {
                // Triple Concentric Velocity Rings
                ZStack {
                    // Ring 1 (Outer): Revenue Goal
                    Circle()
                        .stroke(goldAccent.opacity(0.18), lineWidth: 9)
                        .frame(width: 86, height: 86)
                    Circle()
                        .trim(from: 0, to: animateRings ? CGFloat(revenueProgress) : 0)
                        .stroke(
                            AngularGradient(
                                colors: [goldAccent, Color(red: 1.0, green: 0.85, blue: 0.4), goldAccent],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 9, lineCap: .round)
                        )
                        .frame(width: 86, height: 86)
                        .rotationEffect(.degrees(-90))
                    
                    // Ring 2 (Middle): Tasks Closed
                    Circle()
                        .stroke(deepPurple.opacity(0.20), lineWidth: 8)
                        .frame(width: 64, height: 64)
                    Circle()
                        .trim(from: 0, to: animateRings ? CGFloat(tasksProgress) : 0)
                        .stroke(
                            AngularGradient(
                                colors: [deepPurple, Color(red: 0.55, green: 0.20, blue: 0.50), deepPurple],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(-90))
                    
                    // Ring 3 (Inner): Zero Overdue Accounts
                    Circle()
                        .stroke(Color(red: 0.06, green: 0.72, blue: 0.44).opacity(0.20), lineWidth: 7)
                        .frame(width: 44, height: 44)
                    Circle()
                        .trim(from: 0, to: animateRings ? CGFloat(healthProgress) : 0)
                        .stroke(
                            LinearGradient(
                                colors: [Color(red: 0.06, green: 0.72, blue: 0.44), Color.mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 7, lineCap: .round)
                        )
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                    
                    // Center Crown
                    Image(systemName: "crown.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(goldAccent)
                }
                .padding(.vertical, 8)
                
                // Details Breakdown
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Founder Velocity Rings")
                            .font(.pjs(13, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                        
                        Spacer()
                        
                        Button {
                            MotionTokens.notification(type: .success)
                            showingConfetti = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                showingConfetti = false
                            }
                        } label: {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(goldAccent)
                                .padding(5)
                                .background(goldAccent.opacity(0.15))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        RingMetricRow(color: goldAccent, title: "Revenue Runway", value: "\(Int(revenueProgress * 100))%")
                        RingMetricRow(color: deepPurple, title: "Today's Milestones", value: "\(store.todayTasks.filter { $0.status == .completed }.count)/\(max(1, store.todayTasks.count))")
                        RingMetricRow(color: Color(red: 0.06, green: 0.72, blue: 0.44), title: "Zero Overdues", value: store.overdueInvoicesCount == 0 ? "Perfect" : "\(store.overdueInvoicesCount) Req.")
                    }
                }
            }
            .padding(16)
            
            // Confetti Particle Explosion
            if showingConfetti {
                GoldConfettiParticleFountain()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.65, dampingFraction: 0.78).delay(0.2)) {
                animateRings = true
            }
        }
    }
}

private struct RingMetricRow: View {
    let color: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            
            Text(title)
                .font(.pjs(11, weight: .medium))
                .foregroundColor(Color(uiColor: .secondaryLabel))
            
            Spacer()
            
            Text(value)
                .font(.pjs(11.5, weight: .bold))
                .foregroundColor(Color.primary)
        }
    }
}

// MARK: - Interactive Gold Confetti Particle Fountain
public struct GoldConfettiParticleFountain: View {
    @State private var particles: [Particle] = (0..<35).map { _ in Particle() }
    
    public init() {}
    
    public var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for p in particles {
                    var ctx = context
                    ctx.opacity = p.opacity
                    ctx.translateBy(x: size.width * p.x, y: size.height * p.y)
                    ctx.rotate(by: .degrees(p.rotation))
                    
                    let rect = CGRect(x: -p.size/2, y: -p.size/2, width: p.size, height: p.size * 0.7)
                    ctx.fill(
                        RoundedRectangle(cornerRadius: 2).path(in: rect),
                        with: .color(p.color)
                    )
                }
            }
        }
        .onAppear {
            for i in particles.indices {
                withAnimation(.easeOut(duration: Double.random(in: 1.2...2.0))) {
                    particles[i].y -= CGFloat.random(in: 0.3...0.7)
                    particles[i].x += CGFloat.random(in: -0.25...0.25)
                    particles[i].rotation += Double.random(in: 90...360)
                    particles[i].opacity = 0
                }
            }
        }
    }
    
    private struct Particle {
        var x: CGFloat = CGFloat.random(in: 0.2...0.8)
        var y: CGFloat = 0.5
        var size: CGFloat = CGFloat.random(in: 6...12)
        var rotation: Double = Double.random(in: 0...360)
        var opacity: Double = 1.0
        var color: Color = [
            Color.gaurexWarmGold,
            Color(red: 1.0, green: 0.85, blue: 0.4),
            Color.gaurexDeepPlum,
            Color(red: 0.06, green: 0.72, blue: 0.44),
            Color.white
        ].randomElement() ?? Color.gaurexWarmGold
    }
}
