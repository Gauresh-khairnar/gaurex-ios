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
        case .home: return "square.grid.2x2"
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
        case .home: return "square.grid.2x2.fill"
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
    
    public init(selectedTab: Binding<MainTab>) {
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        HStack(spacing: 2) {
            ForEach(MainTab.allCases) { tab in
                Button {
                    MotionTokens.selection()
                    withAnimation(MotionTokens.interactiveSpring) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: selectedTab == tab ? tab.selectedIconName : tab.iconName)
                            .font(.system(size: 16, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundColor(selectedTab == tab ? theme.accentColor : .secondary)
                            .scaleEffect(selectedTab == tab ? 1.08 : 1.0)
                        
                        Text(tab.title)
                            .font(.system(size: 8.5, weight: selectedTab == tab ? .bold : .medium))
                            .foregroundColor(selectedTab == tab ? .primary : .secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background {
                        if selectedTab == tab {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(theme.cardBackground.opacity(0.88))
                                .matchedGeometryEffect(id: "ACTIVE_TAB_PILL", in: tabAnimationNamespace)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(theme.glassBorderColor, lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(tab.title) Tab")
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(theme.glassBorderColor, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 6)
    }
}
