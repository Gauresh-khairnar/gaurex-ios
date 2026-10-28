//
//  GaurexActivityAttributes.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  ActivityKit Attributes for Apple Dynamic Island & Lock Screen Live Activities
//

import Foundation
#if canImport(ActivityKit)
import ActivityKit
#endif

public struct GaurexActivityAttributes: #if canImport(ActivityKit) ActivityAttributes #else Codable, Hashable #endif {
    public struct ContentState: Codable, Hashable {
        public var mode: ActivityMode
        
        // Mode 1: Neo AI Voice & Speech Capsule
        public var neoSpeechSnippet: String
        public var isSpeaking: Bool
        public var isListening: Bool
        
        // Mode 2: Cash Inflow Radar
        public var invoiceNumber: String
        public var invoiceAmount: Double
        public var clientName: String
        public var invoiceStatus: String
        
        // Mode 3: Focus & Founder Velocity
        public var activeTaskTitle: String
        public var timeRemainingMinutes: Int
        public var tasksCompletedCount: Int
        public var totalTasksCount: Int
        
        // Mode 4: Revenue Runway
        public var monthlyTargetProgress: Double // 0.0 to 1.0
        public var monthlyTargetAmount: Double
        public var currentMonthCollected: Double
        
        // Mode 5: Security & Transaction Guard
        public var pendingActionTitle: String
        public var authorizationAmount: Double?
        public var isBiometricallyApproved: Bool
        
        public init(
            mode: ActivityMode = .neoVoice,
            neoSpeechSnippet: String = "Good day, Gauresh. GAUREX operations nominal.",
            isSpeaking: Bool = false,
            isListening: Bool = false,
            invoiceNumber: String = "#INV-1024",
            invoiceAmount: Double = 75000.0,
            clientName: String = "Enterprise Client",
            invoiceStatus: String = "Paid",
            activeTaskTitle: String = "Review Sales Pipeline & Contracts",
            timeRemainingMinutes: Int = 35,
            tasksCompletedCount: Int = 3,
            totalTasksCount: Int = 5,
            monthlyTargetProgress: Double = 0.78,
            monthlyTargetAmount: Double = 1250000.0,
            currentMonthCollected: Double = 975000.0,
            pendingActionTitle: String = "Authorize Worker Monthly Payroll",
            authorizationAmount: Double? = 185000.0,
            isBiometricallyApproved: Bool = false
        ) {
            self.mode = mode
            self.neoSpeechSnippet = neoSpeechSnippet
            self.isSpeaking = isSpeaking
            self.isListening = isListening
            self.invoiceNumber = invoiceNumber
            self.invoiceAmount = invoiceAmount
            self.clientName = clientName
            self.invoiceStatus = invoiceStatus
            self.activeTaskTitle = activeTaskTitle
            self.timeRemainingMinutes = timeRemainingMinutes
            self.tasksCompletedCount = tasksCompletedCount
            self.totalTasksCount = totalTasksCount
            self.monthlyTargetProgress = monthlyTargetProgress
            self.monthlyTargetAmount = monthlyTargetAmount
            self.currentMonthCollected = currentMonthCollected
            self.pendingActionTitle = pendingActionTitle
            self.authorizationAmount = authorizationAmount
            self.isBiometricallyApproved = isBiometricallyApproved
        }
    }
    
    public enum ActivityMode: String, Codable, Hashable, CaseIterable, Identifiable {
        case neoVoice = "neoVoice"
        case cashInflow = "cashInflow"
        case focusTimer = "focusTimer"
        case revenueRunway = "revenueRunway"
        case securityAuth = "securityAuth"
        
        public var id: String { rawValue }
        
        public var title: String {
            switch self {
            case .neoVoice: return "Neo AI"
            case .cashInflow: return "Cash Inflow"
            case .focusTimer: return "Velocity Focus"
            case .revenueRunway: return "Runway"
            case .securityAuth: return "Security"
            }
        }
        
        public var iconName: String {
            switch self {
            case .neoVoice: return "sparkles"
            case .cashInflow: return "indianrupeesign"
            case .focusTimer: return "bolt.fill"
            case .revenueRunway: return "chart.line.uptrend.xyaxis"
            case .securityAuth: return "lock.shield.fill"
            }
        }
    }
    
    public var founderTitle: String
    
    public init(founderTitle: String = "Gauresh Khairnar (OWNER)") {
        self.founderTitle = founderTitle
    }
}
