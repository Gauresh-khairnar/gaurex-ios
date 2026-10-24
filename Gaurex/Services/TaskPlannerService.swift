//
//  TaskPlannerService.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import Foundation

public struct ScheduledDayPlan {
    public let date: Date
    public let scheduledTasks: [BusinessTask]
    public let totalEstimatedMinutes: Int
    public let strategicSummary: String
}

public final class TaskPlannerService {
    public static let shared = TaskPlannerService()
    
    private init() {}
    
    /// Analyzes authorized business records and generates an optimal, realistic, non-overlapping schedule for Gauresh
    public func planDay(
        existingTasks: [BusinessTask],
        overdueInvoices: [Invoice],
        pendingFollowUps: [SalesLead],
        workingHoursStartHour: Int = 9, // 9:00 AM
        workingHoursEndHour: Int = 18    // 6:00 PM
    ) -> ScheduledDayPlan {
        let calendar = Calendar.current
        let today = Date()
        
        var prioritizedTasks: [BusinessTask] = []
        
        // 1. Convert overdue invoices into Urgent Financial Follow-up Tasks if not already present
        for inv in overdueInvoices.prefix(2) {
            let taskTitle = "Clear Overdue Invoice #\(inv.invoiceNumber) (\(inv.clientName))"
            if !existingTasks.contains(where: { $0.title == taskTitle && $0.status != .completed }) {
                let task = BusinessTask(
                    title: taskTitle,
                    taskDescription: "Follow up directly on balance due: ₹\(String(format: "%.0f", inv.balanceDue)). Issue formal WhatsApp/email payment reminder.",
                    category: "Financial",
                    priority: .urgent,
                    dueDate: today,
                    estimatedDurationMinutes: 20,
                    relatedInvoiceId: inv.id,
                    isAiGenerated: true,
                    aiReasoning: "Payment is overdue. Immediate cash collection protects operating runway."
                )
                prioritizedTasks.append(task)
            }
        }
        
        // 2. Convert active CRM Follow-ups due today or overdue
        for lead in pendingFollowUps.prefix(2) {
            let taskTitle = "Sales Follow-up: \(lead.clientName) (\(lead.companyName))"
            if !existingTasks.contains(where: { $0.title == taskTitle && $0.status != .completed }) {
                let task = BusinessTask(
                    title: taskTitle,
                    taskDescription: "Action: \(lead.nextAction). Deal value: ₹\(String(format: "%.0f", lead.expectedDealValue)) with \(String(format: "%.0f%%", lead.closingProbability * 100)) probability.",
                    category: "Sales CRM",
                    priority: .high,
                    dueDate: today,
                    estimatedDurationMinutes: 30,
                    relatedClientId: lead.id,
                    isAiGenerated: true,
                    aiReasoning: "High closing probability deal requiring timely contact to maintain pipeline velocity."
                )
                prioritizedTasks.append(task)
            }
        }
        
        // 3. Add pending existing tasks, prioritizing Urgent -> High -> Medium -> Low
        let pendingUserTasks = existingTasks.filter { $0.status == .pending || $0.status == .inProgress }
        let sortedUserTasks = pendingUserTasks.sorted { (a, b) -> Bool in
            let pOrder: [TaskPriority: Int] = [.urgent: 0, .high: 1, .medium: 2, .low: 3]
            return (pOrder[a.priority] ?? 2) < (pOrder[b.priority] ?? 2)
        }
        
        for t in sortedUserTasks {
            if !prioritizedTasks.contains(where: { $0.id == t.id }) {
                prioritizedTasks.append(t)
            }
        }
        
        // 4. Construct Non-Overlapping Schedule
        var currentSlot = calendar.date(bySettingHour: workingHoursStartHour, minute: 0, second: 0, of: today) ?? today
        var scheduledTasks: [BusinessTask] = []
        var totalMinutes = 0
        
        for var task in prioritizedTasks.prefix(6) {
            task.scheduledStartTime = currentSlot
            scheduledTasks.append(task)
            totalMinutes += task.estimatedDurationMinutes
            
            // Advance time slot + 15 minute buffer/break
            currentSlot = calendar.date(byAdding: .minute, value: task.estimatedDurationMinutes + 15, to: currentSlot) ?? currentSlot
        }
        
        let summary = "AI Daily Plan constructed for Founder Gauresh Khairnar: \(scheduledTasks.count) prioritized high-impact actions scheduled with buffer periods to prevent context fatigue."
        
        return ScheduledDayPlan(
            date: today,
            scheduledTasks: scheduledTasks,
            totalEstimatedMinutes: totalMinutes,
            strategicSummary: summary
        )
    }
}
