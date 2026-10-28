//
//  LiquidGlassTabBar.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Executive 5-Tab Floating Navigation Bar with Elevated Center AI Co-Founder Button
//

import SwiftUI

public enum MainTab: Int, CaseIterable, Identifiable {
    case home = 0
    case clients = 1
    case aiModel = 2
    case workers = 3
    case settings = 4
    case tasks = 5
    case finance = 6
    
    public var id: Int { rawValue }
    
    public var title: String {
        switch self {
        case .home: return "Home"
        case .clients: return "Clients"
        case .aiModel: return "AI"
        case .workers: return "Workers"
        case .settings: return "Settings"
        case .tasks: return "Tasks"
        case .finance: return "Finance"
        }
    }
    
    public var iconName: String {
        switch self {
        case .home: return "house"
        case .clients: return "person.2"
        case .aiModel: return "sparkles"
        case .workers: return "person"
        case .settings: return "gearshape"
        case .tasks: return "checklist"
        case .finance: return "chart.pie"
        }
    }
    
    public var selectedIconName: String {
        switch self {
        case .home: return "house.fill"
        case .clients: return "person.2.fill"
        case .aiModel: return "sparkles"
        case .workers: return "person.fill"
        case .settings: return "gearshape.fill"
        case .tasks: return "checklist.checked"
        case .finance: return "chart.pie.fill"
        }
    }
    
    // 5 primary tabs rendered in the bottom navigation bar
    public static var bottomBarTabs: [MainTab] {
        [.home, .clients, .aiModel, .workers, .settings]
    }
}

public struct LiquidGlassTabBar: View {
    @Binding public var selectedTab: MainTab
    @ObservedObject private var theme = ThemeManager.shared
    @Environment(\.colorScheme) private var colorScheme
    @State private var pressedTab: MainTab? = nil
    @State private var aiHaloPulse: Bool = false
    @State private var aiOrbRotation: Double = 0
    @State private var aiLevitate: Bool = false
    @State private var aiSparkleTwinkle: Bool = false
    
    public init(selectedTab: Binding<MainTab>) {
        self._selectedTab = selectedTab
    }
    
    @ObservedObject private var voiceAIService = VoiceAssistantService.shared
    
    private let deepPlum = Color.gaurexDeepPlum
    private let warmGold = Color.gaurexWarmGold
    private let deepPurple = Color.gaurexDeepPlum
    private let goldAccent = Color.gaurexWarmGold
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.bottomBarTabs) { tab in
                let isSelected = selectedTab == tab
                
                if tab == .aiModel {
                    // MARK: - Center Elevated AI Co-Founder Action Button with Micro-Animations
                    Button {
                        let feedback = UIImpactFeedbackGenerator(style: .medium)
                        feedback.impactOccurred()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                            selectedTab = .aiModel
                        }
                    } label: {
                        VStack(spacing: 2) {
                            ZStack {
                                // 1. Multi-Layer Breathing Halo Aura
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                (voiceAIService.isListening ? warmGold : warmGold).opacity(aiHaloPulse ? 0.45 : 0.12),
                                                deepPlum.opacity(aiHaloPulse ? 0.25 : 0.05),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 8,
                                            endRadius: 38
                                        )
                                    )
                                    .frame(width: 66, height: 66)
                                    .scaleEffect(aiHaloPulse ? 1.14 : 0.96)
                                
                                // 2. Outer Rotating Orbital Particle Ring
                                Circle()
                                    .stroke(
                                        AngularGradient(
                                            gradient: Gradient(colors: [
                                                warmGold.opacity(0.85),
                                                deepPlum.opacity(0.3),
                                                warmGold.opacity(0.1),
                                                warmGold.opacity(0.9)
                                            ]),
                                            center: .center
                                        ),
                                        lineWidth: 1.5
                                    )
                                    .frame(width: 53, height: 53)
                                    .rotationEffect(.degrees(aiOrbRotation))
                                
                                // 3. Orbiting Gold Micro-Satellite Particle
                                Circle()
                                    .fill(warmGold)
                                    .frame(width: 4.5, height: 4.5)
                                    .shadow(color: warmGold.opacity(0.9), radius: 3)
                                    .offset(x: 26.5)
                                    .rotationEffect(.degrees(aiOrbRotation))
                                
                                // 4. Elevated Deep Plum Sphere Body
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                deepPlum,
                                                Color(red: 0.16, green: 0.04, blue: 0.15)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        warmGold.opacity(voiceAIService.isListening ? 0.95 : 0.6),
                                                        Color.white.opacity(0.3)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: voiceAIService.isListening ? 1.8 : 1.1
                                            )
                                    )
                                    .shadow(
                                        color: deepPlum.opacity(0.50),
                                        radius: 12,
                                        x: 0,
                                        y: 5
                                    )
                                
                                // 5. Animated AI Core Icon / Voice Waveform
                                if voiceAIService.isListening {
                                    // Live Listening Dynamic Waveform
                                    HStack(spacing: 2.8) {
                                        ForEach(0..<4) { i in
                                            RoundedRectangle(cornerRadius: 1.5)
                                                .fill(warmGold)
                                                .frame(width: 3, height: aiHaloPulse ? CGFloat((i % 2 == 0 ? 16 : 8)) : CGFloat((i % 2 == 0 ? 8 : 16)))
                                                .animation(.easeInOut(duration: 0.35).repeatForever().delay(Double(i) * 0.08), value: aiHaloPulse)
                                        }
                                    }
                                } else {
                                    ZStack {
                                        // Subtle golden glow backing
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 21, weight: .bold))
                                            .foregroundColor(warmGold.opacity(0.4))
                                            .scaleEffect(aiSparkleTwinkle ? 1.25 : 0.95)
                                            .blur(radius: 2)
                                        
                                        // Primary Sharp Sparkle
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(warmGold)
                                            .scaleEffect(isSelected ? 1.12 : (aiSparkleTwinkle ? 1.05 : 0.98))
                                            .rotationEffect(.degrees(aiSparkleTwinkle ? 6 : -6))
                                    }
                                }
                            }
                            .offset(y: aiLevitate ? -2 : 1)
                            
                            Text("AI")
                                .font(.pjs(10, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? deepPlum : Color(uiColor: .secondaryLabel))
                        }
                        .frame(maxWidth: .infinity)
                        .offset(y: -10)
                        .scaleEffect(pressedTab == tab ? 0.92 : 1.0)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                            aiHaloPulse = true
                        }
                        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                            aiOrbRotation = 360
                        }
                        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                            aiLevitate = true
                        }
                        withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                            aiSparkleTwinkle = true
                        }
                    }
                } else {
                    // MARK: - Standard Tab Button
                    Button {
                        let feedback = UISelectionFeedbackGenerator()
                        feedback.selectionChanged()
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.76)) {
                            selectedTab = tab
                        }
                    } label: {
                        VStack(spacing: 3) {
                            Image(systemName: isSelected ? tab.selectedIconName : tab.iconName)
                                .font(.system(size: 19, weight: isSelected ? .semibold : .regular))
                                .foregroundColor(
                                    isSelected
                                        ? (colorScheme == .dark ? Color.white : deepPurple)
                                        : Color(uiColor: .secondaryLabel)
                                )
                                .scaleEffect(isSelected ? 1.06 : 1.0)
                            
                            Text(tab.title)
                                .font(.pjs(10, weight: isSelected ? .bold : .medium))
                                .foregroundColor(
                                    isSelected
                                        ? (colorScheme == .dark ? Color.white : deepPurple)
                                        : Color(uiColor: .secondaryLabel)
                                )
                            
                            // Golden/Yellow Indicator Dot Under Active Tab
                            if isSelected {
                                Circle()
                                    .fill(goldAccent)
                                    .frame(width: 4, height: 4)
                                    .transition(.scale.combined(with: .opacity))
                            } else {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 4, height: 4)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .scaleEffect(pressedTab == tab ? 0.94 : 1.0)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(tab.title) Tab")
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .frame(height: 64)
        // Authentic White / Frosted Glass Floating Capsule
        .background {
            Capsule()
                .fill(
                    colorScheme == .dark
                        ? Color(red: 0.14, green: 0.14, blue: 0.18).opacity(0.95)
                        : Color.white.opacity(0.96)
                )
                .background(
                    Capsule().fill(.ultraThinMaterial)
                )
        }
        // Hairline Specular Border
        .overlay {
            Capsule()
                .stroke(
                    colorScheme == .dark
                        ? Color.white.opacity(0.12)
                        : Color.black.opacity(0.04),
                    lineWidth: 0.8
                )
        }
        // Diffuse Floating Drop Shadow
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.08),
            radius: 16,
            x: 0,
            y: 6
        )
    }
}

// MARK: - Global Reusable Filter Chip
public struct FilterChip: View {
    @ObservedObject private var theme = ThemeManager.shared
    @Environment(\.colorScheme) private var colorScheme
    public var title: String
    public var isSelected: Bool
    public var action: () -> Void
    
    public init(title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background {
                    if isSelected {
                        Capsule().fill(Color(red: 0.18, green: 0.08, blue: 0.28))
                    } else {
                        Capsule().fill(theme.cardBackground).overlay(Capsule().stroke(theme.glassBorderColor, lineWidth: 1))
                    }
                }
        }
        .buttonStyle(.plain)
    }
}
