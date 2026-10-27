//
//  DashboardView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Minimalist, Apple-Grade Clean Executive Experience
//

import SwiftUI

public struct DashboardView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @Environment(\.colorScheme) private var colorScheme
    
    // Quick Action & Deep Dive Sheets
    @State private var showingAddClientSheet = false
    @State private var showingCreateInvoiceSheet = false
    @State private var showingAddWorkerSheet = false
    @State private var showingAddPackageSheet = false
    @State private var showingProfitCenter = false
    @State private var showingVoiceAssistant = false
    @State private var showingSettingsSheet = false
    @State private var showingAddTaskSheet = false
    
    @Binding public var selectedTab: MainTab
    
    public init(selectedTab: Binding<MainTab>) {
        self._selectedTab = selectedTab
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        if hour < 17 { return "Good afternoon" }
        return "Good evening"
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date())
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AuroraLivingBackground()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // MARK: - Minimalist Executive Header
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 8) {
                                    Text("\(greeting), Gauresh")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.primary)
                                    OwnerBadge()
                                }
                                Text(formattedDate)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Voice Assistant Pill
                            Button {
                                showingVoiceAssistant = true
                            } label: {
                                Image(systemName: "waveform")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(theme.accentColor)
                                    .frame(width: 36, height: 36)
                                    .background(theme.cardBackground)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(theme.glassBorderColor, lineWidth: 0.8))
                            }
                            .buttonStyle(.plain)
                            
                            // Settings Button
                            Button {
                                showingSettingsSheet = true
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .frame(width: 36, height: 36)
                                    .background(theme.cardBackground)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(theme.glassBorderColor, lineWidth: 0.8))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 10)
                        
                        // MARK: - Overdue Invoices Alert (Only if present)
                        if store.overdueInvoicesCount > 0 {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.red)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(store.overdueInvoicesCount) OVERDUE INVOICE(S)")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.red)
                                    Text("Uncollected: \(FinancialCalculator.shared.formatCurrency(store.outstandingPayments, symbol: store.settings.currencySymbol))")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                                Spacer()
                                Button("Review") {
                                    selectedTab = .finance
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.red)
                            }
                            .padding(12)
                            .background(Color.red.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.red.opacity(0.25), lineWidth: 0.8))
                            .padding(.horizontal, 18)
                        }
                        
                        // MARK: - Unified Executive Pulse Hero Card
                        GlassCard(padding: 16) {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("COLLECTED REVENUE")
                                            .font(.system(size: 10.5, weight: .semibold))
                                            .tracking(1.0)
                                            .foregroundColor(.secondary)
                                        
                                        Text(FinancialCalculator.shared.formatCurrency(store.revenueCollected, symbol: store.settings.currencySymbol))
                                            .font(.system(size: 28, weight: .black, design: .rounded))
                                            .foregroundColor(.primary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Health Score Indicator
                                    let score = store.businessHealthScore.overallScore
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(score >= 80 ? Color.green : (score >= 60 ? Color.orange : Color.red))
                                            .frame(width: 8, height: 8)
                                        Text("\(score) Health")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.primary.opacity(0.05))
                                    .clipShape(Capsule())
                                }
                                
                                Divider().background(theme.glassBorderColor)
                                
                                // 3 Key Business Health Pillars
                                HStack(spacing: 0) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Invoiced")
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundColor(.secondary)
                                        Text(FinancialCalculator.shared.formatCurrency(store.totalInvoicedRevenue, symbol: store.settings.currencySymbol))
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.primary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Receivables")
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundColor(.secondary)
                                        Text(FinancialCalculator.shared.formatCurrency(store.outstandingPayments, symbol: store.settings.currencySymbol))
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(store.outstandingPayments > 0 ? .orange : .secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Net Operating")
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundColor(.secondary)
                                        Text(FinancialCalculator.shared.formatCurrency(store.netOperatingIncome, symbol: store.settings.currencySymbol))
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(store.netOperatingIncome >= 0 ? .green : .red)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .padding(.horizontal, 18)
                        
                        // MARK: - Minimalist Executive Quick Action Pills
                        HStack(spacing: 8) {
                            Button {
                                showingAddClientSheet = true
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: "plus")
                                    Text("Client")
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(theme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(theme.glassBorderColor, lineWidth: 0.8))
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                showingAddTaskSheet = true
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: "plus")
                                    Text("Task")
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(theme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(theme.glassBorderColor, lineWidth: 0.8))
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                showingCreateInvoiceSheet = true
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: "plus")
                                    Text("Invoice")
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(theme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(theme.glassBorderColor, lineWidth: 0.8))
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                showingProfitCenter = true
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: "chart.pie.fill")
                                    Text("Finance")
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(theme.accentColor)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(theme.accentColor.opacity(0.10))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(theme.accentColor.opacity(0.25), lineWidth: 0.8))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 18)
                        
                        // MARK: - Strategic Milestone Progress (Clean Single Milestone)
                        if let primaryGoal = store.businessGoals.first {
                            GlassCard(padding: 14) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "flag.checkered")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(theme.accentColor)
                                        Text(primaryGoal.title.uppercased())
                                            .font(.system(size: 11, weight: .bold))
                                            .tracking(0.5)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text(primaryGoal.percentageString)
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(theme.accentColor)
                                    }
                                    
                                    ProgressView(value: primaryGoal.progressFraction)
                                        .tint(primaryGoal.progressFraction >= 1.0 ? Color.green : theme.accentColor)
                                    
                                    HStack {
                                        Text("Target: \(FinancialCalculator.shared.formatCurrency(primaryGoal.targetValue, symbol: store.settings.currencySymbol))")
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("Current: \(FinancialCalculator.shared.formatCurrency(primaryGoal.currentValue, symbol: store.settings.currencySymbol))")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            .padding(.horizontal, 18)
                        }
                        
                        // MARK: - Today's Priorities (Focused Tasks)
                        TodayTasksSectionView()
                        
                        // MARK: - Active Client Highlights (Recent 3 Clients)
                        if !store.clients.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("ACTIVE CLIENTS")
                                        .font(.system(size: 11, weight: .bold))
                                        .tracking(1.0)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Button("View All (\(store.clients.count))") {
                                        selectedTab = .clients
                                    }
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(theme.accentColor)
                                }
                                .padding(.horizontal, 18)
                                
                                VStack(spacing: 8) {
                                    ForEach(store.clients.prefix(3)) { client in
                                        GlassCard(padding: 12) {
                                            HStack(spacing: 12) {
                                                Circle()
                                                    .fill(theme.accentColor.opacity(0.12))
                                                    .frame(width: 36, height: 36)
                                                    .overlay(
                                                        Text(String(client.name.prefix(1)))
                                                            .font(.system(size: 14, weight: .bold))
                                                            .foregroundColor(theme.accentColor)
                                                    )
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(client.name)
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(.primary)
                                                    Text(client.companyName.isEmpty ? client.businessCategory : client.companyName)
                                                        .font(.system(size: 11))
                                                        .foregroundColor(.secondary)
                                                }
                                                
                                                Spacer()
                                                
                                                VStack(alignment: .trailing, spacing: 2) {
                                                    Text(FinancialCalculator.shared.formatCurrency(client.totalCollected, symbol: store.settings.currencySymbol))
                                                        .font(.system(size: 13, weight: .bold))
                                                        .foregroundColor(.green)
                                                    if client.outstandingBalance > 0 {
                                                        Text("Due: \(FinancialCalculator.shared.formatCurrency(client.outstandingBalance, symbol: store.settings.currencySymbol))")
                                                            .font(.system(size: 10, weight: .semibold))
                                                            .foregroundColor(.orange)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 18)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Toast Message Banner
                ToastOverlay(toast: $store.activeToast)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddClientSheet) { AddEditClientView() }
            .sheet(isPresented: $showingCreateInvoiceSheet) { CreateInvoiceView() }
            .sheet(isPresented: $showingAddWorkerSheet) { AddEditWorkerView() }
            .sheet(isPresented: $showingAddPackageSheet) { AddEditPackageView() }
            .sheet(isPresented: $showingProfitCenter) { FinanceProfitCenterView() }
            .sheet(isPresented: $showingVoiceAssistant) { VoiceAssistantOverlay() }
            .sheet(isPresented: $showingSettingsSheet) { SettingsView() }
            .sheet(isPresented: $showingAddTaskSheet) { AddTaskSheet() }
        }
    }
}
