//
//  FounderCommandCenterView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct FounderCommandCenterView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    
    @State private var showingHealthScoreDetails = false
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Section Title
            HStack {
                Text("FOUNDER COMMAND & GOALS")
                    .font(TypographyTokens.sectionHeader)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 24)
            
            // Health Score Card
            let health = store.businessHealthScore
            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("BUSINESS HEALTH SCORE")
                                .font(TypographyTokens.caption)
                                .foregroundColor(.secondary)
                            Text(healthScoreRating(score: health.overallScore))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(healthScoreColor(score: health.overallScore))
                        }
                        
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .stroke(Color.secondary.opacity(0.15), lineWidth: 5)
                                .frame(width: 48, height: 48)
                            Circle()
                                .trim(from: 0, to: CGFloat(health.overallScore) / 100.0)
                                .stroke(healthScoreColor(score: health.overallScore), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .frame(width: 48, height: 48)
                            
                            Text("\(health.overallScore)")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                        }
                    }
                    
                    Divider().background(theme.glassBorderColor)
                    
                    // Transparent Factor Indicators
                    HStack(spacing: 8) {
                        HealthFactorPill(title: "Revenue", pts: "\(health.revenueScore)/30")
                        HealthFactorPill(title: "Pipeline", pts: "\(health.pipelineScore)/20")
                        HealthFactorPill(title: "Expenses", pts: "\(health.expenseControlScore)/15")
                        HealthFactorPill(title: "Execution", pts: "\(health.executionScore)/15")
                    }
                }
            }
            .padding(.horizontal, 24)
            .tactilePress(scale: MotionTokens.cardPressScale)
            .onTapGesture {
                showingHealthScoreDetails = true
            }
            
            // Business Goals Progress
            VStack(spacing: 8) {
                ForEach(store.businessGoals) { goal in
                    GlassCard(padding: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: goal.metricType.icon)
                                    .font(.system(size: 12))
                                    .foregroundColor(theme.accentColor)
                                Text(goal.title)
                                    .font(.system(size: 13, weight: .semibold))
                                Spacer()
                                Text(goal.percentageString)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(theme.accentColor)
                            }
                            
                            ProgressView(value: goal.progressFraction)
                                .tint(goal.progressFraction >= 1.0 ? Color.green : Color.blue)
                            
                            HStack {
                                if goal.metricType == .newClients {
                                    Text("Current: \(Int(goal.currentValue)) Clients")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("Target: \(Int(goal.targetValue)) Clients")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.secondary)
                                } else if goal.metricType == .dealsClosed {
                                    Text("Current: \(Int(goal.currentValue)) Deals")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("Target: \(Int(goal.targetValue)) Deals")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Current: \(FinancialCalculator.shared.formatCurrency(goal.currentValue, symbol: store.settings.currencySymbol))")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("Target: \(FinancialCalculator.shared.formatCurrency(goal.targetValue, symbol: store.settings.currencySymbol))")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .sheet(isPresented: $showingHealthScoreDetails) {
            HealthScoreExplanationSheet(breakdown: store.businessHealthScore)
        }
    }
    
    private func healthScoreRating(score: Int) -> String {
        if score >= 85 { return "Optimal Executive Health" }
        if score >= 70 { return "Healthy Growth Trajectory" }
        if score >= 50 { return "Moderate Operational Risk" }
        return "Action Required"
    }
    
    private func healthScoreColor(score: Int) -> Color {
        if score >= 80 { return .green }
        if score >= 60 { return .blue }
        if score >= 40 { return .orange }
        return .red
    }
}

public struct HealthFactorPill: View {
    @ObservedObject private var theme = ThemeManager.shared
    public var title: String
    public var pts: String
    
    public var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
            Text(pts)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        .background(theme.backgroundColor.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

public struct HealthScoreExplanationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var theme = ThemeManager.shared
    public var breakdown: HealthScoreBreakdown
    
    public var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Executive Health Methodology")
                                        .font(.system(size: 16, weight: .bold))
                                    Spacer()
                                    Text("\(breakdown.overallScore)/100")
                                        .font(.system(size: 20, weight: .black, design: .rounded))
                                }
                                Text("This score provides a transparent, quantifiable snapshot of GAUREX business operations based on authentic ledger entries. It is an internal executive metric, not a third-party credit rating.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Text("FACTOR BREAKDOWN")
                            .font(TypographyTokens.sectionHeader)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 8) {
                            ForEach(breakdown.explanations, id: \.self) { exp in
                                GlassCard(padding: 12) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "checkmark.shield.fill")
                                            .foregroundColor(.blue)
                                        Text(exp)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Health Score Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
            }
        }
    }
}
