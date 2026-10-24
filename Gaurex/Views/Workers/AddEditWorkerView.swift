//
//  AddEditWorkerView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct AddEditWorkerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    
    public var workerToEdit: Worker?
    
    @State private var fullName: String = ""
    @State private var employeeId: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var jobTitle: String = ""
    @State private var department: String = "Engineering"
    @State private var dateOfJoining: Date = Date()
    @State private var employmentStatus: EmploymentStatus = .active
    @State private var monthlySalary: Double = 0.0
    @State private var annualLeaveQuota: Int = 18
    @State private var performanceNotes: String = ""
    
    // Bank Details
    @State private var bankName: String = ""
    @State private var accountNumber: String = ""
    @State private var ifscOrRouting: String = ""
    @State private var accountHolderName: String = ""
    @State private var upiId: String = ""
    
    @State private var showingError = false
    @State private var errorMessage = ""
    
    public init(workerToEdit: Worker? = nil) {
        self.workerToEdit = workerToEdit
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Employee Information")) {
                    TextField("Full Name *", text: $fullName)
                    TextField("Employee ID (e.g. GX-EMP-01) *", text: $employeeId)
                    TextField("Email Address *", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Designation / Job Title (e.g. Senior iOS Engineer) *", text: $jobTitle)
                    TextField("Department (e.g. Engineering, AI Architecture)", text: $department)
                    DatePicker("Date of Joining", selection: $dateOfJoining, displayedComponents: .date)
                    Picker("Employment Status", selection: $employmentStatus) {
                        ForEach(EmploymentStatus.allCases) { st in
                            Text(st.rawValue).tag(st)
                        }
                    }
                }
                
                Section(header: Text("Compensation & Leave Quota")) {
                    HStack {
                        Text("Monthly Fixed Salary (₹) *")
                        Spacer()
                        TextField("0", value: $monthlySalary, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }
                    
                    Stepper("Annual Leave Quota: \(annualLeaveQuota) days", value: $annualLeaveQuota, in: 0...60)
                }
                
                Section(header: Text("Confidential Bank Disbursement Details")) {
                    TextField("Bank Name (e.g. HDFC Bank)", text: $bankName)
                    TextField("Account Number", text: $accountNumber)
                        .keyboardType(.numberPad)
                    TextField("IFSC / Routing Code", text: $ifscOrRouting)
                        .textInputAutocapitalization(.characters)
                    TextField("Account Holder Name", text: $accountHolderName)
                    TextField("UPI ID (Optional)", text: $upiId)
                        .textInputAutocapitalization(.never)
                }
                
                Section(header: Text("Performance & Executive Notes")) {
                    TextEditor(text: $performanceNotes)
                        .frame(minHeight: 60)
                }
            }
            .navigationTitle(workerToEdit == nil ? "Add Team Member" : "Edit Team Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Record") {
                        saveWorker()
                    }
                    .fontWeight(.bold)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                loadExistingIfEditing()
            }
        }
    }
    
    private func loadExistingIfEditing() {
        guard let w = workerToEdit else {
            // Auto generate next Employee ID
            let count = store.workers.count + 1
            employeeId = String(format: "GX-EMP-%02d", count)
            return
        }
        fullName = w.fullName
        employeeId = w.employeeId
        email = w.email
        phone = w.phone
        jobTitle = w.jobTitle
        department = w.department
        dateOfJoining = w.dateOfJoining
        employmentStatus = w.employmentStatus
        monthlySalary = w.monthlySalary
        annualLeaveQuota = w.annualLeaveQuota
        performanceNotes = w.performanceNotes
        bankName = w.bankDetails.bankName
        accountNumber = w.bankDetails.accountNumber
        ifscOrRouting = w.bankDetails.ifscOrRouting
        accountHolderName = w.bankDetails.accountHolderName
        upiId = w.bankDetails.upiId ?? ""
    }
    
    private func saveWorker() {
        if fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please enter employee full name."
            showingError = true
            return
        }
        if employeeId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please enter an Employee ID."
            showingError = true
            return
        }
        
        let bank = BankAccountDetails(
            bankName: bankName,
            accountNumber: accountNumber,
            ifscOrRouting: ifscOrRouting,
            accountHolderName: accountHolderName,
            upiId: upiId.isEmpty ? nil : upiId
        )
        
        if let existing = workerToEdit {
            var updated = existing
            updated.fullName = fullName
            updated.employeeId = employeeId
            updated.email = email
            updated.phone = phone
            updated.jobTitle = jobTitle
            updated.department = department
            updated.dateOfJoining = dateOfJoining
            updated.employmentStatus = employmentStatus
            updated.monthlySalary = monthlySalary
            updated.annualLeaveQuota = annualLeaveQuota
            updated.bankDetails = bank
            updated.performanceNotes = performanceNotes
            store.updateWorker(updated)
        } else {
            let newWorker = Worker(
                employeeId: employeeId,
                fullName: fullName,
                email: email,
                phone: phone,
                jobTitle: jobTitle,
                department: department,
                dateOfJoining: dateOfJoining,
                employmentStatus: employmentStatus,
                monthlySalary: monthlySalary,
                bankDetails: bank,
                annualLeaveQuota: annualLeaveQuota,
                performanceNotes: performanceNotes
            )
            store.addWorker(newWorker)
        }
        
        dismiss()
    }
}
