//
//  LiquidGlassTabBar.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public enum MainTab: Int, CaseIterable, Identifiable {
    case home = 0
    case clients = 1
    case workers = 2
    case aiModel = 3
    case settings = 4
    
    public var id: Int { rawValue }
    
    public var title: String {
        switch self {
        case .home: return "Home"
        case .clients: return "Clients"
        case .workers: return "Workers"
        case .aiModel: return "AI Model"
        case .settings: return "Settings"
        }
    }
    
    public var iconName: String {
        switch self {
        case .home: return "square.grid.2x2"
        case .clients: return "person.2"
        case .workers: return "person.badge.shield.checkmark"
        case .aiModel: return "sparkles"
        case .settings: return "slider.horizontal.3"
        }
    }
    
    public var selectedIconName: String {
        switch self {
        case .home: return "square.grid.2x2.fill"
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
        HStack(spacing: 4) {
            ForEach(MainTab.allCases) { tab in
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == tab ? tab.selectedIconName : tab.iconName)
                            .font(.system(size: 18, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundColor(selectedTab == tab ? theme.accentColor : .secondary)
                            .scaleEffect(selectedTab == tab ? 1.08 : 1.0)
                        
                        Text(tab.title)
                            .font(.system(size: 10, weight: selectedTab == tab ? .bold : .medium))
                            .foregroundColor(selectedTab == tab ? .primary : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background {
                        if selectedTab == tab {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(theme.cardBackground.opacity(0.85))
                                .matchedGeometryEffect(id: "ACTIVE_TAB_PILL", in: tabAnimationNamespace)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(theme.glassBorderColor, lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(theme.glassBorderColor, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }
}
