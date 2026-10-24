//
//  FinancialCalculator.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import Foundation

public struct FinancialCalculationResult {
    public let subtotal: Double
    public let discountAmount: Double
    public let taxableAmount: Double
    public let taxAmount: Double
    public let finalTotal: Double
    public let balanceDue: Double
}

public struct SalaryCalculationResult {
    public let grossEarnings: Double
    public let unpaidLeaveDeduction: Double
    public let totalDeductions: Double
    public let netSalaryPayable: Double
}

public final class FinancialCalculator {
    public static let shared = FinancialCalculator()
    
    private init() {}
    
    /// Calculates invoice amounts according to GAUREX business rules.
    public func calculateInvoice(
        items: [InvoiceItem],
        isPercentageDiscount: Bool,
        discountValue: Double,
        isTaxable: Bool,
        taxRate: Double,
        paymentsRecorded: Double
    ) -> FinancialCalculationResult {
        // Subtotal = sum of (quantity * unitPrice) for each line item
        let subtotal = items.reduce(0.0) { sum, item in
            sum + (Double(item.quantity) * item.unitPrice)
        }
        
        // Discount calculation
        let calculatedDiscount: Double
        if isPercentageDiscount {
            let percentage = max(0.0, min(100.0, discountValue))
            calculatedDiscount = subtotal * (percentage / 100.0)
        } else {
            calculatedDiscount = max(0.0, min(subtotal, discountValue))
        }
        
        let taxableAmount = max(0.0, subtotal - calculatedDiscount)
        
        // Tax calculation (e.g. GST)
        let taxAmount = isTaxable ? (taxableAmount * (max(0.0, taxRate) / 100.0)) : 0.0
        
        let finalTotal = taxableAmount + taxAmount
        let balanceDue = max(0.0, finalTotal - max(0.0, paymentsRecorded))
        
        return FinancialCalculationResult(
            subtotal: subtotal,
            discountAmount: calculatedDiscount,
            taxableAmount: taxableAmount,
            taxAmount: taxAmount,
            finalTotal: finalTotal,
            balanceDue: balanceDue
        )
    }
    
    /// Calculates worker payroll according to GAUREX standard compensation guidelines.
    public func calculatePayroll(
        basicSalary: Double,
        houseRentAllowance: Double,
        specialAllowance: Double,
        performanceBonus: Double,
        daysInMonth: Int,
        unpaidLeaveDays: Int,
        taxDeduction: Double,
        otherDeductions: Double
    ) -> SalaryCalculationResult {
        let gross = max(0.0, basicSalary + houseRentAllowance + specialAllowance + performanceBonus)
        
        let perDayRate = (daysInMonth > 0 && basicSalary > 0) ? (basicSalary / Double(daysInMonth)) : 0.0
        let unpaidLeaveDeduction = perDayRate * Double(max(0, unpaidLeaveDays))
        
        let totalDeductions = max(0.0, unpaidLeaveDeduction + taxDeduction + otherDeductions)
        let netSalaryPayable = max(0.0, gross - totalDeductions)
        
        return SalaryCalculationResult(
            grossEarnings: gross,
            unpaidLeaveDeduction: unpaidLeaveDeduction,
            totalDeductions: totalDeductions,
            netSalaryPayable: netSalaryPayable
        )
    }
    
    /// Net Operating Income = Revenue Collected − Total Monthly Expenses − Disbursed Payroll Expenses
    public func calculateNetOperatingIncome(
        revenueCollected: Double,
        monthlyExpenses: Double,
        payrollExpenses: Double
    ) -> Double {
        return revenueCollected - (monthlyExpenses + payrollExpenses)
    }
    
    /// Formats currency with GAUREX default symbol (₹ INR)
    public func formatCurrency(_ amount: Double, symbol: String = "₹") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = symbol
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "\(symbol)\(String(format: "%.2f", amount))"
    }
}
