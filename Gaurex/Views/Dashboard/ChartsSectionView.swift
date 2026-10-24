//
//  ChartsSectionView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI
import Charts

public struct MonthlyRevenuePoint: Identifiable {
    public var id = UUID()
    public var month: String
    public var revenue: Double
    public var expenses: Double
}

public struct StatusPieSlice: Identifiable {
    public var id = UUID()
    public var status: String
    public var count: Int
    public var color: Color
}

public struct ChartsSectionView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @State private var selectedMetricName: String? = nil
    @State private var selectedMetricValue: Double? = nil
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 16) {
            // Revenue & Financial Trends Card
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("FINANCIAL TRAJECTORY")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                            Text("Revenue vs Expenses")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        Image(systemName: "chart.xyaxis.line")
                            .foregroundColor(theme.accentColor)
                    }
                    
                    // Liquid Scrubber Tooltip
                    if let name = selectedMetricName, let val = selectedMetricValue {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(theme.accentColor)
                                .frame(width: 8, height: 8)
                            Text(name)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.primary)
                            Spacer()
                            Text(FinancialCalculator.shared.formatCurrency(val, symbol: store.settings.currencySymbol))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(theme.accentColor)
                                .monospacedDigit()
                                .contentTransition(.numericText())
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background {
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
                                )
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    if store.invoices.isEmpty && store.expenses.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 30, weight: .light))
                                .foregroundColor(.secondary.opacity(0.6))
                            Text("No revenue or expense records recorded yet.")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 140)
                    } else {
                        // Dynamic Swift Chart with Interactive Selection
                        Chart {
                            BarMark(
                                x: .value("Category", "Invoiced"),
                                y: .value("Amount", store.totalInvoicedRevenue)
                            )
                            .foregroundStyle(Color.blue.gradient)
                            .opacity(selectedMetricName == nil || selectedMetricName == "Total Invoiced" ? 1.0 : 0.4)
                            
                            BarMark(
                                x: .value("Category", "Collected"),
                                y: .value("Amount", store.revenueCollected)
                            )
                            .foregroundStyle(Color.green.gradient)
                            .opacity(selectedMetricName == nil || selectedMetricName == "Collected Cash" ? 1.0 : 0.4)
                            
                            BarMark(
                                x: .value("Category", "Expenses"),
                                y: .value("Amount", store.totalMonthlyExpenses + store.totalMonthlyPayrollExpenses)
                            )
                            .foregroundStyle(Color.red.gradient)
                            .opacity(selectedMetricName == nil || selectedMetricName == "Operating Expenses" ? 1.0 : 0.4)
                            
                            BarMark(
                                x: .value("Category", "Net Income"),
                                y: .value("Amount", max(0, store.netOperatingIncome))
                            )
                            .foregroundStyle(Color.purple.gradient)
                            .opacity(selectedMetricName == nil || selectedMetricName == "Net Operating Income" ? 1.0 : 0.4)
                        }
                        .frame(height: 180)
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .chartOverlay { proxy in
                            GeometryReader { geometry in
                                Rectangle()
                                    .fill(Color.clear)
                                    .contentShape(Rectangle())
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                let x = value.location.x - geometry[proxy.plotAreaFrame].origin.x
                                                let width = geometry[proxy.plotAreaFrame].width
                                                guard width > 0 else { return }
                                                let segment = Int((x / width) * 4)
                                                let feedback = UISelectionFeedbackGenerator()
                                                feedback.selectionChanged()
                                                
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                                    switch segment {
                                                    case 0:
                                                        selectedMetricName = "Total Invoiced"
                                                        selectedMetricValue = store.totalInvoicedRevenue
                                                    case 1:
                                                        selectedMetricName = "Collected Cash"
                                                        selectedMetricValue = store.revenueCollected
                                                    case 2:
                                                        selectedMetricName = "Operating Expenses"
                                                        selectedMetricValue = store.totalMonthlyExpenses + store.totalMonthlyPayrollExpenses
                                                    default:
                                                        selectedMetricName = "Net Operating Income"
                                                        selectedMetricValue = max(0, store.netOperatingIncome)
                                                    }
                                                }
                                            }
                                            .onEnded { _ in
                                                withAnimation(.easeOut(duration: 0.4).delay(2.0)) {
                                                    selectedMetricName = nil
                                                    selectedMetricValue = nil
                                                }
                                            }
                                    )
                            }
                        }
                    }
                }
            }
            
            // Invoices Payment Status Breakdown
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("INVOICE STATUS RATIO")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                            Text("Payment Settlement Status")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        Image(systemName: "chart.pie.fill")
                            .foregroundColor(.blue)
                    }
                    
                    if store.invoices.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 30, weight: .light))
                                .foregroundColor(.secondary.opacity(0.6))
                            Text("Create an invoice to view settlement distribution.")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                    } else {
                        let paidCount = store.invoices.filter { $0.status == .paid }.count
                        let partialCount = store.invoices.filter { $0.status == .partiallyPaid }.count
                        let issuedCount = store.invoices.filter { $0.status == .issued }.count
                        let overdueCount = store.invoices.filter { $0.status == .overdue }.count
                        
                        let slices: [StatusPieSlice] = [
                            StatusPieSlice(status: "Paid", count: paidCount, color: .green),
                            StatusPieSlice(status: "Partially Paid", count: partialCount, color: .orange),
                            StatusPieSlice(status: "Issued", count: issuedCount, color: .blue),
                            StatusPieSlice(status: "Overdue", count: overdueCount, color: .red)
                        ].filter { $0.count > 0 }
                        
                        Chart(slices) { slice in
                            SectorMark(
                                angle: .value("Count", slice.count),
                                innerRadius: .ratio(0.55),
                                angularInset: 1.5
                            )
                            .cornerRadius(4)
                            .foregroundStyle(slice.color)
                        }
                        .frame(height: 150)
                        
                        // Legend
                        HStack(spacing: 12) {
                            ForEach(slices) { slice in
                                HStack(spacing: 4) {
                                    Circle().fill(slice.color).frame(width: 8, height: 8)
                                    Text("\(slice.status): \(slice.count)")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
        }
    }
}
