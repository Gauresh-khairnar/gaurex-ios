//
//  PayrollRecord.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import Foundation

public enum PayrollStatus: String, Codable, CaseIterable, Identifiable {
    case pending = "Pending Approval"
    case approved = "Approved"
    case paid = "Disbursed / Paid"
    
    public var id: String { rawValue }
    
    public var badgeColor: String {
        switch self {
        case .pending: return "orange"
        case .approved: return "blue"
        case .paid: return "green"
        }
    }
}

public struct PayrollRecord: Identifiable, Codable, Hashable {
    public var id: String
    public var workerId: String
    public var workerName: String
    public var employeeId: String
    public var designation: String
    public var salaryMonth: String // e.g. "October"
    public var salaryYear: Int     // e.g. 2026
    public var basicSalary: Double
    public var houseRentAllowance: Double
    public var specialAllowance: Double
    public var performanceBonus: Double
    public var taxDeduction: Double
    public var providentFundOrInsurance: Double
    public var unpaidLeaveDeduction: Double
    public var daysInMonth: Int
    public var unpaidLeaveDays: Int
    
    public var grossEarnings: Double
    public var totalDeductions: Double
    public var netSalaryPayable: Double
    
    public var paymentStatus: PayrollStatus
    public var paymentDate: Date?
    public var paymentMethod: PaymentMethod?
    public var transactionReference: String?
    public var notes: String
    public var generatedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        workerId: String,
        workerName: String,
        employeeId: String,
        designation: String,
        salaryMonth: String,
        salaryYear: Int,
        basicSalary: Double,
        houseRentAllowance: Double = 0.0,
        specialAllowance: Double = 0.0,
        performanceBonus: Double = 0.0,
        taxDeduction: Double = 0.0,
        providentFundOrInsurance: Double = 0.0,
        daysInMonth: Int = 30,
        unpaidLeaveDays: Int = 0,
        paymentStatus: PayrollStatus = .pending,
        paymentDate: Date? = nil,
        paymentMethod: PaymentMethod? = .bankTransfer,
        transactionReference: String? = nil,
        notes: String = "GAUREX Executive Payroll - Confidential",
        generatedAt: Date = Date()
    ) {
        self.id = id
        self.workerId = workerId
        self.workerName = workerName
        self.employeeId = employeeId
        self.designation = designation
        self.salaryMonth = salaryMonth
        self.salaryYear = salaryYear
        self.basicSalary = basicSalary
        self.houseRentAllowance = houseRentAllowance
        self.specialAllowance = specialAllowance
        self.performanceBonus = performanceBonus
        self.taxDeduction = taxDeduction
        self.providentFundOrInsurance = providentFundOrInsurance
        self.daysInMonth = daysInMonth
        self.unpaidLeaveDays = unpaidLeaveDays
        
        let perDayRate = daysInMonth > 0 ? (basicSalary / Double(daysInMonth)) : 0.0
        let unpaidDeduction = perDayRate * Double(unpaidLeaveDays)
        self.unpaidLeaveDeduction = unpaidDeduction
        
        let gross = basicSalary + houseRentAllowance + specialAllowance + performanceBonus
        self.grossEarnings = gross
        
        let deductions = taxDeduction + providentFundOrInsurance + unpaidDeduction
        self.totalDeductions = deductions
        
        self.netSalaryPayable = max(0.0, gross - deductions)
        
        self.paymentStatus = paymentStatus
        self.paymentDate = paymentDate
        self.paymentMethod = paymentMethod
        self.transactionReference = transactionReference
        self.notes = notes
        self.generatedAt = generatedAt
    }
}
