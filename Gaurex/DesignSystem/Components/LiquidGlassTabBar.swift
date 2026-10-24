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
        case .aiModel: return "AI"
        case .settings: return "Settings"
        }
    }
    
    public var iconName: String {
        switch self {
        case .home: return "house"
        case .tasks: return "checklist"
        case .finance: return "chart.pie"
        case .clients: return "person.2"
        case .workers: return "person.3"
        case .aiModel: return "sparkles"
        case .settings: return "gearshape"
        }
    }
    
    public var selectedIconName: String {
        switch self {
        case .home: return "house.fill"
        case .tasks: return "checklist.checked"
        case .finance: return "chart.pie.fill"
        case .clients: return "person.2.fill"
        case .workers: return "person.3.fill"
        case .aiModel: return "sparkles"
        case .settings: return "gearshape.fill"
        }
    }
}

public struct LiquidGlassTabBar: View {
    @Binding public var selectedTab: MainTab
    @ObservedObject private var theme = ThemeManager.shared
    @Namespace private var liquidSliderNamespace
    
    public init(selectedTab: Binding<MainTab>) {
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        HStack(spacing: 2) {
            ForEach(MainTab.allCases) { tab in
                let isSelected = selectedTab == tab
                
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    withAnimation(.spring(response: 0.36, dampingFraction: 0.72, blendDuration: 0.15)) {
                        selectedTab = tab
                    }
                } label: {
                    ZStack {
                        // Original Apple liquid slider pill
                        if isSelected {
                            Capsule()
                                .fill(theme.cardBackground.opacity(0.92))
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.40),
                                                    theme.accentColor.opacity(0.35),
                                                    Color.white.opacity(0.15)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                                .overlay(
                                    Capsule()
                                        .fill(theme.accentColor.opacity(0.14))
                                )
                                .matchedGeometryEffect(id: "ORIGINAL_APPLE_LIQUID_SLIDER", in: liquidSliderNamespace)
                                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
                                .shadow(color: theme.accentColor.opacity(0.15), radius: 6, x: 0, y: 1)
                        }
                        
                        VStack(spacing: 3) {
                            Image(systemName: isSelected ? tab.selectedIconName : tab.iconName)
                                .font(.system(size: 17, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? theme.accentColor : Color.primary.opacity(0.65))
                                .scaleEffect(isSelected ? 1.08 : 1.0)
                            
                            Text(tab.title)
                                .font(.system(size: 9, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? theme.accentColor : Color.primary.opacity(0.65))
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }
                        .padding(.vertical, 7)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 50)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(tab.title) Tab")
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 3)
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
                .shadow(color: Color.black.opacity(0.16), radius: 20, x: 0, y: 8)
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 6)
    }
}
