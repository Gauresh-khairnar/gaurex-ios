//
//  GenerateSalarySlipView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct GenerateSalarySlipView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    
    public var worker: Worker
    
    @State private var salaryMonth: String = "October"
    @State private var salaryYear: Int = 2026
    @State private var basicSalary: Double = 0.0
    @State private var hra: Double = 0.0
    @State private var specialAllowance: Double = 0.0
    @State private var bonus: Double = 0.0
    @State private var taxDeduction: Double = 0.0
    @State private var insuranceDeduction: Double = 0.0
    @State private var daysInMonth: Int = 30
    @State private var unpaidLeaveDays: Int = 0
    @State private var paymentStatus: PayrollStatus = .approved
    @State private var paymentMethod: PaymentMethod = .bankTransfer
    @State private var transactionRef: String = ""
    
    @State private var showingPDFPreview = false
    
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    public init(worker: Worker) {
        self.worker = worker
    }
    
    private var calculation: SalaryCalculationResult {
        FinancialCalculator.shared.calculatePayroll(
            basicSalary: basicSalary,
            houseRentAllowance: hra,
            specialAllowance: specialAllowance,
            performanceBonus: bonus,
            daysInMonth: daysInMonth,
            unpaidLeaveDays: unpaidLeaveDays,
            taxDeduction: taxDeduction,
            otherDeductions: insuranceDeduction
        )
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Compensation Period")) {
                    Picker("Salary Month", selection: $salaryMonth) {
                        ForEach(months, id: \.self) { m in
                            Text(m).tag(m)
                        }
                    }
                    
                    Stepper("Year: \(salaryYear)", value: $salaryYear, in: 2024...2030)
                    Stepper("Days in Month: \(daysInMonth)", value: $daysInMonth, in: 28...31)
                    Stepper("Unpaid Leave Days: \(unpaidLeaveDays)", value: $unpaidLeaveDays, in: 0...31)
                }
                
                Section(header: Text("Earnings Breakdown")) {
                    HStack {
                        Text("Basic Salary")
                        Spacer()
                        TextField("0", value: $basicSalary, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("HRA Allowance")
                        Spacer()
                        TextField("0", value: $hra, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Special Allowance")
                        Spacer()
                        TextField("0", value: $specialAllowance, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Performance Bonus")
                        Spacer()
                        TextField("0", value: $bonus, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Gross Earnings")
                            .fontWeight(.bold)
                        Spacer()
                        Text(FinancialCalculator.shared.formatCurrency(calculation.grossEarnings))
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                
                Section(header: Text("Deductions")) {
                    HStack {
                        Text("Unpaid Leave Deduction")
                        Spacer()
                        Text(FinancialCalculator.shared.formatCurrency(calculation.unpaidLeaveDeduction))
                            .foregroundColor(.red)
                    }
                    HStack {
                        Text("Tax / TDS Deduction")
                        Spacer()
                        TextField("0", value: $taxDeduction, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Insurance / PF")
                        Spacer()
                        TextField("0", value: $insuranceDeduction, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Total Deductions")
                            .fontWeight(.bold)
                        Spacer()
                        Text(FinancialCalculator.shared.formatCurrency(calculation.totalDeductions))
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("Net Disbursement Total")) {
                    HStack {
                        Text("Net Payable Salary")
                            .font(.system(size: 16, weight: .bold))
                        Spacer()
                        Text(FinancialCalculator.shared.formatCurrency(calculation.netSalaryPayable))
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(theme.accentColor)
                    }
                    
                    Picker("Disbursement Status", selection: $paymentStatus) {
                        ForEach(PayrollStatus.allCases) { st in
                            Text(st.rawValue).tag(st)
                        }
                    }
                    
                    Picker("Disbursement Method", selection: $paymentMethod) {
                        ForEach(PaymentMethod.allCases) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                    
                    TextField("Bank UTR / Transaction Ref", text: $transactionRef)
                }
                
                Section {
                    Button {
                        showingPDFPreview = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.viewfinder")
                            Text("Preview Official Salary Slip PDF")
                        }
                        .font(.system(size: 14, weight: .semibold))
                    }
                }
            }
            .navigationTitle("Generate Salary Slip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Disburse & Save") {
                        savePayroll()
                    }
                    .fontWeight(.bold)
                }
            }
            .sheet(isPresented: $showingPDFPreview) {
                let record = makeRecord()
                let pdf = PDFGeneratorService.shared.generateSalarySlipPDF(payroll: record, worker: worker, business: store.settings)
                PDFPreviewView(pdfData: pdf, documentTitle: "Payslip - \(worker.fullName) - \(salaryMonth)")
            }
            .onAppear {
                // Prepopulate 60% basic, 25% HRA, 15% special allowance from worker monthly salary
                basicSalary = worker.monthlySalary * 0.60
                hra = worker.monthlySalary * 0.25
                specialAllowance = worker.monthlySalary * 0.15
            }
        }
    }
    
    private func makeRecord() -> PayrollRecord {
        PayrollRecord(
            workerId: worker.id,
            workerName: worker.fullName,
            employeeId: worker.employeeId,
            designation: worker.jobTitle,
            salaryMonth: salaryMonth,
            salaryYear: salaryYear,
            basicSalary: basicSalary,
            houseRentAllowance: hra,
            specialAllowance: specialAllowance,
            performanceBonus: bonus,
            taxDeduction: taxDeduction,
            providentFundOrInsurance: insuranceDeduction,
            daysInMonth: daysInMonth,
            unpaidLeaveDays: unpaidLeaveDays,
            paymentStatus: paymentStatus,
            paymentDate: paymentStatus == .paid ? Date() : nil,
            paymentMethod: paymentMethod,
            transactionReference: transactionRef.isEmpty ? nil : transactionRef
        )
    }
    
    private func savePayroll() {
        let record = makeRecord()
        store.addPayrollRecord(record)
        dismiss()
    }
}
