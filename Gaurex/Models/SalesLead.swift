//
//  SalesLead.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import Foundation

public enum SalesStage: String, Codable, CaseIterable, Identifiable {
    case newLead = "New Lead"
    case contacted = "Contacted"
    case meetingScheduled = "Meeting Scheduled"
    case proposalSent = "Proposal Sent"
    case negotiation = "Negotiation"
    case won = "Closed Won"
    case lost = "Closed Lost"
    
    public var id: String { rawValue }
    
    public var stageColorName: String {
        switch self {
        case .newLead: return "gray"
        case .contacted: return "blue"
        case .meetingScheduled: return "purple"
        case .proposalSent: return "orange"
        case .negotiation: return "yellow"
        case .won: return "green"
        case .lost: return "red"
        }
    }
}

public struct LeadFollowUp: Identifiable, Codable, Hashable {
    public var id: String
    public var scheduledDate: Date
    public var notes: String
    public var isCompleted: Bool
    public var completedAt: Date?
    
    public init(id: String = UUID().uuidString, scheduledDate: Date, notes: String, isCompleted: Bool = false, completedAt: Date? = nil) {
        self.id = id
        self.scheduledDate = scheduledDate
        self.notes = notes
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }
}

public struct SalesLead: Identifiable, Codable, Hashable {
    public var id: String
    public var clientName: String
    public var companyName: String
    public var email: String
    public var phone: String
    public var stage: SalesStage
    public var expectedDealValue: Double
    public var currency: String
    public var closingProbability: Double // 0.0 to 1.0 (e.g. 0.60 for 60%)
    public var expectedClosingDate: Date
    public var nextFollowUpDate: Date?
    public var nextAction: String
    public var assignedEmployeeName: String
    public var lossReason: String?
    public var notes: String
    public var followUps: [LeadFollowUp]
    public var createdAt: Date
    
    public init(
        id: String = UUID().uuidString,
        clientName: String,
        companyName: String,
        email: String,
        phone: String,
        stage: SalesStage = .newLead,
        expectedDealValue: Double = 0.0,
        currency: String = "INR",
        closingProbability: Double = 0.20,
        expectedClosingDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
        nextFollowUpDate: Date? = Calendar.current.date(byAdding: .day, value: 2, to: Date()),
        nextAction: String = "Introductory call",
        assignedEmployeeName: String = "Gauresh Khairnar (OWNER)",
        lossReason: String? = nil,
        notes: String = "",
        followUps: [LeadFollowUp] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.clientName = clientName
        self.companyName = companyName
        self.email = email
        self.phone = phone
        self.stage = stage
        self.expectedDealValue = expectedDealValue
        self.currency = currency
        self.closingProbability = max(0.0, min(1.0, closingProbability))
        self.expectedClosingDate = expectedClosingDate
        self.nextFollowUpDate = nextFollowUpDate
        self.nextAction = nextAction
        self.assignedEmployeeName = assignedEmployeeName
        self.lossReason = lossReason
        self.notes = notes
        self.followUps = followUps
        self.createdAt = createdAt
    }
    
    // Weighted value = Expected Deal Value × Closing Probability
    public var weightedValue: Double {
        expectedDealValue * closingProbability
    }
}
