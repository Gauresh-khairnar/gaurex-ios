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
    @Namespace private var tabAnimationNamespace
    
    // 5 primary Apple-style tabs (Home, Tasks, Clients, Finance, AI Advisor)
    private let displayTabs: [MainTab] = [.home, .tasks, .clients, .finance, .aiModel]
    
    public init(selectedTab: Binding<MainTab>) {
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(displayTabs) { tab in
                let isSelected = selectedTab == tab
                
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        selectedTab = tab
                    }
                } label: {
                    ZStack {
                        // Apple-style active oval/capsule glow
                        if isSelected {
                            Capsule()
                                .fill(theme.accentColor.opacity(0.18))
                                .overlay(
                                    Capsule()
                                        .stroke(theme.accentColor.opacity(0.35), lineWidth: 1)
                                )
                                .matchedGeometryEffect(id: "ACTIVE_TAB_PILL", in: tabAnimationNamespace)
                                .shadow(color: theme.accentColor.opacity(0.12), radius: 8, x: 0, y: 2)
                        }
                        
                        VStack(spacing: 3) {
                            Image(systemName: isSelected ? tab.selectedIconName : tab.iconName)
                                .font(.system(size: 19, weight: isSelected ? .semibold : .medium))
                                .foregroundColor(isSelected ? theme.accentColor : Color.primary.opacity(0.65))
                                .scaleEffect(isSelected ? 1.08 : 1.0)
                            
                            Text(tab.title)
                                .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? theme.accentColor : Color.primary.opacity(0.65))
                                .lineLimit(1)
                        }
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 52)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(tab.title) Tab")
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.35),
                                    Color.white.opacity(0.12),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.14), radius: 20, x: 0, y: 8)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}
