//
//  BusinessSettingsAndAuditViews.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct BusinessSettingsView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var companyName: String = ""
    @State private var tagline: String = ""
    @State private var founderName: String = ""
    @State private var officialEmail: String = ""
    @State private var officialPhone: String = ""
    @State private var registeredAddress: String = ""
    @State private var websiteUrl: String = ""
    @State private var currencySymbol: String = "₹"
    @State private var gstNumber: String = ""
    @State private var panNumber: String = ""
    @State private var invoicePrefix: String = ""
    @State private var bankName: String = ""
    @State private var bankAccountNumber: String = ""
    @State private var bankIfsc: String = ""
    @State private var bankBranch: String = ""
    @State private var upiId: String = ""
    @State private var defaultPaymentTerms: String = ""
    @State private var defaultNotes: String = ""
    
    public init() {}
    
    public var body: some View {
        Form {
            Section(header: Text("Company Identity")) {
                TextField("Company Name", text: $companyName)
                TextField("Tagline", text: $tagline)
                TextField("Founder & Owner Name", text: $founderName)
                TextField("Official Email", text: $officialEmail)
                    .keyboardType(.emailAddress)
                TextField("Official Phone", text: $officialPhone)
                    .keyboardType(.phonePad)
                TextField("Registered Address", text: $registeredAddress)
                TextField("Website URL", text: $websiteUrl)
            }
            
            Section(header: Text("Tax & Invoicing Structure")) {
                TextField("Currency Symbol (Default ₹)", text: $currencySymbol)
                TextField("GST / Tax Identification Number", text: $gstNumber)
                TextField("PAN Card Number", text: $panNumber)
                TextField("Invoice Prefix (e.g. GX-INV-)", text: $invoicePrefix)
            }
            
            Section(header: Text("Bank & Settlement Account")) {
                TextField("Bank Name", text: $bankName)
                TextField("Account Number", text: $bankAccountNumber)
                TextField("IFSC / Routing Code", text: $bankIfsc)
                TextField("Branch Name", text: $bankBranch)
                TextField("UPI ID", text: $upiId)
            }
            
            Section(header: Text("Default Commercial Terms")) {
                TextField("Default Payment Terms", text: $defaultPaymentTerms)
                TextField("Default Invoice Footer Notes", text: $defaultNotes)
            }
        }
        .navigationTitle("Business Configuration")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                    dismiss()
                }
                .fontWeight(.bold)
            }
        }
        .onAppear {
            let s = store.settings
            companyName = s.companyName
            tagline = s.tagline
            founderName = s.founderName
            officialEmail = s.officialEmail
            officialPhone = s.officialPhone
            registeredAddress = s.registeredAddress
            websiteUrl = s.websiteUrl
            currencySymbol = s.currencySymbol
            gstNumber = s.gstNumber
            panNumber = s.panNumber
            invoicePrefix = s.invoicePrefix
            bankName = s.bankName
            bankAccountNumber = s.bankAccountNumber
            bankIfsc = s.bankIfsc
            bankBranch = s.bankBranch
            upiId = s.upiId
            defaultPaymentTerms = s.defaultPaymentTerms
            defaultNotes = s.defaultInvoiceNotes
        }
    }
    
    private func save() {
        store.settings.companyName = companyName
        store.settings.tagline = tagline
        store.settings.founderName = founderName
        store.settings.officialEmail = officialEmail
        store.settings.officialPhone = officialPhone
        store.settings.registeredAddress = registeredAddress
        store.settings.websiteUrl = websiteUrl
        store.settings.currencySymbol = currencySymbol
        store.settings.gstNumber = gstNumber
        store.settings.panNumber = panNumber
        store.settings.invoicePrefix = invoicePrefix
        store.settings.bankName = bankName
        store.settings.bankAccountNumber = bankAccountNumber
        store.settings.bankIfsc = bankIfsc
        store.settings.bankBranch = bankBranch
        store.settings.upiId = upiId
        store.settings.defaultPaymentTerms = defaultPaymentTerms
        store.settings.defaultInvoiceNotes = defaultNotes
        store.saveSettings()
    }
}

public struct AuditLogsView: View {
    @ObservedObject private var logger = AuditLogger.shared
    @ObservedObject private var theme = ThemeManager.shared
    
    public init() {}
    
    public var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            if logger.logs.isEmpty {
                EmptyStateView(
                    icon: "shield.lefthalf.filled",
                    title: "No Audit Entries",
                    description: "All client, financial, payroll, and security activities will be recorded in this immutable audit ledger."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(logger.logs) { log in
                            GlassCard(padding: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(log.actionType)
                                            .font(.system(size: 10, weight: .black, design: .monospaced))
                                            .foregroundColor(.blue)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.12))
                                            .clipShape(Capsule())
                                        
                                        Text(log.entityType)
                                            .font(.system(size: 12, weight: .bold))
                                        
                                        Spacer()
                                        
                                        Text(log.timestamp, style: .time)
                                            .font(.system(size: 10))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text(log.description)
                                        .font(.system(size: 12))
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    Spacer().frame(height: 80)
                }
            }
        }
        .navigationTitle("Activity Audit Trail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
