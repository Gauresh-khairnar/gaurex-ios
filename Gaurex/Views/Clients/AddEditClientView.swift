//
//  AddEditClientView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct AddEditClientView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    
    // Existing client for editing, or nil for new
    public var clientToEdit: Client?
    
    // Form States
    @State private var name: String = ""
    @State private var companyName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var whatsapp: String = ""
    @State private var businessCategory: String = "Technology & IT"
    @State private var address: String = ""
    @State private var website: String = ""
    @State private var leadSource: LeadSource = .directInquiry
    @State private var status: ClientStatus = .active
    @State private var selectedPackageIds: Set<String> = []
    @State private var isPercentageDiscount: Bool = false
    @State private var discountValue: Double = 0.0
    @State private var isTaxable: Bool = true
    @State private var taxRate: Double = 18.0
    @State private var advancePayment: Double = 0.0
    @State private var paymentTerms: String = "Payment due within 15 days of invoice."
    @State private var projectStartDate: Date = Date()
    @State private var dueDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var selectedWorkerId: String = ""
    @State private var notesText: String = ""
    
    @State private var showingValidationError = false
    @State private var validationMessage = ""
    
    public init(clientToEdit: Client? = nil) {
        self.clientToEdit = clientToEdit
    }
    
    // Financial Calculations
    private var subtotal: Double {
        store.packages
            .filter { selectedPackageIds.contains($0.id) }
            .reduce(0.0) { $0 + $1.basePrice }
    }
    
    private var discountAmount: Double {
        if isPercentageDiscount {
            return subtotal * (max(0.0, min(100.0, discountValue)) / 100.0)
        } else {
            return max(0.0, min(subtotal, discountValue))
        }
    }
    
    private var taxableAmount: Double {
        max(0.0, subtotal - discountAmount)
    }
    
    private var taxAmount: Double {
        isTaxable ? (taxableAmount * (taxRate / 100.0)) : 0.0
    }
    
    private var finalTotal: Double {
        taxableAmount + taxAmount
    }
    
    private var balanceDue: Double {
        max(0.0, finalTotal - advancePayment)
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                // Section 1: Basic Information
                Section(header: Text("Client & Organization Details")) {
                    TextField("Client Full Name *", text: $name)
                    TextField("Company / Brand Name", text: $companyName)
                    TextField("Official Email Address *", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Contact Phone Number *", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("WhatsApp Number", text: $whatsapp)
                        .keyboardType(.phonePad)
                    TextField("Business Category (e.g. Fintech, SaaS)", text: $businessCategory)
                    TextField("Company Registered Address", text: $address)
                    TextField("Website URL", text: $website)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                    
                    Picker("Lead Source", selection: $leadSource) {
                        ForEach(LeadSource.allCases) { src in
                            Text(src.rawValue).tag(src)
                        }
                    }
                    
                    Picker("Client Status", selection: $status) {
                        ForEach(ClientStatus.allCases) { st in
                            Text(st.rawValue).tag(st)
                        }
                    }
                }
                
                // Section 2: Selected Packages
                Section(header: Text("Service Packages (Multiple Selection)")) {
                    if store.packages.isEmpty {
                        Text("No packages configured. Add packages in Settings.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(store.packages.filter { $0.isActive }) { pkg in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(pkg.name)
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("\(FinancialCalculator.shared.formatCurrency(pkg.basePrice)) • \(pkg.billingType.rawValue)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if selectedPackageIds.contains(pkg.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedPackageIds.contains(pkg.id) {
                                    selectedPackageIds.remove(pkg.id)
                                } else {
                                    selectedPackageIds.insert(pkg.id)
                                }
                            }
                        }
                    }
                }
                
                // Section 3: Financial Terms & Calculations
                Section(header: Text("Pricing, Tax & Commercial Terms")) {
                    HStack {
                        Text("Subtotal")
                        Spacer()
                        Text(FinancialCalculator.shared.formatCurrency(subtotal))
                            .fontWeight(.semibold)
                    }
                    
                    Toggle("Discount as Percentage (%)", isOn: $isPercentageDiscount)
                    
                    HStack {
                        Text(isPercentageDiscount ? "Discount (%)" : "Discount Amount (₹)")
                        Spacer()
                        TextField("0", value: $discountValue, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    Toggle("Apply GST / Tax (18%)", isOn: $isTaxable)
                    
                    HStack {
                        Text("Taxable Amount")
                        Spacer()
                        Text(FinancialCalculator.shared.formatCurrency(taxableAmount))
                    }
                    
                    if isTaxable {
                        HStack {
                            Text("GST (18%)")
                            Spacer()
                            Text(FinancialCalculator.shared.formatCurrency(taxAmount))
                        }
                    }
                    
                    HStack {
                        Text("Final Payable Total")
                            .fontWeight(.bold)
                        Spacer()
                        Text(FinancialCalculator.shared.formatCurrency(finalTotal))
                            .fontWeight(.bold)
                            .foregroundColor(theme.accentColor)
                    }
                    
                    HStack {
                        Text("Advance Payment Received")
                        Spacer()
                        TextField("0", value: $advancePayment, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }
                    
                    HStack {
                        Text("Net Balance Due")
                            .fontWeight(.bold)
                        Spacer()
                        Text(FinancialCalculator.shared.formatCurrency(balanceDue))
                            .fontWeight(.bold)
                            .foregroundColor(balanceDue > 0 ? .orange : .green)
                    }
                }
                
                // Section 4: Operational Assignments & Project Schedule
                Section(header: Text("Project Milestones & Account Manager")) {
                    DatePicker("Project Start Date", selection: $projectStartDate, displayedComponents: .date)
                    DatePicker("Target Due Date", selection: $dueDate, displayedComponents: .date)
                    
                    Picker("Assigned Account Manager", selection: $selectedWorkerId) {
                        Text("Gauresh Khairnar (OWNER)").tag("")
                        ForEach(store.workers) { worker in
                            Text("\(worker.fullName) (\(worker.jobTitle))").tag(worker.id)
                        }
                    }
                    
                    TextField("Payment Terms", text: $paymentTerms)
                }
                
                // Section 5: Notes & Brief
                Section(header: Text("Notes & Business Intelligence")) {
                    TextEditor(text: $notesText)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle(clientToEdit == nil ? "New Client" : "Edit Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Client") {
                        saveClientRecord()
                    }
                    .fontWeight(.bold)
                }
            }
            .alert("Validation Error", isPresented: $showingValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationMessage)
            }
            .onAppear {
                loadExistingIfEditing()
            }
        }
    }
    
    private func loadExistingIfEditing() {
        guard let c = clientToEdit else { return }
        name = c.name
        companyName = c.companyName
        email = c.email
        phone = c.phone
        whatsapp = c.whatsapp ?? ""
        businessCategory = c.businessCategory
        address = c.address
        website = c.website ?? ""
        leadSource = c.leadSource
        status = c.status
        selectedPackageIds = Set(c.packageIds)
        selectedWorkerId = c.assignedWorkerId ?? ""
        notesText = c.notes.last?.content ?? ""
    }
    
    private func saveClientRecord() {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please enter the client's name."
            showingValidationError = true
            return
        }
        
        let assignedWorker = store.workers.first(where: { $0.id == selectedWorkerId })
        var notesList: [ClientNote] = []
        if !notesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            notesList.append(ClientNote(content: notesText))
        }
        
        if let existing = clientToEdit {
            var updated = existing
            updated.name = name
            updated.companyName = companyName
            updated.email = email
            updated.phone = phone
            updated.whatsapp = whatsapp.isEmpty ? nil : whatsapp
            updated.businessCategory = businessCategory
            updated.address = address
            updated.website = website.isEmpty ? nil : website
            updated.leadSource = leadSource
            updated.status = status
            updated.packageIds = Array(selectedPackageIds)
            updated.assignedWorkerId = selectedWorkerId.isEmpty ? nil : selectedWorkerId
            updated.assignedWorkerName = assignedWorker?.fullName ?? "Gauresh Khairnar"
            if !notesText.isEmpty {
                updated.notes.append(ClientNote(content: notesText))
            }
            updated.totalInvoiced = finalTotal
            updated.totalCollected = advancePayment
            updated.outstandingBalance = balanceDue
            store.updateClient(updated)
        } else {
            let newClient = Client(
                name: name,
                companyName: companyName,
                email: email,
                phone: phone,
                whatsapp: whatsapp.isEmpty ? nil : whatsapp,
                businessCategory: businessCategory,
                address: address,
                website: website.isEmpty ? nil : website,
                leadSource: leadSource,
                status: status,
                assignedWorkerId: selectedWorkerId.isEmpty ? nil : selectedWorkerId,
                assignedWorkerName: assignedWorker?.fullName ?? "Gauresh Khairnar",
                notes: notesList,
                packageIds: Array(selectedPackageIds),
                totalInvoiced: finalTotal,
                totalCollected: advancePayment,
                outstandingBalance: balanceDue
            )
            store.addClient(newClient)
            
            // If the client has commercial terms or packages, record invoice & advance payment in the financial ledger
            if finalTotal > 0 {
                var invoiceItems: [InvoiceItem] = []
                for pkgId in selectedPackageIds {
                    if let pkg = store.packages.first(where: { $0.id == pkgId }) {
                        invoiceItems.append(
                            InvoiceItem(
                                packageId: pkg.id,
                                title: pkg.name,
                                itemDescription: pkg.description,
                                quantity: 1,
                                unitPrice: pkg.basePrice,
                                discountAmount: 0.0,
                                taxRate: isTaxable ? taxRate : 0.0
                            )
                        )
                    }
                }
                if invoiceItems.isEmpty {
                    invoiceItems.append(
                        InvoiceItem(
                            title: "Contract Initiation Retainer",
                            itemDescription: "Services for \(companyName.isEmpty ? name : companyName)",
                            quantity: 1,
                            unitPrice: taxableAmount,
                            taxRate: isTaxable ? taxRate : 0.0
                        )
                    )
                }
                
                let invoice = Invoice(
                    invoiceNumber: store.generateNextInvoiceNumber(),
                    clientId: newClient.id,
                    clientName: newClient.name,
                    clientEmail: newClient.email,
                    clientPhone: newClient.phone,
                    clientAddress: newClient.address,
                    items: invoiceItems,
                    subtotal: subtotal,
                    discountType: isPercentageDiscount ? .percentage : .fixedAmount,
                    discountValue: discountValue,
                    discountAmount: discountAmount,
                    taxRate: isTaxable ? taxRate : 0.0,
                    taxAmount: taxAmount,
                    totalAmount: finalTotal,
                    amountPaid: advancePayment,
                    balanceDue: balanceDue,
                    status: (advancePayment >= finalTotal) ? .paid : ((advancePayment > 0) ? .partiallyPaid : .issued),
                    dueDate: dueDate,
                    paymentTerms: paymentTerms
                )
                store.addInvoice(invoice)
                
                if advancePayment > 0 {
                    let pmt = PaymentRecord(
                        invoiceId: invoice.id,
                        clientId: newClient.id,
                        amount: advancePayment,
                        paymentMethod: .bankTransfer,
                        transactionReference: "ADV-\(UUID().uuidString.prefix(8).uppercased())",
                        notes: "Advance payment settlement for \(newClient.name)"
                    )
                    store.recordPayment(pmt)
                }
            }
        }
        
        dismiss()
    }
}
