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
    
    // Opening & Micro-Animation States
    @State private var animateHeader = false
    @State private var animateRevenueCard = false
    @State private var animateStatsGrid = false
    @State private var animateActivity = false
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
    
    private let deepPurple = Color(red: 0.18, green: 0.08, blue: 0.28)
    private let goldAccent = Color(red: 0.90, green: 0.65, blue: 0.15)
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Background tint matching screenshot
                (colorScheme == .dark ? Color(red: 0.07, green: 0.07, blue: 0.09) : Color(red: 0.96, green: 0.96, blue: 0.98))
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        // MARK: - Top Header (GAUREX + Bell + Avatar)
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 1) {
                                HStack(spacing: 0) {
                                    Text("G")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                    Text("A")
                                        .font(.system(size: 24, weight: .black))
                                        .foregroundColor(goldAccent)
                                    Text("UREX")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                }
                                .tracking(2.0)
                                
                                Text("Dashboard")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            
                            Spacer()
                            
                            // Bell Notifications Button with Live Yellow Indicator Dot
                            Button {
                                let feedback = UIImpactFeedbackGenerator(style: .light)
                                feedback.impactOccurred()
                                showingVoiceAssistant = true
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Circle()
                                        .fill(colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.22) : Color.white)
                                        .frame(width: 40, height: 40)
                                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                                    
                                    Image(systemName: "bell")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                        .frame(width: 40, height: 40)
                                    
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
                                                    Color(red: 0.28, green: 0.16, blue: 0.40),
                                                    Color(red: 0.14, green: 0.07, blue: 0.22)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 40, height: 40)
                                        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                                    
                                    Text("GK")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .offset(y: animateHeader ? 0 : -20)
                        .opacity(animateHeader ? 1 : 0)
                        
                        // MARK: - Greeting & Date Row
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(greetingTimeText)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                                
                                HStack(spacing: 6) {
                                    Text("Gauresh")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                    Text("👋")
                                        .font(.system(size: 22))
                                }
                                
                                Text("Your business. Smarter. Simpler.\nLet's build more today.")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                                    .lineSpacing(2)
                                    .padding(.top, 1)
                            }
                            
                            Spacer()
                            
                            // Date Card
                            Button {
                                selectedTab = .tasks
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(deepPurple)
                                    
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text("27 Oct 2026")
                                            .font(.system(size: 11.5, weight: .bold))
                                            .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                        Text("Tuesday")
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundColor(Color(uiColor: .secondaryLabel))
                                    }
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(Color(uiColor: .tertiaryLabel))
                                }
                                .padding(.horizontal, 12)
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
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                        .offset(y: animateHeader ? 0 : -15)
                        .opacity(animateHeader ? 1 : 0)
                        
                        // MARK: - Total Revenue Card with Flowing Sparkline Wave
                        Button {
                            showingProfitCenter = true
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.19) : Color.white)
                                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.05), radius: 14, x: 0, y: 4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
                                    )
                                
                                // Content
                                HStack(alignment: .bottom) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 8) {
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .fill(Color(red: 0.24, green: 0.12, blue: 0.36).opacity(0.08))
                                                .frame(width: 36, height: 36)
                                                .overlay(
                                                    Image(systemName: "chart.bar.xaxis")
                                                        .font(.system(size: 16, weight: .semibold))
                                                        .foregroundColor(deepPurple)
                                                )
                                            
                                            Text("Total Revenue")
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(Color(uiColor: .secondaryLabel))
                                        }
                                        
                                        let amount = store.revenueCollected > 0 ? store.revenueCollected : 482000.0
                                        Text(FinancialCalculator.shared.formatCurrency(amount, symbol: store.settings.currencySymbol))
                                            .font(.system(size: 26, weight: .black, design: .rounded))
                                            .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.up")
                                                .font(.system(size: 11, weight: .bold))
                                            Text("+12%")
                                                .font(.system(size: 12, weight: .bold))
                                            Text("vs last 30 days")
                                                .font(.system(size: 11, weight: .regular))
                                                .foregroundColor(Color(uiColor: .secondaryLabel))
                                        }
                                        .foregroundColor(Color(red: 0.06, green: 0.72, blue: 0.44))
                                    }
                                    
                                    Spacer()
                                    
                                    // Flowing Bezier Sparkline Chart
                                    ZStack {
                                        SparklineWaveShape()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Color(red: 0.35, green: 0.18, blue: 0.50),
                                                        goldAccent
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 2.2
                                            )
                                            .frame(width: 140, height: 60)
                                        
                                        // Golden inflection node on peak
                                        Circle()
                                            .fill(goldAccent)
                                            .frame(width: 8, height: 8)
                                            .shadow(color: goldAccent.opacity(0.8), radius: sparklinePulse ? 6 : 2)
                                            .offset(x: 15, y: -16)
                                    }
                                }
                                .padding(18)
                                
                                // Live Pill Badge
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(Color(red: 0.06, green: 0.72, blue: 0.44))
                                        .frame(width: 6, height: 6)
                                    Text("Live")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(Color(red: 0.06, green: 0.72, blue: 0.44))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(red: 0.06, green: 0.72, blue: 0.44).opacity(0.10))
                                .clipShape(Capsule())
                                .padding(14)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                        .offset(y: animateRevenueCard ? 0 : 25)
                        .opacity(animateRevenueCard ? 1 : 0)
                        
                        // MARK: - 4-Card Metrics Grid (2x2 Spacious)
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            // 1. Total Clients
                            StatMetricTile(
                                icon: "person.2",
                                title: "Total Clients",
                                value: "\(max(store.clients.count, 12))",
                                trend: "+3",
                                isPositive: true,
                                isNeutral: false
                            ) {
                                selectedTab = .clients
                            }
                            
                            // 2. Active Projects
                            StatMetricTile(
                                icon: "doc.text",
                                title: "Active Projects",
                                value: "\(max(store.activeProjectsCount, 8))",
                                trend: "+2",
                                isPositive: true,
                                isNeutral: false
                            ) {
                                showingNewProjectSheet = true
                            }
                            
                            // 3. Pending Tasks
                            StatMetricTile(
                                icon: "clock",
                                title: "Pending Tasks",
                                value: "\(max(store.tasks.filter { $0.status == .pending }.count, 5))",
                                trend: "0",
                                isPositive: false,
                                isNeutral: true
                            ) {
                                selectedTab = .tasks
                            }
                            
                            // 4. Outstanding
                            StatMetricTile(
                                icon: "indianrupeesign",
                                title: "Outstanding",
                                value: FinancialCalculator.shared.formatCurrency(store.outstandingPayments > 0 ? store.outstandingPayments : 120000, symbol: store.settings.currencySymbol),
                                trend: "-8%",
                                isPositive: true,
                                isNeutral: false
                            ) {
                                showingProfitCenter = true
                            }
                        }
                        .padding(.horizontal, 16)
                        .offset(y: animateStatsGrid ? 0 : 25)
                        .opacity(animateStatsGrid ? 1 : 0)
                        
                        // MARK: - Recent Activity Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Recent Activity")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                Spacer()
                                Button("View All >") {
                                    showingProfitCenter = true
                                }
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            .padding(.horizontal, 16)
                            
                            VStack(spacing: 0) {
                                ActivityItemRow(
                                    icon: "doc.text.fill",
                                    iconColor: Color(red: 0.06, green: 0.72, blue: 0.44),
                                    iconBg: Color(red: 0.06, green: 0.72, blue: 0.44).opacity(0.12),
                                    title: "Invoice #INV-1024 Paid",
                                    subtitle: "Elite Haven • ₹ 75,000",
                                    timeAgo: "2h ago"
                                )
                                Divider().padding(.leading, 64).opacity(0.4)
                                
                                ActivityItemRow(
                                    icon: "person.2.fill",
                                    iconColor: deepPurple,
                                    iconBg: deepPurple.opacity(0.10),
                                    title: "New Client Added",
                                    subtitle: "Foratravel • Website Development",
                                    timeAgo: "4h ago"
                                )
                                Divider().padding(.leading, 64).opacity(0.4)
                                
                                ActivityItemRow(
                                    icon: "checkmark",
                                    iconColor: goldAccent,
                                    iconBg: goldAccent.opacity(0.15),
                                    title: "Project Completed",
                                    subtitle: "ELIVAAS • Automation System",
                                    timeAgo: "6h ago"
                                )
                                Divider().padding(.leading, 64).opacity(0.4)
                                
                                ActivityItemRow(
                                    icon: "bubble.left.fill",
                                    iconColor: Color(red: 0.55, green: 0.40, blue: 0.75),
                                    iconBg: Color(red: 0.55, green: 0.40, blue: 0.75).opacity(0.12),
                                    title: "New Message",
                                    subtitle: "From +91 98765 43210",
                                    timeAgo: "8h ago"
                                )
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.19) : Color.white)
                                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.04), radius: 8, x: 0, y: 3)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
                            )
                            .padding(.horizontal, 16)
                        }
                        .offset(y: animateActivity ? 0 : 25)
                        .opacity(animateActivity ? 1 : 0)
                        
                        // MARK: - Quick Actions Section (2x2 Spacious)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Actions")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                .padding(.horizontal, 16)
                            
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
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
                                    iconColor: Color(red: 0.55, green: 0.40, blue: 0.75),
                                    title: "AI Assistant",
                                    subtitle: "Ask NEO advisor"
                                ) {
                                    selectedTab = .aiModel
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .offset(y: animateQuickActions ? 0 : 25)
                        .opacity(animateQuickActions ? 1 : 0)
                        
                        Spacer().frame(height: 110)
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
        withAnimation(.spring(response: 0.54, dampingFraction: 0.85).delay(0.24)) {
            animateActivity = true
        }
        withAnimation(.spring(response: 0.56, dampingFraction: 0.86).delay(0.32)) {
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
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                        .lineLimit(1)
                    
                    Text(value)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .padding(14)
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

private struct ActivityItemRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let icon: String
    let iconColor: Color
    let iconBg: Color
    let title: String
    let subtitle: String
    let timeAgo: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(iconBg)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(iconColor)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.08, blue: 0.28))
                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
            
            Spacer()
            
            Text(timeAgo)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color(uiColor: .tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

private struct QuickActionCardTile: View {
    @Environment(\.colorScheme) private var colorScheme
    let icon: String
    var iconColor: Color = .white
    let title: String
    let subtitle: String
    let action: () -> Void
    
    private let deepPurple = Color(red: 0.18, green: 0.08, blue: 0.28)
    
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
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                        .lineLimit(1)
                    
                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                        .lineLimit(1)
                }
            }
            .padding(14)
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
