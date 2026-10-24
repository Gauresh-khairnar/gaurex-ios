//
//  FinancialCalculationsTests.swift
//  GAUREX Dashboard Tests
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import XCTest
@testable import Gaurex

final class FinancialCalculationsTests: XCTestCase {
    
    func testInvoiceCalculationWithFixedDiscountAndTax() {
        let items = [
            InvoiceItem(title: "iOS App Development", quantity: 1, unitPrice: 350000.0),
            InvoiceItem(title: "Cloud Infrastructure Setup", quantity: 1, unitPrice: 50000.0)
        ]
        
        let result = FinancialCalculator.shared.calculateInvoice(
            items: items,
            isPercentageDiscount: false,
            discountValue: 20000.0,
            isTaxable: true,
            taxRate: 18.0,
            paymentsRecorded: 100000.0
        )
        
        // Subtotal = 350,000 + 50,000 = 400,000
        XCTAssertEqual(result.subtotal, 400000.0, accuracy: 0.01)
        // Discount = 20,000
        XCTAssertEqual(result.discountAmount, 20000.0, accuracy: 0.01)
        // Taxable = 380,000
        XCTAssertEqual(result.taxableAmount, 380000.0, accuracy: 0.01)
        // Tax (18%) = 380,000 * 0.18 = 68,400
        XCTAssertEqual(result.taxAmount, 68400.0, accuracy: 0.01)
        // Final Total = 380,000 + 68,400 = 448,400
        XCTAssertEqual(result.finalTotal, 448400.0, accuracy: 0.01)
        // Balance Due = 448,400 - 100,000 = 348,400
        XCTAssertEqual(result.balanceDue, 348400.0, accuracy: 0.01)
    }
    
    func testInvoiceCalculationWithPercentageDiscount() {
        let items = [
            InvoiceItem(title: "AI Workflow Agent", quantity: 1, unitPrice: 200000.0)
        ]
        
        let result = FinancialCalculator.shared.calculateInvoice(
            items: items,
            isPercentageDiscount: true,
            discountValue: 10.0, // 10% discount
            isTaxable: true,
            taxRate: 18.0,
            paymentsRecorded: 0.0
        )
        
        // Subtotal = 200,000
        XCTAssertEqual(result.subtotal, 200000.0, accuracy: 0.01)
        // Discount 10% = 20,000
        XCTAssertEqual(result.discountAmount, 20000.0, accuracy: 0.01)
        // Taxable = 180,000
        XCTAssertEqual(result.taxableAmount, 180000.0, accuracy: 0.01)
        // Tax 18% = 32,400
        XCTAssertEqual(result.taxAmount, 32400.0, accuracy: 0.01)
        // Final Total = 212,400
        XCTAssertEqual(result.finalTotal, 212400.0, accuracy: 0.01)
        XCTAssertEqual(result.balanceDue, 212400.0, accuracy: 0.01)
    }
    
    func testNetOperatingIncomeCalculation() {
        let revenueCollected = 500000.0
        let monthlyExpenses = 60000.0
        let payrollExpenses = 140000.0
        
        let net = FinancialCalculator.shared.calculateNetOperatingIncome(
            revenueCollected: revenueCollected,
            monthlyExpenses: monthlyExpenses,
            payrollExpenses: payrollExpenses
        )
        
        // Net = 500,000 - 60,000 - 140,000 = 300,000
        XCTAssertEqual(net, 300000.0, accuracy: 0.01)
    }
    
    func testInvoiceItemGuardsAgainstNegativeValues() {
        // Test defensive bounds protection
        let item = InvoiceItem(
            title: "Security Hardening",
            quantity: -2,
            unitPrice: -5000.0,
            discountAmount: -200.0,
            taxRate: -18.0
        )
        
        XCTAssertGreaterThanOrEqual(item.quantity, 1)
        XCTAssertGreaterThanOrEqual(item.unitPrice, 0.0)
        XCTAssertGreaterThanOrEqual(item.discountAmount, 0.0)
        XCTAssertGreaterThanOrEqual(item.taxRate, 0.0)
        XCTAssertGreaterThanOrEqual(item.subtotal, 0.0)
        XCTAssertGreaterThanOrEqual(item.total, 0.0)
    }
    
    func testPaymentRefundAndReversalAccounting() {
        let store = FirestoreDataStore.shared
        let client = Client(name: "Audit Client", companyName: "Audit Labs", email: "audit@client.com", phone: "111")
        store.addClient(client)
        
        let invoice = Invoice(
            invoiceNumber: "GX-TEST-REFUND",
            clientId: client.id,
            clientName: client.name,
            clientEmail: client.email,
            totalAmount: 100000.0,
            balanceDue: 100000.0,
            status: .issued
        )
        store.addInvoice(invoice)
        
        // 1. Record payment of 40,000
        store.recordPayment(for: invoice.id, amount: 40000.0, method: .bankTransfer, reference: "REFUND-TXN-01", notes: "First payment")
        
        let updatedInvoice = store.invoices.first(where: { $0.id == invoice.id })
        XCTAssertEqual(updatedInvoice?.balanceDue, 60000.0, accuracy: 0.01)
        XCTAssertEqual(updatedInvoice?.status, .partiallyPaid)
        
        let paymentRecord = store.payments.first(where: { $0.invoiceId == invoice.id })
        XCTAssertNotNil(paymentRecord)
        
        // 2. Refund the payment
        if let pId = paymentRecord?.id {
            store.refundPayment(paymentId: pId, reason: "Accidental overcharge reversal")
            
            let postRefundInvoice = store.invoices.first(where: { $0.id == invoice.id })
            XCTAssertEqual(postRefundInvoice?.balanceDue, 100000.0, accuracy: 0.01)
            XCTAssertEqual(postRefundInvoice?.advancePaid, 0.0, accuracy: 0.01)
            
            let clientAfterRefund = store.clients.first(where: { $0.id == client.id })
            XCTAssertEqual(clientAfterRefund?.totalCollected, 0.0, accuracy: 0.01)
            XCTAssertEqual(clientAfterRefund?.outstandingBalance, 100000.0, accuracy: 0.01)
        }
    }
}
