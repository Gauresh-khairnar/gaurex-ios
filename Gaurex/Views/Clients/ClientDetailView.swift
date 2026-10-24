//
//  ClientDetailView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct ClientDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    
    public var client: Client
    
    @State private var showingEditSheet = false
    @State private var showingCreateInvoiceSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var showingPermanentDeleteConfirmation = false
    @State private var showingRecordPaymentSheet = false
    @State private var paymentAmount: Double = 0.0
    @State private var paymentRef: String = ""
    @State private var paymentNotes: String = ""
    @State private var selectedPaymentMethod: PaymentMethod = .bankTransfer
    
    public init(client: Client) {
        self.client = client
    }
    
    private var currentClient: Client {
        store.clients.first(where: { $0.id == client.id }) ?? client
    }
    
    private var clientInvoices: [Invoice] {
        store.invoices.filter { $0.clientId == currentClient.id }
    }
    
    public var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Profile Header Card
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(currentClient.name)
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.primary)
                                    if !currentClient.companyName.isEmpty {
                                        Text(currentClient.companyName)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                StatusBadge(
                                    text: currentClient.status.rawValue,
                                    color: currentClient.status == .active ? .green : .orange
                                )
                            }
                            
                            HStack(spacing: 6) {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Text(currentClient.businessCategory)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider().background(theme.glassBorderColor)
                            
                            // Direct Quick Action Buttons
                            HStack(spacing: 12) {
                                ContactActionButton(icon: "phone.fill", title: "Call", color: .green) {
                                    if let url = URL(string: "tel:\(currentClient.phone.filter { "0123456789+".contains($0) })") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                
                                ContactActionButton(icon: "envelope.fill", title: "Email", color: .blue) {
                                    if let url = URL(string: "mailto:\(currentClient.email)") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                
                                ContactActionButton(icon: "message.fill", title: "WhatsApp", color: Color(red: 0.15, green: 0.78, blue: 0.35)) {
                                    let phoneDigits = (currentClient.whatsapp ?? currentClient.phone).filter { "0123456789".contains($0) }
                                    if let url = URL(string: "https://wa.me/\(phoneDigits)") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Financial Overview Cards
                    HStack(spacing: 12) {
                        MetricCard(
                            title: "Total Invoiced",
                            value: FinancialCalculator.shared.formatCurrency(currentClient.totalInvoiced),
                            icon: "doc.text.fill",
                            accentColor: .blue
                        )
                        MetricCard(
                            title: "Collected Revenue",
                            value: FinancialCalculator.shared.formatCurrency(currentClient.totalCollected),
                            icon: "checkmark.circle.fill",
                            accentColor: .green
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    HStack(spacing: 12) {
                        MetricCard(
                            title: "Outstanding Balance",
                            value: FinancialCalculator.shared.formatCurrency(currentClient.outstandingBalance),
                            icon: "clock.badge.exclamationmark.fill",
                            accentColor: currentClient.outstandingBalance > 0 ? .orange : .gray
                        )
                        MetricCard(
                            title: "Invoices Generated",
                            value: "\(clientInvoices.count)",
                            icon: "newspaper.fill",
                            accentColor: .purple
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    // Associated Packages
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ACTIVE SERVICE PACKAGES")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                        
                        let packages = store.packages.filter { currentClient.packageIds.contains($0.id) }
                        if packages.isEmpty {
                            GlassCard {
                                Text("No service packages currently linked to this client.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(packages) { pkg in
                                    GlassCard(padding: 12) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(pkg.name)
                                                    .font(.system(size: 14, weight: .semibold))
                                                Text(pkg.category.rawValue)
                                                    .font(.system(size: 11))
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Text(FinancialCalculator.shared.formatCurrency(pkg.basePrice))
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(theme.accentColor)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // Invoices Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("INVOICES & STATEMENTS")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                            Spacer()
                            Button {
                                showingCreateInvoiceSheet = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("New Invoice")
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(theme.accentColor)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        if clientInvoices.isEmpty {
                            GlassCard {
                                VStack(spacing: 8) {
                                    Text("No invoices generated yet for \(currentClient.name).")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                    Button("Generate First Invoice") {
                                        showingCreateInvoiceSheet = true
                                    }
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(theme.accentColor)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                            }
                            .padding(.horizontal, 16)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(clientInvoices) { inv in
                                    NavigationLink {
                                        InvoiceDetailView(invoice: inv)
                                    } label: {
                                        InvoiceRowCard(invoice: inv)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // Bottom Spacer
                    Spacer().frame(height: 80)
                }
                .padding(.vertical, 12)
            }
        }
        .navigationTitle(currentClient.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit Profile", systemImage: "pencil")
                    }
                    
                    Button {
                        showingCreateInvoiceSheet = true
                    } label: {
                        Label("Generate Invoice", systemImage: "doc.badge.plus")
                    }
                    
                    Divider()
                    
                    if currentClient.status == .archived {
                        Button {
                            store.restoreClient(id: currentClient.id)
                        } label: {
                            Label("Restore to Active", systemImage: "arrow.uturn.backward.circle")
                        }
                    } else {
                        Button {
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Archive Client", systemImage: "archivebox")
                        }
                    }
                    
                    Button(role: .destructive) {
                        showingPermanentDeleteConfirmation = true
                    } label: {
                        Label("Delete Client Permanently", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddEditClientView(clientToEdit: currentClient)
        }
        .sheet(isPresented: $showingCreateInvoiceSheet) {
            CreateInvoiceView(preselectedClientId: currentClient.id)
        }
        .confirmationDialog("Archive Client?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Archive Record", role: .destructive) {
                store.archiveClient(id: currentClient.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Archiving will preserve existing invoices and payment records while removing the client from active rosters.")
        }
        .confirmationDialog("Delete Client Permanently?", isPresented: $showingPermanentDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete Client Permanently", role: .destructive) {
                store.deleteClient(id: currentClient.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to permanently delete '\(currentClient.name)'? This action cannot be undone.")
        }
    }
}

public struct ContactActionButton: View {
    @ObservedObject private var theme = ThemeManager.shared
    public var icon: String
    public var title: String
    public var color: Color
    public var action: () -> Void
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.25), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

public struct InvoiceRowCard: View {
    @ObservedObject private var theme = ThemeManager.shared
    public var invoice: Invoice
    
    public var body: some View {
        GlassCard(padding: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(invoice.invoiceNumber)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                    Text(invoice.issueDate, style: .date)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 3) {
                    Text(FinancialCalculator.shared.formatCurrency(invoice.totalAmount))
                        .font(.system(size: 14, weight: .bold))
                    StatusBadge(
                        text: invoice.status.rawValue,
                        color: invoice.status == .paid ? .green : (invoice.status == .partiallyPaid ? .orange : (invoice.status == .overdue ? .red : .blue))
                    )
                }
            }
        }
    }
}
