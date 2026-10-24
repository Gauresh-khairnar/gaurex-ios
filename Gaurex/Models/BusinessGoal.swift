//
//  BusinessGoal.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import Foundation

public enum GoalMetricType: String, Codable, CaseIterable, Identifiable {
    case monthlyRevenue = "Monthly Revenue Target"
    case annualRevenue = "Annual Revenue Target"
    case newClients = "New Client Acquisitions"
    case dealsClosed = "Closed Won Deals"
    case cashCollections = "Cash Collection Target"
    case expenseBudget = "Monthly Expense Budget"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .monthlyRevenue, .annualRevenue: return "chart.line.uptrend.xyaxis"
        case .newClients: return "person.badge.plus"
        case .dealsClosed: return "handshake.fill"
        case .cashCollections: return "banknote.fill"
        case .expenseBudget: return "creditcard.fill"
        }
    }
}

public struct BusinessGoal: Identifiable, Codable, Hashable {
    public var id: String
    public var title: String
    public var metricType: GoalMetricType
    public var targetValue: Double
    public var currentValue: Double
    public var currency: String
    public var deadline: Date
    public var blockers: [String]
    public var recommendedActions: [String]
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        metricType: GoalMetricType,
        targetValue: Double,
        currentValue: Double = 0.0,
        currency: String = "INR",
        deadline: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
        blockers: [String] = [],
        recommendedActions: [String] = []
    ) {
        self.id = id
        self.title = title
        self.metricType = metricType
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.currency = currency
        self.deadline = deadline
        self.blockers = blockers
        self.recommendedActions = recommendedActions
    }
    
    public var progressFraction: Double {
        guard targetValue > 0 else { return 0.0 }
        return min(1.0, max(0.0, currentValue / targetValue))
    }
    
    public var percentageString: String {
        String(format: "%.1f%%", progressFraction * 100.0)
    }
    
    public var remainingValue: Double {
        max(0.0, targetValue - currentValue)
    }
}
