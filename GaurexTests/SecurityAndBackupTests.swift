//
//  SecurityAndBackupTests.swift
//  GAUREX Dashboard Tests
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import XCTest
@testable import Gaurex

final class SecurityAndBackupTests: XCTestCase {
    
    func testDataExportAndRestorationIntegrity() throws {
        let settings = BusinessSettings(founderName: "Gauresh Khairnar")
        let client = Client(name: "Test Client", companyName: "GAUREX Labs", email: "test@gaurex.com", phone: "9999999999")
        let pkg = BusinessPackage(name: "Security Audit", description: "Vulnerability analysis", basePrice: 85000.0)
        
        let exportedData = try DataBackupService.shared.exportJSON(
            settings: settings,
            clients: [client],
            packages: [pkg],
            invoices: [],
            payments: [],
            workers: [],
            payrollRecords: [],
            expenses: [],
            projects: []
        )
        
        XCTAssertFalse(exportedData.isEmpty)
        
        let restored = try DataBackupService.shared.decodeBackup(from: exportedData)
        XCTAssertEqual(restored.founder, "Gauresh Khairnar (OWNER)")
        XCTAssertEqual(restored.clients.count, 1)
        XCTAssertEqual(restored.clients.first?.name, "Test Client")
        XCTAssertEqual(restored.packages.count, 1)
        XCTAssertEqual(restored.packages.first?.name, "Security Audit")
    }
    
    func testThemePersistence() {
        let theme = ThemeManager.shared
        theme.currentTheme = .midnight
        XCTAssertEqual(theme.currentTheme, .midnight)
        XCTAssertEqual(theme.currentThemeRaw, AppTheme.midnight.rawValue)
        
        theme.currentTheme = .gaurexAccent
        XCTAssertEqual(theme.currentTheme, .gaurexAccent)
    }
}
