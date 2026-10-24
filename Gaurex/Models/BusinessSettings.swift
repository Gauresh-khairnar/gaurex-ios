//
//  BusinessSettings.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import Foundation

public struct BusinessSettings: Codable, Hashable {
    public var companyName: String
    public var tagline: String
    public var founderName: String
    public var ownerBadge: String
    public var officialEmail: String
    public var officialPhone: String
    public var registeredAddress: String
    public var websiteUrl: String
    public var currencySymbol: String
    public var currencyCode: String
    public var gstNumber: String
    public var panNumber: String
    public var invoicePrefix: String
    public var nextInvoiceNumber: Int
    public var bankName: String
    public var bankAccountNumber: String
    public var bankIfsc: String
    public var bankBranch: String
    public var upiId: String
    public var defaultPaymentTerms: String
    public var defaultInvoiceNotes: String
    public var biometricUnlockEnabled: Bool
    public var autoLockTimeoutMinutes: Int
    public var aiProvider: String // "groq", "gemini", "openai", "anthropic"
    public var aiModelName: String
    public var activeThemeRaw: String
    
    public init(
        companyName: String = "GAUREX",
        tagline: String = "Next-Generation Technology & Enterprise Engineering",
        founderName: String = "Gauresh Khairnar",
        ownerBadge: String = "OWNER",
        officialEmail: String = "gauresh@gaurex.com",
        officialPhone: String = "+91 98765 43210",
        registeredAddress: String = "GAUREX Headquarters, Tech Park, Mumbai, India",
        websiteUrl: String = "https://gaurex.com",
        currencySymbol: String = "₹",
        currencyCode: String = "INR",
        gstNumber: String = "27AAAAA0000A1Z5",
        panNumber: String = "ABCDE1234F",
        invoicePrefix: String = "GX-INV-",
        nextInvoiceNumber: Int = 1001,
        bankName: String = "HDFC Bank Ltd.",
        bankAccountNumber: String = "50200012345678",
        bankIfsc: String = "HDFC0000123",
        bankBranch: String = "Corporate Financial Hub",
        upiId: String = "gaurex@hdfcbank",
        defaultPaymentTerms: String = "Payment strictly due within 15 days of invoice date.",
        defaultInvoiceNotes: String = "Thank you for choosing GAUREX. All software intellectual property is transferred upon final payment settlement.",
        biometricUnlockEnabled: Bool = true,
        autoLockTimeoutMinutes: Int = 5,
        aiProvider: String = "groq",
        aiModelName: String = "openai/gpt-oss-120b",
        activeThemeRaw: String = "system"
    ) {
        self.companyName = companyName
        self.tagline = tagline
        self.founderName = founderName
        self.ownerBadge = ownerBadge
        self.officialEmail = officialEmail
        self.officialPhone = officialPhone
        self.registeredAddress = registeredAddress
        self.websiteUrl = websiteUrl
        self.currencySymbol = currencySymbol
        self.currencyCode = currencyCode
        self.gstNumber = gstNumber
        self.panNumber = panNumber
        self.invoicePrefix = invoicePrefix
        self.nextInvoiceNumber = nextInvoiceNumber
        self.bankName = bankName
        self.bankAccountNumber = bankAccountNumber
        self.bankIfsc = bankIfsc
        self.bankBranch = bankBranch
        self.upiId = upiId
        self.defaultPaymentTerms = defaultPaymentTerms
        self.defaultInvoiceNotes = defaultInvoiceNotes
        self.biometricUnlockEnabled = biometricUnlockEnabled
        self.autoLockTimeoutMinutes = autoLockTimeoutMinutes
        self.aiProvider = aiProvider
        self.aiModelName = aiModelName
        self.activeThemeRaw = activeThemeRaw
    }
}
