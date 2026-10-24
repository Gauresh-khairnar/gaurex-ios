//
//  LiquidGlassTabBar.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Apple Music Style Navigation Bar & Executive HUD in GAUREX Luxury Aesthetic
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
    @ObservedObject private var aiService = AIService.shared
    @State private var isExecutiveHUDVisible: Bool = true
    @Namespace private var liquidSliderNamespace
    
    public init(selectedTab: Binding<MainTab>) {
        self._selectedTab = selectedTab
    }
    
    private var pendingTasksCount: Int {
        store.tasks.filter { $0.status == .pending }.count
    }
    
    private var currentContext: AIAnalysisContext {
        aiService.buildAnalysisContext()
    }
    
    public var body: some View {
        VStack(spacing: 5) {
            // MARK: - Apple Music Style Executive Now-Playing Mini-Player HUD
            if isExecutiveHUDVisible && selectedTab != .aiModel {
                AppleMusicExecutiveHUD(
                    context: currentContext,
                    onTap: {
                        let feedback = UISelectionFeedbackGenerator()
                        feedback.selectionChanged()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedTab = .aiModel
                        }
                    },
                    onDismiss: {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.8)) {
                            isExecutiveHUDVisible = false
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
            }
            
            // MARK: - Apple Music Style 7-Tab Floating Liquid Glass Navigation Bar
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
                                    .shadow(color: theme.accentColor.opacity(0.16), radius: 6, x: 0, y: 1)
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
                                    
                                    // Apple-style subtle notification badge dot for pending tasks
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
}

// MARK: - Apple Music Style Executive Now-Playing Mini-Player HUD
public struct AppleMusicExecutiveHUD: View {
    public var context: AIAnalysisContext
    public var onTap: () -> Void
    public var onDismiss: () -> Void
    @ObservedObject private var theme = ThemeManager.shared
    
    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                // Apple Music Album Artwork-style Thumbnail (Fortuner Milestone)
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    theme.accentColor.opacity(0.85),
                                    Color.black.opacity(0.90)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                        .overlay(
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .stroke(Color.white.opacity(0.35), lineWidth: 0.8)
                        )
                        .shadow(color: theme.accentColor.opacity(0.3), radius: 6, x: 0, y: 2)
                    
                    Image(systemName: "car.side.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Track Info / Milestone Title & Progress
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Text("Toyota Fortuner 4M Sprint")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Circle()
                            .fill(Color.green)
                            .frame(width: 5, height: 5)
                    }
                    
                    HStack(spacing: 4) {
                        Text("\(context.currencySymbol)\(String(format: "%.0f", context.revenueCollected)) / ₹50L")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(theme.accentColor)
                        
                        Text("•")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                        
                        Text("Req: \(context.currencySymbol)\(String(format: "%.0f", context.fortunerRequiredDailyRunRate))/day")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .lineLimit(1)
                    
                    // Micro Progress Bar (like track elapsed time line)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.primary.opacity(0.10))
                                .frame(height: 2.5)
                            
                            Capsule()
                                .fill(theme.accentColor)
                                .frame(width: max(4, geo.size.width * CGFloat(context.fortunerCompletionPercentage)), height: 2.5)
                        }
                    }
                    .frame(height: 2.5)
                }
                
                Spacer(minLength: 4)
                
                // Apple Music Mini Controls (Ask AI & Chevron)
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.accentColor)
                        .frame(width: 28, height: 28)
                        .background(theme.accentColor.opacity(0.12))
                        .clipShape(Circle())
                    
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                            .frame(width: 20, height: 20)
                            .background(Color.primary.opacity(0.06))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.35),
                                        Color.white.opacity(0.10)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.8
                            )
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)
            }
            .padding(.horizontal, 10)
        }
        .buttonStyle(.plain)
    }
}
