//
//  TodayTasksSectionView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct TodayTasksSectionView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    
    @State private var showingPlanMyDaySheet = false
    @State private var showingAddTaskSheet = false
    @State private var currentPlan: ScheduledDayPlan? = nil
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with AI Plan Button
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TODAY'S EXECUTION")
                        .font(TypographyTokens.sectionHeader)
                        .foregroundColor(.secondary)
                    HStack(spacing: 6) {
                        Text("Daily Action Plan")
                            .font(.system(size: 16, weight: .bold))
                        Text("(\(store.todayTasks.filter { $0.status == .completed }.count)/\(store.todayTasks.count) Done)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button {
                    generateAiDayPlan()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "sparkles")
                        Text("Plan My Day")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.primary)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .tactilePress()
            }
            .padding(.horizontal, 16)
            
            // Progress Bar
            if !store.todayTasks.isEmpty {
                ProgressView(value: store.taskCompletionRate)
                    .tint(store.taskCompletionRate == 1.0 ? Color.green : Color.blue)
                    .padding(.horizontal, 16)
            }
            
            if store.todayTasks.isEmpty {
                GlassCard {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.badge.questionmark")
                            .font(.system(size: 26, weight: .light))
                            .foregroundColor(.secondary)
                        Text("No tasks scheduled for today yet.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            Button("Plan with AI") {
                                generateAiDayPlan()
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(theme.accentColor)
                            
                            Button("Add Task (+)") {
                                showingAddTaskSheet = true
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.primary)
                        }
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, 16)
            } else {
                VStack(spacing: 8) {
                    ForEach(store.todayTasks) { task in
                        TaskRowCard(task: task)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .sheet(isPresented: $showingPlanMyDaySheet) {
            if let plan = currentPlan {
                AiDayPlanSheet(plan: plan)
            }
        }
        .sheet(isPresented: $showingAddTaskSheet) {
            AddTaskSheet()
        }
    }
    
    private func generateAiDayPlan() {
        let overdue = store.invoices.filter { $0.status == .overdue || ($0.status == .issued && $0.dueDate < Date()) }
        let pendingLeads = store.salesLeads.filter { $0.stage != .won && $0.stage != .lost }
        let plan = TaskPlannerService.shared.planDay(
            existingTasks: store.tasks,
            overdueInvoices: overdue,
            pendingFollowUps: pendingLeads
        )
        currentPlan = plan
        showingPlanMyDaySheet = true
    }
}

public struct TaskRowCard: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @State private var showingDeleteAlert = false
    public var task: BusinessTask
    
    public init(task: BusinessTask) {
        self.task = task
    }
    
    public var body: some View {
        GlassCard(padding: 12) {
            HStack(spacing: 12) {
                Button {
                    store.toggleTaskCompletion(id: task.id)
                } label: {
                    Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                        .foregroundColor(task.status == .completed ? .green : .secondary)
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(task.title)
                        .font(.system(size: 14, weight: .semibold))
                        .strikethrough(task.status == .completed, color: .secondary)
                        .foregroundColor(task.status == .completed ? .secondary : .primary)
                    
                    HStack(spacing: 6) {
                        Text(task.category)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        if let start = task.scheduledStartTime {
                            Text("• \(start, style: .time)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(theme.accentColor)
                        }
                        
                        Text("• \(task.estimatedDurationMinutes) min")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                StatusBadge(text: task.priority.rawValue, color: task.priority == .urgent ? .red : (task.priority == .high ? .orange : .blue))
                
                // Delete button
                Button {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 13))
                        .foregroundColor(.red.opacity(0.75))
                        .padding(6)
                        .background(Color.red.opacity(0.08))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .confirmationDialog(
            "Delete Task",
            isPresented: $showingDeleteAlert,
            titleVisibility: .visible
        ) {
            Button("Delete Task", role: .destructive) {
                withAnimation {
                    store.deleteTask(id: task.id)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(task.title)\"? This cannot be undone.")
        }
        .contextMenu {
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Delete Task", systemImage: "trash")
            }
            Button {
                store.toggleTaskCompletion(id: task.id)
            } label: {
                Label(task.status == .completed ? "Mark as Pending" : "Mark as Complete", systemImage: task.status == .completed ? "circle" : "checkmark.circle")
            }
        }
    }
}

public struct AiDayPlanSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    public var plan: ScheduledDayPlan
    
    public var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(theme.accentColor)
                                    Text("AI Strategic Schedule")
                                        .font(.system(size: 15, weight: .bold))
                                    Spacer()
                                    OwnerBadge()
                                }
                                Text(plan.strategicSummary)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Text("PROPOSED TIMELINE (\(plan.scheduledTasks.count) ACTIONS)")
                            .font(TypographyTokens.sectionHeader)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                        
                        VStack(spacing: 8) {
                            ForEach(plan.scheduledTasks) { task in
                                GlassCard(padding: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            if let time = task.scheduledStartTime {
                                                Text(time, style: .time)
                                                    .font(TypographyTokens.code)
                                                    .foregroundColor(theme.accentColor)
                                            }
                                            Text(task.title)
                                                .font(.system(size: 13, weight: .bold))
                                            Spacer()
                                            StatusBadge(text: task.priority.rawValue, color: task.priority == .urgent ? .red : .orange)
                                        }
                                        if let reason = task.aiReasoning {
                                            Text("Reason: \(reason)")
                                                .font(.system(size: 11))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Spacer().frame(height: 60)
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("AI Daily Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply to Schedule") {
                        for t in plan.scheduledTasks {
                            if !store.tasks.contains(where: { $0.title == t.title }) {
                                store.addTask(t)
                            }
                        }
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

public struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = FirestoreDataStore.shared
    
    @State private var title: String = ""
    @State private var desc: String = ""
    @State private var category: String = "Executive"
    @State private var priority: TaskPriority = .high
    @State private var duration: Int = 30
    @State private var dueDate: Date = Date()
    
    let categories = ["Executive", "Financial", "Sales CRM", "Engineering", "Client Follow-up"]
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task Title *", text: $title)
                    TextField("Description", text: $desc)
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { c in
                            Text(c).tag(c)
                        }
                    }
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    Stepper("Estimated Duration: \(duration) minutes", value: $duration, in: 10...240, step: 10)
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard !title.isEmpty else { return }
                        let task = BusinessTask(
                            title: title,
                            taskDescription: desc,
                            category: category,
                            priority: priority,
                            dueDate: dueDate,
                            estimatedDurationMinutes: duration
                        )
                        store.addTask(task)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}
