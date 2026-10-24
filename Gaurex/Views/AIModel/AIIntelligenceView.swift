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
    @State private var showingVoiceSheet = false
    @State private var showingDocumentExtraction = false
    @State private var showingClearHistoryAlert = false
    
    let allExecutivePrompts = [
        "🚗 Fortuner 4-Month Target Status",
        "🔥 What deals will get my Fortuner fastest?",
        "💰 Remaining run-rate needed per day for Fortuner",
        "How much money did we actually collect this month?",
        "Which invoices are overdue right now?",
        "Which deals need follow-up today?",
        "What should Gauresh prioritize today?",
        "Generate this week's business performance report."
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
                    // Header Assistant Mode Bar
                    HStack(spacing: 10) {
                        Button {
                            showingVoiceSheet = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "mic.fill")
                                Text("Voice Mode")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(theme.cardBackground)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(theme.glassBorderColor, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .tactilePress()
                        
                        Button {
                            showingDocumentExtraction = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.viewfinder.fill")
                                Text("Scan / Extract")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(theme.cardBackground)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(theme.glassBorderColor, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .tactilePress()
                        
                        Spacer()
                        
                        if !store.aiMessages.isEmpty {
                            Button {
                                showingClearHistoryAlert = true
                            } label: {
                                HStack(spacing: 3) {
                                    Image(systemName: "trash")
                                    Text("Clear History")
                                }
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.red.opacity(0.85))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red.opacity(0.08))
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Text("Ledger Grounded")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    
                    // Messages Chat Area
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 14) {
                                GlassCard {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: "brain.head.profile")
                                                .font(.system(size: 18))
                                                .foregroundColor(theme.accentColor)
                                            Text("GAUREX AI Business Advisor")
                                                .font(.system(size: 15, weight: .bold))
                                            Spacer()
                                            OwnerBadge()
                                        }
                                        Text("Ask natural language queries regarding collected revenue, recorded expenses, sales pipeline loss points, employee payroll, and daily priorities.")
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 6)
                                
                                // Fortuner 4-Month Target Sprint Tracker Card
                                GlassCard {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            HStack(spacing: 6) {
                                                Image(systemName: "car.fill")
                                                    .font(.system(size: 15))
                                                    .foregroundColor(.yellow)
                                                Text("4-MONTH TOYOTA FORTUNER TARGET")
                                                    .font(TypographyTokens.caption)
                                                    .foregroundColor(.yellow)
                                            }
                                            Spacer()
                                            OwnerBadge()
                                        }
                                        
                                        HStack(alignment: .firstTextBaseline) {
                                            Text("\(currentContext.currencySymbol)\(String(format: "%.0f", currentContext.revenueCollected))")
                                                .font(.system(size: 20, weight: .bold))
                                            Text("of \(currentContext.currencySymbol)50,00,000")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("\(String(format: "%.1f", currentContext.fortunerCompletionPercentage * 100))%")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.yellow)
                                        }
                                        
                                        ProgressView(value: currentContext.fortunerCompletionPercentage)
                                            .tint(.yellow)
                                        
                                        HStack {
                                            Text("Remaining: \(currentContext.currencySymbol)\(String(format: "%.0f", currentContext.fortunerRemainingAmount))")
                                                .font(.system(size: 11, weight: .semibold))
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("Required: \(currentContext.currencySymbol)\(String(format: "%.0f", currentContext.fortunerRequiredDailyRunRate))/day")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(theme.accentColor)
                                        }
                                        
                                        Button {
                                            sendMessage(text: "🚗 Fortuner 4-Month Target Status")
                                        } label: {
                                            HStack {
                                                Text("Generate Fortuner Tactical Sprint Plan")
                                                Spacer()
                                                Image(systemName: "arrow.right.circle.fill")
                                            }
                                            .font(.system(size: 11.5, weight: .bold))
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 7)
                                            .background(Color.yellow)
                                            .clipShape(Capsule())
                                        }
                                        .buttonStyle(.plain)
                                        .padding(.top, 2)
                                    }
                                }
                                .padding(.horizontal, 16)
                                
                                // Suggested Quick Questions
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("STRATEGIC INQUIRIES")
                                        .font(TypographyTokens.sectionHeader)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 16)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(allExecutivePrompts, id: \.self) { prompt in
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
                                                .tactilePress(scale: 0.95)
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
                                        Text("Querying authorized business records...")
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
                                withAnimation(MotionTokens.interactiveSpring) {
                                    proxy.scrollTo(lastId, anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    // Input Bar
                    VStack(spacing: 0) {
                        Divider().background(theme.glassBorderColor)
                        HStack(spacing: 10) {
                            TextField("Ask business advisor...", text: $inputText)
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
                        .padding(.top, 8)
                        .padding(.bottom, 68)
                        .background(.ultraThinMaterial)
                    }
                }
            }
            .navigationTitle("AI Advisor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if !store.aiMessages.isEmpty {
                        Button {
                            showingClearHistoryAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red.opacity(0.85))
                        }
                        .accessibilityLabel("Clear AI History")
                    }
                    
                    Button {
                        showingSettingsSheet = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .confirmationDialog(
                "Clear AI History",
                isPresented: $showingClearHistoryAlert,
                titleVisibility: .visible
            ) {
                Button("Clear All Messages", role: .destructive) {
                    withAnimation {
                        store.clearAIMessages()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete all past AI conversations and inquiry history?")
            }
            .sheet(isPresented: $showingSettingsSheet) {
                AISettingsSheet()
            }
            .sheet(isPresented: $showingVoiceSheet) {
                VoiceAssistantOverlay()
            }
            .sheet(isPresented: $showingDocumentExtraction) {
                DocumentExtractionView()
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
                        Text("GAUREX ADVISOR")
                            .font(TypographyTokens.code)
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
                                .font(TypographyTokens.code)
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
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }
}

public struct AISettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var theme: ThemeManager
    @State private var selectedModel: String = "openai/gpt-oss-120b"
    @State private var customApiKey: String = ""
    @State private var statusMessage: String = ""
    @State private var isTesting: Bool = false
    
    private let availableModels = [
        "openai/gpt-oss-120b",
        "llama-3.3-70b-versatile",
        "llama-3.1-8b-instant",
        "mixtral-8x7b-32768"
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Model Engine")) {
                    Picker("Active Model", selection: $selectedModel) {
                        ForEach(availableModels, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                }
                
                Section(header: Text("API Credentials"), footer: Text("Custom credentials override the built-in GAUREX enterprise AI key.")) {
                    SecureField("Custom Groq API Key (Optional)", text: $customApiKey)
                    
                    Button {
                        testConnection()
                    } label: {
                        HStack {
                            Text("Test Connectivity")
                            Spacer()
                            if isTesting {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isTesting)
                    
                    if !statusMessage.isEmpty {
                        Text(statusMessage)
                            .font(.system(size: 12))
                            .foregroundColor(statusMessage.contains("Success") ? .green : .red)
                    }
                }
                
                Section(header: Text("Executive Context")) {
                    HStack {
                        Text("Authorized User")
                        Spacer()
                        Text("Gauresh Khairnar (OWNER)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Engine")
                        Spacer()
                        Text("Groq Cloud Ultra-Low Latency")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("AI Intelligence Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if !customApiKey.isEmpty {
                            _ = KeychainService.shared.saveSecret(key: "gaurex_ai_api_key", value: customApiKey)
                        }
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let key = KeychainService.shared.readSecret(key: "gaurex_ai_api_key"), !key.isEmpty {
                    customApiKey = key
                }
            }
        }
    }
    
    private func testConnection() {
        isTesting = true
        statusMessage = ""
        AIService.shared.testConnection(provider: "groq", model: selectedModel) { success, msg in
            DispatchQueue.main.async {
                isTesting = false
                statusMessage = success ? "Success: Connected to Groq API" : "Error: \(msg)"
            }
        }
    }
}
