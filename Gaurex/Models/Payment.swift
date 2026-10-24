//
//  Payment.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import Foundation

public enum PaymentMethod: String, Codable, CaseIterable, Identifiable {
    case bankTransfer = "NEFT / RTGS / Bank Wire"
    case upi = "UPI (GPay / PhonePe / BHIM)"
    case creditDebitCard = "Corporate Card"
    case stripeOrRazorpay = "Online Gateway"
    case cheque = "Cheque"
    case cash = "Cash"
    
    public var id: String { rawValue }
}

public struct PaymentRecord: Identifiable, Codable, Hashable {
    public var id: String
    public var invoiceId: String
    public var clientId: String
    public var amount: Double
    public var paymentDate: Date
    public var paymentMethod: PaymentMethod
    public var transactionReference: String
    public var notes: String
    public var recordedBy: String
    public var isRefunded: Bool
    public var refundReason: String?
    public var createdAt: Date
    
    public init(
        id: String = UUID().uuidString,
        invoiceId: String,
        clientId: String,
        amount: Double,
        paymentDate: Date = Date(),
        paymentMethod: PaymentMethod = .bankTransfer,
        transactionReference: String,
        notes: String = "",
        recordedBy: String = "Gauresh Khairnar (OWNER)",
        isRefunded: Bool = false,
        refundReason: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.invoiceId = invoiceId
        self.clientId = clientId
        self.amount = amount
        self.paymentDate = paymentDate
        self.paymentMethod = paymentMethod
        self.transactionReference = transactionReference
        self.notes = notes
        self.recordedBy = recordedBy
        self.isRefunded = isRefunded
        self.refundReason = refundReason
        self.createdAt = createdAt
    }
}
