//
//  WorkersListView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct WorkersListView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    
    @State private var searchText: String = ""
    @State private var selectedStatus: EmploymentStatus? = nil
    @State private var showingAddSheet = false
    @State private var showingAttendanceSheet = false
    
    public init() {}
    
    public var filteredWorkers: [Worker] {
        var list = store.workers
        if let st = selectedStatus {
            list = list.filter { $0.employmentStatus == st }
        }
        if !searchText.isEmpty {
            list = list.filter {
                $0.fullName.localizedCaseInsensitiveContains(searchText) ||
                $0.employeeId.localizedCaseInsensitiveContains(searchText) ||
                $0.jobTitle.localizedCaseInsensitiveContains(searchText) ||
                $0.department.localizedCaseInsensitiveContains(searchText)
            }
        }
        return list
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Bar with Attendance shortcut
                    HStack {
                        Button {
                            showingAttendanceSheet = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(theme.accentColor)
                                Text("Attendance & Leaves (\(store.leaveRequests.filter { $0.status == .pending }.count) Pending)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(theme.cardBackground)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(theme.glassBorderColor, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .tactilePress()
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    .padding(.bottom, 6)
                    
                    // Search & Filter Bar
                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            TextField("Search workers, employee ID, title...", text: $searchText)
                                .textFieldStyle(.plain)
                                .font(.system(size: 14))
                        }
                        .padding(10)
                        .background(theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(theme.glassBorderColor, lineWidth: 1))
                        .padding(.horizontal, 16)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FilterChip(title: "All (\(store.workers.count))", isSelected: selectedStatus == nil) {
                                    selectedStatus = nil
                                }
                                ForEach(EmploymentStatus.allCases) { st in
                                    let count = store.workers.filter { $0.employmentStatus == st }.count
                                    FilterChip(title: "\(st.rawValue) (\(count))", isSelected: selectedStatus == st) {
                                        selectedStatus = st
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 12)
                    
                    if filteredWorkers.isEmpty {
                        EmptyStateView(
                            icon: "person.badge.shield.checkmark",
                            title: searchText.isEmpty ? "No Team Members Added" : "No Matching Team Members",
                            description: searchText.isEmpty
                                ? "Register engineers, designers, and managers to coordinate client projects and disburse payroll."
                                : "No workers match the current search criteria.",
                            actionTitle: searchText.isEmpty ? "Add Worker" : nil
                        ) {
                            showingAddSheet = true
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredWorkers) { worker in
                                    NavigationLink {
                                        WorkerDetailView(worker: worker)
                                    } label: {
                                        WorkerRowCard(worker: worker)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            Spacer().frame(height: 80)
                        }
                    }
                }
                
                ToastOverlay(toast: $store.activeToast)
            }
            .navigationTitle("Workers & Payroll")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(theme.accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddEditWorkerView()
            }
            .sheet(isPresented: $showingAttendanceSheet) {
                AttendanceAndLeaveView()
            }
        }
    }
}

public struct WorkerRowCard: View {
    @ObservedObject private var theme = ThemeManager.shared
    public var worker: Worker
    
    public var body: some View {
        GlassCard(padding: 14) {
            HStack(spacing: 14) {
                Text(String(worker.fullName.prefix(2)).uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 42, height: 42)
                    .background(Color.primary)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(worker.fullName)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)
                        Text("(\(worker.employeeId))")
                            .font(TypographyTokens.code)
                            .foregroundColor(.secondary)
                    }
                    Text("\(worker.jobTitle) • \(worker.department)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 3) {
                    Text(FinancialCalculator.shared.formatCurrency(worker.monthlySalary))
                        .font(.system(size: 13, weight: .bold))
                        .monospacedDigit()
                        .foregroundColor(.primary)
                    StatusBadge(
                        text: worker.employmentStatus.rawValue,
                        color: worker.employmentStatus == .active ? .green : .blue
                    )
                }
            }
        }
        .tactilePress(scale: MotionTokens.cardPressScale)
    }
}
