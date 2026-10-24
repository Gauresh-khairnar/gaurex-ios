//
//  AuditAndBackupServices.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import Foundation

// MARK: - Audit Logger
public final class AuditLogger: ObservableObject {
    public static let shared = AuditLogger()
    
    @Published public private(set) var logs: [ActivityLog] = []
    
    private let storageKey = "gaurex_activity_audit_logs"
    
    private init() {
        loadLogs()
    }
    
    public func log(actionType: String, entityType: String, entityId: String, description: String) {
        let entry = ActivityLog(
            actionType: actionType,
            entityType: entityType,
            entityId: entityId,
            description: description
        )
        DispatchQueue.main.async {
            self.logs.insert(entry, at: 0)
            self.persistLogs()
        }
    }
    
    private func persistLogs() {
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func loadLogs() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([ActivityLog].self, from: data) {
            self.logs = saved
        }
    }
    
    public func clearLogs() {
        logs.removeAll()
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}

// MARK: - Full Business Data Backup & Restore Service
public struct FullBusinessBackupData: Codable {
    public var version: String
    public var exportDate: Date
    public var founder: String
    public var settings: BusinessSettings
    public var clients: [Client]
    public var packages: [BusinessPackage]
    public var invoices: [Invoice]
    public var payments: [PaymentRecord]
    public var workers: [Worker]
    public var payrollRecords: [PayrollRecord]
    public var expenses: [Expense]
    public var projects: [Project]
}

public final class DataBackupService {
    public static let shared = DataBackupService()
    
    private init() {}
    
    public func exportJSON(
        settings: BusinessSettings,
        clients: [Client],
        packages: [BusinessPackage],
        invoices: [Invoice],
        payments: [PaymentRecord],
        workers: [Worker],
        payrollRecords: [PayrollRecord],
        expenses: [Expense],
        projects: [Project]
    ) throws -> Data {
        let backup = FullBusinessBackupData(
            version: "1.0.0",
            exportDate: Date(),
            founder: "Gauresh Khairnar (OWNER)",
            settings: settings,
            clients: clients,
            packages: packages,
            invoices: invoices,
            payments: payments,
            workers: workers,
            payrollRecords: payrollRecords,
            expenses: expenses,
            projects: projects
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(backup)
    }
    
    public func decodeBackup(from data: Data) throws -> FullBusinessBackupData {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(FullBusinessBackupData.self, from: data)
    }
}
