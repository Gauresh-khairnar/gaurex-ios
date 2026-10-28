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
    
    public init(selectedTab: Binding<MainTab>) {
        self._selectedTab = selectedTab
    }
    
    private let deepPurple = Color(red: 0.18, green: 0.08, blue: 0.28)
    private let goldAccent = Color(red: 0.90, green: 0.65, blue: 0.15)
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.bottomBarTabs) { tab in
                let isSelected = selectedTab == tab
                
                if tab == .aiModel {
                    // MARK: - Center Elevated AI Co-Founder Action Button
                    Button {
                        let feedback = UIImpactFeedbackGenerator(style: .medium)
                        feedback.impactOccurred()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                            selectedTab = .aiModel
                        }
                    } label: {
                        VStack(spacing: 2) {
                            ZStack {
                                // Subtle Breathing Halo Ring
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color(red: 0.55, green: 0.30, blue: 0.75).opacity(aiHaloPulse ? 0.35 : 0.15),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 10,
                                            endRadius: 36
                                        )
                                    )
                                    .frame(width: 62, height: 62)
                                
                                // Elevated Gradient Circle
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.24, green: 0.10, blue: 0.36),
                                                Color(red: 0.14, green: 0.05, blue: 0.22)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                    )
                                    .shadow(
                                        color: Color(red: 0.24, green: 0.10, blue: 0.36).opacity(0.40),
                                        radius: 10,
                                        x: 0,
                                        y: 5
                                    )
                                
                                Image(systemName: "sparkles")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                    .scaleEffect(isSelected ? 1.08 : 1.0)
                            }
                            
                            Text("AI")
                                .font(.system(size: 9.5, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? deepPurple : Color(uiColor: .secondaryLabel))
                        }
                        .frame(maxWidth: .infinity)
                        .offset(y: -10)
                        .scaleEffect(pressedTab == tab ? 0.92 : 1.0)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                            aiHaloPulse = true
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
                                .font(.system(size: 10, weight: isSelected ? .bold : .medium))
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
