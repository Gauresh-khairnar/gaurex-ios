//
//  SalesPipelineView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct SalesPipelineView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    
    @State private var selectedStage: SalesStage? = nil
    @State private var showingAddLeadSheet = false
    
    public init() {}
    
    private var filteredLeads: [SalesLead] {
        if let st = selectedStage {
            return store.salesLeads.filter { $0.stage == st }
        }
        return store.salesLeads
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Weighted Pipeline Value Card
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SALES PIPELINE & CRM")
                                .font(TypographyTokens.sectionHeader)
                                .foregroundColor(.secondary)
                            Text("Weighted Pipeline Forecast")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        Spacer()
                        Image(systemName: "funnel.fill")
                            .foregroundColor(theme.accentColor)
                    }
                    
                    AnimatedNumberView(
                        value: store.weightedPipelineValue,
                        prefix: store.settings.currencySymbol,
                        font: TypographyTokens.metricLarge,
                        color: theme.accentColor
                    )
                    
                    Text("Calculated from open deals × closing probability. Excludes lost or closed opportunities.")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            
            // Stage Selector Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "All (\(store.salesLeads.count))", isSelected: selectedStage == nil) {
                        selectedStage = nil
                    }
                    ForEach(SalesStage.allCases) { stage in
                        let count = store.salesLeads.filter { $0.stage == stage }.count
                        FilterChip(title: "\(stage.rawValue) (\(count))", isSelected: selectedStage == stage) {
                            selectedStage = stage
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            
            // Leads List
            if filteredLeads.isEmpty {
                GlassCard {
                    VStack(spacing: 6) {
                        Text("No active leads in this pipeline stage.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Button("Add Opportunity (+)") {
                            showingAddLeadSheet = true
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(theme.accentColor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, 16)
            } else {
                VStack(spacing: 8) {
                    ForEach(filteredLeads) { lead in
                        LeadRowCard(lead: lead)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .sheet(isPresented: $showingAddLeadSheet) {
            AddSalesLeadSheet()
        }
    }
}

public struct LeadRowCard: View {
    @ObservedObject private var theme = ThemeManager.shared
    @ObservedObject private var store = FirestoreDataStore.shared
    public var lead: SalesLead
    
    public var body: some View {
        GlassCard(padding: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(lead.clientName)
                            .font(.system(size: 14, weight: .bold))
                        Text(lead.companyName)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    StatusBadge(text: lead.stage.rawValue, color: stageColor(lead.stage))
                }
                
                HStack {
                    Text("Deal: \(FinancialCalculator.shared.formatCurrency(lead.expectedDealValue, symbol: store.settings.currencySymbol))")
                        .font(.system(size: 12, weight: .semibold))
                    Text("(\(String(format: "%.0f%%", lead.closingProbability * 100)) prob)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Weighted: \(FinancialCalculator.shared.formatCurrency(lead.weightedValue, symbol: store.settings.currencySymbol))")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(theme.accentColor)
                }
                
                if !lead.nextAction.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.blue)
                        Text("Next: \(lead.nextAction)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private func stageColor(_ stage: SalesStage) -> Color {
        switch stage {
        case .newLead: return .gray
        case .contacted: return .blue
        case .meetingScheduled: return .purple
        case .proposalSent: return .orange
        case .negotiation: return .yellow
        case .won: return .green
        case .lost: return .red
        }
    }
}

public struct AddSalesLeadSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = FirestoreDataStore.shared
    
    @State private var clientName: String = ""
    @State private var companyName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var dealValue: Double = 0.0
    @State private var stage: SalesStage = .newLead
    @State private var probability: Double = 30.0
    @State private var nextAction: String = "Schedule discovery call"
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Lead Contact")) {
                    TextField("Client Name *", text: $clientName)
                    TextField("Company Name", text: $companyName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("Deal Economics")) {
                    HStack {
                        Text("Expected Deal Value (₹) *")
                        Spacer()
                        TextField("0", value: $dealValue, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    Picker("Pipeline Stage", selection: $stage) {
                        ForEach(SalesStage.allCases) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    Stepper("Closing Probability: \(String(format: "%.0f%%", probability))", value: $probability, in: 0...100, step: 10)
                    TextField("Next Follow-up Action", text: $nextAction)
                }
            }
            .navigationTitle("New Pipeline Opportunity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Lead") {
                        guard !clientName.isEmpty else { return }
                        let lead = SalesLead(
                            clientName: clientName,
                            companyName: companyName,
                            email: email,
                            phone: phone,
                            stage: stage,
                            expectedDealValue: dealValue,
                            closingProbability: probability / 100.0,
                            nextAction: nextAction
                        )
                        store.addSalesLead(lead)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}
