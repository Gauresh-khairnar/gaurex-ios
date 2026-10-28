//
//  GhostRunwaySimulatorSheet.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Interactive "Ghost Runway" War-Game Scenario Simulator
//

import SwiftUI

public struct GhostRunwaySimulatorSheet: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var newEnterpriseClients: Double = 2.0
    @State private var contractSizePerClient: Double = 450000.0
    @State private var newWorkerHires: Double = 2.0
    @State private var salaryPerWorker: Double = 60000.0
    @State private var additionalOpsBurn: Double = 35000.0
    
    private let deepPurple = Color.gaurexDeepPlum
    private let goldAccent = Color.gaurexWarmGold
    
    public init() {}
    
    // Computed Real-Time War Game Projections
    private var projectedInflow: Double {
        store.revenueCollected + (newEnterpriseClients * contractSizePerClient)
    }
    
    private var projectedMonthlyBurn: Double {
        store.allOperationalExpenses + (newWorkerHires * salaryPerWorker) + additionalOpsBurn
    }
    
    private var projectedNetCashflow: Double {
        max(0.0, projectedInflow - projectedMonthlyBurn)
    }
    
    private var runwayMonths: Double {
        guard projectedMonthlyBurn > 0 else { return 48.0 }
        return min(60.0, projectedInflow / projectedMonthlyBurn * 3.5)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                (colorScheme == .dark ? Color(red: 0.08, green: 0.08, blue: 0.10) : Color(red: 0.96, green: 0.95, blue: 0.97))
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header Description
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Ghost Runway Simulator")
                                    .font(.pjs(20, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                Text("What-If Strategic War Games for Founder Gauresh")
                                    .font(.pjs(12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color.secondary.opacity(0.7))
                            }
                        }
                        .padding(.top, 10)
                        
                        // Projected Net Outcome Hero Banner
                        ZStack(alignment: .topTrailing) {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [deepPurple, Color(red: 0.16, green: 0.05, blue: 0.18)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: deepPurple.opacity(0.3), radius: 12, y: 6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .stroke(goldAccent.opacity(0.5), lineWidth: 1.2)
                                )
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "wand.and.stars")
                                        .foregroundColor(goldAccent)
                                    Text("Simulated Net Cash Inflow")
                                        .font(.pjs(13, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.85))
                                }
                                
                                Text(FinancialCalculator.shared.formatCurrency(projectedNetCashflow, symbol: store.settings.currencySymbol))
                                    .font(.pjs(30, weight: .bold))
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 12) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.down.left")
                                        Text("Projected In: \(FinancialCalculator.shared.formatCurrency(projectedInflow, symbol: store.settings.currencySymbol))")
                                    }
                                    .font(.pjs(11, weight: .bold))
                                    .foregroundColor(Color(red: 0.06, green: 0.72, blue: 0.44))
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.up.right")
                                        Text("Burn: -\(FinancialCalculator.shared.formatCurrency(projectedMonthlyBurn, symbol: store.settings.currencySymbol))")
                                    }
                                    .font(.pjs(11, weight: .bold))
                                    .foregroundColor(Color(red: 0.95, green: 0.35, blue: 0.35))
                                }
                                
                                Divider().background(Color.white.opacity(0.15))
                                
                                HStack {
                                    Text("Runway Buffer: \(String(format: "%.1f", runwayMonths)) Months")
                                        .font(.pjs(12, weight: .bold))
                                        .foregroundColor(goldAccent)
                                    
                                    Spacer()
                                    
                                    Text(runwayMonths > 12 ? "Hyper-Sustainable" : "Conservative")
                                        .font(.pjs(11, weight: .bold))
                                        .foregroundColor(Color(red: 0.06, green: 0.72, blue: 0.44))
                                }
                            }
                            .padding(20)
                        }
                        
                        // Interactive War Game Sliders
                        VStack(spacing: 16) {
                            Text("Scenario Parameters")
                                .font(.pjs(15, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Parameter 1: New Enterprise Clients
                            ScenarioSliderTile(
                                title: "New Enterprise Clients Signed",
                                valueText: "\(Int(newEnterpriseClients)) Clients",
                                sliderValue: $newEnterpriseClients,
                                range: 0...10,
                                step: 1
                            )
                            
                            // Parameter 2: Average Contract Size
                            ScenarioSliderTile(
                                title: "Average Contract Value",
                                valueText: "\(store.settings.currencySymbol)\(Int(contractSizePerClient).formatted())",
                                sliderValue: $contractSizePerClient,
                                range: 100000...1500000,
                                step: 50000
                            )
                            
                            // Parameter 3: New Developer Hires
                            ScenarioSliderTile(
                                title: "New Engineers Hired",
                                valueText: "\(Int(newWorkerHires)) Workers",
                                sliderValue: $newWorkerHires,
                                range: 0...10,
                                step: 1
                            )
                            
                            // Parameter 4: Salary Per Engineer
                            ScenarioSliderTile(
                                title: "Avg Engineer Salary",
                                valueText: "\(store.settings.currencySymbol)\(Int(salaryPerWorker).formatted())/mo",
                                sliderValue: $salaryPerWorker,
                                range: 30000...200000,
                                step: 10000
                            )
                            
                            // Parameter 5: Additional Tech Burn
                            ScenarioSliderTile(
                                title: "Additional Cloud & Marketing Burn",
                                valueText: "\(store.settings.currencySymbol)\(Int(additionalOpsBurn).formatted())/mo",
                                sliderValue: $additionalOpsBurn,
                                range: 0...250000,
                                step: 5000
                            )
                        }
                        
                        Spacer().frame(height: 30)
                    }
                    .padding(.horizontal, ThemeManager.bezelPadding)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

private struct ScenarioSliderTile: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let valueText: String
    @Binding var sliderValue: Double
    let range: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.pjs(12.5, weight: .semibold))
                    .foregroundColor(Color.primary)
                Spacer()
                Text(valueText)
                    .font(.pjs(13, weight: .bold))
                    .foregroundColor(Color.gaurexDeepPlum)
            }
            
            Slider(value: $sliderValue, in: range, step: step)
                .tint(Color.gaurexWarmGold)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.19) : Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
        )
    }
}
