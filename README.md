# GAUREX — iOS Business Dashboard
### Executive Technology Business Management Suite
**Founder and Owner:** Gauresh Khairnar (`OWNER`)  
**Platform:** iOS 17.0+ (iPhone)  
**Primary UI Framework:** SwiftUI with Apple Liquid Glass Design System  
**Bundle Identifier:** `com.gaurex.dashboard`  

---

## 1. Executive Summary

**GAUREX Dashboard** is a native, production-grade iPhone application engineered specifically for founder **Gauresh Khairnar** to manage all operations, clients, service packages, invoicing, team payroll, financial metrics, and AI business intelligence from a single interface.

### Brand Identity & Iconography
- **Official App Icon:** Generated from the official GAUREX monochrome monogram (`Assets.xcassets/AppIcon.appiconset`).
- **Owner Badge:** Signature `OWNER` executive badge displayed across navigation bars and generated documents.
- **Visual Aesthetic:** Refined Apple Liquid Glass styling, `.ultraThinMaterial` dynamic translucency, 1px hairline glass borders, restrained shadows, and haptic feedback.
- **Theme Engine:** 8 persistent themes including *System, Pure Light, Studio Dark, Midnight Black, Pure White, Graphite Slate, Ocean Blue,* and *GAUREX Executive*.

---

## 2. Core Architecture & Modules

```
Gaurex/
├── App/
│   └── GaurexApp.swift                       # Root @main SwiftUI lifecycle with Biometric Lock
├── DesignSystem/
│   ├── Theme/ThemeManager.swift              # 8-Theme dynamic color & material switcher
│   └── Components/
│       ├── LiquidGlassTabBar.swift           # Floating bottom capsule tab bar with spring pill
│       ├── DesignComponents.swift            # GlassCard, MetricCard, OwnerBadge, StatusBadge
├── Models/
│   ├── Client.swift                          # Client CRM entity with contact actions & ledger
│   ├── Package.swift                         # Commercial service packages & retainer catalog
│   ├── Invoice.swift                         # Itemized invoices with GST/tax & payment status
│   ├── Payment.swift                         # Immutable payment records & ledger audit
│   ├── Worker.swift                          # HR employee profile with protected bank details
│   ├── PayrollRecord.swift                   # Explicit salary calculations & deductions
│   ├── BusinessSettings.swift                # GSTIN, PAN, bank wiring, invoice numbering
│   └── BusinessEntities.swift                # Expenses, Projects, ActivityLogs, AIMessages
├── Services/
│   ├── FinancialCalculator.swift             # Subtotals, discounts, taxes, payroll, net income
│   ├── PDFGeneratorService.swift             # Vector PDFKit Invoice & Salary Slip generator
│   ├── SecurityServices.swift                # Face ID / Touch ID & Keychain Vault
│   ├── AuditAndBackupServices.swift          # Immutable event logger & full JSON export/restore
│   ├── AIService.swift                       # GAUREX Business Intelligence query engine
│   └── FirestoreDataStore.swift              # Reactive central state repository & offline cache
├── Views/
│   ├── MainTabView.swift                     # 5-tab coordinator with floating Liquid Glass bar
│   ├── Dashboard/DashboardView.swift         # Home Tab: Real-time KPIs, Swift Charts, Alerts
│   ├── Clients/ClientsListView.swift         # Clients Tab: CRM list, search, filters & details
│   ├── Invoices/InvoicesListView.swift       # Invoicing: Multi-item invoice builder & PDF preview
│   ├── Workers/WorkersListView.swift         # Workers Tab: Team directory & payslip generator
│   ├── AIModel/AIIntelligenceView.swift      # AI Tab: Natural language copilot for ledger data
│   └── Settings/SettingsView.swift           # Settings Tab: Owner Control Center & themes
└── GaurexTests/                              # Unit, integration & PDF rendering test suites
```

---

## 3. Five Primary Application Tabs

### 1. Home — Business Analytics Dashboard
- **Real-Time KPI Cards:** Calculated strictly from authentic records: Total Clients, Active Clients, Invoiced Revenue, Collected Revenue, Outstanding Balance, Overdue Invoices, Operating Expenses, Disbursed Payroll, and Net Operating Income.
- **Swift Charts Integration:** Multi-bar financial trajectory charts (Revenue vs Expenses vs Profit) and settlement status donut charts.
- **Quick Action Bar:** One-tap shortcuts to Add Client, Issue Invoice, Add Worker, Add Package, or Ask AI.
- **Date Filter Pills:** 7 Days, 30 Days, 90 Days, This Month, and This Year.

### 2. Clients — CRM & Multi-Package Management
- **Client Records:** Complete profiles with contact details, business category, website, lead source, assigned worker, and notes.
- **One-Tap Actions:** Direct phone calls (`tel:`), emails (`mailto:`), and WhatsApp conversations (`wa.me`).
- **Commercial Calculations:** Supports multiple packages per client, percentage or fixed discounts, GST/tax treatment, advance payments, and live balance due calculation.

### 3. Workers — Employee Directory & Payroll Management
- **HR Profiles:** Job title, department, date of joining, salary, and annual leave quota tracking.
- **Protected Bank Details:** Masked account numbers with toggle to reveal, preserving employee privacy.
- **Executive Salary Slip Generator:** Configurable payroll breakdown with basic salary, HRA, special allowances, bonus, tax/TDS, and automatic deduction for unpaid leave days.
- **PDF Export:** Vector PDF generation via PDFKit with authorized signature and iOS Share Sheet integration.

### 4. AI Model — GAUREX Business Intelligence
- **Ledger-Aware Assistant:** Queries live business data to answer inquiries on revenue collected, overdue invoices, client balances, and performance summaries.
- **Strict Distinction:** Distinguishes between verified database facts, estimates/forecasts, and strategic recommendations.
- **Zero API Key Leakage:** Provider API keys are stored in the iOS Hardware Keychain and proxied through authenticated Cloud Functions.

### 5. Settings — Owner Control Center
- **Executive Profile:** Gauresh Khairnar profile card with prominent `OWNER` badge.
- **Theme Studio:** Real-time theme switcher with 8 themes and persistent preference storage.
- **Package Management:** Catalog CRUD for enterprise software, mobile apps, AI automation, and retainers.
- **Biometric Lock:** Optional Face ID / Touch ID gate on app launch with manual lock button.
- **Audit Trail Ledger:** Tamper-evident log of all financial and administrative operations.
- **Full Backup:** Export complete business ledger as a clean, standardized JSON file.

---

## 4. Build, Signing & IPA Installation

Refer to [DEPLOYMENT.md](file:///e:/Gaurex/ios/DEPLOYMENT.md) for full instructions:
- **Cloud Build (GitHub Actions):** `.github/workflows/build-ipa.yml` builds on `macos-14`, signs, and outputs `GAUREX.ipa` as a downloadable artifact.
- **Local Build:** Use `scripts/build_ipa.sh` on macOS Xcode command line tools.
- **Installation:** Compatible with AltStore, TrollStore, Sideloadly, TestFlight, or Xcode Devices.
