//
//  AIIntelligenceView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  NEO: Autonomous AI Co-Founder & Executive Intelligence Engine
//

import SwiftUI

public struct AIIntelligenceView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @ObservedObject private var aiService = AIService.shared
    @ObservedObject private var neoVoice = NeoCoFounderService.shared
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var inputText: String = ""
    @State private var showingSettingsSheet = false
    @State private var showingVoiceSheet = false
    @State private var showingDocumentExtraction = false
    @State private var showingClearHistoryAlert = false
    @State private var pulseAnimation = false
    @State private var copiedMessageId: String? = nil
    
    private let deepPlum = Color.gaurexDeepPlum
    private let warmGold = Color.gaurexWarmGold
    private let mistGray = Color.gaurexMistGray
    @ObservedObject private var voiceAI = MultilingualVoiceAIService.shared
    
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
                // Background
                (colorScheme == .dark ? Color(red: 0.07, green: 0.07, blue: 0.09) : Color(red: 0.96, green: 0.96, blue: 0.98))
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // MARK: - Minimalist Executive Top Bar
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 1) {
                            HStack(spacing: 0) {
                                Text("G")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? .white : deepPlum)
                                Text("A")
                                    .font(.system(size: 22, weight: .black))
                                    .foregroundColor(warmGold)
                                Text("UREX")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? .white : deepPlum)
                            }
                            .tracking(1.5)
                            
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color(red: 0.06, green: 0.72, blue: 0.44))
                                    .frame(width: 6, height: 6)
                                Text("NEO AI Co-Founder")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(Color(red: 0.06, green: 0.72, blue: 0.44))
                            }
                        }
                        
                        Spacer()
                        
                        // 100% Free On-Device Badge
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 10))
                                .foregroundColor(warmGold)
                            Text("Free On-Device AI")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .white : deepPlum)
                        }
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.20) : Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
                        )
                        .overlay(
                            Capsule().stroke(warmGold.opacity(0.3), lineWidth: 0.8)
                        )
                        
                        // Voice Button
                        Button {
                            MotionTokens.selection()
                            showingVoiceSheet = true
                        } label: {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : deepPlum)
                                .padding(9)
                                .background(
                                    Circle()
                                        .fill(colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.20) : Color.white)
                                        .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
                                )
                                .overlay(
                                    Circle().stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
                                )
                        }
                        .buttonStyle(.plain)
                        
                        // Menu Button
                        Menu {
                            Button {
                                showingSettingsSheet = true
                            } label: {
                                Label("Model & Key Settings", systemImage: "slider.horizontal.3")
                            }
                            
                            Button {
                                showingDocumentExtraction = true
                            } label: {
                                Label("Scan Document", systemImage: "doc.viewfinder")
                            }
                            
                            if !store.aiMessages.isEmpty {
                                Divider()
                                Button(role: .destructive) {
                                    showingClearHistoryAlert = true
                                } label: {
                                    Label("Clear Conversation", systemImage: "trash")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                                .padding(9)
                                .background(
                                    Circle()
                                        .fill(colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.20) : Color.white)
                                        .shadow(color: Color.black.opacity(0.04), radius: 4, y: 1)
                                )
                                .overlay(
                                    Circle().stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 6)
                    
                    // MARK: - Multilingual Language Quick Selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(VoiceAILanguage.allCases) { lang in
                                let isSelected = voiceAI.selectedLanguage == lang
                                Button {
                                    MotionTokens.selection()
                                    voiceAI.setLanguage(lang)
                                } label: {
                                    Text(lang.displayName)
                                        .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                        .foregroundColor(isSelected ? .white : Color(uiColor: .label))
                                        .padding(.horizontal, 11)
                                        .padding(.vertical, 5)
                                        .background(isSelected ? deepPlum : Color.white)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(isSelected ? warmGold.opacity(0.6) : Color.black.opacity(0.06), lineWidth: 0.9)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 6)
                    }
                    
                    // MARK: - Conversational Stream Area
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            if store.aiMessages.isEmpty {
                                // MARK: - Clean Ambient Welcome State (Uncluttered)
                                VStack(spacing: 24) {
                                    Spacer().frame(height: 20)
                                    
                                    // Animated NEO Breathing Core
                                    ZStack {
                                        // Outer pulsing halo
                                        Circle()
                                            .fill(
                                                RadialGradient(
                                                    colors: [
                                                        warmGold.opacity(0.20),
                                                        deepPlum.opacity(0.05),
                                                        Color.clear
                                                    ],
                                                    center: .center,
                                                    startRadius: 20,
                                                    endRadius: 75
                                                )
                                            )
                                            .frame(width: 150, height: 150)
                                            .scaleEffect(pulseAnimation ? 1.15 : 0.95)
                                            .animation(
                                                Animation.easeInOut(duration: 2.4).repeatForever(autoreverses: true),
                                                value: pulseAnimation
                                            )
                                        
                                        // Middle Ring
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        warmGold.opacity(0.6),
                                                        Color(red: 0.65, green: 0.35, blue: 0.85).opacity(0.4)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                            .frame(width: 88, height: 88)
                                            .rotationEffect(.degrees(pulseAnimation ? 360 : 0))
                                            .animation(
                                                Animation.linear(duration: 20).repeatForever(autoreverses: false),
                                                value: pulseAnimation
                                            )
                                        
                                        // Core Orb
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        deepPlum,
                                                        Color(red: 0.18, green: 0.05, blue: 0.16)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 70, height: 70)
                                            .overlay(
                                                Circle()
                                                    .stroke(warmGold.opacity(0.5), lineWidth: 1.5)
                                            )
                                            .shadow(color: deepPlum.opacity(0.3), radius: 10, y: 4)
                                        
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 26, weight: .semibold))
                                            .foregroundColor(warmGold)
                                    }
                                    .padding(.top, 10)
                                    
                                    // Welcome Text
                                    VStack(spacing: 6) {
                                        Text("Good Morning, Gauresh")
                                            .font(.system(size: 22, weight: .bold, design: .rounded))
                                            .foregroundColor(colorScheme == .dark ? .white : deepPlum)
                                        
                                        Text("I'm NEO, your executive AI co-founder.\nWhat would you like to analyze or execute across GAUREX?")
                                            .font(.system(size: 13, weight: .regular))
                                            .foregroundColor(Color(uiColor: .secondaryLabel))
                                            .multilineTextAlignment(.center)
                                            .lineSpacing(3)
                                            .padding(.horizontal, 24)
                                    }
                                    
                                    // Compact Business Pulse Capsule
                                    HStack(spacing: 12) {
                                        HStack(spacing: 4) {
                                            Text("Cash:")
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundColor(.secondary)
                                            Text("\(currentContext.currencySymbol)\(String(format: "%.0f", currentContext.revenueCollected))")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(Color(red: 0.06, green: 0.72, blue: 0.44))
                                        }
                                        
                                        Text("•").foregroundColor(.secondary)
                                        
                                        HStack(spacing: 4) {
                                            Text("Due:")
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundColor(.secondary)
                                            Text("\(currentContext.currencySymbol)\(String(format: "%.0f", currentContext.outstandingPayments))")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.orange)
                                        }
                                        
                                        Text("•").foregroundColor(.secondary)
                                        
                                        HStack(spacing: 4) {
                                            Text("Clients:")
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundColor(.secondary)
                                            Text("\(currentContext.totalClients)")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.19) : Color.white)
                                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.03), radius: 6, y: 2)
                                    )
                                    .overlay(
                                        Capsule().stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
                                    )
                                    
                                    // 4 Curated High-Impact Prompt Cards (2x2 Grid)
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("SUGGESTED EXECUTIVE ACTIONS")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 4)
                                        
                                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                                            QuickAIPromptTile(
                                                icon: "chart.line.uptrend.xyaxis",
                                                iconColor: Color(red: 0.06, green: 0.72, blue: 0.44),
                                                title: "Financial Briefing",
                                                subtitle: "Profit, revenue & runway"
                                            ) {
                                                sendMessage(text: "Generate this week's executive financial briefing with cash runway and net profit.")
                                            }
                                            
                                            QuickAIPromptTile(
                                                icon: "exclamationmark.circle.fill",
                                                iconColor: .orange,
                                                title: "Overdue Invoices",
                                                subtitle: "Collections & balances"
                                            ) {
                                                sendMessage(text: "Which client invoices are overdue right now and what is our collection strategy?")
                                            }
                                            
                                            QuickAIPromptTile(
                                                icon: "bolt.fill",
                                                iconColor: goldAccent,
                                                title: "Today's Priorities",
                                                subtitle: "Key actions & follow-ups"
                                            ) {
                                                sendMessage(text: "What are my top 3 highest leverage business priorities for today?")
                                            }
                                            
                                            QuickAIPromptTile(
                                                icon: "arrow.up.right.circle.fill",
                                                iconColor: deepPurple,
                                                title: "Growth Plan",
                                                subtitle: "Packages & margin review"
                                            ) {
                                                sendMessage(text: "Analyze our package offerings and recommend how to increase our gross operating margin.")
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.top, 4)
                                    
                                    Spacer().frame(height: 120)
                                }
                            } else {
                                // MARK: - Active Conversation Stream
                                VStack(spacing: 16) {
                                    ForEach(store.aiMessages) { msg in
                                        CleanAIMessageRow(
                                            message: msg,
                                            onSpeak: {
                                                neoVoice.speak(text: msg.content)
                                            },
                                            onCopy: {
                                                UIPasteboard.general.string = msg.content
                                                copiedMessageId = msg.id
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    copiedMessageId = nil
                                                }
                                            },
                                            isCopied: copiedMessageId == msg.id
                                        )
                                        .id(msg.id)
                                    }
                                    
                                    if aiService.isAnalyzing {
                                        HStack(spacing: 10) {
                                            ProgressView()
                                                .scaleEffect(0.85)
                                            Text("NEO is querying authorized ledger records...")
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(.secondary)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.19) : Color.white)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
                                        )
                                        .padding(.horizontal, 16)
                                        .id("ANALYSIS_LOADING")
                                    }
                                    
                                    Spacer().frame(height: 120)
                                }
                                .padding(.vertical, 12)
                            }
                        }
                        .onAppear {
                            pulseAnimation = true
                        }
                        .onChange(of: store.aiMessages.count) { _ in
                            if let lastId = store.aiMessages.last?.id {
                                withAnimation(MotionTokens.interactiveSpring) {
                                    proxy.scrollTo(lastId, anchor: .bottom)
                                }
                            }
                        }
                    }
                    
                    // MARK: - Floating Executive Input Capsule
                    VStack(spacing: 0) {
                        HStack(spacing: 10) {
                            // Quick Mic Button
                            Button {
                                MotionTokens.selection()
                                showingVoiceSheet = true
                            } label: {
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                    .frame(width: 38, height: 38)
                                    .background(
                                        Circle()
                                            .fill(colorScheme == .dark ? Color(red: 0.20, green: 0.20, blue: 0.26) : Color(uiColor: .systemGroupedBackground))
                                    )
                            }
                            .buttonStyle(.plain)
                            
                            // Text Input Field
                            TextField("Ask NEO anything about your business...", text: $inputText)
                                .font(.system(size: 14))
                                .submitLabel(.send)
                                .onSubmit {
                                    sendMessage(text: inputText)
                                }
                            
                            // Send Button
                            Button {
                                sendMessage(text: inputText)
                            } label: {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(
                                                inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                                    ? Color.secondary.opacity(0.4)
                                                    : deepPurple
                                            )
                                    )
                            }
                            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || aiService.isAnalyzing)
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.20) : Color.white)
                                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.06), radius: 10, y: 3)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.primary.opacity(0.08), lineWidth: 0.8)
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingVoiceSheet) {
                VoiceAssistantOverlay()
            }
            .sheet(isPresented: $showingSettingsSheet) {
                AISettingsSheet()
            }
            .sheet(isPresented: $showingDocumentExtraction) {
                DocumentExtractionView()
            }
            .alert("Clear Conversation?", isPresented: $showingClearHistoryAlert) {
                Button("Clear", role: .destructive) {
                    store.aiMessages.removeAll()
                    store.saveAIMessages()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete all messages in this consultation session?")
            }
        }
    }
    
    private func sendMessage(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let userMsg = AIMessage(sender: "user", content: trimmed)
        store.aiMessages.append(userMsg)
        inputText = ""
        
        MotionTokens.selection()
        
        aiService.askBusinessAssistant(question: trimmed, context: currentContext) { response in
            store.aiMessages.append(response)
            store.saveAIMessages()
        }
    }
}

// MARK: - Quick AI Prompt Tile Component
private struct QuickAIPromptTile: View {
    @Environment(\.colorScheme) private var colorScheme
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    private let deepPlum = Color.gaurexDeepPlum
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(iconColor)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : deepPlum)
                        .lineLimit(1)
                    
                    Text(subtitle)
                        .font(.system(size: 10.5, weight: .regular))
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                        .lineLimit(1)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.19) : Color.white)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.03), radius: 6, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Clean AI Message Row
private struct CleanAIMessageRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let message: AIMessage
    let onSpeak: () -> Void
    let onCopy: () -> Void
    let isCopied: Bool
    
    private let deepPlum = Color.gaurexDeepPlum
    private let warmGold = Color.gaurexWarmGold
    private let mistGray = Color.gaurexMistGray
    @ObservedObject private var voiceAI = MultilingualVoiceAIService.shared
    
    var body: some View {
        HStack {
            if message.sender == "user" {
                Spacer(minLength: 44)
                
                Text(message.content)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(deepPlum)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    // NEO Header inside response bubble
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(warmGold)
                        Text("NEO")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .white : deepPlum)
                        
                        Text("• Co-Founder")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if message.isForecastEstimate {
                            Text("ML FORECAST")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                    
                    // Message Content
                    Text(LocalizedStringKey(message.content))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.primary)
                        .lineSpacing(3.5)
                    
                    // Action Recommendation Card if present
                    if let rec = message.actionRecommendation {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("EXECUTIVE RECOMMENDATION")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(warmGold)
                            Text(rec)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(colorScheme == .dark ? Color.black.opacity(0.2) : Color.black.opacity(0.03))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(warmGold.opacity(0.3), lineWidth: 0.8)
                        )
                    }
                    
                    // Footer: Speak aloud & Copy actions
                    HStack(spacing: 12) {
                        Button {
                            voiceAI.speak(message.content)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: voiceAI.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                                    .font(.system(size: 11))
                                Text(voiceAI.isSpeaking ? "Speaking..." : "Listen")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(warmGold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(warmGold.opacity(0.10))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            onCopy()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 11))
                                Text(isCopied ? "Copied" : "Copy")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.10))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    .padding(.top, 2)
                }
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.19) : Color.white)
                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.03), radius: 8, x: 0, y: 3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
                )
                
                Spacer(minLength: 44)
            }
        }
        .padding(.horizontal, 16)
    }
}
                            HStack(spacing: 4) {
                                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 11))
                                Text(isCopied ? "Copied" : "Copy")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.10))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    .padding(.top, 2)
                }
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.19) : Color.white)
                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.03), radius: 8, x: 0, y: 3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
                )
                
                Spacer(minLength: 44)
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - AIMessageBubble Alias for any legacy views
public struct AIMessageBubble: View {
    public let message: AIMessage
    
    public init(message: AIMessage) {
        self.message = message
    }
    
    public var body: some View {
        CleanAIMessageRow(
            message: message,
            onSpeak: {
                NeoCoFounderService.shared.speak(text: message.content)
            },
            onCopy: {
                UIPasteboard.general.string = message.content
            },
            isCopied: false
        )
    }
}

// MARK: - AI Settings Sheet
public struct AISettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var theme: ThemeManager
    @State private var selectedModel: String = "llama-3.3-70b-versatile"
    @State private var customApiKey: String = ""
    @State private var statusMessage: String = ""
    @State private var isTesting: Bool = false
    
    private let availableModels = [
        "llama-3.3-70b-versatile",
        "llama-3.1-8b-instant",
        "mixtral-8x7b-32768"
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            Form {
                SwiftUI.Section {
                    Picker("Active Model", selection: $selectedModel) {
                        ForEach(availableModels, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                } header: {
                    Text("Model Engine")
                }
                
                SwiftUI.Section {
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
                } header: {
                    Text("API Credentials")
                } footer: {
                    Text("Custom credentials override the built-in GAUREX enterprise AI key.")
                }
                
                SwiftUI.Section {
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
                } header: {
                    Text("Executive Context")
                }
            }
            .navigationTitle("NEO AI Engine Settings")
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
