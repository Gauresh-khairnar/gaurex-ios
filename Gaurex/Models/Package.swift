//
//  Package.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import Foundation

public enum PackageCategory: String, Codable, CaseIterable, Identifiable {
    case softwareDevelopment = "Software Development"
    case mobileApps = "Mobile Apps (iOS/Android)"
    case aiAutomation = "AI & Workflow Automation"
    case cloudDevOps = "Cloud & DevOps"
    case enterpriseSolutions = "Enterprise Solutions"
    case maintenanceRetainer = "Maintenance & Retainer"
    case consulting = "Strategic Tech Consulting"
    
    public var id: String { rawValue }
}

public enum BillingType: String, Codable, CaseIterable, Identifiable {
    case oneTime = "One-Time Project"
    case monthly = "Monthly Retainer"
    case quarterly = "Quarterly Retainer"
    case annual = "Annual Contract"
    case custom = "Custom Milestone"
    
    public var id: String { rawValue }
}

public struct BusinessPackage: Identifiable, Codable, Hashable {
    public var id: String
    public var name: String
    public var description: String
    public var category: PackageCategory
    public var basePrice: Double
    public var currency: String
    public var billingType: BillingType
    public var features: [String]
    public var deliverables: [String]
    public var discountPercentage: Double?
    public var discountAmount: Double?
    public var isTaxable: Bool
    public var taxRate: Double // e.g. 18.0 for 18% GST
    public var isActive: Bool
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        category: PackageCategory = .softwareDevelopment,
        basePrice: Double,
        currency: String = "INR",
        billingType: BillingType = .oneTime,
        features: [String] = [],
        deliverables: [String] = [],
        discountPercentage: Double? = nil,
        discountAmount: Double? = nil,
        isTaxable: Bool = true,
        taxRate: Double = 18.0,
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.basePrice = basePrice
        self.currency = currency
        self.billingType = billingType
        self.features = features
        self.deliverables = deliverables
        self.discountPercentage = discountPercentage
        self.discountAmount = discountAmount
        self.isTaxable = isTaxable
        self.taxRate = taxRate
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
