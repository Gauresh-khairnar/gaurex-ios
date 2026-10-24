//
//  AIIntelligenceView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct AIIntelligenceView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @ObservedObject private var aiService = AIService.shared
    
    @State private var inputText: String = ""
    @State private var showingSettingsSheet = false
    
    let suggestedPrompts = [
        "What is our collected revenue this month?",
        "Which invoices are overdue?",
        "Summarize this month's business performance.",
        "Which clients have the highest outstanding balances?",
        "What revenue target should we pursue next month?",
        "Which packages generate the most revenue?"
    ]
    
    public init() {}
    
    private var currentContext: AIAnalysisContext {
        let topOverdue = store.clients
            .filter { $0.outstandingBalance > 0 }
            .sorted { $0.outstandingBalance > $1.outstandingBalance }
            .map { (name: $0.name, balance: $0.outstandingBalance) }
        
        let pkgBreakdown = store.packages.map { pkg in
            let rev = store.invoices
                .filter { $0.status == .paid }
                .flatMap { $0.items }
                .filter { $0.packageId == pkg.id }
                .reduce(0.0) { $0 + $1.total }
            return (packageName: pkg.name, revenue: rev)
        }
        
        return AIAnalysisContext(
            totalClients: store.clients.count,
            activeClients: store.activeClientsCount,
            totalInvoiced: store.totalInvoicedRevenue,
            revenueCollected: store.revenueCollected,
            outstandingPayments: store.outstandingPayments,
            overdueInvoicesCount: store.overdueInvoicesCount,
            totalWorkers: store.totalWorkersCount,
            monthlyPayrollExpenses: store.totalMonthlyPayrollExpenses,
            monthlyOperatingExpenses: store.totalMonthlyExpenses,
            netOperatingIncome: store.netOperatingIncome,
            activeProjectsCount: store.activeProjectsCount,
            currencySymbol: store.settings.currencySymbol,
            topOverdueClients: topOverdue,
            packageRevenueBreakdown: pkgBreakdown
        )
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Executive AI Disclaimer
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(theme.accentColor)
                            .font(.system(size: 13))
                        Text("Connected to GAUREX Intelligence Engine. Contextualized to real financial ledger.")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(theme.cardBackground.opacity(0.6))
                    
                    // Messages Chat Area
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 14) {
                                // Welcome Intro Card
                                GlassCard {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: "brain.head.profile")
                                                .font(.system(size: 18))
                                                .foregroundColor(theme.accentColor)
                                            Text("GAUREX Executive Copilot")
                                                .font(.system(size: 15, weight: .bold))
                                            Spacer()
                                            OwnerBadge()
                                        }
                                        Text("Ask natural language queries regarding collected revenue, overdue balances, client pipeline, payroll disbursements, and operational forecasts.")
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                                
                                // Suggested Quick Questions
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("QUICK EXECUTIVE INQUIRIES")
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 16)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(suggestedPrompts, id: \.self) { prompt in
                                                Button {
                                                    sendMessage(text: prompt)
                                                } label: {
                                                    Text(prompt)
                                                        .font(.system(size: 12, weight: .medium))
                                                        .foregroundColor(.primary)
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 7)
                                                        .background(theme.cardBackground)
                                                        .clipShape(Capsule())
                                                        .overlay(Capsule().stroke(theme.glassBorderColor, lineWidth: 1))
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                }
                                
                                // Conversation Messages
                                ForEach(store.aiMessages) { msg in
                                    AIMessageBubble(message: msg)
                                        .id(msg.id)
                                }
                                
                                if aiService.isAnalyzing {
                                    HStack(spacing: 8) {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                        Text("Analyzing real-time financial records...")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .id("ANALYSIS_LOADING")
                                }
                                
                                Spacer().frame(height: 100)
                            }
                            .padding(.vertical, 8)
                        }
                        .onChange(of: store.aiMessages.count) { _ in
                            if let lastId = store.aiMessages.last?.id {
                                withAnimation {
                                    proxy.scrollTo(lastId, anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    // Input Bar
                    VStack(spacing: 0) {
                        Divider().background(theme.glassBorderColor)
                        HStack(spacing: 10) {
                            TextField("Ask business intelligence assistant...", text: $inputText)
                                .textFieldStyle(.plain)
                                .font(.system(size: 14))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(theme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(theme.glassBorderColor, lineWidth: 1))
                            
                            Button {
                                sendMessage(text: inputText)
                            } label: {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : theme.accentColor)
                            }
                            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || aiService.isAnalyzing)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                    }
                }
            }
            .navigationTitle("AI Intelligence")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettingsSheet = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingSettingsSheet) {
                AISettingsSheet()
            }
        }
    }
    
    private func sendMessage(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let userMsg = AIMessage(sender: "user", content: trimmed)
        store.aiMessages.append(userMsg)
        inputText = ""
        
        aiService.askBusinessAssistant(question: trimmed, context: currentContext) { response in
            store.aiMessages.append(response)
            store.saveAIMessages()
        }
    }
}

public struct AIMessageBubble: View {
    @ObservedObject private var theme = ThemeManager.shared
    public var message: AIMessage
    
    public var body: some View {
        HStack {
            if message.sender == "user" {
                Spacer()
                Text(message.content)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.leading, 40)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                            .foregroundColor(theme.accentColor)
                        Text("GAUREX INTELLIGENCE")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.secondary)
                        if message.isForecastEstimate {
                            Text("• ESTIMATE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text(LocalizedStringKey(message.content))
                        .font(.system(size: 13.5))
                        .foregroundColor(.primary)
                        .lineSpacing(3)
                    
                    if let rec = message.actionRecommendation {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("EXECUTIVE RECOMMENDATION")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(theme.accentColor)
                            Text(rec)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(theme.backgroundColor.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(theme.glassBorderColor, lineWidth: 1))
                    }
                }
                .padding(14)
                .background(theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(theme.glassBorderColor, lineWidth: 1))
                .padding(.trailing, 40)
                Spacer()
            }
        }
        .padding(.horizontal, 16)
    }
}

public struct AISettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = FirestoreDataStore.shared
    
    @State private var provider: String = "gemini"
    @State private var modelName: String = "gemini-1.5-pro"
    @State private var apiKeyInput: String = ""
    @State private var testStatus: String? = nil
    @State private var isTesting = false
    
    let providers = [
        ("gemini", "Google Gemini (Gemini 1.5 Pro)"),
        ("openai", "OpenAI (GPT-4o)"),
        ("anthropic", "Anthropic (Claude 3.5 Sonnet)"),
        ("custom", "GAUREX Private Backend")
    ]
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Model Provider Configuration")) {
                    Picker("Provider", selection: $provider) {
                        ForEach(providers, id: \.0) { p in
                            Text(p.1).tag(p.0)
                        }
                    }
                    
                    TextField("Model ID (e.g. gemini-1.5-pro)", text: $modelName)
                }
                
                Section(header: Text("Encrypted API Key (Keychain Vault)")) {
                    SecureField("Paste Secret API Key", text: $apiKeyInput)
                        .textInputAutocapitalization(.never)
                    
                    Text("API keys are never stored in plaintext or logged. Keys are isolated in the iOS Hardware Keychain.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button {
                        testConnection()
                    } label: {
                        HStack {
                            Text("Test Provider Connectivity")
                            if isTesting {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    
                    if let status = testStatus {
                        Text(status)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("AI Model Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSettings()
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                provider = store.settings.aiProvider
                modelName = store.settings.aiModelName
                apiKeyInput = KeychainService.shared.readSecret(key: "gaurex_ai_api_key") ?? ""
            }
        }
    }
    
    private func testConnection() {
        isTesting = true
        testStatus = "Validating TLS handshake and model credentials..."
        if !apiKeyInput.isEmpty {
            _ = KeychainService.shared.saveSecret(key: "gaurex_ai_api_key", value: apiKeyInput)
        }
        AIService.shared.testConnection(provider: provider, model: modelName) { success, msg in
            isTesting = false
            testStatus = msg
        }
    }
    
    private func saveSettings() {
        store.settings.aiProvider = provider
        store.settings.aiModelName = modelName
        store.saveSettings()
        if !apiKeyInput.isEmpty {
            _ = KeychainService.shared.saveSecret(key: "gaurex_ai_api_key", value: apiKeyInput)
        }
        dismiss()
    }
}
