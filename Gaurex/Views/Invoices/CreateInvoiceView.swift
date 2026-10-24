//
//  CreateInvoiceView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct CreateInvoiceView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    
    public var preselectedClientId: String?
    
    @State private var selectedClientId: String = ""
    @State private var invoiceNumber: String = ""
    @State private var issueDate: Date = Date()
    @State private var dueDate: Date = Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date()
    @State private var lineItems: [InvoiceItem] = []
    
    // Add Item Dialog
    @State private var itemTitle: String = ""
    @State private var itemDesc: String = ""
    @State private var itemQty: Int = 1
    @State private var itemUnitPrice: Double = 0.0
    @State private var selectedPackageId: String = ""
    
    @State private var isPercentageDiscount: Bool = false
    @State private var discountValue: Double = 0.0
    @State private var isTaxable: Bool = true
    @State private var taxRate: Double = 18.0
    @State private var advancePayment: Double = 0.0
    @State private var paymentTerms: String = "Payment due within 15 days of invoice date."
    @State private var invoiceNotes: String = "Thank you for partnering with GAUREX."
    
    @State private var errorMessage = ""
    @State private var showingError = false
    
    public init(preselectedClientId: String? = nil) {
        self.preselectedClientId = preselectedClientId
    }
    
    // Financial Calculation
    private var calculation: FinancialCalculationResult {
        FinancialCalculator.shared.calculateInvoice(
            items: lineItems,
            isPercentageDiscount: isPercentageDiscount,
            discountValue: discountValue,
            isTaxable: isTaxable,
            taxRate: taxRate,
            paymentsRecorded: advancePayment
        )
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                // Section 1: Client & Invoice Metadata
                Section(header: Text("Invoice Metadata")) {
                    Picker("Select Client *", selection: $selectedClientId) {
                        Text("Choose Client...").tag("")
                        ForEach(store.clients) { client in
                            Text("\(client.name) (\(client.companyName))").tag(client.id)
                        }
                    }
                    
                    HStack {
                        Text("Invoice Number")
                        Spacer()
                        Text(invoiceNumber)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.bold)
                    }
                    
                    DatePicker("Issue Date", selection: $issueDate, displayedComponents: .date)
                    DatePicker("Payment Due Date", selection: $dueDate, displayedComponents: .date)
                }
                
                // Section 2: Line Items
                Section(header: Text("Invoice Line Items (\(lineItems.count))")) {
                    ForEach(lineItems) { item in
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(item.title)
                                    .font(.system(size: 14, weight: .semibold))
                                Spacer()
                                Text(FinancialCalculator.shared.formatCurrency(item.total))
                                    .font(.system(size: 14, weight: .bold))
                            }
                            Text("Qty: \(item.quantity) × \(FinancialCalculator.shared.formatCurrency(item.unitPrice))")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete { indices in
                        lineItems.remove(atOffsets: indices)
                    }
                    
                    // Add Package / Item helper
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add Item from Packages:")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        Picker("Select Package", selection: $selectedPackageId) {
                            Text("Select a service package...").tag("")
                            ForEach(store.packages.filter { $0.isActive }) { pkg in
                                Text("\(pkg.name) - \(FinancialCalculator.shared.formatCurrency(pkg.basePrice))").tag(pkg.id)
                            }
                        }
                        
                        Button {
                            if let pkg = store.packages.first(where: { $0.id == selectedPackageId }) {
                                let newItem = InvoiceItem(
                                    packageId: pkg.id,
                                    title: pkg.name,
                                    itemDescription: pkg.description,
                                    quantity: 1,
                                    unitPrice: pkg.basePrice,
                                    taxRate: taxRate
                                )
                                lineItems.append(newItem)
                                selectedPackageId = ""
                            }
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Package to Invoice")
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(selectedPackageId.isEmpty ? .secondary : theme.accentColor)
                        }
                        .disabled(selectedPackageId.isEmpty)
                    }
                    .padding(.vertical, 4)
                }
                
                // Section 3: Tax & Commercials
                Section(header: Text("Taxes & Financial Totals")) {
                    HStack {
                        Text("Subtotal")
                        Spacer()
                        Text(FinancialCalculator.shared.formatCurrency(calculation.subtotal))
                    }
                    
                    Toggle("Discount as Percentage (%)", isOn: $isPercentageDiscount)
                    
                    HStack {
                        Text(isPercentageDiscount ? "Discount (%)" : "Discount Amount (₹)")
                        Spacer()
                        TextField("0", value: $discountValue, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 90)
                    }
                    
                    Toggle("Apply GST (18%)", isOn: $isTaxable)
                    
                    if isTaxable {
                        HStack {
                            Text("GST (18%)")
                            Spacer()
                            Text(FinancialCalculator.shared.formatCurrency(calculation.taxAmount))
                        }
                    }
                    
                    HStack {
                        Text("Final Payable Total")
                            .fontWeight(.bold)
                        Spacer()
                        Text(FinancialCalculator.shared.formatCurrency(calculation.finalTotal))
                            .fontWeight(.bold)
                            .foregroundColor(theme.accentColor)
                    }
                    
                    HStack {
                        Text("Advance Payment Recorded")
                        Spacer()
                        TextField("0", value: $advancePayment, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Balance Due")
                            .fontWeight(.bold)
                        Spacer()
                        Text(FinancialCalculator.shared.formatCurrency(calculation.balanceDue))
                            .fontWeight(.bold)
                            .foregroundColor(calculation.balanceDue > 0 ? .orange : .green)
                    }
                }
                
                // Section 4: Terms & Notes
                Section(header: Text("Terms & Settlement Notes")) {
                    TextField("Payment Terms", text: $paymentTerms)
                    TextField("Invoice Notes", text: $invoiceNotes)
                }
            }
            .navigationTitle("New Invoice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Issue Invoice") {
                        saveInvoice()
                    }
                    .fontWeight(.bold)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                if let pre = preselectedClientId {
                    selectedClientId = pre
                }
                invoiceNumber = store.generateNextInvoiceNumber()
            }
        }
    }
    
    private func saveInvoice() {
        guard let client = store.clients.first(where: { $0.id == selectedClientId }) else {
            errorMessage = "Please select a client."
            showingError = true
            return
        }
        
        if lineItems.isEmpty {
            errorMessage = "Please add at least one line item to the invoice."
            showingError = true
            return
        }
        
        let calc = calculation
        var inv = Invoice(
            invoiceNumber: invoiceNumber,
            clientId: client.id,
            clientName: client.companyName.isEmpty ? client.name : "\(client.name) (\(client.companyName))",
            clientEmail: client.email,
            clientAddress: client.address,
            issueDate: issueDate,
            dueDate: dueDate,
            items: lineItems,
            subtotal: calc.subtotal,
            discountTotal: calc.discountAmount,
            taxTotal: calc.taxAmount,
            totalAmount: calc.finalTotal,
            advancePaid: advancePayment,
            balanceDue: calc.balanceDue,
            status: calc.balanceDue <= 0.01 ? .paid : (advancePayment > 0 ? .partiallyPaid : .issued),
            paymentTerms: paymentTerms,
            notes: invoiceNotes
        )
        
        if advancePayment > 0 {
            let payment = PaymentRecord(
                invoiceId: inv.id,
                clientId: client.id,
                amount: advancePayment,
                paymentMethod: .bankTransfer,
                transactionReference: "ADV-\(inv.invoiceNumber)",
                notes: "Advance payment settled upon invoice issuance."
            )
            store.payments.insert(payment, at: 0)
            store.savePayments()
            inv.paymentIds.append(payment.id)
        }
        
        store.addInvoice(inv)
        dismiss()
    }
}
