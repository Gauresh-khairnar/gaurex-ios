//
//  DashboardView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Pixel-Perfect Implementation of Executive GAUREX Dashboard
//

import SwiftUI

public struct DashboardView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @Environment(\.colorScheme) private var colorScheme
    
    // Sheet States
    @State private var showingAddClientSheet = false
    @State private var showingCreateInvoiceSheet = false
    @State private var showingAddWorkerSheet = false
    @State private var showingProfitCenter = false
    @State private var showingVoiceAssistant = false
    @State private var showingSettingsSheet = false
    @State private var showingNewProjectSheet = false
    @State private var showingAddExpenseSheet = false
    @State private var showingGhostSimulatorSheet = false
    
    // Opening & Micro-Animation States
    @State private var animateHeader = false
    @State private var animateRevenueCard = false
    @State private var animateStatsGrid = false
    @State private var animateQuickActions = false
    @State private var sparklinePulse = false
    
    @Binding public var selectedTab: MainTab
    
    public init(selectedTab: Binding<MainTab>) {
        self._selectedTab = selectedTab
    }
    
    private var greetingTimeText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning," }
        if hour < 17 { return "Good Afternoon," }
        return "Good Evening,"
    }
    
    private var formattedCurrentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: Date())
    }
    
    private var formattedCurrentWeekday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }
    
    private let deepPurple = Color.gaurexDeepPlum
    private let goldAccent = Color.gaurexWarmGold
    private let mistGray = Color.gaurexMistGray
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Background tint with subtle Mist Gray (#DDE3E8)
                (colorScheme == .dark ? Color(red: 0.07, green: 0.07, blue: 0.09) : mistGray.opacity(0.35))
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // MARK: - Top Header (GAUREX + Bell + Avatar)
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 8) {
                                    HStack(spacing: 0) {
                                        Text("G")
                                            .font(.pjs(24, weight: .bold))
                                            .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                        Text("A")
                                            .font(.pjs(24, weight: .black))
                                            .foregroundColor(goldAccent)
                                        Text("UREX")
                                            .font(.pjs(24, weight: .bold))
                                            .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                    }
                                    .tracking(2.0)
                                    
                                    // Animated AI Sparkles - Tap to trigger Neo voice briefing
                                    Button {
                                        MotionTokens.impact(style: .light)
                                        if NeoCoFounderService.shared.isSpeaking {
                                            NeoCoFounderService.shared.stopSpeaking()
                                        } else {
                                            NeoCoFounderService.shared.greetFounderOnLaunch(force: true)
                                        }
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(deepPurple)
                                                .frame(width: 22, height: 22)
                                                .overlay(Circle().stroke(goldAccent.opacity(0.8), lineWidth: 1))
                                            Image(systemName: "sparkles")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(goldAccent)
                                                .rotationEffect(.degrees(sparklinePulse ? 180 : 0))
                                                .scaleEffect(sparklinePulse ? 1.15 : 0.90)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: sparklinePulse)
                                }
                                
                                Text("Executive Dashboard")
                                    .font(.pjs(12, weight: .medium))
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            
                            Spacer()
                            
                            // Stealth Privacy Shield Button
                            Button {
                                store.toggleStealthPrivacy()
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.22) : Color.white)
                                        .frame(width: 42, height: 42)
                                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                                    
                                    Image(systemName: store.isStealthPrivacyActive ? "eye.slash.fill" : "eye.fill")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(store.isStealthPrivacyActive ? Color.red : goldAccent)
                                }
                            }
                            .buttonStyle(.plain)
                            
                            // Bell Notifications Button with Live Yellow Indicator Dot
                            Button {
                                let feedback = UIImpactFeedbackGenerator(style: .light)
                                feedback.impactOccurred()
                                showingVoiceAssistant = true
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Circle()
                                        .fill(colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.22) : Color.white)
                                        .frame(width: 42, height: 42)
                                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                                    
                                    Image(systemName: "bell")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                        .frame(width: 42, height: 42)
                                    
                                    // Notification Alert Dot
                                    Circle()
                                        .fill(goldAccent)
                                        .frame(width: 8, height: 8)
                                        .offset(x: -6, y: 8)
                                }
                            }
                            .buttonStyle(.plain)
                            
                            // Founder Avatar Circle
                            Button {
                                selectedTab = .settings
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    deepPurple,
                                                    Color(red: 0.14, green: 0.07, blue: 0.22)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 42, height: 42)
                                        .overlay(Circle().stroke(goldAccent.opacity(0.4), lineWidth: 1.2))
                                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                                    
                                    Text("GK")
                                        .font(.pjs(14, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                        .offset(y: animateHeader ? 0 : -20)
                        .opacity(animateHeader ? 1 : 0)
                        
                        // MARK: - Ambient Voice Aura Waveform on Nav Bar (Audio-Reactive Liquid Glass)
                        AmbientVoiceAuraWaveform()
                        
                        // MARK: - Greeting & Date Row
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(greetingTimeText)
                                    .font(.pjs(14, weight: .regular))
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                                
                                HStack(spacing: 6) {
                                    Text("Gauresh")
                                        .font(.pjs(24, weight: .bold))
                                        .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                    Text("👋")
                                        .font(.system(size: 22))
                                }
                                
                                Text("Your business. Smarter. Simpler.\nExecutive command initialized.")
                                    .font(.pjs(12, weight: .regular))
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                                    .lineSpacing(2)
                                    .padding(.top, 1)
                            }
                            
                            Spacer()
                            
                            // Live Date Card
                            Button {
                                selectedTab = .tasks
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(deepPurple)
                                    
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(formattedCurrentDate)
                                            .font(.pjs(11.5, weight: .bold))
                                            .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                        Text(formattedCurrentWeekday)
                                            .font(.pjs(10, weight: .medium))
                                            .foregroundColor(Color(uiColor: .secondaryLabel))
                                    }
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(Color(uiColor: .tertiaryLabel))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.20) : Color.white)
                                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.04), radius: 8, x: 0, y: 2)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(goldAccent.opacity(0.2), lineWidth: 0.6)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 24)
                        .offset(y: animateHeader ? 0 : -15)
                        .opacity(animateHeader ? 1 : 0)
                        
                        // MARK: - 3D Holographic Gyroscope Hero Card
                        HolographicFounderHeroCard {
                            showingProfitCenter = true
                        }
                        .padding(.horizontal, 24)
                        .offset(y: animateRevenueCard ? 0 : 25)
                        .opacity(animateRevenueCard ? 1 : 0)
                        
                        // MARK: - Founder Velocity 3-Ring Activity Center
                        FounderVelocityRingsView()
                            .padding(.horizontal, 24)
                        
                        // MARK: - 4-Card Metrics Grid (2x2 Spacious with Real Data)
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                            // 1. Total Clients
                            StatMetricTile(
                                icon: "person.2",
                                title: "Total Clients",
                                value: "\(store.clients.count)",
                                trend: "\(store.clients.filter { $0.status == .active }.count) Active",
                                isPositive: true,
                                isNeutral: false
                            ) {
                                selectedTab = .clients
                            }
                            
                            // 2. Active Projects
                            StatMetricTile(
                                icon: "doc.text",
                                title: "Active Projects",
                                value: "\(store.activeProjectsCount)",
                                trend: "\(store.packages.count) Services",
                                isPositive: true,
                                isNeutral: false
                            ) {
                                showingNewProjectSheet = true
                            }
                            
                            // 3. Pending Tasks
                            StatMetricTile(
                                icon: "clock",
                                title: "Pending Tasks",
                                value: "\(store.tasks.filter { $0.status == .pending }.count)",
                                trend: store.tasks.filter { $0.status == .pending }.isEmpty ? "All Done" : "Action Req.",
                                isPositive: store.tasks.filter { $0.status == .pending }.isEmpty,
                                isNeutral: !store.tasks.filter { $0.status == .pending }.isEmpty
                            ) {
                                selectedTab = .tasks
                            }
                            
                            // 4. Outstanding
                            StatMetricTile(
                                icon: "indianrupeesign",
                                title: "Outstanding",
                                value: FinancialCalculator.shared.formatCurrency(store.outstandingPayments, symbol: store.settings.currencySymbol),
                                trend: store.overdueInvoicesCount > 0 ? "\(store.overdueInvoicesCount) Overdue" : "On Track",
                                isPositive: store.outstandingPayments == 0,
                                isNeutral: store.outstandingPayments > 0
                            ) {
                                showingProfitCenter = true
                            }
                        }
                        .padding(.horizontal, 24)
                        .offset(y: animateStatsGrid ? 0 : 25)
                        .opacity(animateStatsGrid ? 1 : 0)
                        
                        // MARK: - Quick Actions Section (2x2 Spacious)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Actions")
                                .font(.pjs(16, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                .padding(.horizontal, 24)
                            
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                                // 1. New Project
                                QuickActionCardTile(
                                    icon: "sparkles",
                                    title: "New Project",
                                    subtitle: "Start a new solution"
                                ) {
                                    showingNewProjectSheet = true
                                }
                                
                                // 2. Create Invoice
                                QuickActionCardTile(
                                    icon: "doc.text.fill",
                                    iconColor: goldAccent,
                                    title: "Create Invoice",
                                    subtitle: "Bill your client"
                                ) {
                                    showingCreateInvoiceSheet = true
                                }
                                
                                // 3. Add Client
                                QuickActionCardTile(
                                    icon: "person.2.fill",
                                    title: "Add Client",
                                    subtitle: "Grow your network"
                                ) {
                                    showingAddClientSheet = true
                                }
                                
                                // 4. AI Assistant
                                QuickActionCardTile(
                                    icon: "brain.head.profile",
                                    iconColor: goldAccent,
                                    title: "AI Assistant",
                                    subtitle: "Ask NEO advisor"
                                ) {
                                    selectedTab = .aiModel
                                }
                                
                                // 5. Log Expense
                                QuickActionCardTile(
                                    icon: "creditcard.fill",
                                    iconColor: Color(red: 0.92, green: 0.28, blue: 0.28),
                                    title: "Log Expense",
                                    subtitle: "Deducts live cashflow"
                                ) {
                                    showingAddExpenseSheet = true
                                }
                                
                                // 6. Ghost Simulator
                                QuickActionCardTile(
                                    icon: "wand.and.stars",
                                    iconColor: goldAccent,
                                    title: "Ghost Simulator",
                                    subtitle: "What-If war games"
                                ) {
                                    showingGhostSimulatorSheet = true
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .offset(y: animateQuickActions ? 0 : 25)
                        .opacity(animateQuickActions ? 1 : 0)
                        
                        Spacer().frame(height: 120)
                    }
                    .padding(.vertical, 10)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddClientSheet) { AddEditClientView() }
            .sheet(isPresented: $showingCreateInvoiceSheet) { CreateInvoiceView() }
            .sheet(isPresented: $showingAddWorkerSheet) { AddEditWorkerView() }
            .sheet(isPresented: $showingProfitCenter) { FinanceProfitCenterView() }
            .sheet(isPresented: $showingVoiceAssistant) { VoiceAssistantOverlay() }
            .sheet(isPresented: $showingSettingsSheet) { SettingsView() }
            .sheet(isPresented: $showingNewProjectSheet) {
                AddEditPackageView()
            }
            .sheet(isPresented: $showingAddExpenseSheet) {
                AddExpenseSheet()
            }
            .sheet(isPresented: $showingGhostSimulatorSheet) {
                GhostRunwaySimulatorSheet()
            }
            .onAppear {
                triggerAppOpeningAnimations()
            }
        }
    }
    
    // MARK: - App Opening Micro-Animations Sequence
    private func triggerAppOpeningAnimations() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            animateHeader = true
        }
        withAnimation(.spring(response: 0.50, dampingFraction: 0.82).delay(0.08)) {
            animateRevenueCard = true
        }
        withAnimation(.spring(response: 0.52, dampingFraction: 0.84).delay(0.16)) {
            animateStatsGrid = true
        }
        withAnimation(.spring(response: 0.56, dampingFraction: 0.86).delay(0.24)) {
            animateQuickActions = true
        }
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
            sparklinePulse = true
        }
    }
}

// MARK: - Reusable Dashboard UI Components

private struct StatMetricTile: View {
    @Environment(\.colorScheme) private var colorScheme
    let icon: String
    let title: String
    let value: String
    let trend: String
    let isPositive: Bool
    let isNeutral: Bool
    let action: () -> Void
    
    private let deepPurple = Color(red: 0.18, green: 0.08, blue: 0.28)
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(red: 0.24, green: 0.12, blue: 0.36).opacity(0.08))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: icon)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(deepPurple)
                        )
                    
                    Spacer()
                    
                    HStack(spacing: 3) {
                        if isNeutral {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 9, weight: .bold))
                            Text(trend)
                                .font(.system(size: 10.5, weight: .bold))
                        } else {
                            Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                                .font(.system(size: 9, weight: .bold))
                            Text(trend)
                                .font(.system(size: 10.5, weight: .bold))
                        }
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(
                        (isNeutral ? Color.secondary : (isPositive ? Color(red: 0.06, green: 0.72, blue: 0.44) : Color.red)).opacity(0.12)
                    )
                    .clipShape(Capsule())
                    .foregroundColor(
                        isNeutral
                            ? Color(uiColor: .secondaryLabel)
                            : (isPositive ? Color(red: 0.06, green: 0.72, blue: 0.44) : Color.red)
                    )
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.pjs(12, weight: .medium))
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                        .lineLimit(1)
                    
                    Text(value)
                        .font(.pjs(18, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.19) : Color.white)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.04), radius: 8, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct QuickActionCardTile: View {
    @Environment(\.colorScheme) private var colorScheme
    let icon: String
    var iconColor: Color = .white
    let title: String
    let subtitle: String
    let action: () -> Void
    
    private let deepPurple = Color.gaurexDeepPlum
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(deepPurple)
                    .frame(width: 38, height: 38)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(iconColor)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.pjs(13, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                        .lineLimit(1)
                    
                    Text(subtitle)
                        .font(.pjs(11, weight: .regular))
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                        .lineLimit(1)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.19) : Color.white)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.04), radius: 8, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct SparklineWaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        path.move(to: CGPoint(x: 0, y: h * 0.75))
        path.addCurve(
            to: CGPoint(x: w * 0.35, y: h * 0.70),
            control1: CGPoint(x: w * 0.15, y: h * 0.95),
            control2: CGPoint(x: w * 0.25, y: h * 0.60)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.70, y: h * 0.25),
            control1: CGPoint(x: w * 0.45, y: h * 0.80),
            control2: CGPoint(x: w * 0.58, y: h * 0.20)
        )
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.10),
            control1: CGPoint(x: w * 0.82, y: h * 0.30),
            control2: CGPoint(x: w * 0.92, y: h * 0.15)
        )
        return path
    }
}
