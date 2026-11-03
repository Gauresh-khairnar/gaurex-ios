//
//  WarGameCommandCenterView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Executive Founder War Game Simulation & Crisis Command Center
//

import SwiftUI

public struct WarGameCommandCenterView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var defconLevel: Int = 1
    @State private var selectedScenario: WarGameScenario = .churnBlackSwan
    @State private var simulatedDelayedClients: Double = 2.0
    @State private var simulatedBurnCutPercent: Double = 20.0
    @State private var newConquestContracts: Double = 3.0
    @State private var isDrillExecuting: Bool = false
    @State private var drillResultMessage: String? = nil
    
    public enum WarGameScenario: String, CaseIterable, Identifiable {
        case churnBlackSwan = "Black Swan Churn (-30%)"
        case freezeCollections = "30-Day Payment Freeze"
        case conquestSurge = "Revenue Conquest Blitz"
        case burnDefense = "Surgical Burn Cut"
        
        public var id: String { rawValue }
        
        public var icon: String {
            switch self {
            case .churnBlackSwan: return "exclamationmark.triangle.fill"
            case .freezeCollections: return "snowflake"
            case .conquestSurge: return "bolt.shield.fill"
            case .burnDefense: return "scissors"
            }
        }
    }
    
    public init() {}
    
    // Real-Time War Game Computation
    private var baseInflow: Double {
        store.revenueCollected
    }
    
    private var baseMonthlyBurn: Double {
        max(1.0, store.allOperationalExpenses)
    }
    
    private var simulatedInflow: Double {
        switch selectedScenario {
        case .churnBlackSwan:
            return baseInflow * 0.70
        case .freezeCollections:
            return max(0.0, baseInflow - (simulatedDelayedClients * 350000.0))
        case .conquestSurge:
            return baseInflow + (newConquestContracts * 450000.0)
        case .burnDefense:
            return baseInflow
        }
    }
    
    private var simulatedBurn: Double {
        switch selectedScenario {
        case .burnDefense:
            return baseMonthlyBurn * (1.0 - (simulatedBurnCutPercent / 100.0))
        default:
            return baseMonthlyBurn
        }
    }
    
    private var simulatedRunwayMonths: Double {
        guard simulatedBurn > 0 else { return 48.0 }
        return min(60.0, (simulatedInflow / simulatedBurn) * 3.5)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Military tactical dark background
                Color(red: 0.05, green: 0.05, blue: 0.07).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        
                        // Header Status Pill
                        HStack {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(defconColor)
                                    .frame(width: 8, height: 8)
                                Text("DEFCON \(theme.warGameDefconLevel) : \(defconTitle.uppercased())")
                                    .font(.system(size: 11, weight: .black))
                                    .foregroundColor(defconColor)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(defconColor.opacity(0.15))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(defconColor.opacity(0.4), lineWidth: 1))
                            
                            Spacer()
                            
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .padding(.top, 8)
                        
                        // Tactical Simulation Hero Screen
                        tacticalDisplayCard
                        
                        // Scenario Selector Tabs
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SELECT COMBAT DRILL")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(WarGameScenario.allCases) { scn in
                                        let isSel = selectedScenario == scn
                                        Button {
                                            selectedScenario = scn
                                            GaurexSoundEffectsService.shared.playStealthModeClick()
                                        } label: {
                                            HStack(spacing: 6) {
                                                Image(systemName: scn.icon)
                                                Text(scn.rawValue)
                                            }
                                            .font(.system(size: 12, weight: isSel ? .bold : .medium))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(isSel ? Color.gaurexWarmGold : Color.white.opacity(0.08))
                                            .foregroundColor(isSel ? .black : .white)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        
                        // Dynamic Parameter Sliders
                        scenarioControlsCard
                        
                        // DEFCON Threat Level Selector
                        defconLevelPicker
                        
                        // Action Drills
                        VStack(spacing: 10) {
                            Button {
                                executeCombatDrill()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "shield.checkered")
                                    Text(isDrillExecuting ? "EXECUTING COUNTER-MEASURES..." : "DEPLOY DEFENSIVE COUNTER-MEASURES")
                                        .font(.system(size: 13, weight: .heavy))
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.gaurexWarmGold)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(.plain)
                            .disabled(isDrillExecuting)
                            
                            if let res = drillResultMessage {
                                Text(res)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.green)
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding(.top, 6)
                        
                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("War Game Simulation")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Subviews
    private var tacticalDisplayCard: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.12, green: 0.05, blue: 0.14), Color(red: 0.06, green: 0.03, blue: 0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.gaurexWarmGold.opacity(0.4), lineWidth: 1.2)
                )
            
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("PROJECTED WAR RUNWAY")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.gaurexWarmGold)
                        Text(String(format: "%.1f Months", simulatedRunwayMonths))
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Image(systemName: "cross.vial.fill")
                        .font(.system(size: 32))
                        .foregroundColor(defconColor.opacity(0.8))
                }
                
                Divider().background(Color.white.opacity(0.15))
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Simulated Inflow")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.6))
                        Text(FinancialCalculator.shared.formatCurrency(simulatedInflow, symbol: store.settings.currencySymbol))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Simulated Burn")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.6))
                        Text(FinancialCalculator.shared.formatCurrency(simulatedBurn, symbol: store.settings.currencySymbol))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.red.opacity(0.9))
                    }
                    
                    Spacer()
                }
            }
            .padding(16)
        }
    }
    
    private var scenarioControlsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SCENARIO VARIABLES")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
            
            VStack(spacing: 12) {
                switch selectedScenario {
                case .churnBlackSwan:
                    HStack {
                        Text("Simulated Client Churn Rate")
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                        Spacer()
                        Text("-30% Collections")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.red)
                    }
                    
                case .freezeCollections:
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Clients Delaying Payments")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(Int(simulatedDelayedClients)) Clients")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color.gaurexWarmGold)
                        }
                        Slider(value: $simulatedDelayedClients, in: 1...8, step: 1)
                            .tint(Color.gaurexWarmGold)
                    }
                    
                case .conquestSurge:
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("New High-Value Contracts Closed")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                            Spacer()
                            Text("+\(Int(newConquestContracts)) Contracts")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.green)
                        }
                        Slider(value: $newConquestContracts, in: 1...10, step: 1)
                            .tint(.green)
                    }
                    
                case .burnDefense:
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Expense & Overhead Reduction")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                            Spacer()
                            Text("-\(Int(simulatedBurnCutPercent))%")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color.gaurexWarmGold)
                        }
                        Slider(value: $simulatedBurnCutPercent, in: 5...50, step: 5)
                            .tint(Color.gaurexWarmGold)
                    }
                }
            }
            .padding(14)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    private var defconLevelPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SET STRATEGIC DEFCON LEVEL")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
            
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { level in
                    let isSel = theme.warGameDefconLevel == level
                    Button {
                        theme.warGameDefconLevel = level
                        GaurexSoundEffectsService.shared.playStealthModeClick()
                    } label: {
                        Text("\(level)")
                            .font(.system(size: 14, weight: .heavy))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(isSel ? defconColorFor(level) : Color.white.opacity(0.08))
                            .foregroundColor(isSel ? .black : .white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private func defconColorFor(_ level: Int) -> Color {
        switch level {
        case 1: return .red
        case 2: return .orange
        case 3: return Color.gaurexWarmGold
        case 4: return .blue
        case 5: return .green
        default: return .white
        }
    }
    
    private var defconColor: Color {
        defconColorFor(theme.warGameDefconLevel)
    }
    
    private var defconTitle: String {
        switch theme.warGameDefconLevel {
        case 1: return "Critical Battle Station"
        case 2: return "Elevated Tactical"
        case 3: return "Normal Strategic"
        case 4: return "Growth Offensive"
        case 5: return "Total Dominance"
        default: return "Standby"
        }
    }
    
    private func executeCombatDrill() {
        isDrillExecuting = true
        GaurexSoundEffectsService.shared.playMilestoneCompletedSound()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isDrillExecuting = false
            drillResultMessage = "✓ Counter-measures active: Runway protected at \(String(format: "%.1f", simulatedRunwayMonths)) months."
            GaurexSoundEffectsService.shared.playCashSettledSound()
        }
    }
}
