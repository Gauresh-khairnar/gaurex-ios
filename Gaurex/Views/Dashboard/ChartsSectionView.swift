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
                        // Dynamic Swift Chart
                        Chart {
                            BarMark(
                                x: .value("Category", "Total Invoiced"),
                                y: .value("Amount", store.totalInvoicedRevenue)
                            )
                            .foregroundStyle(Color.blue.gradient)
                            
                            BarMark(
                                x: .value("Category", "Collected"),
                                y: .value("Amount", store.revenueCollected)
                            )
                            .foregroundStyle(Color.green.gradient)
                            
                            BarMark(
                                x: .value("Category", "Expenses"),
                                y: .value("Amount", store.totalMonthlyExpenses + store.totalMonthlyPayrollExpenses)
                            )
                            .foregroundStyle(Color.red.gradient)
                            
                            BarMark(
                                x: .value("Category", "Net Income"),
                                y: .value("Amount", max(0, store.netOperatingIncome))
                            )
                            .foregroundStyle(Color.purple.gradient)
                        }
                        .frame(height: 180)
                        .chartYAxis {
                            AxisMarks(position: .leading)
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
