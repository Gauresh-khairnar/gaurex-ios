//
//  Client.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import Foundation

public enum ClientStatus: String, Codable, CaseIterable, Identifiable {
    case prospective = "Prospective"
    case active = "Active"
    case completed = "Completed"
    case onHold = "On Hold"
    case inactive = "Inactive"
    case archived = "Archived"
    
    public var id: String { rawValue }
    
    public var systemColorName: String {
        switch self {
        case .prospective: return "orange"
        case .active: return "green"
        case .completed: return "blue"
        case .onHold: return "yellow"
        case .inactive: return "gray"
        case .archived: return "purple"
        }
    }
}

public enum LeadSource: String, Codable, CaseIterable, Identifiable {
    case referral = "Client Referral"
    case directInquiry = "Direct Website"
    case linkedin = "LinkedIn / Social"
    case partner = "Strategic Partner"
    case outbound = "Executive Outreach"
    case other = "Other"
    
    public var id: String { rawValue }
}

public struct ClientNote: Identifiable, Codable, Hashable {
    public var id: String
    public var timestamp: Date
    public var author: String
    public var content: String
    
    public init(id: String = UUID().uuidString, timestamp: Date = Date(), author: String = "Gauresh Khairnar", content: String) {
        self.id = id
        self.timestamp = timestamp
        self.author = author
        self.content = content
    }
}

public struct Client: Identifiable, Codable, Hashable {
    public var id: String
    public var name: String
    public var companyName: String
    public var email: String
    public var phone: String
    public var whatsapp: String?
    public var businessCategory: String
    public var address: String
    public var website: String?
    public var leadSource: LeadSource
    public var status: ClientStatus
    public var assignedWorkerId: String?
    public var assignedWorkerName: String?
    public var notes: [ClientNote]
    public var createdAt: Date
    public var packageIds: [String]
    public var projectStatus: String
    public var totalInvoiced: Double
    public var totalCollected: Double
    public var outstandingBalance: Double
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        companyName: String,
        email: String,
        phone: String,
        whatsapp: String? = nil,
        businessCategory: String = "Technology & IT",
        address: String = "",
        website: String? = nil,
        leadSource: LeadSource = .directInquiry,
        status: ClientStatus = .active,
        assignedWorkerId: String? = nil,
        assignedWorkerName: String? = nil,
        notes: [ClientNote] = [],
        createdAt: Date = Date(),
        packageIds: [String] = [],
        projectStatus: String = "In Progress",
        totalInvoiced: Double = 0.0,
        totalCollected: Double = 0.0,
        outstandingBalance: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.companyName = companyName
        self.email = email
        self.phone = phone
        self.whatsapp = whatsapp
        self.businessCategory = businessCategory
        self.address = address
        self.website = website
        self.leadSource = leadSource
        self.status = status
        self.assignedWorkerId = assignedWorkerId
        self.assignedWorkerName = assignedWorkerName
        self.notes = notes
        self.createdAt = createdAt
        self.packageIds = packageIds
        self.projectStatus = projectStatus
        self.totalInvoiced = totalInvoiced
        self.totalCollected = totalCollected
        self.outstandingBalance = outstandingBalance
    }
}
