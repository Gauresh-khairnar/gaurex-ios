//
//  Worker.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import Foundation

public enum EmploymentStatus: String, Codable, CaseIterable, Identifiable {
    case active = "Active Full-Time"
    case probation = "Probation"
    case contractor = "Retainer Contractor"
    case onLeave = "On Approved Leave"
    case noticePeriod = "Serving Notice"
    case archived = "Archived / Exited"
    
    public var id: String { rawValue }
    
    public var statusBadgeColor: String {
        switch self {
        case .active: return "green"
        case .probation: return "blue"
        case .contractor: return "purple"
        case .onLeave: return "orange"
        case .noticePeriod: return "yellow"
        case .archived: return "gray"
        }
    }
}

public struct BankAccountDetails: Codable, Hashable {
    public var bankName: String
    public var accountNumber: String
    public var ifscOrRouting: String
    public var accountHolderName: String
    public var upiId: String?
    
    public init(
        bankName: String = "",
        accountNumber: String = "",
        ifscOrRouting: String = "",
        accountHolderName: String = "",
        upiId: String? = nil
    ) {
        self.bankName = bankName
        self.accountNumber = accountNumber
        self.ifscOrRouting = ifscOrRouting
        self.accountHolderName = accountHolderName
        self.upiId = upiId
    }
    
    public var maskedAccountNumber: String {
        guard accountNumber.count > 4 else { return "••••" }
        let suffix = accountNumber.suffix(4)
        return "•••• •••• \(suffix)"
    }
}

public struct Worker: Identifiable, Codable, Hashable {
    public var id: String
    public var employeeId: String // e.g. GX-EMP-01
    public var fullName: String
    public var email: String
    public var phone: String
    public var jobTitle: String
    public var department: String
    public var dateOfJoining: Date
    public var employmentStatus: EmploymentStatus
    public var monthlySalary: Double
    public var bankDetails: BankAccountDetails
    public var assignedProjectIds: [String]
    public var annualLeaveQuota: Int
    public var leavesTaken: Int
    public var unpaidLeavesThisMonth: Int
    public var performanceNotes: String
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        employeeId: String,
        fullName: String,
        email: String,
        phone: String,
        jobTitle: String,
        department: String = "Engineering",
        dateOfJoining: Date = Date(),
        employmentStatus: EmploymentStatus = .active,
        monthlySalary: Double = 0.0,
        bankDetails: BankAccountDetails = BankAccountDetails(),
        assignedProjectIds: [String] = [],
        annualLeaveQuota: Int = 18,
        leavesTaken: Int = 0,
        unpaidLeavesThisMonth: Int = 0,
        performanceNotes: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.employeeId = employeeId
        self.fullName = fullName
        self.email = email
        self.phone = phone
        self.jobTitle = jobTitle
        self.department = department
        self.dateOfJoining = dateOfJoining
        self.employmentStatus = employmentStatus
        self.monthlySalary = monthlySalary
        self.bankDetails = bankDetails
        self.assignedProjectIds = assignedProjectIds
        self.annualLeaveQuota = annualLeaveQuota
        self.leavesTaken = leavesTaken
        self.unpaidLeavesThisMonth = unpaidLeavesThisMonth
        self.performanceNotes = performanceNotes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public var remainingLeaves: Int {
        max(0, annualLeaveQuota - leavesTaken)
    }
}
