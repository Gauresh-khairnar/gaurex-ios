//
//  DocumentVaultItem.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import Foundation

public enum DocumentCategory: String, Codable, CaseIterable, Identifiable {
    case contract = "Client Contract"
    case proposal = "Sales Proposal"
    case invoice = "Customer Invoice"
    case receipt = "Business Expense Receipt"
    case project = "Project Deliverable"
    case employee = "Employee Agreement"
    case salarySlip = "Payslip Archive"
    case compliance = "Legal & Compliance"
    case misc = "Miscellaneous"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .contract: return "doc.text.fill"
        case .proposal: return "newspaper.fill"
        case .invoice: return "doc.plaintext.fill"
        case .receipt: return "receipt.fill"
        case .project: return "folder.fill"
        case .employee: return "person.text.rectangle.fill"
        case .salarySlip: return "banknote.fill"
        case .compliance: return "checkmark.shield.fill"
        case .misc: return "doc.fill"
        }
    }
}

public struct ExtractedDocumentFields: Codable, Hashable {
    public var detectedType: String?
    public var documentNumber: String?
    public var entityName: String?
    public var dateString: String?
    public var totalAmount: Double?
    public var taxAmount: Double?
    public var currency: String?
    public var confidenceScore: Double // 0.0 to 1.0
    
    public init(
        detectedType: String? = nil,
        documentNumber: String? = nil,
        entityName: String? = nil,
        dateString: String? = nil,
        totalAmount: Double? = nil,
        taxAmount: Double? = nil,
        currency: String? = "INR",
        confidenceScore: Double = 0.90
    ) {
        self.detectedType = detectedType
        self.documentNumber = documentNumber
        self.entityName = entityName
        self.dateString = dateString
        self.totalAmount = totalAmount
        self.taxAmount = taxAmount
        self.currency = currency
        self.confidenceScore = confidenceScore
    }
}

public struct VaultDocument: Identifiable, Codable, Hashable {
    public var id: String
    public var title: String
    public var category: DocumentCategory
    public var fileName: String
    public var fileSizeBytes: Int
    public var mimeType: String
    public var createdAt: Date
    public var tags: [String]
    public var relatedEntityId: String?
    public var extractedFields: ExtractedDocumentFields?
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        category: DocumentCategory = .misc,
        fileName: String,
        fileSizeBytes: Int = 1024,
        mimeType: String = "application/pdf",
        createdAt: Date = Date(),
        tags: [String] = [],
        relatedEntityId: String? = nil,
        extractedFields: ExtractedDocumentFields? = nil
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.fileName = fileName
        self.fileSizeBytes = fileSizeBytes
        self.mimeType = mimeType
        self.createdAt = createdAt
        self.tags = tags
        self.relatedEntityId = relatedEntityId
        self.extractedFields = extractedFields
    }
    
    public var formattedSize: String {
        let kb = Double(fileSizeBytes) / 1024.0
        if kb < 1024 {
            return String(format: "%.1f KB", kb)
        } else {
            return String(format: "%.2f MB", kb / 1024.0)
        }
    }
}
