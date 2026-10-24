//
//  DashboardView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct DashboardView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // Quick Action & Deep Dive Sheets
    @State private var showingAddClientSheet = false
    @State private var showingCreateInvoiceSheet = false
    @State private var showingAddWorkerSheet = false
    @State private var showingAddPackageSheet = false
    @State private var showingProfitCenter = false
    @State private var showingVoiceAssistant = false
    @State private var showingSettingsSheet = false
    
    @State private var headerAppeared = false
    
    @Binding public var selectedTab: MainTab
    
    public init(selectedTab: Binding<MainTab>) {
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AuroraLivingBackground()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // MARK: - Header
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Text("GAUREX")
                                        .font(TypographyTokens.executiveTitle)
                                        .tracking(1.5)
                                    OwnerBadge()
                                }
                                Text("Executive Business Operating System")
                                    .font(TypographyTokens.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button {
                                showingVoiceAssistant = true
                            } label: {
                                Image(systemName: "waveform.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(theme.accentColor)
                            }
                            .buttonStyle(.plain)
                            .tactilePress()
                            
                            Button {
                                showingSettingsSheet = true
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 20))
                                    .foregroundColor(.primary)
                                    .frame(width: 38, height: 38)
                                    .background(theme.cardBackground)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(theme.glassBorderColor, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                            .tactilePress()
                            
                            Image("GaurexLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 38, height: 38)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(theme.glassBorderColor, lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .opacity(headerAppeared ? 1.0 : 0.0)
                        
                        // MARK: - Date Filter Bar
                        DateFilterBar(selectedFilter: $store.activeDateFilter)
                        
                        // MARK: - Actionable Alerts Banner
                        if store.overdueInvoicesCount > 0 {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 18))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("ACTION REQUIRED: \(store.overdueInvoicesCount) OVERDUE INVOICE(S)")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.red)
                                    Text("Uncollected balance: \(FinancialCalculator.shared.formatCurrency(store.outstandingPayments, symbol: store.settings.currencySymbol))")
                                        .font(.system(size: 12))
                                        .foregroundColor(.primary)
                                }
                                Spacer()
                            }
                            .padding(14)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.red.opacity(0.3), lineWidth: 1))
                            .padding(.horizontal, 16)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // MARK: - Founder Command Center & Business Health Score
                        FounderCommandCenterView()
                        
                        // MARK: - Dedicated Today's Tasks & AI Daily Planner (Module 5)
                        TodayTasksSectionView()
                        
                        // MARK: - Executive Quick Actions Panel
                        VStack(alignment: .leading, spacing: 10) {
                            Text("EXECUTIVE COMMAND")
                                .font(TypographyTokens.sectionHeader)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    QuickActionButton(title: "Profit Center", icon: "chart.pie.fill", color: .purple) {
                                        showingProfitCenter = true
                                    }
                                    QuickActionButton(title: "Add Client", icon: "person.badge.plus", color: .blue) {
                                        showingAddClientSheet = true
                                    }
                                    QuickActionButton(title: "New Invoice", icon: "doc.badge.plus", color: .green) {
                                        showingCreateInvoiceSheet = true
                                    }
                                    QuickActionButton(title: "Add Worker", icon: "person.2.badge.gearshape", color: .teal) {
                                        showingAddWorkerSheet = true
                                    }
                                    QuickActionButton(title: "Add Package", icon: "shippingbox.fill", color: .orange) {
                                        showingAddPackageSheet = true
                                    }
                                    QuickActionButton(title: "Ask AI", icon: "sparkles", color: theme.accentColor) {
                                        selectedTab = .aiModel
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        // MARK: - Primary Financial Metrics Grid
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("FINANCIAL POSITION")
                                    .font(TypographyTokens.sectionHeader)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button("Deep Dive") {
                                    showingProfitCenter = true
                                }
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(theme.accentColor)
                            }
                            .padding(.horizontal, 16)
                            
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                                MetricCard(
                                    title: "Revenue Collected",
                                    value: FinancialCalculator.shared.formatCurrency(store.revenueCollected, symbol: store.settings.currencySymbol),
                                    subtitle: "Settled cashflow",
                                    icon: "arrow.down.left.circle.fill",
                                    trendPercentage: store.revenueCollected > 0 ? 12.4 : nil,
                                    accentColor: .green
                                )
                                
                                MetricCard(
                                    title: "Invoiced Revenue",
                                    value: FinancialCalculator.shared.formatCurrency(store.totalInvoicedRevenue, symbol: store.settings.currencySymbol),
                                    subtitle: "\(store.invoices.count) invoices generated",
                                    icon: "doc.text.fill",
                                    accentColor: .blue
                                )
                                
                                MetricCard(
                                    title: "Outstanding Balance",
                                    value: FinancialCalculator.shared.formatCurrency(store.outstandingPayments, symbol: store.settings.currencySymbol),
                                    subtitle: "\(store.overdueInvoicesCount) overdue accounts",
                                    icon: "clock.badge.exclamationmark.fill",
                                    accentColor: store.outstandingPayments > 0 ? .orange : .gray
                                )
                                
                                MetricCard(
                                    title: "Net Operating Income",
                                    value: FinancialCalculator.shared.formatCurrency(store.netOperatingIncome, symbol: store.settings.currencySymbol),
                                    subtitle: "Rev - Exp - Payroll",
                                    icon: "chart.line.uptrend.xyaxis.circle.fill",
                                    accentColor: store.netOperatingIncome >= 0 ? .green : .red
                                )
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // MARK: - Analytics Charts
                        VStack(alignment: .leading, spacing: 12) {
                            Text("BUSINESS ANALYTICS")
                                .font(TypographyTokens.sectionHeader)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                            
                            ChartsSectionView()
                                .padding(.horizontal, 16)
                        }
                        
                        Spacer().frame(height: 80)
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
            .onAppear {
                withAnimation(MotionTokens.interactiveSpring) {
                    headerAppeared = true
                }
            }
        }
    }
}

public struct QuickActionButton: View {
    @ObservedObject private var theme = ThemeManager.shared
    public var title: String
    public var icon: String
    public var color: Color
    public var action: () -> Void
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(theme.cardBackground)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(theme.glassBorderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .tactilePress()
    }
}
