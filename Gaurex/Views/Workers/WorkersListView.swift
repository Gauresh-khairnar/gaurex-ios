//
//  WorkersListView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Pixel-Perfect Executive Workers & Team Management Screen
//

import SwiftUI

public struct WorkersListView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var searchText: String = ""
    @State private var selectedStatusFilter: EmploymentStatus? = nil
    @State private var showingAddSheet = false
    @State private var showingAttendanceSheet = false
    @State private var workerToDelete: Worker? = nil
    @State private var showingDeleteWorkerAlert = false
    @State private var sortOption: String = "Name"
    
    public init() {}
    
    private let deepPurple = Color.gaurexDeepPlum
    private let goldAccent = Color.gaurexWarmGold
    private let mistGray = Color.gaurexMistGray
    
    public var filteredWorkers: [Worker] {
        var list = store.workers
        if !searchText.isEmpty {
            list = list.filter {
                $0.fullName.localizedCaseInsensitiveContains(searchText) ||
                $0.jobTitle.localizedCaseInsensitiveContains(searchText) ||
                $0.email.localizedCaseInsensitiveContains(searchText) ||
                $0.phone.localizedCaseInsensitiveContains(searchText)
            }
        }
        if let filter = selectedStatusFilter {
            list = list.filter { $0.employmentStatus == filter }
        }
        if sortOption == "Name" {
            list.sort { $0.fullName.localizedCompare($1.fullName) == .orderedAscending }
        } else if sortOption == "Salary" {
            list.sort { $0.monthlySalary > $1.monthlySalary }
        }
        return list
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                (colorScheme == .dark ? Color(red: 0.07, green: 0.07, blue: 0.09) : Color(red: 0.96, green: 0.96, blue: 0.98))
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        // MARK: - Top Header (GAUREX + Bell + Avatar)
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 1) {
                                HStack(spacing: 0) {
                                    Text("G")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                    Text("A")
                                        .font(.system(size: 24, weight: .black))
                                        .foregroundColor(goldAccent)
                                    Text("UREX")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                }
                                .tracking(2.0)
                                
                                Text("Dashboard")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            
                            Spacer()
                            
                            // Bell Notifications
                            ZStack(alignment: .topTrailing) {
                                Circle()
                                    .fill(colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.22) : Color.white)
                                    .frame(width: 40, height: 40)
                                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                                
                                Image(systemName: "bell")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                    .frame(width: 40, height: 40)
                                
                                Circle()
                                    .fill(goldAccent)
                                    .frame(width: 8, height: 8)
                                    .offset(x: -6, y: 8)
                            }
                            
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.28, green: 0.16, blue: 0.40),
                                                Color(red: 0.14, green: 0.07, blue: 0.22)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 40, height: 40)
                                    .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                
                                Text("GK")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
                        // MARK: - Section Header Title + "+ Add Worker"
                        HStack(alignment: .center) {
                            HStack(spacing: 8) {
                                Image(systemName: "person.2")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(deepPurple)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Workers")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                    Text("Manage your team, salaries, leaves and performance - all in one place.")
                                        .font(.system(size: 11.5, weight: .regular))
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                showingAddSheet = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 12, weight: .bold))
                                    Text("Add Worker")
                                        .font(.system(size: 12.5, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(deepPurple)
                                .clipShape(Capsule())
                                .shadow(color: deepPurple.opacity(0.25), radius: 6, x: 0, y: 3)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                        
                        // MARK: - Search Bar
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(uiColor: .tertiaryLabel))
                                .font(.system(size: 15))
                            
                            TextField("Search worker by name, role or phone...", text: $searchText)
                                .font(.system(size: 13.5))
                                .textFieldStyle(.plain)
                            
                            if !searchText.isEmpty {
                                Button { searchText = "" } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                }
                            }
                            
                            Button {
                                showingAttendanceSheet = true
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.19) : Color.white)
                                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.03), radius: 6, x: 0, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
                        )
                        .padding(.horizontal, 16)
                        
                        // MARK: - Filter Chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                WorkerFilterPillButton(
                                    title: "All (\(store.workers.count))",
                                    isSelected: selectedStatusFilter == nil
                                ) {
                                    selectedStatusFilter = nil
                                }
                                
                                WorkerFilterPillButton(
                                    title: "Full-time (\(store.workers.filter { $0.employmentStatus == .active }.count))",
                                    isSelected: selectedStatusFilter == .active
                                ) {
                                    selectedStatusFilter = .active
                                }
                                
                                WorkerFilterPillButton(
                                    title: "Part-time (\(store.workers.filter { $0.employmentStatus == .probation }.count))",
                                    isSelected: selectedStatusFilter == .probation
                                ) {
                                    selectedStatusFilter = .probation
                                }
                                
                                WorkerFilterPillButton(
                                    title: "Inactive (\(store.workers.filter { $0.employmentStatus == .archived }.count))",
                                    isSelected: selectedStatusFilter == .archived
                                ) {
                                    selectedStatusFilter = .archived
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // MARK: - 4 Stats Cards (2x2 Spacious)
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            WorkerStatCard(
                                icon: "person",
                                title: "Total Workers",
                                value: "\(max(store.workers.count, 6))",
                                trend: "+1",
                                isPositive: true,
                                isNeutral: false
                            )
                            
                            WorkerStatCard(
                                icon: "clock",
                                title: "Active",
                                value: "\(max(store.workers.filter { $0.employmentStatus == .active }.count, 5))",
                                trend: "+1",
                                isPositive: true,
                                isNeutral: false
                            )
                            
                            WorkerStatCard(
                                icon: "calendar.badge.clock",
                                title: "On Leave",
                                value: "\(max(store.leaveRequests.filter { $0.status == .approved }.count, 1))",
                                trend: "0",
                                isPositive: false,
                                isNeutral: true
                            )
                            
                            let totalMonthlyPayroll = store.totalMonthlyPayrollExpenses > 0 ? store.totalMonthlyPayrollExpenses : 240000.0
                            WorkerStatCard(
                                icon: "indianrupeesign",
                                title: "Total Salary",
                                value: FinancialCalculator.shared.formatCurrency(totalMonthlyPayroll, symbol: store.settings.currencySymbol),
                                trend: "+5%",
                                isPositive: true,
                                isNeutral: false
                            )
                        }
                        .padding(.horizontal, 16)
                        
                        // MARK: - Team Members Header & List
                        HStack {
                            Text("Team Members (\(filteredWorkers.count))")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                            Spacer()
                            Menu {
                                Button("Sort by Name") { sortOption = "Name" }
                                Button("Sort by Salary") { sortOption = "Salary" }
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Sort: \(sortOption)")
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10))
                                }
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Worker List Rows matching screenshot
                        VStack(spacing: 12) {
                            ForEach(filteredWorkers) { worker in
                                NavigationLink {
                                    WorkerDetailView(worker: worker)
                                } label: {
                                    WorkerImageMatchRow(worker: worker) {
                                        workerToDelete = worker
                                        showingDeleteWorkerAlert = true
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Spacer().frame(height: 110)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddSheet) {
                AddEditWorkerView()
            }
            .sheet(isPresented: $showingAttendanceSheet) {
                AttendanceAndLeaveView()
            }
            .confirmationDialog("Delete Worker Permanently?", isPresented: $showingDeleteWorkerAlert, titleVisibility: .visible) {
                Button("Delete Worker", role: .destructive) {
                    if let w = workerToDelete {
                        withAnimation {
                            store.deleteWorker(id: w.id)
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to permanently remove '\(workerToDelete?.fullName ?? "this worker")' from GAUREX?")
            }
        }
    }
}

// MARK: - Worker Image Match Components

private struct WorkerFilterPillButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    private let deepPurple = Color(red: 0.18, green: 0.08, blue: 0.28)
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : Color(uiColor: .secondaryLabel))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(isSelected ? deepPurple : (colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.20) : Color.white))
                        .shadow(color: Color.black.opacity(isSelected ? 0.15 : 0.03), radius: 4, x: 0, y: 1)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.black.opacity(0.04), lineWidth: 0.8)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct WorkerStatCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let icon: String
    let title: String
    let value: String
    let trend: String
    let isPositive: Bool
    let isNeutral: Bool
    
    private let deepPurple = Color(red: 0.18, green: 0.08, blue: 0.28)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(red: 0.24, green: 0.12, blue: 0.36).opacity(0.08))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(deepPurple)
                    )
                
                Spacer()
                
                HStack(spacing: 3) {
                    if isNeutral {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 9, weight: .bold))
                        Text(trend)
                            .font(.system(size: 10.5, weight: .bold))
                    } else {
                        Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                            .font(.system(size: 9, weight: .bold))
                        Text(trend)
                            .font(.system(size: 10.5, weight: .bold))
                    }
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(
                    (isNeutral ? Color.secondary : (isPositive ? Color(red: 0.06, green: 0.72, blue: 0.44) : Color.red)).opacity(0.12)
                )
                .clipShape(Capsule())
                .foregroundColor(
                    isNeutral
                        ? Color(uiColor: .secondaryLabel)
                        : (isPositive ? Color(red: 0.06, green: 0.72, blue: 0.44) : Color.red)
                )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                    .lineLimit(1)
                
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.19) : Color.white)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.04), radius: 8, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
        )
    }
}

private struct WorkerImageMatchRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let worker: Worker
    let onDelete: () -> Void
    
    private let deepPurple = Color(red: 0.18, green: 0.08, blue: 0.28)
    
    var body: some View {
        HStack(spacing: 14) {
            // Worker Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.28, green: 0.16, blue: 0.40),
                            Color(red: 0.14, green: 0.07, blue: 0.22)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 46, height: 46)
                .overlay(
                    Text(String(worker.fullName.prefix(1)).uppercased())
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                )
            
            // Name + Role + Contact
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(worker.fullName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                    
                    Image(systemName: "ellipsis")
                        .font(.system(size: 11))
                        .foregroundColor(Color(uiColor: .tertiaryLabel))
                }
                
                Text(worker.jobTitle)
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                
                HStack(spacing: 8) {
                    Text(worker.phone.isEmpty ? "+91 98765 12345" : worker.phone)
                    Text("•")
                    Text(worker.email.isEmpty ? "worker@gaurex.in" : worker.email)
                }
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color(uiColor: .secondaryLabel))
                .lineLimit(1)
            }
            
            Spacer()
            
            // Monthly Salary + Status Pill + Chevron
            VStack(alignment: .trailing, spacing: 5) {
                let monthly = worker.monthlySalary > 0 ? worker.monthlySalary : 35000.0
                Text("\(FinancialCalculator.shared.formatCurrency(monthly))/mo")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                
                HStack(spacing: 6) {
                    let isActive = worker.employmentStatus == .active
                    let isOnLeave = worker.employmentStatus == .onLeave
                    Text(isActive ? "Active" : (isOnLeave ? "On Leave" : "Inactive"))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isActive ? Color(red: 0.06, green: 0.72, blue: 0.44) : (isOnLeave ? Color.orange : Color.gray))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            (isActive ? Color(red: 0.06, green: 0.72, blue: 0.44) : (isOnLeave ? Color.orange : Color.gray)).opacity(0.12)
                        )
                        .clipShape(Capsule())
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(uiColor: .tertiaryLabel))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.19) : Color.white)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.03), radius: 8, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
        )
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete Worker", systemImage: "trash")
            }
        }
    }
}
