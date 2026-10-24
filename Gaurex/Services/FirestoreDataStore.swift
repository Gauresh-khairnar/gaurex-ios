//
//  FirestoreDataStore.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI
import Combine

public final class FirestoreDataStore: ObservableObject {
    public static let shared = FirestoreDataStore()
    
    // Core Published Collections
    @Published public var clients: [Client] = []
    @Published public var packages: [BusinessPackage] = []
    @Published public var invoices: [Invoice] = []
    @Published public var payments: [PaymentRecord] = []
    @Published public var workers: [Worker] = []
    @Published public var payrollRecords: [PayrollRecord] = []
    @Published public var expenses: [Expense] = []
    @Published public var projects: [Project] = []
    @Published public var settings: BusinessSettings = BusinessSettings()
    @Published public var aiMessages: [AIMessage] = []
    
    // Extended Enterprise Collections (Master Prompt 03)
    @Published public var tasks: [BusinessTask] = []
    @Published public var salesLeads: [SalesLead] = []
    @Published public var attendanceRecords: [AttendanceRecord] = []
    @Published public var leaveRequests: [LeaveRequest] = []
    @Published public var salaryHistory: [SalaryHistoryRecord] = []
    @Published public var vaultDocuments: [VaultDocument] = []
    @Published public var businessGoals: [BusinessGoal] = []
    @Published public var reminders: [SmartReminder] = []
    @Published public var integrations: [IntegrationItem] = []
    @Published public var activeCurrency: SupportedCurrency = .inr {
        didSet {
            settings.currencySymbol = activeCurrency.symbol
            saveSettings()
        }
    }
    
    // UI Feedback
    @Published public var activeToast: ToastMessage? = nil
    @Published public var activeDateFilter: DateRangeFilter = .thisMonth
    
    // Keys
    private let clientsKey = "gaurex_db_clients"
    private let packagesKey = "gaurex_db_packages"
    private let invoicesKey = "gaurex_db_invoices"
    private let paymentsKey = "gaurex_db_payments"
    private let workersKey = "gaurex_db_workers"
    private let payrollKey = "gaurex_db_payroll"
    private let expensesKey = "gaurex_db_expenses"
    private let projectsKey = "gaurex_db_projects"
    private let settingsKey = "gaurex_db_settings"
    private let aiMessagesKey = "gaurex_db_ai_messages"
    
    private let tasksKey = "gaurex_db_tasks"
    private let leadsKey = "gaurex_db_leads"
    private let attendanceKey = "gaurex_db_attendance"
    private let leavesKey = "gaurex_db_leaves"
    private let salaryHistKey = "gaurex_db_salary_hist"
    private let documentsKey = "gaurex_db_documents"
    private let goalsKey = "gaurex_db_goals"
    private let integrationsKey = "gaurex_db_integrations"
    
    private init() {
        loadData()
        seedInitialDataIfEmpty()
    }
    
    private func seedInitialDataIfEmpty() {
        // Initial Packages
        if packages.isEmpty {
            packages = [
                BusinessPackage(
                    name: "Enterprise Custom Software",
                    description: "Full-stack web & backend architecture, microservices, and high-availability deployment.",
                    category: .softwareDevelopment,
                    basePrice: 450000.0,
                    billingType: .oneTime,
                    features: ["System Architecture", "Microservices Backend", "Admin Dashboard", "API Security Suite", "Production CI/CD"],
                    deliverables: ["Full Source Code", "Docker Containers", "API Documentation", "1 Year Warranty"]
                ),
                BusinessPackage(
                    name: "iOS & Mobile Ecosystem",
                    description: "Native SwiftUI iOS application development with Liquid Glass UI, widgets, and App Store submission.",
                    category: .mobileApps,
                    basePrice: 350000.0,
                    billingType: .oneTime,
                    features: ["Native SwiftUI", "Offline-first Cache", "Biometric Security", "Push Notifications", "App Store Release"],
                    deliverables: ["iOS App Binary", "TestFlight Beta", "App Store Metadata"]
                ),
                BusinessPackage(
                    name: "AI & Workflow Automation Agent",
                    description: "Autonomous LLM agents, RAG pipeline, CRM integration, and intelligent business workflow automation.",
                    category: .aiAutomation,
                    basePrice: 280000.0,
                    billingType: .oneTime,
                    features: ["Custom RAG Pipeline", "Vector Database", "Autonomous Agents", "Multi-model Routing"],
                    deliverables: ["Deployed AI Agent", "Admin Training UI", "Evaluation Benchmarks"]
                ),
                BusinessPackage(
                    name: "Executive Cloud & DevOps Retainer",
                    description: "Continuous infrastructure monitoring, AWS/GCP optimization, Kubernetes cluster management, and 24/7 security.",
                    category: .cloudDevOps,
                    basePrice: 125000.0,
                    billingType: .monthly,
                    features: ["99.99% Uptime SLA", "24/7 Incident Response", "Cost Optimization", "Security Auditing"],
                    deliverables: ["Monthly Incident Reports", "Quarterly Architecture Review"]
                )
            ]
            savePackages()
        }
        
        // Initial Goals for Founder Gauresh Khairnar (OWNER)
        if businessGoals.isEmpty {
            businessGoals = [
                BusinessGoal(
                    title: "Toyota Fortuner Milestone (4-Month Target)",
                    metricType: .cashCollections,
                    targetValue: 5000000.0,
                    currentValue: 0.0,
                    deadline: Calendar.current.date(byAdding: .month, value: 4, to: Date()) ?? Date(),
                    blockers: ["Requires maintaining ₹41,666/day collection pace"],
                    recommendedActions: [
                        "Close high-value enterprise retainer contracts (₹5L+ each)",
                        "Convert outstanding client balances into collected cash",
                        "Maintain ₹12,50,000 monthly collected revenue target"
                    ]
                ),
                BusinessGoal(
                    title: "Monthly Revenue Target",
                    metricType: .monthlyRevenue,
                    targetValue: 1250000.0,
                    currentValue: 0.0,
                    blockers: ["Pending enterprise contract signatures"],
                    recommendedActions: ["Close negotiation with active pipeline leads"]
                ),
                BusinessGoal(
                    title: "New Client Acquisitions",
                    metricType: .newClients,
                    targetValue: 4.0,
                    currentValue: 0.0,
                    blockers: ["Lead follow-ups pending"],
                    recommendedActions: ["Schedule discovery meetings for newly inbound leads"]
                ),
                BusinessGoal(
                    title: "Monthly Operating Budget",
                    metricType: .expenseBudget,
                    targetValue: 200000.0,
                    currentValue: 0.0,
                    blockers: [],
                    recommendedActions: ["Maintain cloud infrastructure within allocated limits"]
                )
            ]
            saveGoals()
        } else if !businessGoals.contains(where: { $0.title.contains("Fortuner") }) {
            businessGoals.insert(
                BusinessGoal(
                    title: "Toyota Fortuner Milestone (4-Month Target)",
                    metricType: .cashCollections,
                    targetValue: 5000000.0,
                    currentValue: 0.0,
                    deadline: Calendar.current.date(byAdding: .month, value: 4, to: Date()) ?? Date(),
                    blockers: ["Requires maintaining ₹41,666/day collection pace"],
                    recommendedActions: [
                        "Close high-value enterprise retainer contracts (₹5L+ each)",
                        "Convert outstanding client balances into collected cash",
                        "Maintain ₹12,50,000 monthly collected revenue target"
                    ]
                ),
                at: 0
            )
            saveGoals()
        }
        
        // Initial Integrations Catalog
        if integrations.isEmpty {
            integrations = [
                IntegrationItem(provider: .gmail, isConnected: false, statusDescription: "Connect Google Workspace for email sync"),
                IntegrationItem(provider: .googleCalendar, isConnected: false, statusDescription: "Sync meetings and project delivery deadlines"),
                IntegrationItem(provider: .outlook, isConnected: false, statusDescription: "Microsoft 365 Exchange integration"),
                IntegrationItem(provider: .stripe, isConnected: false, statusDescription: "International corporate payment processing"),
                IntegrationItem(provider: .razorpay, isConnected: false, statusDescription: "Indian domestic UPI and NEFT gateway"),
                IntegrationItem(provider: .cloudStorage, isConnected: true, connectedAccountEmail: "cloud@gaurex.com", statusDescription: "Connected to AWS S3 & Cloud Storage"),
                IntegrationItem(provider: .gemini, isConnected: true, connectedAccountEmail: "gauresh@gaurex.com", statusDescription: "Gemini 1.5 Pro connected via Keychain")
            ]
            saveIntegrations()
        }
    }
    
    // MARK: - Persistence
    private func loadData() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: clientsKey), let val = try? decoder.decode([Client].self, from: data) { clients = val }
        if let data = UserDefaults.standard.data(forKey: packagesKey), let val = try? decoder.decode([BusinessPackage].self, from: data) { packages = val }
        if let data = UserDefaults.standard.data(forKey: invoicesKey), let val = try? decoder.decode([Invoice].self, from: data) { invoices = val }
        if let data = UserDefaults.standard.data(forKey: paymentsKey), let val = try? decoder.decode([PaymentRecord].self, from: data) { payments = val }
        if let data = UserDefaults.standard.data(forKey: workersKey), let val = try? decoder.decode([Worker].self, from: data) { workers = val }
        if let data = UserDefaults.standard.data(forKey: payrollKey), let val = try? decoder.decode([PayrollRecord].self, from: data) { payrollRecords = val }
        if let data = UserDefaults.standard.data(forKey: expensesKey), let val = try? decoder.decode([Expense].self, from: data) { expenses = val }
        if let data = UserDefaults.standard.data(forKey: projectsKey), let val = try? decoder.decode([Project].self, from: data) { projects = val }
        if let data = UserDefaults.standard.data(forKey: settingsKey), let val = try? decoder.decode(BusinessSettings.self, from: data) { settings = val }
        if let data = UserDefaults.standard.data(forKey: aiMessagesKey), let val = try? decoder.decode([AIMessage].self, from: data) { aiMessages = val }
        
        if let data = UserDefaults.standard.data(forKey: tasksKey), let val = try? decoder.decode([BusinessTask].self, from: data) { tasks = val }
        if let data = UserDefaults.standard.data(forKey: leadsKey), let val = try? decoder.decode([SalesLead].self, from: data) { salesLeads = val }
        if let data = UserDefaults.standard.data(forKey: attendanceKey), let val = try? decoder.decode([AttendanceRecord].self, from: data) { attendanceRecords = val }
        if let data = UserDefaults.standard.data(forKey: leavesKey), let val = try? decoder.decode([LeaveRequest].self, from: data) { leaveRequests = val }
        if let data = UserDefaults.standard.data(forKey: salaryHistKey), let val = try? decoder.decode([SalaryHistoryRecord].self, from: data) { salaryHistory = val }
        if let data = UserDefaults.standard.data(forKey: documentsKey), let val = try? decoder.decode([VaultDocument].self, from: data) { vaultDocuments = val }
        if let data = UserDefaults.standard.data(forKey: goalsKey), let val = try? decoder.decode([BusinessGoal].self, from: data) { businessGoals = val }
        if let data = UserDefaults.standard.data(forKey: integrationsKey), let val = try? decoder.decode([IntegrationItem].self, from: data) { integrations = val }
    }
    
    public func saveClients() { if let data = try? JSONEncoder().encode(clients) { UserDefaults.standard.set(data, forKey: clientsKey) } }
    public func savePackages() { if let data = try? JSONEncoder().encode(packages) { UserDefaults.standard.set(data, forKey: packagesKey) } }
    public func saveInvoices() { if let data = try? JSONEncoder().encode(invoices) { UserDefaults.standard.set(data, forKey: invoicesKey) } }
    public func savePayments() { if let data = try? JSONEncoder().encode(payments) { UserDefaults.standard.set(data, forKey: paymentsKey) } }
    public func saveWorkers() { if let data = try? JSONEncoder().encode(workers) { UserDefaults.standard.set(data, forKey: workersKey) } }
    public func savePayroll() { if let data = try? JSONEncoder().encode(payrollRecords) { UserDefaults.standard.set(data, forKey: payrollKey) } }
    public func saveExpenses() { if let data = try? JSONEncoder().encode(expenses) { UserDefaults.standard.set(data, forKey: expensesKey) } }
    public func saveProjects() { if let data = try? JSONEncoder().encode(projects) { UserDefaults.standard.set(data, forKey: projectsKey) } }
    public func saveSettings() { if let data = try? JSONEncoder().encode(settings) { UserDefaults.standard.set(data, forKey: settingsKey) } }
    public func saveAIMessages() { if let data = try? JSONEncoder().encode(aiMessages) { UserDefaults.standard.set(data, forKey: aiMessagesKey) } }
    
    public func clearAIMessages() {
        aiMessages = []
        saveAIMessages()
        showToast(title: "AI Chat History Cleared")
    }
    
    public func saveTasks() { if let data = try? JSONEncoder().encode(tasks) { UserDefaults.standard.set(data, forKey: tasksKey) } }
    public func saveLeads() { if let data = try? JSONEncoder().encode(salesLeads) { UserDefaults.standard.set(data, forKey: leadsKey) } }
    public func saveAttendance() { if let data = try? JSONEncoder().encode(attendanceRecords) { UserDefaults.standard.set(data, forKey: attendanceKey) } }
    public func saveLeaves() { if let data = try? JSONEncoder().encode(leaveRequests) { UserDefaults.standard.set(data, forKey: leavesKey) } }
    public func saveSalaryHistory() { if let data = try? JSONEncoder().encode(salaryHistory) { UserDefaults.standard.set(data, forKey: salaryHistKey) } }
    public func saveDocuments() { if let data = try? JSONEncoder().encode(vaultDocuments) { UserDefaults.standard.set(data, forKey: documentsKey) } }
    public func saveGoals() { if let data = try? JSONEncoder().encode(businessGoals) { UserDefaults.standard.set(data, forKey: goalsKey) } }
    public func saveIntegrations() { if let data = try? JSONEncoder().encode(integrations) { UserDefaults.standard.set(data, forKey: integrationsKey) } }
    
    // MARK: - Toast Banner Dispatcher
    public func showToast(title: String, isSuccess: Bool = true) {
        withAnimation(MotionTokens.snappySpring) {
            self.activeToast = ToastMessage(title: title, isSuccess: isSuccess)
        }
        MotionTokens.notification(type: isSuccess ? .success : .error)
    }
    
    // MARK: - Clients Operations
    public func addClient(_ client: Client) {
        clients.insert(client, at: 0)
        saveClients()
        AuditLogger.shared.log(actionType: "CREATE", entityType: "Client", entityId: client.id, description: "Added client: \(client.name)")
        showToast(title: "Client Saved Successfully")
    }
    
    public func updateClient(_ client: Client) {
        if let idx = clients.firstIndex(where: { $0.id == client.id }) {
            clients[idx] = client
            saveClients()
            AuditLogger.shared.log(actionType: "UPDATE", entityType: "Client", entityId: client.id, description: "Updated client: \(client.name)")
            showToast(title: "Client Updated")
        }
    }
    
    public func archiveClient(id: String) {
        if let idx = clients.firstIndex(where: { $0.id == id }) {
            clients[idx].status = .archived
            saveClients()
            AuditLogger.shared.log(actionType: "ARCHIVE", entityType: "Client", entityId: id, description: "Archived client: \(clients[idx].name)")
            showToast(title: "Client Moved to Archive")
        }
    }
    
    public func restoreClient(id: String) {
        if let idx = clients.firstIndex(where: { $0.id == id }) {
            clients[idx].status = .active
            saveClients()
            AuditLogger.shared.log(actionType: "RESTORE", entityType: "Client", entityId: id, description: "Restored client: \(clients[idx].name)")
            showToast(title: "Client Restored to Active CRM")
        }
    }
    
    public func deleteClient(id: String) {
        if let idx = clients.firstIndex(where: { $0.id == id }) {
            let name = clients[idx].name
            clients.remove(at: idx)
            saveClients()
            AuditLogger.shared.log(actionType: "DELETE", entityType: "Client", entityId: id, description: "Permanently deleted client: \(name)")
            showToast(title: "Client Removed")
        }
    }
    
    // MARK: - Invoices & Payments Operations
    public func generateNextInvoiceNumber() -> String {
        let prefix = settings.invoicePrefix
        let num = settings.nextInvoiceNumber
        settings.nextInvoiceNumber += 1
        saveSettings()
        return "\(prefix)\(num)"
    }
    
    public func addInvoice(_ invoice: Invoice) {
        invoices.insert(invoice, at: 0)
        saveInvoices()
        recalculateClientFinancials(clientId: invoice.clientId)
        AuditLogger.shared.log(actionType: "CREATE", entityType: "Invoice", entityId: invoice.id, description: "Issued invoice #\(invoice.invoiceNumber)")
        showToast(title: "Invoice #\(invoice.invoiceNumber) Issued")
    }
    
    public func recordPayment(for invoiceId: String, amount: Double, method: PaymentMethod, reference: String, notes: String) {
        guard let idx = invoices.firstIndex(where: { $0.id == invoiceId }) else { return }
        let inv = invoices[idx]
        
        if inv.status == .cancelled {
            showToast(title: "Cannot record payment for a cancelled invoice.", isSuccess: false)
            return
        }
        
        guard amount > 0 else {
            showToast(title: "Payment amount must be greater than zero.", isSuccess: false)
            return
        }
        
        if inv.balanceDue <= 0.01 {
            showToast(title: "Invoice is already paid in full.", isSuccess: false)
            return
        }
        
        // Prevent duplicate transaction reference submissions
        let cleanRef = reference.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanRef.isEmpty && payments.contains(where: { $0.transactionReference == cleanRef && !$0.isRefunded }) {
            showToast(title: "Duplicate transaction reference detected.", isSuccess: false)
            return
        }
        
        let validAmount = min(amount, inv.balanceDue)
        
        let payment = PaymentRecord(
            invoiceId: invoiceId,
            clientId: inv.clientId,
            amount: validAmount,
            paymentMethod: method,
            transactionReference: cleanRef.isEmpty ? "TXN-\(UUID().uuidString.prefix(8))" : cleanRef,
            notes: notes
        )
        
        payments.insert(payment, at: 0)
        savePayments()
        
        var updatedInv = inv
        if !updatedInv.paymentIds.contains(payment.id) {
            updatedInv.paymentIds.append(payment.id)
        }
        
        let totalPaid = payments.filter { $0.invoiceId == invoiceId && !$0.isRefunded }.reduce(0.0) { $0 + $1.amount }
        updatedInv.advancePaid = totalPaid
        updatedInv.balanceDue = max(0.0, updatedInv.totalAmount - totalPaid)
        
        if updatedInv.balanceDue <= 0.01 {
            updatedInv.status = .paid
        } else if totalPaid > 0 {
            updatedInv.status = .partiallyPaid
        }
        
        invoices[idx] = updatedInv
        saveInvoices()
        recalculateClientFinancials(clientId: updatedInv.clientId)
        
        AuditLogger.shared.log(actionType: "PAYMENT", entityType: "Invoice", entityId: invoiceId, description: "Recorded payment of \(settings.currencySymbol)\(validAmount) for invoice #\(updatedInv.invoiceNumber)")
        showToast(title: "Payment Recorded Successfully")
    }
    
    public func refundPayment(paymentId: String, reason: String = "Client Refund / Payment Reversal") {
        guard let pIdx = payments.firstIndex(where: { $0.id == paymentId }) else { return }
        payments[pIdx].isRefunded = true
        payments[pIdx].refundReason = reason
        savePayments()
        
        let invoiceId = payments[pIdx].invoiceId
        if let invIdx = invoices.firstIndex(where: { $0.id == invoiceId }) {
            var inv = invoices[invIdx]
            let nonRefundedPaid = payments.filter { $0.invoiceId == invoiceId && !$0.isRefunded }.reduce(0.0) { $0 + $1.amount }
            inv.advancePaid = nonRefundedPaid
            inv.balanceDue = max(0.0, inv.totalAmount - nonRefundedPaid)
            
            if inv.balanceDue <= 0.01 {
                inv.status = .paid
            } else if nonRefundedPaid > 0 {
                inv.status = .partiallyPaid
            } else {
                inv.status = (inv.dueDate < Date()) ? .overdue : .issued
            }
            
            invoices[invIdx] = inv
            saveInvoices()
            recalculateClientFinancials(clientId: inv.clientId)
        }
        
        AuditLogger.shared.log(actionType: "REFUND", entityType: "Payment", entityId: paymentId, description: "Refunded payment \(payments[pIdx].amount): \(reason)")
        showToast(title: "Payment Refunded & Reversed")
    }
    
    public func cancelInvoice(id: String, reason: String = "Administrative Cancellation") {
        if let idx = invoices.firstIndex(where: { $0.id == id }) {
            invoices[idx].status = .cancelled
            saveInvoices()
            recalculateClientFinancials(clientId: invoices[idx].clientId)
            AuditLogger.shared.log(actionType: "CANCEL", entityType: "Invoice", entityId: id, description: "Cancelled invoice #\(invoices[idx].invoiceNumber): \(reason)")
            showToast(title: "Invoice #\(invoices[idx].invoiceNumber) Cancelled")
        }
    }
    
    public func recalculateClientFinancials(clientId: String) {
        guard let idx = clients.firstIndex(where: { $0.id == clientId }) else { return }
        let clientInvoices = invoices.filter { $0.clientId == clientId && $0.status != .cancelled }
        let totalInvoiced = clientInvoices.reduce(0.0) { $0 + $1.totalAmount }
        let clientPayments = payments.filter { $0.clientId == clientId && !$0.isRefunded }
        let totalCollected = clientPayments.reduce(0.0) { $0 + $1.amount }
        
        clients[idx].totalInvoiced = totalInvoiced
        clients[idx].totalCollected = totalCollected
        clients[idx].outstandingBalance = max(0.0, totalInvoiced - totalCollected)
        saveClients()
    }
    
    // MARK: - Task Operations (Today's Tasks & AI Daily Planner)
    public func addTask(_ task: BusinessTask) {
        tasks.insert(task, at: 0)
        saveTasks()
        showToast(title: "Task Added to Schedule")
    }
    
    public func updateTask(_ task: BusinessTask) {
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[idx] = task
            saveTasks()
        }
    }
    
    public func deleteTask(id: String) {
        if let idx = tasks.firstIndex(where: { $0.id == id }) {
            let removed = tasks.remove(at: idx)
            saveTasks()
            AuditLogger.shared.log(actionType: "DELETE", entityType: "BusinessTask", entityId: id, description: "Deleted task: \(removed.title)")
            showToast(title: "Task Deleted")
        }
    }
    
    public func toggleTaskCompletion(id: String) {
        if let idx = tasks.firstIndex(where: { $0.id == id }) {
            withAnimation(MotionTokens.snappySpring) {
                if tasks[idx].status == .completed {
                    tasks[idx].status = .pending
                    tasks[idx].completedAt = nil
                } else {
                    tasks[idx].status = .completed
                    tasks[idx].completedAt = Date()
                    MotionTokens.notification(type: .success)
                }
            }
            saveTasks()
        }
    }
    
    // MARK: - Sales Pipeline Operations
    public func addSalesLead(_ lead: SalesLead) {
        salesLeads.insert(lead, at: 0)
        saveLeads()
        AuditLogger.shared.log(actionType: "CREATE", entityType: "SalesLead", entityId: lead.id, description: "New lead: \(lead.clientName)")
        showToast(title: "Lead Added to Pipeline")
    }
    
    public func updateSalesLead(_ lead: SalesLead) {
        if let idx = salesLeads.firstIndex(where: { $0.id == lead.id }) {
            salesLeads[idx] = lead
            saveLeads()
        }
    }
    
    // MARK: - Attendance & Leave Operations
    public func recordAttendance(workerId: String, workerName: String, status: AttendanceStatus, notes: String = "") {
        let record = AttendanceRecord(
            workerId: workerId,
            workerName: workerName,
            date: Date(),
            status: status,
            clockInTime: status == .present ? Date() : nil,
            notes: notes
        )
        attendanceRecords.insert(record, at: 0)
        saveAttendance()
        showToast(title: "Attendance Recorded for \(workerName)")
    }
    
    public func submitLeaveRequest(_ request: LeaveRequest) {
        leaveRequests.insert(request, at: 0)
        saveLeaves()
        showToast(title: "Leave Request Submitted")
    }
    
    public func processLeaveApproval(id: String, approve: Bool, comment: String = "") {
        if let idx = leaveRequests.firstIndex(where: { $0.id == id }) {
            leaveRequests[idx].status = approve ? .approved : .rejected
            leaveRequests[idx].managerComment = comment
            saveLeaves()
            AuditLogger.shared.log(actionType: "LEAVE", entityType: "Worker", entityId: leaveRequests[idx].workerId, description: "\(approve ? "Approved" : "Rejected") leave request")
            showToast(title: "Leave Request \(approve ? "Approved" : "Rejected")")
        }
    }
    
    // MARK: - Document Vault Operations
    public func addVaultDocument(_ doc: VaultDocument) {
        vaultDocuments.insert(doc, at: 0)
        saveDocuments()
        AuditLogger.shared.log(actionType: "UPLOAD", entityType: "Document", entityId: doc.id, description: "Imported document: \(doc.title)")
        showToast(title: "Document Vault Updated")
    }
    
    // MARK: - Packages & Workers Operations
    public func addPackage(_ pkg: BusinessPackage) { packages.append(pkg); savePackages() }
    public func updatePackage(_ pkg: BusinessPackage) {
        if let idx = packages.firstIndex(where: { $0.id == pkg.id }) { packages[idx] = pkg; savePackages() }
    }
    
    public func addWorker(_ worker: Worker) { workers.insert(worker, at: 0); saveWorkers(); showToast(title: "Team Member Added") }
    public func updateWorker(_ worker: Worker) {
        if let idx = workers.firstIndex(where: { $0.id == worker.id }) { workers[idx] = worker; saveWorkers() }
    }
    public func addPayrollRecord(_ record: PayrollRecord) {
        payrollRecords.insert(record, at: 0); savePayroll(); showToast(title: "Salary Slip Disbursed")
    }
    
    public func addExpense(_ exp: Expense) {
        expenses.insert(exp, at: 0)
        saveExpenses()
        showToast(title: "Expense Logged")
    }
    
    // MARK: - Computed Real-Time Business Metrics
    public var totalInvoicedRevenue: Double {
        let invoiceSum = invoices.filter { $0.status != .cancelled }.reduce(0.0) { $0 + $1.totalAmount }
        let clientDirectInvoiced = clients.filter { $0.status != .archived }.reduce(0.0) { $0 + $1.totalInvoiced }
        return max(invoiceSum, clientDirectInvoiced)
    }
    
    public var revenueCollected: Double {
        let paymentSum = payments.filter { !$0.isRefunded }.reduce(0.0) { $0 + $1.amount }
        let clientDirectCollected = clients.filter { $0.status != .archived }.reduce(0.0) { $0 + $1.totalCollected }
        return max(paymentSum, clientDirectCollected)
    }
    
    public var outstandingPayments: Double {
        let invoiceBalance = max(0.0, totalInvoicedRevenue - revenueCollected)
        let clientBalance = clients.filter { $0.status != .archived }.reduce(0.0) { $0 + $1.outstandingBalance }
        return max(invoiceBalance, clientBalance)
    }
    
    public var overdueInvoicesCount: Int {
        invoices.filter { $0.status == .overdue || ($0.status == .issued && $0.dueDate < Date()) }.count
    }
    
    public var totalMonthlyExpenses: Double {
        expenses.reduce(0.0) { $0 + $1.amount }
    }
    
    public var totalMonthlyPayrollExpenses: Double {
        payrollRecords.filter { $0.paymentStatus == .paid }.reduce(0.0) { $0 + $1.netSalaryPayable }
    }
    
    public var netOperatingIncome: Double {
        FinancialCalculator.shared.calculateNetOperatingIncome(
            revenueCollected: revenueCollected,
            monthlyExpenses: totalMonthlyExpenses,
            payrollExpenses: totalMonthlyPayrollExpenses
        )
    }
    
    public var activeClientsCount: Int { clients.filter { $0.status == .active }.count }
    public var totalWorkersCount: Int { workers.filter { $0.employmentStatus == .active || $0.employmentStatus == .probation }.count }
    public var activeProjectsCount: Int { projects.filter { $0.status == .inProgress || $0.status == .planning }.count }
    
    // Today's Tasks
    public var todayTasks: [BusinessTask] {
        let cal = Calendar.current
        return tasks.filter { cal.isDateInToday($0.dueDate) || ($0.status == .pending && $0.dueDate < Date()) }
    }
    
    public var overdueTasksCount: Int {
        tasks.filter { $0.isOverdue }.count
    }
    
    public var taskCompletionRate: Double {
        guard !todayTasks.isEmpty else { return 1.0 }
        let completed = todayTasks.filter { $0.status == .completed }.count
        return Double(completed) / Double(todayTasks.count)
    }
    
    // Weighted Sales Pipeline Value
    public var weightedPipelineValue: Double {
        FinancialCalculator.shared.calculateWeightedPipelineValue(leads: salesLeads)
    }
    
    // Transparent Business Health Score
    public var businessHealthScore: HealthScoreBreakdown {
        let target = businessGoals.first(where: { $0.metricType == .monthlyRevenue })?.targetValue ?? 1000000.0
        return FinancialCalculator.shared.calculateBusinessHealthScore(
            revenueCollected: revenueCollected,
            monthlyTarget: target,
            overdueCount: overdueInvoicesCount,
            pipelineValue: weightedPipelineValue,
            monthlyExpenses: totalMonthlyExpenses + totalMonthlyPayrollExpenses,
            taskCompletionRate: taskCompletionRate
        )
    }
    
    // Unified AI Analysis Context
    public var aiAnalysisContext: AIAnalysisContext {
        let topOverdue = clients
            .filter { $0.outstandingBalance > 0 }
            .sorted { $0.outstandingBalance > $1.outstandingBalance }
            .map { (name: $0.name, balance: $0.outstandingBalance) }
        
        let pkgBreakdown = packages.map { pkg in
            let rev = invoices
                .filter { $0.status == .paid }
                .flatMap { $0.items }
                .filter { $0.packageId == pkg.id }
                .reduce(0.0) { $0 + $1.total }
            return (packageName: pkg.name, revenue: rev)
        }
        
        return AIAnalysisContext(
            totalClients: clients.count,
            activeClients: activeClientsCount,
            totalInvoiced: totalInvoicedRevenue,
            revenueCollected: revenueCollected,
            outstandingPayments: outstandingPayments,
            overdueInvoicesCount: overdueInvoicesCount,
            totalWorkers: totalWorkersCount,
            monthlyPayrollExpenses: totalMonthlyPayrollExpenses,
            monthlyOperatingExpenses: totalMonthlyExpenses,
            netOperatingIncome: netOperatingIncome,
            activeProjectsCount: activeProjectsCount,
            currencySymbol: settings.currencySymbol,
            topOverdueClients: topOverdue,
            packageRevenueBreakdown: pkgBreakdown
        )
    }
}
