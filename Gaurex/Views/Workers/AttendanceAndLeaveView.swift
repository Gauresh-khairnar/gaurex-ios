//
//  AttendanceAndLeaveView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct AttendanceAndLeaveView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingSubmitLeave = false
    @State private var selectedWorkerForAttendance: String = ""
    @State private var attendanceStatus: AttendanceStatus = .present
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // MARK: - Daily Attendance Logger Card
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("DAILY ATTENDANCE LOG")
                                            .font(TypographyTokens.sectionHeader)
                                            .foregroundColor(.secondary)
                                        Text("Record Today's Status")
                                            .font(.system(size: 15, weight: .bold))
                                    }
                                    Spacer()
                                    Image(systemName: "clock.badge.checkmark.fill")
                                        .foregroundColor(theme.accentColor)
                                }
                                
                                Picker("Select Worker", selection: $selectedWorkerForAttendance) {
                                    Text("Choose Worker...").tag("")
                                    ForEach(store.workers) { w in
                                        Text("\(w.fullName) (\(w.jobTitle))").tag(w.id)
                                    }
                                }
                                .pickerStyle(.menu)
                                
                                Picker("Status", selection: $attendanceStatus) {
                                    ForEach(AttendanceStatus.allCases) { st in
                                        Text(st.rawValue).tag(st)
                                    }
                                }
                                .pickerStyle(.segmented)
                                
                                Button {
                                    if let w = store.workers.first(where: { $0.id == selectedWorkerForAttendance }) {
                                        store.recordAttendance(workerId: w.id, workerName: w.fullName, status: attendanceStatus)
                                        selectedWorkerForAttendance = ""
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Confirm Attendance")
                                    }
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(selectedWorkerForAttendance.isEmpty ? Color.secondary : Color.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                                .disabled(selectedWorkerForAttendance.isEmpty)
                                .buttonStyle(.plain)
                                .tactilePress()
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // MARK: - Pending Leave Requests
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("LEAVE APPROVALS")
                                    .font(TypographyTokens.sectionHeader)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button {
                                    showingSubmitLeave = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Request Leave")
                                    }
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(theme.accentColor)
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            if store.leaveRequests.isEmpty {
                                GlassCard {
                                    Text("No employee leave requests currently pending.")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.vertical, 8)
                                }
                                .padding(.horizontal, 16)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(store.leaveRequests) { req in
                                        GlassCard(padding: 12) {
                                            VStack(alignment: .leading, spacing: 6) {
                                                HStack {
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(req.workerName)
                                                            .font(.system(size: 14, weight: .bold))
                                                        Text("\(req.leaveType.rawValue) • \(req.numberOfDays) day(s)")
                                                            .font(.system(size: 11))
                                                            .foregroundColor(.secondary)
                                                    }
                                                    Spacer()
                                                    StatusBadge(text: req.status.rawValue, color: req.status == .approved ? .green : (req.status == .rejected ? .red : .orange))
                                                }
                                                
                                                Text("Reason: \(req.reason)")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.primary)
                                                
                                                if req.status == .pending {
                                                    HStack(spacing: 12) {
                                                        Button("Approve") {
                                                            store.processLeaveApproval(id: req.id, approve: true)
                                                        }
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(.green)
                                                        
                                                        Button("Reject") {
                                                            store.processLeaveApproval(id: req.id, approve: false, comment: "Operational priority")
                                                        }
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(.red)
                                                    }
                                                    .padding(.top, 4)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        // MARK: - Attendance History
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ATTENDANCE RECORDS")
                                .font(TypographyTokens.sectionHeader)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                            
                            if store.attendanceRecords.isEmpty {
                                GlassCard {
                                    Text("No daily attendance logged yet.")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.vertical, 8)
                                }
                                .padding(.horizontal, 16)
                            } else {
                                VStack(spacing: 6) {
                                    ForEach(store.attendanceRecords.prefix(10)) { record in
                                        GlassCard(padding: 10) {
                                            HStack {
                                                Text(record.workerName)
                                                    .font(.system(size: 13, weight: .semibold))
                                                Spacer()
                                                Text(record.date, style: .date)
                                                    .font(.system(size: 11))
                                                    .foregroundColor(.secondary)
                                                StatusBadge(text: record.status.rawValue, color: record.status == .present ? .green : .orange)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        Spacer().frame(height: 60)
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Attendance & Leaves")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
            }
            .sheet(isPresented: $showingSubmitLeave) {
                SubmitLeaveSheet()
            }
        }
    }
}

public struct SubmitLeaveSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = FirestoreDataStore.shared
    
    @State private var selectedWorkerId: String = ""
    @State private var leaveType: LeaveType = .annual
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var reason: String = ""
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Leave Applicant")) {
                    Picker("Employee", selection: $selectedWorkerId) {
                        Text("Select Worker...").tag("")
                        ForEach(store.workers) { w in
                            Text("\(w.fullName) (\(w.jobTitle))").tag(w.id)
                        }
                    }
                    Picker("Leave Type", selection: $leaveType) {
                        ForEach(LeaveType.allCases) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    TextField("Reason for leave", text: $reason)
                }
            }
            .navigationTitle("Request Leave")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        guard let w = store.workers.first(where: { $0.id == selectedWorkerId }), !reason.isEmpty else { return }
                        let req = LeaveRequest(
                            workerId: w.id,
                            workerName: w.fullName,
                            leaveType: leaveType,
                            startDate: startDate,
                            endDate: endDate,
                            reason: reason
                        )
                        store.submitLeaveRequest(req)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}
