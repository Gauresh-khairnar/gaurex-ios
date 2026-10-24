//
//  Invoice.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import Foundation

public enum InvoiceStatus: String, Codable, CaseIterable, Identifiable {
    case draft = "Draft"
    case issued = "Issued"
    case partiallyPaid = "Partially Paid"
    case paid = "Paid"
    case overdue = "Overdue"
    case cancelled = "Cancelled"
    
    public var id: String { rawValue }
    
    public var badgeColorName: String {
        switch self {
        case .draft: return "gray"
        case .issued: return "blue"
        case .partiallyPaid: return "orange"
        case .paid: return "green"
        case .overdue: return "red"
        case .cancelled: return "secondary"
        }
    }
}

public struct InvoiceItem: Identifiable, Codable, Hashable {
    public var id: String
    public var packageId: String?
    public var title: String
    public var itemDescription: String
    public var quantity: Int
    public var unitPrice: Double
    public var discountAmount: Double
    public var taxRate: Double // e.g. 18.0%
    public var subtotal: Double
    public var total: Double
    
    public init(
        id: String = UUID().uuidString,
        packageId: String? = nil,
        title: String,
        itemDescription: String = "",
        quantity: Int = 1,
        unitPrice: Double,
        discountAmount: Double = 0.0,
        taxRate: Double = 18.0
    ) {
        self.id = id
        self.packageId = packageId
        self.title = title
        self.itemDescription = itemDescription
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.discountAmount = discountAmount
        self.taxRate = taxRate
        
        let sub = (Double(quantity) * unitPrice) - discountAmount
        self.subtotal = max(0.0, sub)
        let tax = self.subtotal * (taxRate / 100.0)
        self.total = self.subtotal + tax
    }
}

public struct Invoice: Identifiable, Codable, Hashable {
    public var id: String
    public var invoiceNumber: String
    public var clientId: String
    public var clientName: String
    public var clientEmail: String
    public var clientAddress: String
    public var issueDate: Date
    public var dueDate: Date
    public var items: [InvoiceItem]
    public var subtotal: Double
    public var discountTotal: Double
    public var taxTotal: Double
    public var totalAmount: Double
    public var advancePaid: Double
    public var balanceDue: Double
    public var status: InvoiceStatus
    public var paymentTerms: String
    public var notes: String
    public var paymentIds: [String]
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        invoiceNumber: String,
        clientId: String,
        clientName: String,
        clientEmail: String,
        clientAddress: String = "",
        issueDate: Date = Date(),
        dueDate: Date = Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date(),
        items: [InvoiceItem] = [],
        subtotal: Double = 0.0,
        discountTotal: Double = 0.0,
        taxTotal: Double = 0.0,
        totalAmount: Double = 0.0,
        advancePaid: Double = 0.0,
        balanceDue: Double = 0.0,
        status: InvoiceStatus = .draft,
        paymentTerms: String = "Payment due within 15 days of issue.",
        notes: String = "Thank you for partnering with GAUREX.",
        paymentIds: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.invoiceNumber = invoiceNumber
        self.clientId = clientId
        self.clientName = clientName
        self.clientEmail = clientEmail
        self.clientAddress = clientAddress
        self.issueDate = issueDate
        self.dueDate = dueDate
        self.items = items
        self.subtotal = subtotal
        self.discountTotal = discountTotal
        self.taxTotal = taxTotal
        self.totalAmount = totalAmount
        self.advancePaid = advancePaid
        self.balanceDue = balanceDue
        self.status = status
        self.paymentTerms = paymentTerms
        self.notes = notes
        self.paymentIds = paymentIds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
