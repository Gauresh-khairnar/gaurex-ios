//
//  AttendanceAndLeave.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import Foundation

public enum AttendanceStatus: String, Codable, CaseIterable, Identifiable {
    case present = "Present"
    case absent = "Absent"
    case halfDay = "Half-Day"
    case approvedLeave = "Approved Leave"
    
    public var id: String { rawValue }
    
    public var colorName: String {
        switch self {
        case .present: return "green"
        case .absent: return "red"
        case .halfDay: return "orange"
        case .approvedLeave: return "purple"
        }
    }
}

public struct AttendanceRecord: Identifiable, Codable, Hashable {
    public var id: String
    public var workerId: String
    public var workerName: String
    public var date: Date
    public var status: AttendanceStatus
    public var clockInTime: Date?
    public var clockOutTime: Date?
    public var notes: String
    
    public init(
        id: String = UUID().uuidString,
        workerId: String,
        workerName: String,
        date: Date = Date(),
        status: AttendanceStatus = .present,
        clockInTime: Date? = nil,
        clockOutTime: Date? = nil,
        notes: String = ""
    ) {
        self.id = id
        self.workerId = workerId
        self.workerName = workerName
        self.date = date
        self.status = status
        self.clockInTime = clockInTime
        self.clockOutTime = clockOutTime
        self.notes = notes
    }
}

public enum LeaveType: String, Codable, CaseIterable, Identifiable {
    case annual = "Annual Paid Leave"
    case sick = "Medical / Sick Leave"
    case casual = "Casual Leave"
    case unpaid = "Unpaid Leave"
    
    public var id: String { rawValue }
}

public enum LeaveApprovalStatus: String, Codable, CaseIterable, Identifiable {
    case pending = "Pending Review"
    case approved = "Approved"
    case rejected = "Rejected"
    
    public var id: String { rawValue }
    
    public var badgeColor: String {
        switch self {
        case .pending: return "orange"
        case .approved: return "green"
        case .rejected: return "red"
        }
    }
}

public struct LeaveRequest: Identifiable, Codable, Hashable {
    public var id: String
    public var workerId: String
    public var workerName: String
    public var leaveType: LeaveType
    public var startDate: Date
    public var endDate: Date
    public var reason: String
    public var status: LeaveApprovalStatus
    public var managerComment: String
    public var requestedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        workerId: String,
        workerName: String,
        leaveType: LeaveType = .annual,
        startDate: Date = Date(),
        endDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
        reason: String,
        status: LeaveApprovalStatus = .pending,
        managerComment: String = "",
        requestedAt: Date = Date()
    ) {
        self.id = id
        self.workerId = workerId
        self.workerName = workerName
        self.leaveType = leaveType
        self.startDate = startDate
        self.endDate = endDate
        self.reason = reason
        self.status = status
        self.managerComment = managerComment
        self.requestedAt = requestedAt
    }
    
    public var numberOfDays: Int {
        let cal = Calendar.current
        let days = cal.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        return max(1, days + 1)
    }
}

public struct SalaryHistoryRecord: Identifiable, Codable, Hashable {
    public var id: String
    public var workerId: String
    public var workerName: String
    public var effectiveDate: Date
    public var previousSalary: Double
    public var updatedSalary: Double
    public var reason: String
    public var approvedBy: String
    
    public init(
        id: String = UUID().uuidString,
        workerId: String,
        workerName: String,
        effectiveDate: Date = Date(),
        previousSalary: Double,
        updatedSalary: Double,
        reason: String,
        approvedBy: String = "Gauresh Khairnar (OWNER)"
    ) {
        self.id = id
        self.workerId = workerId
        self.workerName = workerName
        self.effectiveDate = effectiveDate
        self.previousSalary = previousSalary
        self.updatedSalary = updatedSalary
        self.reason = reason
        self.approvedBy = approvedBy
    }
}
