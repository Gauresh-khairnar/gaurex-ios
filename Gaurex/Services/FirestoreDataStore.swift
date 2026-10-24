//
//  FirestoreDataStore.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI
import Combine

public final class FirestoreDataStore: ObservableObject {
    public static let shared = FirestoreDataStore()
    
    // Published State
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
    
    // Filter State
    @Published public var activeDateFilter: DateRangeFilter = .thisMonth
    
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
    
    private init() {
        loadData()
        seedInitialPackagesIfEmpty()
    }
    
    // MARK: - Initial Packages Setup
    private func seedInitialPackagesIfEmpty() {
        if packages.isEmpty {
            packages = [
                BusinessPackage(
                    name: "Enterprise Custom Software",
                    description: "End-to-end full-stack web & backend application architecture, microservices, and high-availability deployment.",
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
    }
    
    // MARK: - Persistence
    public func saveData() {
        saveClients()
        savePackages()
        saveInvoices()
        savePayments()
        saveWorkers()
        savePayroll()
        saveExpenses()
        saveProjects()
        saveSettings()
        saveAIMessages()
    }
    
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
    }
    
    public func saveClients() {
        if let data = try? JSONEncoder().encode(clients) { UserDefaults.standard.set(data, forKey: clientsKey) }
    }
    public func savePackages() {
        if let data = try? JSONEncoder().encode(packages) { UserDefaults.standard.set(data, forKey: packagesKey) }
    }
    public func saveInvoices() {
        if let data = try? JSONEncoder().encode(invoices) { UserDefaults.standard.set(data, forKey: invoicesKey) }
    }
    public func savePayments() {
        if let data = try? JSONEncoder().encode(payments) { UserDefaults.standard.set(data, forKey: paymentsKey) }
    }
    public func saveWorkers() {
        if let data = try? JSONEncoder().encode(workers) { UserDefaults.standard.set(data, forKey: workersKey) }
    }
    public func savePayroll() {
        if let data = try? JSONEncoder().encode(payrollRecords) { UserDefaults.standard.set(data, forKey: payrollKey) }
    }
    public func saveExpenses() {
        if let data = try? JSONEncoder().encode(expenses) { UserDefaults.standard.set(data, forKey: expensesKey) }
    }
    public func saveProjects() {
        if let data = try? JSONEncoder().encode(projects) { UserDefaults.standard.set(data, forKey: projectsKey) }
    }
    public func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) { UserDefaults.standard.set(data, forKey: settingsKey) }
    }
    public func saveAIMessages() {
        if let data = try? JSONEncoder().encode(aiMessages) { UserDefaults.standard.set(data, forKey: aiMessagesKey) }
    }
    
    // MARK: - Client Operations
    public func addClient(_ client: Client) {
        clients.insert(client, at: 0)
        saveClients()
        AuditLogger.shared.log(
            actionType: "CREATE",
            entityType: "Client",
            entityId: client.id,
            description: "Registered new client: \(client.name) (\(client.companyName))"
        )
    }
    
    public func updateClient(_ client: Client) {
        if let idx = clients.firstIndex(where: { $0.id == client.id }) {
            clients[idx] = client
            saveClients()
            AuditLogger.shared.log(
                actionType: "UPDATE",
                entityType: "Client",
                entityId: client.id,
                description: "Updated profile for: \(client.name)"
            )
        }
    }
    
    public func deleteClient(id: String) {
        if let idx = clients.firstIndex(where: { $0.id == id }) {
            let name = clients[idx].name
            clients.remove(at: idx)
            saveClients()
            AuditLogger.shared.log(
                actionType: "DELETE",
                entityType: "Client",
                entityId: id,
                description: "Archived client record: \(name)"
            )
        }
    }
    
    // MARK: - Package Operations
    public func addPackage(_ package: BusinessPackage) {
        packages.append(package)
        savePackages()
        AuditLogger.shared.log(
            actionType: "CREATE",
            entityType: "Package",
            entityId: package.id,
            description: "Created service package: \(package.name)"
        )
    }
    
    public func updatePackage(_ package: BusinessPackage) {
        if let idx = packages.firstIndex(where: { $0.id == package.id }) {
            packages[idx] = package
            savePackages()
            AuditLogger.shared.log(
                actionType: "UPDATE",
                entityType: "Package",
                entityId: package.id,
                description: "Updated package: \(package.name)"
            )
        }
    }
    
    // MARK: - Invoice & Payment Operations
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
        AuditLogger.shared.log(
            actionType: "CREATE",
            entityType: "Invoice",
            entityId: invoice.id,
            description: "Issued invoice #\(invoice.invoiceNumber) for \(invoice.clientName)"
        )
    }
    
    public func recordPayment(for invoiceId: String, amount: Double, method: PaymentMethod, reference: String, notes: String) {
        guard let idx = invoices.firstIndex(where: { $0.id == invoiceId }) else { return }
        
        let payment = PaymentRecord(
            invoiceId: invoiceId,
            clientId: invoices[idx].clientId,
            amount: amount,
            paymentMethod: method,
            transactionReference: reference,
            notes: notes
        )
        
        payments.insert(payment, at: 0)
        savePayments()
        
        // Update invoice advance/recorded paid amount and status
        var inv = invoices[idx]
        inv.paymentIds.append(payment.id)
        let totalPaid = payments.filter { $0.invoiceId == invoiceId }.reduce(0.0) { $0 + $1.amount }
        inv.advancePaid = totalPaid
        inv.balanceDue = max(0.0, inv.totalAmount - totalPaid)
        
        if inv.balanceDue <= 0.01 {
            inv.status = .paid
        } else if totalPaid > 0 {
            inv.status = .partiallyPaid
        }
        
        invoices[idx] = inv
        saveInvoices()
        
        recalculateClientFinancials(clientId: inv.clientId)
        
        AuditLogger.shared.log(
            actionType: "PAYMENT",
            entityType: "Invoice",
            entityId: invoiceId,
            description: "Recorded payment of \(settings.currencySymbol)\(amount) via \(method.rawValue) for Invoice #\(inv.invoiceNumber)"
        )
    }
    
    public func recalculateClientFinancials(clientId: String) {
        guard let idx = clients.firstIndex(where: { $0.id == clientId }) else { return }
        let clientInvoices = invoices.filter { $0.clientId == clientId && $0.status != .cancelled }
        let totalInvoiced = clientInvoices.reduce(0.0) { $0 + $1.totalAmount }
        
        let clientPayments = payments.filter { $0.clientId == clientId }
        let totalCollected = clientPayments.reduce(0.0) { $0 + $1.amount }
        
        clients[idx].totalInvoiced = totalInvoiced
        clients[idx].totalCollected = totalCollected
        clients[idx].outstandingBalance = max(0.0, totalInvoiced - totalCollected)
        saveClients()
    }
    
    // MARK: - Worker & Payroll Operations
    public func addWorker(_ worker: Worker) {
        workers.insert(worker, at: 0)
        saveWorkers()
        AuditLogger.shared.log(
            actionType: "CREATE",
            entityType: "Worker",
            entityId: worker.id,
            description: "Added team member: \(worker.fullName) (\(worker.jobTitle))"
        )
    }
    
    public func updateWorker(_ worker: Worker) {
        if let idx = workers.firstIndex(where: { $0.id == worker.id }) {
            workers[idx] = worker
            saveWorkers()
            AuditLogger.shared.log(
                actionType: "UPDATE",
                entityType: "Worker",
                entityId: worker.id,
                description: "Updated profile for: \(worker.fullName)"
            )
        }
    }
    
    public func addPayrollRecord(_ record: PayrollRecord) {
        payrollRecords.insert(record, at: 0)
        savePayroll()
        AuditLogger.shared.log(
            actionType: "CREATE",
            entityType: "Payroll",
            entityId: record.id,
            description: "Processed salary slip for \(record.workerName) [\(record.salaryMonth) \(record.salaryYear)]"
        )
    }
    
    // MARK: - Real-time Computed Business Metrics
    public var totalInvoicedRevenue: Double {
        invoices.filter { $0.status != .cancelled }.reduce(0.0) { $0 + $1.totalAmount }
    }
    
    public var revenueCollected: Double {
        payments.reduce(0.0) { $0 + $1.amount }
    }
    
    public var outstandingPayments: Double {
        max(0.0, totalInvoicedRevenue - revenueCollected)
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
    
    public var activeClientsCount: Int {
        clients.filter { $0.status == .active }.count
    }
    
    public var activeProjectsCount: Int {
        projects.filter { $0.status == .inProgress || $0.status == .planning }.count
    }
    
    public var totalWorkersCount: Int {
        workers.filter { $0.employmentStatus == .active || $0.employmentStatus == .probation }.count
    }
}
