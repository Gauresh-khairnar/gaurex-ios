//
//  DesignComponents.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

// MARK: - Glass Card
public struct GlassCard<Content: View>: View {
    @ObservedObject private var theme = ThemeManager.shared
    private let content: Content
    private var padding: CGFloat
    
    public init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(theme.glassBorderColor, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
            }
    }
}

// MARK: - Metric Card
public struct MetricCard: View {
    @ObservedObject private var theme = ThemeManager.shared
    public var title: String
    public var value: String
    public var subtitle: String?
    public var icon: String
    public var trendPercentage: Double?
    public var accentColor: Color?
    
    public init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String,
        trendPercentage: Double? = nil,
        accentColor: Color? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.trendPercentage = trendPercentage
        self.accentColor = accentColor
    }
    
    public var body: some View {
        GlassCard(padding: 14) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(accentColor ?? theme.accentColor)
                        .padding(7)
                        .background((accentColor ?? theme.accentColor).opacity(0.12))
                        .clipShape(Circle())
                    
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if let trend = trendPercentage {
                        HStack(spacing: 2) {
                            Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.system(size: 9, weight: .bold))
                            Text(String(format: "%.1f%%", abs(trend)))
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(trend >= 0 ? .green : .red)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background((trend >= 0 ? Color.green : Color.red).opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                if let sub = subtitle {
                    Text(sub)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }
}

// MARK: - Owner Badge
public struct OwnerBadge: View {
    public var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.25))
            
            Text("OWNER")
                .font(.system(size: 10, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .tracking(1.2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.black, Color(red: 0.15, green: 0.15, blue: 0.18)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Capsule()
                        .stroke(Color(red: 0.95, green: 0.77, blue: 0.25).opacity(0.4), lineWidth: 1)
                )
        }
    }
}

// MARK: - Status Badge
public struct StatusBadge: View {
    public var text: String
    public var color: Color
    
    public init(text: String, color: Color) {
        self.text = text
        self.color = color
    }
    
    public var body: some View {
        Text(text.uppercased())
            .font(.system(size: 9, weight: .bold, design: .rounded))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3.5)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.25), lineWidth: 0.8)
            )
    }
}

// MARK: - Empty State View
public struct EmptyStateView: View {
    @ObservedObject private var theme = ThemeManager.shared
    public var icon: String
    public var title: String
    public var description: String
    public var actionTitle: String?
    public var action: (() -> Void)?
    
    public init(
        icon: String,
        title: String,
        description: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 44, weight: .light))
                .foregroundColor(.secondary.opacity(0.7))
                .padding(20)
                .background(theme.cardBackground)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(theme.glassBorderColor, lineWidth: 1)
                )
            
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            if let actTitle = actionTitle, let act = action {
                Button(action: act) {
                    Text(actTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.primary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Date Filter Bar
public enum DateRangeFilter: String, CaseIterable, Identifiable {
    case sevenDays = "7 Days"
    case thirtyDays = "30 Days"
    case ninetyDays = "90 Days"
    case thisMonth = "This Month"
    case thisYear = "This Year"
    
    public var id: String { rawValue }
}

public struct DateFilterBar: View {
    @Binding public var selectedFilter: DateRangeFilter
    @ObservedObject private var theme = ThemeManager.shared
    
    public init(selectedFilter: Binding<DateRangeFilter>) {
        self._selectedFilter = selectedFilter
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(DateRangeFilter.allCases) { filter in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = filter
                        }
                    } label: {
                        Text(filter.rawValue)
                            .font(.system(size: 12, weight: selectedFilter == filter ? .bold : .medium))
                            .foregroundColor(selectedFilter == filter ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background {
                                if selectedFilter == filter {
                                    Capsule()
                                        .fill(Color.primary)
                                } else {
                                    Capsule()
                                        .fill(theme.cardBackground)
                                        .overlay(Capsule().stroke(theme.glassBorderColor, lineWidth: 1))
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
