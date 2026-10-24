//
//  TasksManagementView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct TasksManagementView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @ObservedObject private var aiService = AIService.shared
    
    @State private var selectedFilter = 0 // 0: Today, 1: Upcoming, 2: Completed, 3: Overdue
    @State private var showingAddTask = false
    @State private var isSchedulingWithGroq = false
    
    public init() {}
    
    private var displayedTasks: [BusinessTask] {
        let cal = Calendar.current
        switch selectedFilter {
        case 0: // Today
            return store.todayTasks
        case 1: // Upcoming
            return store.tasks.filter { !cal.isDateInToday($0.dueDate) && $0.dueDate >= Date() && $0.status != .completed }
        case 2: // Completed
            return store.tasks.filter { $0.status == .completed }
        case 3: // Overdue
            return store.tasks.filter { $0.isOverdue }
        default:
            return store.tasks
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        // MARK: - Filter Tabs
                        Picker("Task Filter", selection: $selectedFilter) {
                            Text("Today (\(store.todayTasks.count))").tag(0)
                            Text("Upcoming").tag(1)
                            Text("Completed").tag(2)
                            Text("Overdue (\(store.overdueTasksCount))").tag(3)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        
                        // MARK: - Task List
                        if displayedTasks.isEmpty {
                            EmptyStateView(
                                icon: "checklist",
                                title: "No Tasks In This View",
                                description: "Schedule tasks or trigger the Groq AI Planner to generate goal-aligned actions.",
                                actionTitle: "Add Task"
                            ) {
                                showingAddTask = true
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(displayedTasks) { task in
                                    TaskRowCard(task: task)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        Spacer().frame(height: 80)
                    }
                    .padding(.vertical, 10)
                }
                
                ToastOverlay(toast: $store.activeToast)
            }
            .navigationTitle("Tasks & Schedule")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(theme.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskSheet()
            }
        }
    }
    
    private func scheduleWithGroq() {
        isSchedulingWithGroq = true
        AIService.shared.scheduleDailyTasksForGoals(
            goals: store.businessGoals,
            existingTasks: store.tasks
        ) { generated in
            self.isSchedulingWithGroq = false
            for t in generated {
                if !store.tasks.contains(where: { $0.title == t.title }) {
                    store.addTask(t)
                }
            }
            store.showToast(title: "Groq Scheduled \(generated.count) Strategic Goal Tasks")
        }
    }
}
