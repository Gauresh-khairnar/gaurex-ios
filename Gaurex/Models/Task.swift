//
//  Task.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import Foundation

public enum TaskPriority: String, Codable, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    
    public var id: String { rawValue }
    
    public var colorName: String {
        switch self {
        case .low: return "gray"
        case .medium: return "blue"
        case .high: return "orange"
        case .urgent: return "red"
        }
    }
}

public enum TaskStatus: String, Codable, CaseIterable, Identifiable {
    case pending = "Pending"
    case inProgress = "In Progress"
    case completed = "Completed"
    case skipped = "Skipped"
    
    public var id: String { rawValue }
}

public struct BusinessTask: Identifiable, Codable, Hashable {
    public var id: String
    public var title: String
    public var taskDescription: String
    public var category: String // "Client Follow-up", "Engineering", "Financial", "Executive"
    public var priority: TaskPriority
    public var dueDate: Date
    public var scheduledStartTime: Date?
    public var estimatedDurationMinutes: Int
    public var actualDurationMinutes: Int
    public var status: TaskStatus
    public var assignedEmployeeId: String?
    public var relatedClientId: String?
    public var relatedProjectId: String?
    public var relatedInvoiceId: String?
    public var isAiGenerated: Bool
    public var aiReasoning: String?
    public var completedAt: Date?
    public var createdAt: Date
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        taskDescription: String = "",
        category: String = "Executive",
        priority: TaskPriority = .medium,
        dueDate: Date = Date(),
        scheduledStartTime: Date? = nil,
        estimatedDurationMinutes: Int = 30,
        actualDurationMinutes: Int = 0,
        status: TaskStatus = .pending,
        assignedEmployeeId: String? = nil,
        relatedClientId: String? = nil,
        relatedProjectId: String? = nil,
        relatedInvoiceId: String? = nil,
        isAiGenerated: Bool = false,
        aiReasoning: String? = nil,
        completedAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.category = category
        self.priority = priority
        self.dueDate = dueDate
        self.scheduledStartTime = scheduledStartTime
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.actualDurationMinutes = actualDurationMinutes
        self.status = status
        self.assignedEmployeeId = assignedEmployeeId
        self.relatedClientId = relatedClientId
        self.relatedProjectId = relatedProjectId
        self.relatedInvoiceId = relatedInvoiceId
        self.isAiGenerated = isAiGenerated
        self.aiReasoning = aiReasoning
        self.completedAt = completedAt
        self.createdAt = createdAt
    }
    
    public var isOverdue: Bool {
        status != .completed && status != .skipped && dueDate < Date()
    }
}
