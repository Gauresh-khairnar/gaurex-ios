//
//  WorkerDetailView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct WorkerDetailView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    
    public var worker: Worker
    
    @State private var showingEditSheet = false
    @State private var showingGenerateSlipSheet = false
    @State private var showSensitiveBankDetails = false
    
    public init(worker: Worker) {
        self.worker = worker
    }
    
    private var currentWorker: Worker {
        store.workers.first(where: { $0.id == worker.id }) ?? worker
    }
    
    private var workerPayrolls: [PayrollRecord] {
        store.payrollRecords.filter { $0.workerId == currentWorker.id }
    }
    
    public var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Profile Header Card
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top) {
                                Text(String(currentWorker.fullName.prefix(2)).uppercased())
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 48, height: 48)
                                    .background(Color.primary)
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(spacing: 6) {
                                        Text(currentWorker.fullName)
                                            .font(.system(size: 18, weight: .bold))
                                        Text("(\(currentWorker.employeeId))")
                                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                                            .foregroundColor(.secondary)
                                    }
                                    Text("\(currentWorker.jobTitle) • \(currentWorker.department)")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                StatusBadge(
                                    text: currentWorker.employmentStatus.rawValue,
                                    color: currentWorker.employmentStatus == .active ? .green : .blue
                                )
                            }
                            
                            Divider().background(theme.glassBorderColor)
                            
                            HStack(spacing: 12) {
                                ContactActionButton(icon: "phone.fill", title: "Call", color: .green) {
                                    if let url = URL(string: "tel:\(currentWorker.phone.filter { "0123456789+".contains($0) })") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                
                                ContactActionButton(icon: "envelope.fill", title: "Email", color: .blue) {
                                    if let url = URL(string: "mailto:\(currentWorker.email)") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                
                                ContactActionButton(icon: "doc.badge.plus", title: "Payslip", color: .purple) {
                                    showingGenerateSlipSheet = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Compensation & Leave Metrics
                    HStack(spacing: 12) {
                        MetricCard(
                            title: "Monthly Fixed Pay",
                            value: FinancialCalculator.shared.formatCurrency(currentWorker.monthlySalary),
                            icon: "banknote.fill",
                            accentColor: .green
                        )
                        
                        MetricCard(
                            title: "Remaining Leaves",
                            value: "\(currentWorker.remainingLeaves) / \(currentWorker.annualLeaveQuota)",
                            subtitle: "\(currentWorker.leavesTaken) leaves taken",
                            icon: "calendar.badge.clock",
                            accentColor: .blue
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    // Confidential Bank Details
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Label("Bank Disbursement Info", systemImage: "lock.shield.fill")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button {
                                    showSensitiveBankDetails.toggle()
                                } label: {
                                    Text(showSensitiveBankDetails ? "Hide" : "Reveal")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(theme.accentColor)
                                }
                            }
                            
                            Divider().background(theme.glassBorderColor)
                            
                            VStack(spacing: 6) {
                                DetailRow(label: "Bank Name", value: currentWorker.bankDetails.bankName.isEmpty ? "Not configured" : currentWorker.bankDetails.bankName)
                                DetailRow(
                                    label: "Account Number",
                                    value: showSensitiveBankDetails
                                        ? currentWorker.bankDetails.accountNumber
                                        : currentWorker.bankDetails.maskedAccountNumber
                                )
                                DetailRow(label: "IFSC Code", value: currentWorker.bankDetails.ifscOrRouting.isEmpty ? "—" : currentWorker.bankDetails.ifscOrRouting)
                                DetailRow(label: "Account Holder", value: currentWorker.bankDetails.accountHolderName.isEmpty ? currentWorker.fullName : currentWorker.bankDetails.accountHolderName)
                                if let upi = currentWorker.bankDetails.upiId, !upi.isEmpty {
                                    DetailRow(label: "UPI ID", value: upi)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Disbursed Salary Slips History
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("PAYROLL DISBURSEMENT HISTORY")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                            Spacer()
                            Button {
                                showingGenerateSlipSheet = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("New Slip")
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(theme.accentColor)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        if workerPayrolls.isEmpty {
                            GlassCard {
                                VStack(spacing: 6) {
                                    Text("No salary slips generated yet for this employee.")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                    Button("Generate First Salary Slip") {
                                        showingGenerateSlipSheet = true
                                    }
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(theme.accentColor)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                            }
                            .padding(.horizontal, 16)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(workerPayrolls) { slip in
                                    PayrollHistoryCard(record: slip, worker: currentWorker)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    Spacer().frame(height: 80)
                }
                .padding(.vertical, 12)
            }
        }
        .navigationTitle(currentWorker.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddEditWorkerView(workerToEdit: currentWorker)
        }
        .sheet(isPresented: $showingGenerateSlipSheet) {
            GenerateSalarySlipView(worker: currentWorker)
        }
    }
}

public struct DetailRow: View {
    public var label: String
    public var value: String
    
    public var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}

public struct PayrollHistoryCard: View {
    @ObservedObject private var theme = ThemeManager.shared
    public var record: PayrollRecord
    public var worker: Worker
    @State private var showingPDF = false
    
    public var body: some View {
        GlassCard(padding: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(record.salaryMonth) \(record.salaryYear)")
                        .font(.system(size: 14, weight: .bold))
                    Text("Net Disbursed: \(FinancialCalculator.shared.formatCurrency(record.netSalaryPayable))")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                }
                Spacer()
                Button {
                    showingPDF = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.text")
                        Text("PDF Slip")
                    }
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(theme.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(theme.cardBackground)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(theme.glassBorderColor, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showingPDF) {
            let pdf = PDFGeneratorService.shared.generateSalarySlipPDF(payroll: record, worker: worker, business: FirestoreDataStore.shared.settings)
            PDFPreviewView(pdfData: pdf, documentTitle: "Payslip \(record.salaryMonth) \(record.salaryYear)")
        }
    }
}
