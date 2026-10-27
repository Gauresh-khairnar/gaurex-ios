//
//  LiquidGlassTabBar.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Genuine Apple Native Liquid Glass Floating Tab Bar
//  Faithful Native Swift/SwiftUI Port of Liquid Glass Bottom Bar Specifications
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
    @Environment(\.colorScheme) private var colorScheme
    @State private var pressedTab: MainTab? = nil
    
    public init(selectedTab: Binding<MainTab>) {
        self._selectedTab = selectedTab
    }
    
    private var pendingTasksCount: Int {
        store.tasks.filter { $0.status == .pending }.count
    }
    
    public var body: some View {
        HStack(spacing: 0) {
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
                        // Liquid Glass Viscoelastic Sliding Selection Pill
                        if isSelected {
                            Capsule()
                                .fill(
                                    colorScheme == .dark
                                        ? Color.white.opacity(0.12)
                                        : Color.black.opacity(0.06)
                                )
                                .overlay(
                                    Capsule()
                                        .fill(theme.accentColor.opacity(colorScheme == .dark ? 0.20 : 0.12))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            theme.accentColor.opacity(colorScheme == .dark ? 0.35 : 0.22),
                                            lineWidth: 0.8
                                        )
                                )
                                .matchedGeometryEffect(id: "LIQUID_GLASS_SELECTION_PILL", in: liquidSliderNamespace)
                                .padding(.horizontal, 2)
                                .padding(.vertical, 4)
                        }
                        
                        // Tab Item (Icon + Label)
                        VStack(spacing: 2) {
                            ZStack(alignment: .topTrailing) {
                                Group {
                                    if #available(iOS 17.0, *) {
                                        Image(systemName: isSelected ? tab.selectedIconName : tab.iconName)
                                            .font(.system(size: 19, weight: isSelected ? .semibold : .medium))
                                            .symbolEffect(.bounce, value: isSelected)
                                            .contentTransition(.symbolEffect(.replace))
                                    } else {
                                        Image(systemName: isSelected ? tab.selectedIconName : tab.iconName)
                                            .font(.system(size: 19, weight: isSelected ? .semibold : .medium))
                                    }
                                }
                                .foregroundColor(
                                    isSelected
                                        ? theme.accentColor
                                        : (colorScheme == .dark ? Color.white.opacity(0.62) : Color.black.opacity(0.60))
                                )
                                
                                // Live Task Pending Badge Indicator Dot
                                if tab == .tasks && pendingTasksCount > 0 {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 6, height: 6)
                                        .offset(x: 5, y: -2)
                                }
                            }
                            
                            Text(tab.title)
                                .font(.system(size: 9.5, weight: isSelected ? .bold : .medium))
                                .foregroundColor(
                                    isSelected
                                        ? theme.accentColor
                                        : (colorScheme == .dark ? Color.white.opacity(0.62) : Color.black.opacity(0.60))
                                )
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .scaleEffect(pressedTab == tab ? 0.92 : 1.0)
                    }
                    .frame(height: 52)
                    .contentShape(Rectangle())
                }
                .buttonStyle(TabItemButtonStyle(onPress: { isPressed in
                    withAnimation(.easeOut(duration: 0.12)) {
                        pressedTab = isPressed ? tab : nil
                    }
                }))
                .accessibilityLabel("\(tab.title) Tab")
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .frame(height: 60)
        // Liquid Glass Capsule Base & Refraction Material
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .fill(
                            colorScheme == .dark
                                ? Color.white.opacity(0.06)
                                : Color.white.opacity(0.25)
                        )
                )
        }
        // Fresnel Specular Gradient Rim (1.0pt stroke at -45° virtual light angle)
        .overlay {
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(colorScheme == .dark ? 0.40 : 0.65),
                            Color.white.opacity(colorScheme == .dark ? 0.08 : 0.15),
                            Color.white.opacity(colorScheme == .dark ? 0.22 : 0.35)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.0
                )
        }
        // Dual Soft Floating Shadows (Contact shadow + Key light shadow)
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.08),
            radius: 8,
            x: 0,
            y: 4
        )
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.45 : 0.12),
            radius: 20,
            x: 0,
            y: 10
        )
    }
}

// Custom ButtonStyle to capture press-down and release for the 0.92 scale feedback
private struct TabItemButtonStyle: ButtonStyle {
    let onPress: (Bool) -> Void
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                onPress(newValue)
            }
    }
}
