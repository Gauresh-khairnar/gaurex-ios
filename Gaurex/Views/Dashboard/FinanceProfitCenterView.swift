//
//  FinanceProfitCenterView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct FinanceProfitCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    
    @State private var showingAddExpenseSheet = false
    @State private var selectedExpenseCategory: ExpenseCategory? = nil
    @State private var expenseToDelete: Expense? = nil
    @State private var showingDeleteExpenseAlert = false
    
    public init() {}
    
    private var filteredExpenses: [Expense] {
        if let cat = selectedExpenseCategory {
            return store.expenses.filter { $0.category == cat }
        }
        return store.expenses
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // MARK: - Executive Profit & Cash Position Card
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("FINANCE & PROFIT CENTER")
                                            .font(TypographyTokens.sectionHeader)
                                            .foregroundColor(.secondary)
                                        Text("Recognized Operating Profit")
                                            .font(.system(size: 15, weight: .semibold))
                                    }
                                    Spacer()
                                    OwnerBadge()
                                }
                                
                                AnimatedNumberView(
                                    value: store.netOperatingIncome,
                                    prefix: store.settings.currencySymbol,
                                    font: Font.system(size: 28, weight: .black, design: .rounded),
                                    color: store.netOperatingIncome >= 0 ? .green : .red
                                )
                                
                                Divider().background(theme.glassBorderColor)
                                
                                // Strict Financial Metric Separations
                                VStack(spacing: 8) {
                                    FinancialDetailRow(
                                        title: "Collected Revenue (Actual Cash In)",
                                        value: store.revenueCollected,
                                        color: .green
                                    )
                                    FinancialDetailRow(
                                        title: "Total Invoiced (Billed Pipeline)",
                                        value: store.totalInvoicedRevenue,
                                        color: .blue
                                    )
                                    FinancialDetailRow(
                                        title: "Outstanding Receivables (Unpaid)",
                                        value: store.outstandingPayments,
                                        color: store.outstandingPayments > 0 ? .orange : .secondary
                                    )
                                    FinancialDetailRow(
                                        title: "Recorded Operating Expenses",
                                        value: store.totalMonthlyExpenses,
                                        color: .red
                                    )
                                    FinancialDetailRow(
                                        title: "Disbursed Payroll Expenses",
                                        value: store.totalMonthlyPayrollExpenses,
                                        color: .purple
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // MARK: - Budget Utilization
                        let budget = store.businessGoals.first(where: { $0.metricType == .expenseBudget })?.targetValue ?? 200000.0
                        let currentSpend = store.totalMonthlyExpenses + store.totalMonthlyPayrollExpenses
                        let utilizationFraction = budget > 0 ? min(1.0, currentSpend / budget) : 0.0
                        
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("MONTHLY BUDGET UTILIZATION")
                                        .font(TypographyTokens.sectionHeader)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(String(format: "%.1f%%", utilizationFraction * 100))")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(utilizationFraction > 0.85 ? .red : .primary)
                                }
                                
                                ProgressView(value: utilizationFraction)
                                    .tint(utilizationFraction > 0.85 ? Color.red : Color.green)
                                
                                HStack {
                                    Text("Spent: \(FinancialCalculator.shared.formatCurrency(currentSpend, symbol: store.settings.currencySymbol))")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("Budget: \(FinancialCalculator.shared.formatCurrency(budget, symbol: store.settings.currencySymbol))")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // MARK: - Expense Manager
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("EXPENSE LEDGER")
                                    .font(TypographyTokens.sectionHeader)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button {
                                    showingAddExpenseSheet = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Log Expense")
                                    }
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(theme.accentColor)
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            // Category Filter
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    FilterChip(title: "All (\(store.expenses.count))", isSelected: selectedExpenseCategory == nil) {
                                        selectedExpenseCategory = nil
                                    }
                                    ForEach(ExpenseCategory.allCases) { cat in
                                        let count = store.expenses.filter { $0.category == cat }.count
                                        FilterChip(title: "\(cat.rawValue) (\(count))", isSelected: selectedExpenseCategory == cat) {
                                            selectedExpenseCategory = cat
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            
                            if filteredExpenses.isEmpty {
                                GlassCard {
                                    Text("No recorded business expenses in this category.")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.vertical, 10)
                                }
                                .padding(.horizontal, 16)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(filteredExpenses) { exp in
                                        GlassCard(padding: 12) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(exp.title)
                                                        .font(.system(size: 14, weight: .semibold))
                                                    Text("\(exp.category.rawValue) • \(exp.vendorName.isEmpty ? "Direct" : exp.vendorName)")
                                                        .font(.system(size: 11))
                                                        .foregroundColor(.secondary)
                                                }
                                                Spacer()
                                                VStack(alignment: .trailing, spacing: 2) {
                                                    Text("-\(FinancialCalculator.shared.formatCurrency(exp.amount, symbol: store.settings.currencySymbol))")
                                                        .font(.system(size: 13, weight: .bold))
                                                        .foregroundColor(.red)
                                                    Text(exp.date, style: .date)
                                                        .font(.system(size: 10))
                                                        .foregroundColor(.secondary)
                                                }
                                                
                                                Button(role: .destructive) {
                                                    expenseToDelete = exp
                                                    showingDeleteExpenseAlert = true
                                                } label: {
                                                    Image(systemName: "trash")
                                                        .font(.system(size: 11))
                                                        .foregroundColor(.red.opacity(0.85))
                                                        .padding(6)
                                                        .background(Color.red.opacity(0.08))
                                                        .clipShape(Circle())
                                                }
                                                .buttonStyle(.plain)
                                                .padding(.leading, 6)
                                            }
                                        }
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                expenseToDelete = exp
                                                showingDeleteExpenseAlert = true
                                            } label: {
                                                Label("Delete Expense", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        Spacer().frame(height: 80)
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Profit Center")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showingAddExpenseSheet) {
                AddExpenseSheet()
            }
            .confirmationDialog("Delete Expense?", isPresented: $showingDeleteExpenseAlert, titleVisibility: .visible) {
                Button("Delete Expense", role: .destructive) {
                    if let exp = expenseToDelete {
                        withAnimation {
                            store.deleteExpense(id: exp.id)
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to permanently delete '\(expenseToDelete?.title ?? "this expense")'?")
            }
        }
    }
}

public struct FinancialDetailRow: View {
    public var title: String
    public var value: Double
    public var color: Color
    
    public var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Spacer()
            Text(FinancialCalculator.shared.formatCurrency(value, symbol: FirestoreDataStore.shared.settings.currencySymbol))
                .font(.system(size: 12, weight: .bold))
                .monospacedDigit()
                .foregroundColor(color)
        }
    }
}

public struct AddExpenseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = FirestoreDataStore.shared
    
    @State private var title: String = ""
    @State private var category: ExpenseCategory = .cloudInfrastructure
    @State private var amount: Double = 0.0
    @State private var vendor: String = ""
    @State private var paymentMethod: PaymentMethod = .creditDebitCard
    @State private var date: Date = Date()
    @State private var notes: String = ""
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Expense Specification")) {
                    TextField("Expense Title (e.g. AWS Production Cluster) *", text: $title)
                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    HStack {
                        Text("Amount (₹) *")
                        Spacer()
                        TextField("0", value: $amount, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    TextField("Vendor Name (e.g. Amazon Web Services)", text: $vendor)
                    DatePicker("Expense Date", selection: $date, displayedComponents: .date)
                    Picker("Payment Method", selection: $paymentMethod) {
                        ForEach(PaymentMethod.allCases) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextField("Memo / Notes", text: $notes)
                }
            }
            .navigationTitle("Log Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Expense") {
                        guard !title.isEmpty, amount > 0 else { return }
                        let exp = Expense(
                            title: title,
                            category: category,
                            amount: amount,
                            date: date,
                            paymentMethod: paymentMethod,
                            vendorName: vendor,
                            notes: notes
                        )
                        store.addExpense(exp)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}
