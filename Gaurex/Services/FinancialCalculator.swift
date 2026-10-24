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

public struct HealthScoreBreakdown {
    public let overallScore: Int // 0 to 100
    public let revenueScore: Int  // max 30
    public let overduePenalty: Int // 0 to -20
    public let pipelineScore: Int // max 20
    public let expenseControlScore: Int // max 15
    public let executionScore: Int // max 15
    public let explanations: [String]
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
        let subtotal = items.reduce(0.0) { sum, item in
            sum + (Double(item.quantity) * item.unitPrice)
        }
        
        let calculatedDiscount: Double
        if isPercentageDiscount {
            let percentage = max(0.0, min(100.0, discountValue))
            calculatedDiscount = subtotal * (percentage / 100.0)
        } else {
            calculatedDiscount = max(0.0, min(subtotal, discountValue))
        }
        
        let taxableAmount = max(0.0, subtotal - calculatedDiscount)
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
    
    /// Calculates worker payroll
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
    
    /// Weighted pipeline value = sum of (deal value * closing probability)
    public func calculateWeightedPipelineValue(leads: [SalesLead]) -> Double {
        leads
            .filter { $0.stage != .lost && $0.stage != .won }
            .reduce(0.0) { $0 + ($1.expectedDealValue * $1.closingProbability) }
    }
    
    /// Multi-currency converter
    public func convert(amount: Double, from: SupportedCurrency, to: SupportedCurrency) -> Double {
        if from == to { return amount }
        
        // Base conversion against INR
        let ratesToINR: [SupportedCurrency: Double] = [
            .inr: 1.0,
            .usd: 83.50,
            .aed: 22.73,
            .gbp: 106.20,
            .eur: 90.80
        ]
        
        let inrValue = amount * (ratesToINR[from] ?? 1.0)
        let targetRate = ratesToINR[to] ?? 1.0
        return inrValue / targetRate
    }
    
    /// Transparent Business Health Score (0 to 100)
    public func calculateBusinessHealthScore(
        revenueCollected: Double,
        monthlyTarget: Double,
        overdueCount: Int,
        pipelineValue: Double,
        monthlyExpenses: Double,
        taskCompletionRate: Double
    ) -> HealthScoreBreakdown {
        var explanations: [String] = []
        
        // 1. Revenue progress (30 max)
        let revFraction = monthlyTarget > 0 ? min(1.0, revenueCollected / monthlyTarget) : (revenueCollected > 0 ? 1.0 : 0.5)
        let revScore = Int(revFraction * 30.0)
        explanations.append("Revenue vs Target: \(revScore)/30 pts (\(String(format: "%.1f%%", revFraction * 100)))")
        
        // 2. Overdue penalty (0 to -20)
        let overduePenalty = min(20, overdueCount * 7)
        if overduePenalty > 0 {
            explanations.append("Overdue accounts penalty: -\(overduePenalty) pts (\(overdueCount) overdue)")
        } else {
            explanations.append("Zero overdue receivables: Clean score")
        }
        
        // 3. Pipeline coverage (20 max)
        let pipeScore = pipelineValue > 100000.0 ? 20 : (pipelineValue > 0 ? 12 : 5)
        explanations.append("Sales pipeline coverage: \(pipeScore)/20 pts")
        
        // 4. Expense control (15 max)
        let expScore = monthlyExpenses < revenueCollected ? 15 : 8
        explanations.append("Expense ratio: \(expScore)/15 pts")
        
        // 5. Execution & task completion (15 max)
        let execScore = Int(min(1.0, max(0.0, taskCompletionRate)) * 15.0)
        explanations.append("Task & milestone throughput: \(execScore)/15 pts")
        
        let total = max(0, min(100, revScore - overduePenalty + pipeScore + expScore + execScore))
        
        return HealthScoreBreakdown(
            overallScore: total,
            revenueScore: revScore,
            overduePenalty: overduePenalty,
            pipelineScore: pipeScore,
            expenseControlScore: expScore,
            executionScore: execScore,
            explanations: explanations
        )
    }
    
    public func formatCurrency(_ amount: Double, symbol: String = "₹") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = symbol
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "\(symbol)\(String(format: "%.2f", amount))"
    }
}
