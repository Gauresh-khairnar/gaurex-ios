//
//  InvoicesListView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct InvoicesListView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    
    @State private var selectedStatus: InvoiceStatus? = nil
    @State private var searchText = ""
    @State private var showingCreateSheet = false
    
    public init() {}
    
    public var filteredInvoices: [Invoice] {
        var list = store.invoices
        if let st = selectedStatus {
            list = list.filter { $0.status == st }
        }
        if !searchText.isEmpty {
            list = list.filter {
                $0.invoiceNumber.localizedCaseInsensitiveContains(searchText) ||
                $0.clientName.localizedCaseInsensitiveContains(searchText)
            }
        }
        return list
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Filter & Search
                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            TextField("Search invoice #, client name...", text: $searchText)
                                .textFieldStyle(.plain)
                                .font(.system(size: 14))
                        }
                        .padding(12)
                        .background(theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(theme.glassBorderColor, lineWidth: 1))
                        .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FilterChip(title: "All (\(store.invoices.count))", isSelected: selectedStatus == nil) {
                                    selectedStatus = nil
                                }
                                ForEach(InvoiceStatus.allCases) { st in
                                    let count = store.invoices.filter { $0.status == st }.count
                                    FilterChip(title: "\(st.rawValue) (\(count))", isSelected: selectedStatus == st) {
                                        selectedStatus = st
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    
                    if filteredInvoices.isEmpty {
                        EmptyStateView(
                            icon: "doc.text.badge.plus",
                            title: searchText.isEmpty ? "No Invoices Issued" : "No Matching Invoices",
                            description: searchText.isEmpty
                                ? "Create client invoices with automated tax, discounts, and professional PDF generation."
                                : "No invoices match the search filter.",
                            actionTitle: searchText.isEmpty ? "Create Invoice" : nil
                        ) {
                            showingCreateSheet = true
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredInvoices) { inv in
                                    NavigationLink {
                                        InvoiceDetailView(invoice: inv)
                                    } label: {
                                        InvoiceItemCard(invoice: inv)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            Spacer().frame(height: 80)
                        }
                    }
                }
            }
            .navigationTitle("Invoices")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(theme.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateInvoiceView()
            }
        }
    }
}

public struct InvoiceItemCard: View {
    @ObservedObject private var theme = ThemeManager.shared
    public var invoice: Invoice
    
    public var body: some View {
        GlassCard(padding: 14) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(invoice.invoiceNumber)
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                        Text(invoice.clientName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    StatusBadge(
                        text: invoice.status.rawValue,
                        color: invoice.status == .paid ? .green : (invoice.status == .partiallyPaid ? .orange : (invoice.status == .overdue ? .red : .blue))
                    )
                }
                
                Divider().background(theme.glassBorderColor)
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DUE DATE")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.secondary)
                        Text(invoice.dueDate, style: .date)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(invoice.dueDate < Date() && invoice.status != .paid ? .red : .primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("TOTAL")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.secondary)
                        Text(FinancialCalculator.shared.formatCurrency(invoice.totalAmount))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(theme.accentColor)
                    }
                }
            }
        }
    }
}
