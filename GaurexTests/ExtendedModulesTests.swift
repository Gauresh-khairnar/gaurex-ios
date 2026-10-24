//
//  ExtendedModulesTests.swift
//  GAUREX Dashboard Tests
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import XCTest
@testable import Gaurex

final class ExtendedModulesTests: XCTestCase {
    
    func testMultiCurrencyConversions() {
        let calc = FinancialCalculator.shared
        
        // 100 USD to INR @ 83.50
        let inrAmount = calc.convert(amount: 100.0, from: .usd, to: .inr)
        XCTAssertEqual(inrAmount, 8350.0, accuracy: 0.1)
        
        // 10,000 INR to USD
        let usdAmount = calc.convert(amount: 8350.0, from: .inr, to: .usd)
        XCTAssertEqual(usdAmount, 100.0, accuracy: 0.1)
        
        // Direct identity
        let same = calc.convert(amount: 500.0, from: .aed, to: .aed)
        XCTAssertEqual(same, 500.0)
    }
    
    func testWeightedPipelineCalculation() {
        let leads = [
            SalesLead(clientName: "Enterprise A", companyName: "A Corp", email: "a@a.com", phone: "123", stage: .proposalSent, expectedDealValue: 500000.0, closingProbability: 0.60),
            SalesLead(clientName: "Startup B", companyName: "B Inc", email: "b@b.com", phone: "456", stage: .negotiation, expectedDealValue: 200000.0, closingProbability: 0.80),
            SalesLead(clientName: "Lost Lead", companyName: "Lost Co", email: "c@c.com", phone: "789", stage: .lost, expectedDealValue: 1000000.0, closingProbability: 0.0)
        ]
        
        // Weighted = (500k * 0.60) + (200k * 0.80) + 0 = 300k + 160k = 460,000
        let weighted = FinancialCalculator.shared.calculateWeightedPipelineValue(leads: leads)
        XCTAssertEqual(weighted, 460000.0, accuracy: 0.01)
    }
    
    func testTaskPlannerScheduleNonOverlapping() {
        let planner = TaskPlannerService.shared
        let existing = [
            BusinessTask(title: "Architecture Review", priority: .urgent, estimatedDurationMinutes: 45),
            BusinessTask(title: "Client Sprint Demo", priority: .high, estimatedDurationMinutes: 30)
        ]
        
        let plan = planner.planDay(existingTasks: existing, overdueInvoices: [], pendingFollowUps: [])
        XCTAssertGreaterThanOrEqual(plan.scheduledTasks.count, 2)
        
        // Ensure no overlapping start times
        if plan.scheduledTasks.count >= 2 {
            let first = plan.scheduledTasks[0]
            let second = plan.scheduledTasks[1]
            guard let start1 = first.scheduledStartTime, let start2 = second.scheduledStartTime else {
                XCTFail("Scheduled start times must be present.")
                return
            }
            let diff = start2.timeIntervalSince(start1)
            // Second task must start after first task duration + buffer
            XCTAssertGreaterThanOrEqual(diff, Double(first.estimatedDurationMinutes * 60))
        }
    }
    
    func testLeaveDaysCalculation() {
        let cal = Calendar.current
        let start = Date()
        let end = cal.date(byAdding: .day, value: 4, to: start) ?? start
        
        let leave = LeaveRequest(
            workerId: "GX-EMP-01",
            workerName: "Aarav",
            leaveType: .annual,
            startDate: start,
            endDate: end,
            reason: "Annual vacation"
        )
        
        // start to start+4 days inclusive = 5 days
        XCTAssertEqual(leave.numberOfDays, 5)
    }
    
    func testBusinessHealthScoreBoundsAndFactors() {
        let score = FinancialCalculator.shared.calculateBusinessHealthScore(
            revenueCollected: 750000.0,
            monthlyTarget: 1000000.0,
            overdueCount: 1,
            pipelineValue: 400000.0,
            monthlyExpenses: 200000.0,
            taskCompletionRate: 0.90
        )
        
        XCTAssertGreaterThanOrEqual(score.overallScore, 0)
        XCTAssertLessThanOrEqual(score.overallScore, 100)
        XCTAssertFalse(score.explanations.isEmpty)
    }
    
    func testDocumentFieldExtraction() {
        let text = "TAX INVOICE #GX-INV-9988\nMerchant: AWS Cloud\nDate: 24 Oct 2026\nTotal: ₹84,200.00"
        let fields = DocumentExtractionService.shared.extractFieldsFromDocument(rawText: text)
        
        XCTAssertEqual(fields.detectedType, "Invoice")
        XCTAssertTrue(fields.documentNumber?.contains("9988") ?? false)
        XCTAssertEqual(fields.totalAmount, 84200.0)
    }
    
    func testClientArchiveAndRestorePreservesRecords() {
        let store = FirestoreDataStore.shared
        let client = Client(name: "Client Archive Test", companyName: "Archival Inc", email: "archive@test.com", phone: "123")
        store.addClient(client)
        
        // Archive
        store.archiveClient(id: client.id)
        let archived = store.clients.first(where: { $0.id == client.id })
        XCTAssertEqual(archived?.status, .archived)
        
        // Restore
        store.restoreClient(id: client.id)
        let restored = store.clients.first(where: { $0.id == client.id })
        XCTAssertEqual(restored?.status, .active)
    }
    
    func testReportingCurrencySymbolSync() {
        let store = FirestoreDataStore.shared
        store.activeCurrency = .usd
        XCTAssertEqual(store.settings.currencySymbol, "$")
        
        store.activeCurrency = .eur
        XCTAssertEqual(store.settings.currencySymbol, "€")
        
        store.activeCurrency = .inr
        XCTAssertEqual(store.settings.currencySymbol, "₹")
    }
}
