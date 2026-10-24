//
//  BusinessEntities.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import Foundation

public enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    case cloudInfrastructure = "Cloud & Servers (AWS/GCP/Vercel)"
    case softwareLicenses = "Software & SaaS Subscriptions"
    case officeHardware = "Office & Tech Hardware"
    case legalAccounting = "Legal & Accounting Compliance"
    case marketingSales = "Marketing, Branding & Ads"
    case contractorVendor = "Subcontractors & Freelancers"
    case miscellaneous = "Miscellaneous Operations"
    
    public var id: String { rawValue }
}

public struct Expense: Identifiable, Codable, Hashable {
    public var id: String
    public var title: String
    public var category: ExpenseCategory
    public var amount: Double
    public var date: Date
    public var paymentMethod: PaymentMethod
    public var vendorName: String
    public var receiptUrl: String?
    public var notes: String
    public var recordedBy: String
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        category: ExpenseCategory = .cloudInfrastructure,
        amount: Double,
        date: Date = Date(),
        paymentMethod: PaymentMethod = .creditDebitCard,
        vendorName: String = "",
        receiptUrl: String? = nil,
        notes: String = "",
        recordedBy: String = "Gauresh Khairnar (OWNER)"
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.amount = amount
        self.date = date
        self.paymentMethod = paymentMethod
        self.vendorName = vendorName
        self.receiptUrl = receiptUrl
        self.notes = notes
        self.recordedBy = recordedBy
    }
}

public enum ProjectStatus: String, Codable, CaseIterable, Identifiable {
    case planning = "Planning & Architecture"
    case inProgress = "In Active Development"
    case codeReview = "Code Review & QA"
    case completed = "Production Delivered"
    case onHold = "On Hold"
    
    public var id: String { rawValue }
    
    public var badgeColor: String {
        switch self {
        case .planning: return "orange"
        case .inProgress: return "blue"
        case .codeReview: return "purple"
        case .completed: return "green"
        case .onHold: return "gray"
        }
    }
}

public struct Project: Identifiable, Codable, Hashable {
    public var id: String
    public var clientId: String
    public var clientName: String
    public var title: String
    public var description: String
    public var status: ProjectStatus
    public var startDate: Date
    public var targetCompletionDate: Date
    public var assignedWorkerIds: [String]
    public var budget: Double
    public var completedMilestones: Int
    public var totalMilestones: Int
    
    public init(
        id: String = UUID().uuidString,
        clientId: String,
        clientName: String,
        title: String,
        description: String = "",
        status: ProjectStatus = .inProgress,
        startDate: Date = Date(),
        targetCompletionDate: Date = Calendar.current.date(byAdding: .month, value: 2, to: Date()) ?? Date(),
        assignedWorkerIds: [String] = [],
        budget: Double = 0.0,
        completedMilestones: Int = 0,
        totalMilestones: Int = 5
    ) {
        self.id = id
        self.clientId = clientId
        self.clientName = clientName
        self.title = title
        self.description = description
        self.status = status
        self.startDate = startDate
        self.targetCompletionDate = targetCompletionDate
        self.assignedWorkerIds = assignedWorkerIds
        self.budget = budget
        self.completedMilestones = completedMilestones
        self.totalMilestones = totalMilestones
    }
    
    public var progressFraction: Double {
        guard totalMilestones > 0 else { return 0.0 }
        return Double(completedMilestones) / Double(totalMilestones)
    }
}

public struct ActivityLog: Identifiable, Codable, Hashable {
    public var id: String
    public var timestamp: Date
    public var actorName: String
    public var actionType: String // "CREATED", "UPDATED", "DELETED", "DISBURSED", "SECURITY"
    public var entityType: String // "Invoice", "Payment", "Worker", "Client", "Package"
    public var entityId: String
    public var description: String
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        actorName: String = "Gauresh Khairnar (OWNER)",
        actionType: String,
        entityType: String,
        entityId: String,
        description: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.actorName = actorName
        self.actionType = actionType
        self.entityType = entityType
        self.entityId = entityId
        self.description = description
    }
}

public struct AIMessage: Identifiable, Codable, Hashable {
    public var id: String
    public var sender: String // "user" or "assistant"
    public var content: String
    public var timestamp: Date
    public var actionRecommendation: String?
    public var isForecastEstimate: Bool
    
    public init(
        id: String = UUID().uuidString,
        sender: String,
        content: String,
        timestamp: Date = Date(),
        actionRecommendation: String? = nil,
        isForecastEstimate: Bool = false
    ) {
        self.id = id
        self.sender = sender
        self.content = content
        self.timestamp = timestamp
        self.actionRecommendation = actionRecommendation
        self.isForecastEstimate = isForecastEstimate
    }
}
