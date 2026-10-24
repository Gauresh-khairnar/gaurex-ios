//
//  InvoiceDetailView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct InvoiceDetailView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    
    public var invoice: Invoice
    
    @State private var showingPDFPreview = false
    @State private var showingRecordPaymentSheet = false
    @State private var paymentAmount: Double = 0.0
    @State private var paymentMethod: PaymentMethod = .bankTransfer
    @State private var paymentReference: String = ""
    @State private var paymentNotes: String = ""
    
    public init(invoice: Invoice) {
        self.invoice = invoice
    }
    
    private var currentInvoice: Invoice {
        store.invoices.first(where: { $0.id == invoice.id }) ?? invoice
    }
    
    private var associatedClient: Client? {
        store.clients.first(where: { $0.id == currentInvoice.clientId })
    }
    
    private var invoicePayments: [PaymentRecord] {
        store.payments.filter { $0.invoiceId == currentInvoice.id }
    }
    
    public var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Top Overview Card
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(currentInvoice.invoiceNumber)
                                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                                    Text(currentInvoice.clientName)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                StatusBadge(
                                    text: currentInvoice.status.rawValue,
                                    color: currentInvoice.status == .paid ? .green : (currentInvoice.status == .partiallyPaid ? .orange : (currentInvoice.status == .overdue ? .red : .blue))
                                )
                            }
                            
                            Divider().background(theme.glassBorderColor)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("ISSUE DATE")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.secondary)
                                    Text(currentInvoice.issueDate, style: .date)
                                        .font(.system(size: 12, weight: .medium))
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("PAYMENT DUE DATE")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.secondary)
                                    Text(currentInvoice.dueDate, style: .date)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(currentInvoice.dueDate < Date() && currentInvoice.status != .paid ? .red : .primary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // PDF Preview & Print Action Card
                    GlassCard {
                        HStack(spacing: 12) {
                            Button {
                                showingPDFPreview = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "doc.viewfinder")
                                    Text("Preview Official PDF")
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(theme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(theme.glassBorderColor, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                            
                            if currentInvoice.balanceDue > 0 {
                                Button {
                                    paymentAmount = currentInvoice.balanceDue
                                    showingRecordPaymentSheet = true
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "creditcard.fill")
                                        Text("Record Payment")
                                    }
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Line Items
                    VStack(alignment: .leading, spacing: 10) {
                        Text("LINE ITEMS")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                        
                        VStack(spacing: 8) {
                            ForEach(currentInvoice.items) { item in
                                GlassCard(padding: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(item.title)
                                                .font(.system(size: 14, weight: .semibold))
                                            Spacer()
                                            Text(FinancialCalculator.shared.formatCurrency(item.total))
                                                .font(.system(size: 14, weight: .bold))
                                        }
                                        if !item.itemDescription.isEmpty {
                                            Text(item.itemDescription)
                                                .font(.system(size: 11))
                                                .foregroundColor(.secondary)
                                        }
                                        Text("Qty: \(item.quantity) × \(FinancialCalculator.shared.formatCurrency(item.unitPrice)) | Tax: \(String(format: "%.0f%%", item.taxRate))")
                                            .font(.system(size: 10))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Financial Breakdown
                    GlassCard {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Subtotal")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(FinancialCalculator.shared.formatCurrency(currentInvoice.subtotal))
                                    .font(.system(size: 13))
                            }
                            if currentInvoice.discountTotal > 0 {
                                HStack {
                                    Text("Discount")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("-\(FinancialCalculator.shared.formatCurrency(currentInvoice.discountTotal))")
                                        .font(.system(size: 13))
                                        .foregroundColor(.green)
                                }
                            }
                            HStack {
                                Text("Taxes & GST (18%)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(FinancialCalculator.shared.formatCurrency(currentInvoice.taxTotal))
                                    .font(.system(size: 13))
                            }
                            Divider().background(theme.glassBorderColor)
                            HStack {
                                Text("Final Invoice Total")
                                    .font(.system(size: 15, weight: .bold))
                                Spacer()
                                Text(FinancialCalculator.shared.formatCurrency(currentInvoice.totalAmount))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(theme.accentColor)
                            }
                            HStack {
                                Text("Recorded Payments")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(FinancialCalculator.shared.formatCurrency(currentInvoice.advancePaid))
                                    .font(.system(size: 13))
                                    .foregroundColor(.green)
                            }
                            HStack {
                                Text("Balance Due")
                                    .font(.system(size: 14, weight: .bold))
                                Spacer()
                                Text(FinancialCalculator.shared.formatCurrency(currentInvoice.balanceDue))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(currentInvoice.balanceDue > 0 ? .orange : .green)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Payment History
                    if !invoicePayments.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("PAYMENT TRANSACTION LOG")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                            
                            VStack(spacing: 8) {
                                ForEach(invoicePayments) { payment in
                                    GlassCard(padding: 12) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                HStack(spacing: 6) {
                                                    Text(payment.paymentMethod.rawValue)
                                                        .font(.system(size: 13, weight: .semibold))
                                                    if payment.isRefunded {
                                                        StatusBadge(text: "REFUNDED", color: .red)
                                                    }
                                                }
                                                Text("Ref: \(payment.transactionReference.isEmpty ? "Direct" : payment.transactionReference)")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(.secondary)
                                                if let reason = payment.refundReason, payment.isRefunded {
                                                    Text("Reason: \(reason)")
                                                        .font(.system(size: 10))
                                                        .foregroundColor(.red.opacity(0.8))
                                                }
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 2) {
                                                Text(FinancialCalculator.shared.formatCurrency(payment.amount))
                                                    .font(.system(size: 13, weight: .bold))
                                                    .foregroundColor(payment.isRefunded ? .secondary : .green)
                                                    .strikethrough(payment.isRefunded, color: .secondary)
                                                Text(payment.paymentDate, style: .date)
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.secondary)
                                                
                                                if !payment.isRefunded {
                                                    Button("Refund") {
                                                        store.refundPayment(paymentId: payment.id, reason: "Customer requested reversal")
                                                    }
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundColor(.red)
                                                    .padding(.top, 2)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // Cancel Invoice Option
                    if currentInvoice.status != .cancelled && currentInvoice.status != .paid {
                        Button(role: .destructive) {
                            store.cancelInvoice(id: currentInvoice.id, reason: "Voided by Owner")
                        } label: {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                Text("Cancel & Void Invoice")
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                    }
                    
                    // Bottom Spacer
                    Spacer().frame(height: 80)
                }
                .padding(.vertical, 12)
            }
        }
        .navigationTitle(currentInvoice.invoiceNumber)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPDFPreview) {
            let client = associatedClient ?? Client(name: currentInvoice.clientName, companyName: "", email: currentInvoice.clientEmail, phone: "")
            let pdf = PDFGeneratorService.shared.generateInvoicePDF(invoice: currentInvoice, client: client, business: store.settings)
            PDFPreviewView(pdfData: pdf, documentTitle: "Invoice \(currentInvoice.invoiceNumber)")
        }
        .sheet(isPresented: $showingRecordPaymentSheet) {
            NavigationStack {
                Form {
                    Section(header: Text("Payment Details")) {
                        HStack {
                            Text("Payment Amount (₹)")
                            Spacer()
                            TextField("Amount", value: $paymentAmount, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        Picker("Payment Method", selection: $paymentMethod) {
                            ForEach(PaymentMethod.allCases) { m in
                                Text(m.rawValue).tag(m)
                            }
                        }
                        
                        TextField("Transaction / UTR Reference", text: $paymentReference)
                        TextField("Notes / Ledger memo", text: $paymentNotes)
                    }
                }
                .navigationTitle("Record Payment")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingRecordPaymentSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Confirm Payment") {
                            store.recordPayment(
                                for: currentInvoice.id,
                                amount: paymentAmount,
                                method: paymentMethod,
                                reference: paymentReference,
                                notes: paymentNotes
                            )
                            showingRecordPaymentSheet = false
                        }
                        .fontWeight(.bold)
                    }
                }
            }
        }
    }
}
