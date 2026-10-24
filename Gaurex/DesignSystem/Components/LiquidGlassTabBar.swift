//
//  LiquidGlassTabBar.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Authentic Apple iOS 18 Liquid Glass Tab Bar Primitives
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
    @ObservedObject private var store = FirestoreDataStore.shared
    @Namespace private var liquidSliderNamespace
    
    public init(selectedTab: Binding<MainTab>) {
        self._selectedTab = selectedTab
    }
    
    private var pendingTasksCount: Int {
        store.tasks.filter { $0.status == .pending }.count
    }
    
    public var body: some View {
        HStack(spacing: 2) {
            ForEach(MainTab.allCases) { tab in
                let isSelected = selectedTab == tab
                
                Button {
                    let feedback = UISelectionFeedbackGenerator()
                    feedback.selectionChanged()
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.74, blendDuration: 0.12)) {
                        selectedTab = tab
                    }
                } label: {
                    ZStack {
                        // Apple Viscoelastic Liquid Slider Pill
                        if isSelected {
                            Capsule()
                                .fill(.thinMaterial)
                                .overlay(
                                    Capsule()
                                        .fill(theme.accentColor.opacity(0.14))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.55),
                                                    theme.accentColor.opacity(0.35),
                                                    Color.white.opacity(0.15)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                                .matchedGeometryEffect(id: "APPLE_LIQUID_SLIDER_ACTIVE_PILL", in: liquidSliderNamespace)
                                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
                                .shadow(color: theme.accentColor.opacity(0.15), radius: 6, x: 0, y: 1)
                        }
                        
                        VStack(spacing: 3) {
                            ZStack(alignment: .topTrailing) {
                                Group {
                                    if #available(iOS 17.0, *) {
                                        Image(systemName: isSelected ? tab.selectedIconName : tab.iconName)
                                            .font(.system(size: 17, weight: isSelected ? .semibold : .medium))
                                            .symbolEffect(.bounce, value: isSelected)
                                            .contentTransition(.symbolEffect(.replace))
                                    } else {
                                        Image(systemName: isSelected ? tab.selectedIconName : tab.iconName)
                                            .font(.system(size: 17, weight: isSelected ? .semibold : .medium))
                                    }
                                }
                                .foregroundColor(isSelected ? theme.accentColor : Color(uiColor: .secondaryLabel))
                                .scaleEffect(isSelected ? 1.08 : 1.0)
                                
                                // Tab badge for pending tasks
                                if tab == .tasks && pendingTasksCount > 0 {
                                    Circle()
                                        .fill(theme.accentColor)
                                        .frame(width: 6, height: 6)
                                        .offset(x: 5, y: -2)
                                }
                            }
                            
                            Text(tab.title)
                                .font(.system(size: 9.5, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? theme.accentColor : Color(uiColor: .secondaryLabel))
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
            // Apple Native Liquid Glass Container
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.40),
                                    Color.white.opacity(0.12),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.8
                        )
                )
                .shadow(color: Color.black.opacity(0.15), radius: 18, x: 0, y: 8)
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 6)
    }
}
