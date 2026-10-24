//
//  LiquidGlassTabBar.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public enum MainTab: Int, CaseIterable, Identifiable {
    case home = 0
    case tasks = 1
    case finance = 2
    case clients = 3
    case workers = 4
    case aiModel = 5
    case settings = 6
    
    public var id: Int { rawValue }
    
    public var title: String {
        switch self {
        case .home: return "Home"
        case .tasks: return "Tasks"
        case .finance: return "Finance"
        case .clients: return "Clients"
        case .workers: return "Team"
        case .aiModel: return "AI Advisor"
        case .settings: return "Settings"
        }
    }
    
    public var iconName: String {
        switch self {
        case .home: return "house"
        case .tasks: return "checklist"
        case .finance: return "chart.pie"
        case .clients: return "person.2"
        case .workers: return "person.badge.shield.checkmark"
        case .aiModel: return "sparkles"
        case .settings: return "slider.horizontal.3"
        }
    }
    
    public var selectedIconName: String {
        switch self {
        case .home: return "house.fill"
        case .tasks: return "checklist.checked"
        case .finance: return "chart.pie.fill"
        case .clients: return "person.2.fill"
        case .workers: return "person.badge.shield.checkmark.fill"
        case .aiModel: return "sparkles"
        case .settings: return "slider.horizontal.3"
        }
    }
}

public struct LiquidGlassTabBar: View {
    @Binding public var selectedTab: MainTab
    @ObservedObject private var theme = ThemeManager.shared
    
    // 5 primary Apple-style tabs (Home, Tasks, Clients, Finance, AI Advisor)
    public let displayTabs: [MainTab] = [.home, .tasks, .clients, .finance, .aiModel]
    
    @State private var previousTabIndex: Int = 0
    @State private var isLiquidStretching: Bool = false
    @State private var stretchDirection: CGFloat = 1.0 // 1: right, -1: left
    
    public init(selectedTab: Binding<MainTab>) {
        self._selectedTab = selectedTab
    }
    
    private var activeIndex: Int {
        displayTabs.firstIndex(of: selectedTab) ?? 0
    }
    
    public var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let tabCount = CGFloat(displayTabs.count)
            let itemWidth = totalWidth / tabCount
            let pillWidth = itemWidth - 6
            let pillHeight: CGFloat = 46
            let targetX = CGFloat(activeIndex) * itemWidth + 3
            
            ZStack(alignment: .leading) {
                // MARK: - Apple Liquid Slider Pill (Viscoelastic Fluid Morphing)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                theme.accentColor.opacity(0.24),
                                theme.accentColor.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        theme.accentColor.opacity(0.65),
                                        theme.accentColor.opacity(0.25),
                                        Color.white.opacity(0.40)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    )
                    .shadow(color: theme.accentColor.opacity(0.28), radius: 10, x: 0, y: 3)
                    .frame(width: pillWidth, height: pillHeight)
                    // Viscoelastic stretch during movement
                    .scaleEffect(
                        x: isLiquidStretching ? 1.24 : 1.0,
                        y: isLiquidStretching ? 0.90 : 1.0,
                        anchor: stretchDirection > 0 ? .leading : .trailing
                    )
                    .offset(x: targetX, y: 4)
                    .animation(.interpolatingSpring(mass: 0.7, stiffness: 280, damping: 20), value: activeIndex)
                    .animation(.spring(response: 0.28, dampingFraction: 0.65), value: isLiquidStretching)
                
                // MARK: - Interactive Tab Items
                HStack(spacing: 0) {
                    ForEach(displayTabs) { tab in
                        let isSelected = selectedTab == tab
                        
                        Button {
                            switchTab(to: tab)
                        } label: {
                            VStack(spacing: 3) {
                                Image(systemName: isSelected ? tab.selectedIconName : tab.iconName)
                                    .font(.system(size: 19, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(isSelected ? theme.accentColor : Color.primary.opacity(0.60))
                                    .scaleEffect(isSelected ? 1.12 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                                
                                Text(tab.title)
                                    .font(.system(size: 10.5, weight: isSelected ? .bold : .medium, design: .rounded))
                                    .foregroundColor(isSelected ? theme.accentColor : Color.primary.opacity(0.60))
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(tab.title) Tab")
                    }
                }
            }
            .frame(height: 54)
        }
        .frame(height: 54)
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background {
            // Apple Floating Frosted Liquid Glass Capsule
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.40),
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.04),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                        .padding(1)
                )
                .shadow(color: Color.black.opacity(0.16), radius: 24, x: 0, y: 10)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    private func switchTab(to newTab: MainTab) {
        guard selectedTab != newTab else { return }
        
        let oldIdx = activeIndex
        let newIdx = displayTabs.firstIndex(of: newTab) ?? 0
        
        stretchDirection = newIdx >= oldIdx ? 1.0 : -1.0
        isLiquidStretching = true
        
        // Apple Taptic feedback
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.impactOccurred()
        
        selectedTab = newTab
        previousTabIndex = newIdx
        
        // Reset fluid stretch after slide
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            isLiquidStretching = false
        }
    }
}
