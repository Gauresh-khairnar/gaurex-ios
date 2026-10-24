//
//  PDFGeneratorService.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import UIKit
import PDFKit

public final class PDFGeneratorService {
    public static let shared = PDFGeneratorService()
    
    private init() {}
    
    // MARK: - Generate Invoice PDF
    public func generateInvoicePDF(
        invoice: Invoice,
        client: Client,
        business: BusinessSettings = BusinessSettings()
    ) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "GAUREX Executive Suite",
            kCGPDFContextAuthor: "Gauresh Khairnar (OWNER)",
            kCGPDFContextTitle: "Invoice \(invoice.invoiceNumber)"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // Standard A4 Size: 595.2 x 841.8 points
        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        return renderer.pdfData { context in
            context.beginPage()
            let margin: CGFloat = 40.0
            var currentY: CGFloat = margin
            
            // 1. Header Bar
            let titleFont = UIFont.systemFont(ofSize: 24, weight: .black)
            let headerText = business.companyName
            let headerAttrs: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.black
            ]
            headerText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: headerAttrs)
            
            // Owner Badge on PDF
            let badgeText = " [ \(business.ownerBadge) ] "
            let badgeFont = UIFont.monospacedSystemFont(ofSize: 11, weight: .bold)
            let badgeAttrs: [NSAttributedString.Key: Any] = [
                .font: badgeFont,
                .foregroundColor: UIColor(red: 0.7, green: 0.5, blue: 0.1, alpha: 1.0)
            ]
            badgeText.draw(at: CGPoint(x: margin + 115, y: currentY + 6), withAttributes: badgeAttrs)
            
            // Invoice Title & Number (Right aligned)
            let invNumberText = "INVOICE: \(invoice.invoiceNumber)"
            let invNumFont = UIFont.systemFont(ofSize: 15, weight: .bold)
            let invNumSize = invNumberText.size(withAttributes: [.font: invNumFont])
            let invNumAttrs: [NSAttributedString.Key: Any] = [
                .font: invNumFont,
                .foregroundColor: UIColor.black
            ]
            invNumberText.draw(at: CGPoint(x: pageWidth - margin - invNumSize.width, y: currentY), withAttributes: invNumAttrs)
            
            currentY += 30
            
            // Business Details
            let businessInfo = "\(business.tagline)\nFounder: \(business.founderName)\nEmail: \(business.officialEmail) | Phone: \(business.officialPhone)\nGSTIN: \(business.gstNumber)"
            let bodyFont = UIFont.systemFont(ofSize: 9, weight: .regular)
            let subAttrs: [NSAttributedString.Key: Any] = [
                .font: bodyFont,
                .foregroundColor: UIColor.darkGray
            ]
            businessInfo.draw(in: CGRect(x: margin, y: currentY, width: 300, height: 50), withAttributes: subAttrs)
            
            // Status and Dates (Right aligned)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let dateInfo = "Issue Date: \(dateFormatter.string(from: invoice.issueDate))\nDue Date: \(dateFormatter.string(from: invoice.dueDate))\nStatus: \(invoice.status.rawValue.uppercased())"
            dateInfo.draw(in: CGRect(x: pageWidth - margin - 180, y: currentY, width: 180, height: 50), withAttributes: subAttrs)
            
            currentY += 60
            
            // Divider
            let path = UIBezierPath()
            path.move(to: CGPoint(x: margin, y: currentY))
            path.addLine(to: CGPoint(x: pageWidth - margin, y: currentY))
            UIColor.lightGray.setStroke()
            path.lineWidth = 1
            path.stroke()
            
            currentY += 15
            
            // Bill To Section
            let billToHeader = "BILLED TO:"
            billToHeader.draw(at: CGPoint(x: margin, y: currentY), withAttributes: [.font: UIFont.systemFont(ofSize: 10, weight: .bold), .foregroundColor: UIColor.gray])
            currentY += 14
            
            let clientDetails = "\(client.companyName.isEmpty ? client.name : client.companyName)\nAttn: \(client.name)\nEmail: \(client.email) | Phone: \(client.phone)\n\(client.address)"
            clientDetails.draw(in: CGRect(x: margin, y: currentY, width: 400, height: 45), withAttributes: subAttrs)
            
            currentY += 55
            
            // Table Header
            let tableHeaderY = currentY
            let tableBgRect = CGRect(x: margin, y: tableHeaderY, width: pageWidth - (margin * 2), height: 22)
            UIColor(white: 0.94, alpha: 1.0).setFill()
            UIBezierPath(rect: tableBgRect).fill()
            
            let thFont = UIFont.systemFont(ofSize: 9, weight: .bold)
            let col1X = margin + 8
            let col2X = margin + 180
            let col3X = margin + 320
            let col4X = margin + 390
            let col5X = margin + 450
            
            "ITEM / SERVICE".draw(at: CGPoint(x: col1X, y: tableHeaderY + 5), withAttributes: [.font: thFont])
            "DESCRIPTION".draw(at: CGPoint(x: col2X, y: tableHeaderY + 5), withAttributes: [.font: thFont])
            "QTY".draw(at: CGPoint(x: col3X, y: tableHeaderY + 5), withAttributes: [.font: thFont])
            "RATE".draw(at: CGPoint(x: col4X, y: tableHeaderY + 5), withAttributes: [.font: thFont])
            "TOTAL".draw(at: CGPoint(x: col5X, y: tableHeaderY + 5), withAttributes: [.font: thFont])
            
            currentY += 26
            
            // Table Rows
            let itemFont = UIFont.systemFont(ofSize: 9, weight: .regular)
            for item in invoice.items {
                item.title.draw(in: CGRect(x: col1X, y: currentY, width: 165, height: 20), withAttributes: [.font: itemFont])
                item.itemDescription.draw(in: CGRect(x: col2X, y: currentY, width: 135, height: 20), withAttributes: [.font: itemFont])
                "\(item.quantity)".draw(at: CGPoint(x: col3X, y: currentY), withAttributes: [.font: itemFont])
                "\(business.currencySymbol)\(String(format: "%.2f", item.unitPrice))".draw(at: CGPoint(x: col4X, y: currentY), withAttributes: [.font: itemFont])
                "\(business.currencySymbol)\(String(format: "%.2f", item.total))".draw(at: CGPoint(x: col5X, y: currentY), withAttributes: [.font: itemFont])
                
                currentY += 24
            }
            
            currentY += 10
            // Divider
            let rowDivider = UIBezierPath()
            rowDivider.move(to: CGPoint(x: margin, y: currentY))
            rowDivider.addLine(to: CGPoint(x: pageWidth - margin, y: currentY))
            UIColor(white: 0.88, alpha: 1.0).setStroke()
            rowDivider.lineWidth = 0.5
            rowDivider.stroke()
            
            currentY += 15
            
            // Totals Box (Right aligned)
            let totalsX: CGFloat = pageWidth - margin - 220
            let totalsFont = UIFont.systemFont(ofSize: 10, weight: .regular)
            let boldFont = UIFont.systemFont(ofSize: 11, weight: .bold)
            
            func drawTotalLine(label: String, value: String, isBold: Bool = false) {
                let font = isBold ? boldFont : totalsFont
                let color = isBold ? UIColor.black : UIColor.darkGray
                label.draw(at: CGPoint(x: totalsX, y: currentY), withAttributes: [.font: font, .foregroundColor: color])
                let valSize = value.size(withAttributes: [.font: font])
                value.draw(at: CGPoint(x: pageWidth - margin - valSize.width, y: currentY), withAttributes: [.font: font, .foregroundColor: color])
                currentY += 18
            }
            
            drawTotalLine(label: "Subtotal:", value: "\(business.currencySymbol)\(String(format: "%.2f", invoice.subtotal))")
            if invoice.discountTotal > 0 {
                drawTotalLine(label: "Discount:", value: "-\(business.currencySymbol)\(String(format: "%.2f", invoice.discountTotal))")
            }
            drawTotalLine(label: "Tax / GST (18%):", value: "\(business.currencySymbol)\(String(format: "%.2f", invoice.taxTotal))")
            drawTotalLine(label: "Final Total:", value: "\(business.currencySymbol)\(String(format: "%.2f", invoice.totalAmount))", isBold: true)
            drawTotalLine(label: "Advance Paid:", value: "\(business.currencySymbol)\(String(format: "%.2f", invoice.advancePaid))")
            drawTotalLine(label: "Balance Due:", value: "\(business.currencySymbol)\(String(format: "%.2f", invoice.balanceDue))", isBold: true)
            
            currentY += 20
            
            // Bank & Payment Information
            let bankInfo = "PAYMENT DETAILS / BANK WIRE\nBank: \(business.bankName) | A/C: \(business.bankAccountNumber)\nIFSC: \(business.bankIfsc) | Branch: \(business.bankBranch)\nUPI ID: \(business.upiId)\n\nTerms: \(invoice.paymentTerms)\nNote: \(invoice.notes)"
            bankInfo.draw(in: CGRect(x: margin, y: currentY, width: 340, height: 100), withAttributes: subAttrs)
            
            // Signatory Box
            let signX = pageWidth - margin - 150
            let signY = currentY + 30
            let signLine = UIBezierPath()
            signLine.move(to: CGPoint(x: signX, y: signY))
            signLine.addLine(to: CGPoint(x: signX + 150, y: signY))
            UIColor.black.setStroke()
            signLine.lineWidth = 1
            signLine.stroke()
            
            let signText = "\(business.founderName)\n\(business.ownerBadge), GAUREX"
            signText.draw(in: CGRect(x: signX, y: signY + 6, width: 150, height: 35), withAttributes: [.font: UIFont.systemFont(ofSize: 9, weight: .bold), .foregroundColor: UIColor.black])
        }
    }
    
    // MARK: - Generate Salary Slip PDF
    public func generateSalarySlipPDF(
        payroll: PayrollRecord,
        worker: Worker,
        business: BusinessSettings = BusinessSettings()
    ) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "GAUREX Executive Suite",
            kCGPDFContextAuthor: "Gauresh Khairnar (OWNER)",
            kCGPDFContextTitle: "Salary Slip - \(worker.fullName) - \(payroll.salaryMonth) \(payroll.salaryYear)"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        return renderer.pdfData { context in
            context.beginPage()
            let margin: CGFloat = 40.0
            var currentY: CGFloat = margin
            
            // Header
            let titleFont = UIFont.systemFont(ofSize: 22, weight: .black)
            business.companyName.draw(at: CGPoint(x: margin, y: currentY), withAttributes: [.font: titleFont, .foregroundColor: UIColor.black])
            
            let slipTitle = "EXECUTIVE PAYSLIP"
            let slipFont = UIFont.systemFont(ofSize: 14, weight: .bold)
            let slipSize = slipTitle.size(withAttributes: [.font: slipFont])
            slipTitle.draw(at: CGPoint(x: pageWidth - margin - slipSize.width, y: currentY), withAttributes: [.font: slipFont, .foregroundColor: UIColor.black])
            
            currentY += 28
            
            let subInfo = "Period: \(payroll.salaryMonth) \(payroll.salaryYear) | Confidential Employee Compensation Record"
            subInfo.draw(at: CGPoint(x: margin, y: currentY), withAttributes: [.font: UIFont.systemFont(ofSize: 10, weight: .medium), .foregroundColor: UIColor.darkGray])
            
            currentY += 25
            
            // Employee details box
            let boxRect = CGRect(x: margin, y: currentY, width: pageWidth - (margin * 2), height: 50)
            UIColor(white: 0.95, alpha: 1.0).setFill()
            UIBezierPath(roundedRect: boxRect, cornerRadius: 6).fill()
            
            let empCol1 = "Employee Name: \(worker.fullName)\nEmployee ID: \(worker.employeeId)"
            let empCol2 = "Designation: \(worker.jobTitle)\nDepartment: \(worker.department)"
            let empCol3 = "Status: \(payroll.paymentStatus.rawValue)\nBank A/C: \(worker.bankDetails.maskedAccountNumber)"
            
            let infoFont = UIFont.systemFont(ofSize: 9, weight: .regular)
            empCol1.draw(in: CGRect(x: margin + 12, y: currentY + 10, width: 160, height: 35), withAttributes: [.font: infoFont])
            empCol2.draw(in: CGRect(x: margin + 180, y: currentY + 10, width: 160, height: 35), withAttributes: [.font: infoFont])
            empCol3.draw(in: CGRect(x: margin + 350, y: currentY + 10, width: 150, height: 35), withAttributes: [.font: infoFont])
            
            currentY += 65
            
            // Earnings & Deductions Tables (Side by Side)
            let colWidth = (pageWidth - (margin * 2) - 20) / 2
            let earningsX = margin
            let deductionsX = margin + colWidth + 20
            
            // Table Headers
            let thFont = UIFont.systemFont(ofSize: 10, weight: .bold)
            UIColor(white: 0.90, alpha: 1.0).setFill()
            UIBezierPath(rect: CGRect(x: earningsX, y: currentY, width: colWidth, height: 20)).fill()
            UIBezierPath(rect: CGRect(x: deductionsX, y: currentY, width: colWidth, height: 20)).fill()
            
            "EARNINGS".draw(at: CGPoint(x: earningsX + 8, y: currentY + 4), withAttributes: [.font: thFont])
            "DEDUCTIONS".draw(at: CGPoint(x: deductionsX + 8, y: currentY + 4), withAttributes: [.font: thFont])
            
            currentY += 26
            
            let rowFont = UIFont.systemFont(ofSize: 9, weight: .regular)
            func drawRow(leftLabel: String, leftVal: Double, rightLabel: String, rightVal: Double) {
                leftLabel.draw(at: CGPoint(x: earningsX + 8, y: currentY), withAttributes: [.font: rowFont])
                let lValStr = "\(business.currencySymbol)\(String(format: "%.2f", leftVal))"
                let lSize = lValStr.size(withAttributes: [.font: rowFont])
                lValStr.draw(at: CGPoint(x: earningsX + colWidth - lSize.width - 8, y: currentY), withAttributes: [.font: rowFont])
                
                rightLabel.draw(at: CGPoint(x: deductionsX + 8, y: currentY), withAttributes: [.font: rowFont])
                let rValStr = "\(business.currencySymbol)\(String(format: "%.2f", rightVal))"
                let rSize = rValStr.size(withAttributes: [.font: rowFont])
                rValStr.draw(at: CGPoint(x: deductionsX + colWidth - rSize.width - 8, y: currentY), withAttributes: [.font: rowFont])
                
                currentY += 20
            }
            
            drawRow(leftLabel: "Basic Salary", leftVal: payroll.basicSalary, rightLabel: "Tax / TDS Deduction", rightVal: payroll.taxDeduction)
            drawRow(leftLabel: "House Rent Allowance (HRA)", leftVal: payroll.houseRentAllowance, rightLabel: "Provident Fund / Insurance", rightVal: payroll.providentFundOrInsurance)
            drawRow(leftLabel: "Special Executive Allowance", leftVal: payroll.specialAllowance, rightLabel: "Unpaid Leave (\(payroll.unpaidLeaveDays) days)", rightVal: payroll.unpaidLeaveDeduction)
            drawRow(leftLabel: "Performance Bonus", leftVal: payroll.performanceBonus, rightLabel: "Other Deductions", rightVal: 0.0)
            
            currentY += 10
            // Subtotal rows
            let boldFont = UIFont.systemFont(ofSize: 10, weight: .bold)
            "Gross Earnings:".draw(at: CGPoint(x: earningsX + 8, y: currentY), withAttributes: [.font: boldFont])
            let grossStr = "\(business.currencySymbol)\(String(format: "%.2f", payroll.grossEarnings))"
            let gSize = grossStr.size(withAttributes: [.font: boldFont])
            grossStr.draw(at: CGPoint(x: earningsX + colWidth - gSize.width - 8, y: currentY), withAttributes: [.font: boldFont])
            
            "Total Deductions:".draw(at: CGPoint(x: deductionsX + 8, y: currentY), withAttributes: [.font: boldFont])
            let dedStr = "\(business.currencySymbol)\(String(format: "%.2f", payroll.totalDeductions))"
            let dSize = dedStr.size(withAttributes: [.font: boldFont])
            dedStr.draw(at: CGPoint(x: deductionsX + colWidth - dSize.width - 8, y: currentY), withAttributes: [.font: boldFont])
            
            currentY += 35
            
            // Net Pay Banner
            let netRect = CGRect(x: margin, y: currentY, width: pageWidth - (margin * 2), height: 44)
            UIColor.black.setFill()
            UIBezierPath(roundedRect: netRect, cornerRadius: 8).fill()
            
            let netLabel = "NET SALARY DISBURSED"
            netLabel.draw(at: CGPoint(x: margin + 14, y: currentY + 14), withAttributes: [.font: UIFont.systemFont(ofSize: 11, weight: .bold), .foregroundColor: UIColor.white])
            
            let netValStr = "\(business.currencySymbol)\(String(format: "%.2f", payroll.netSalaryPayable))"
            let netValFont = UIFont.systemFont(ofSize: 16, weight: .black)
            let nvSize = netValStr.size(withAttributes: [.font: netValFont])
            netValStr.draw(at: CGPoint(x: pageWidth - margin - nvSize.width - 14, y: currentY + 12), withAttributes: [.font: netValFont, .foregroundColor: UIColor.white])
            
            currentY += 75
            
            // Authorized Signatory
            let signX = pageWidth - margin - 160
            let signLine = UIBezierPath()
            signLine.move(to: CGPoint(x: signX, y: currentY))
            signLine.addLine(to: CGPoint(x: signX + 160, y: currentY))
            UIColor.black.setStroke()
            signLine.lineWidth = 1
            signLine.stroke()
            
            let signNote = "Authorized Signatory\n\(business.founderName) [ \(business.ownerBadge) ]\nGAUREX Technologies"
            signNote.draw(in: CGRect(x: signX, y: currentY + 6, width: 160, height: 45), withAttributes: [.font: UIFont.systemFont(ofSize: 9, weight: .regular), .foregroundColor: UIColor.black])
        }
    }
}
