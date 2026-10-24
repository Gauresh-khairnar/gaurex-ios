//
//  PayrollAndPDFTests.swift
//  GAUREX Dashboard Tests
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import XCTest
@testable import Gaurex

final class PayrollAndPDFTests: XCTestCase {
    
    func testPayrollCalculationWithUnpaidLeaves() {
        let basic = 90000.0
        let hra = 30000.0
        let special = 10000.0
        let bonus = 5000.0
        let tax = 6000.0
        let daysInMonth = 30
        let unpaidLeaves = 2
        
        let result = FinancialCalculator.shared.calculatePayroll(
            basicSalary: basic,
            houseRentAllowance: hra,
            specialAllowance: special,
            performanceBonus: bonus,
            daysInMonth: daysInMonth,
            unpaidLeaveDays: unpaidLeaves,
            taxDeduction: tax,
            otherDeductions: 0.0
        )
        
        // Gross = 90k + 30k + 10k + 5k = 135,000
        XCTAssertEqual(result.grossEarnings, 135000.0, accuracy: 0.01)
        
        // Per day = 90,000 / 30 = 3,000. 2 days = 6,000
        XCTAssertEqual(result.unpaidLeaveDeduction, 6000.0, accuracy: 0.01)
        
        // Deductions = 6,000 + 6,000 = 12,000
        XCTAssertEqual(result.totalDeductions, 12000.0, accuracy: 0.01)
        
        // Net = 135,000 - 12,000 = 123,000
        XCTAssertEqual(result.netSalaryPayable, 123000.0, accuracy: 0.01)
    }
    
    func testInvoicePDFGeneration() {
        let client = Client(
            name: "John Enterprise",
            companyName: "Acme Corp",
            email: "john@acme.com",
            phone: "+91 9876543210"
        )
        
        let item = InvoiceItem(title: "Mobile App MVP", quantity: 1, unitPrice: 250000.0)
        let invoice = Invoice(
            invoiceNumber: "GX-INV-TEST",
            clientId: client.id,
            clientName: client.name,
            clientEmail: client.email,
            items: [item],
            subtotal: 250000.0,
            discountTotal: 0.0,
            taxTotal: 45000.0,
            totalAmount: 295000.0,
            advancePaid: 0.0,
            balanceDue: 295000.0,
            status: .issued
        )
        
        let pdfData = PDFGeneratorService.shared.generateInvoicePDF(invoice: invoice, client: client)
        XCTAssertFalse(pdfData.isEmpty)
        // PDF header magic bytes "%PDF"
        let prefix = String(data: pdfData.prefix(4), encoding: .utf8)
        XCTAssertEqual(prefix, "%PDF")
    }
    
    func testSalarySlipPDFGeneration() {
        let worker = Worker(
            employeeId: "GX-EMP-01",
            fullName: "Aarav Sharma",
            email: "aarav@gaurex.com",
            phone: "+91 9876543211",
            jobTitle: "Senior Systems Engineer",
            monthlySalary: 120000.0
        )
        
        let payroll = PayrollRecord(
            workerId: worker.id,
            workerName: worker.fullName,
            employeeId: worker.employeeId,
            designation: worker.jobTitle,
            salaryMonth: "October",
            salaryYear: 2026,
            basicSalary: 72000.0,
            houseRentAllowance: 30000.0,
            specialAllowance: 18000.0
        )
        
        let pdfData = PDFGeneratorService.shared.generateSalarySlipPDF(payroll: payroll, worker: worker)
        XCTAssertFalse(pdfData.isEmpty)
        let prefix = String(data: pdfData.prefix(4), encoding: .utf8)
        XCTAssertEqual(prefix, "%PDF")
    }
}
