//
//  ExtendedBusinessModels.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import Foundation

// MARK: - Smart Reminders
public enum ReminderCategory: String, Codable, CaseIterable, Identifiable {
    case clientFollowUp = "Client Follow-up"
    case invoiceDueDate = "Invoice Due Date"
    case overduePayment = "Overdue Payment Alert"
    case projectDeadline = "Project Milestone Deadline"
    case taskDueDate = "Task Due Date"
    case leaveApproval = "Employee Leave Review"
    case salaryPayment = "Payroll Disbursement Date"
    case recurringExpense = "Recurring Server / SaaS Expense"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .clientFollowUp: return "phone.badge.plus"
        case .invoiceDueDate: return "calendar.badge.clock"
        case .overduePayment: return "exclamationmark.triangle.fill"
        case .projectDeadline: return "flag.checkered"
        case .taskDueDate: return "checkmark.circle"
        case .leaveApproval: return "person.badge.shield.checkmark"
        case .salaryPayment: return "banknote.fill"
        case .recurringExpense: return "arrow.triangle.2.circlepath"
        }
    }
}

public struct SmartReminder: Identifiable, Codable, Hashable {
    public var id: String
    public var title: String
    public var message: String
    public var category: ReminderCategory
    public var triggerDate: Date
    public var isCompleted: Bool
    public var isSnoozed: Bool
    public var priority: TaskPriority
    public var relatedEntityId: String?
    public var createdAt: Date
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        message: String,
        category: ReminderCategory,
        triggerDate: Date,
        isCompleted: Bool = false,
        isSnoozed: Bool = false,
        priority: TaskPriority = .medium,
        relatedEntityId: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.category = category
        self.triggerDate = triggerDate
        self.isCompleted = isCompleted
        self.isSnoozed = isSnoozed
        self.priority = priority
        self.relatedEntityId = relatedEntityId
        self.createdAt = createdAt
    }
}

// MARK: - Multi-Currency Architecture
public enum SupportedCurrency: String, Codable, CaseIterable, Identifiable {
    case inr = "INR"
    case usd = "USD"
    case aed = "AED"
    case gbp = "GBP"
    case eur = "EUR"
    
    public var id: String { rawValue }
    
    public var symbol: String {
        switch self {
        case .inr: return "₹"
        case .usd: return "$"
        case .aed: return "AED "
        case .gbp: return "£"
        case .eur: return "€"
        }
    }
    
    public var displayName: String {
        switch self {
        case .inr: return "Indian Rupee (INR)"
        case .usd: return "US Dollar (USD)"
        case .aed: return "UAE Dirham (AED)"
        case .gbp: return "British Pound (GBP)"
        case .eur: return "Euro (EUR)"
        }
    }
}

public struct ExchangeRateEntry: Codable, Hashable {
    public var fromCurrency: SupportedCurrency
    public var toCurrency: SupportedCurrency
    public var rate: Double
    public var effectiveDate: Date
    public var isManuallyEntered: Bool
    
    public init(
        fromCurrency: SupportedCurrency,
        toCurrency: SupportedCurrency,
        rate: Double,
        effectiveDate: Date = Date(),
        isManuallyEntered: Bool = false
    ) {
        self.fromCurrency = fromCurrency
        self.toCurrency = toCurrency
        self.rate = rate
        self.effectiveDate = effectiveDate
        self.isManuallyEntered = isManuallyEntered
    }
}

// MARK: - Integrations Hub
public enum IntegrationProvider: String, Codable, CaseIterable, Identifiable {
    case gmail = "Google Workspace & Gmail"
    case googleCalendar = "Google Calendar"
    case outlook = "Microsoft Outlook"
    case stripe = "Stripe Payments"
    case razorpay = "Razorpay Corporate"
    case cloudStorage = "AWS S3 / Google Cloud Storage"
    case gemini = "Google Gemini AI"
    case openai = "OpenAI Enterprise"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .gmail, .outlook: return "envelope.fill"
        case .googleCalendar: return "calendar"
        case .stripe, .razorpay: return "creditcard.fill"
        case .cloudStorage: return "icloud.fill"
        case .gemini, .openai: return "sparkles"
        }
    }
}

public struct IntegrationItem: Identifiable, Codable, Hashable {
    public var id: String
    public var provider: IntegrationProvider
    public var isConnected: Bool
    public var connectedAccountEmail: String?
    public var lastSyncTime: Date?
    public var statusDescription: String
    
    public init(
        id: String = UUID().uuidString,
        provider: IntegrationProvider,
        isConnected: Bool = false,
        connectedAccountEmail: String? = nil,
        lastSyncTime: Date? = nil,
        statusDescription: String = "Ready to connect"
    ) {
        self.id = id
        self.provider = provider
        self.isConnected = isConnected
        self.connectedAccountEmail = connectedAccountEmail
        self.lastSyncTime = lastSyncTime
        self.statusDescription = statusDescription
    }
}
