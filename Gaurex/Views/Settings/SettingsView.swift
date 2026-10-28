//
//  SettingsView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct SettingsView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @ObservedObject private var bioAuth = BiometricAuthService.shared
    @ObservedObject private var neoService = NeoCoFounderService.shared
    
    @State private var showingExportSheet = false
    @State private var exportData: Data? = nil
    @State private var showingEditProfile = false
    @State private var showingLogoutAlert = false
    @State private var selectedColorIndex = 0
    
    // Editable Profile State
    @State private var founderName: String = "Gauresh Khairnar"
    @State private var officialEmail: String = "gaurex.ai@gmail.com"
    @State private var officialPhone: String = "+91 98765 43210"
    @State private var companyName: String = "GAUREX"
    @State private var showingResetAlert: Bool = false
    
    private let accentColors: [Color] = [
        Color(red: 0.18, green: 0.08, blue: 0.28), // Deep Royal Purple
        Color(red: 0.90, green: 0.65, blue: 0.15), // Luxury Gold
        Color(red: 0.15, green: 0.35, blue: 0.75), // Soft Navy
        Color(red: 0.12, green: 0.60, blue: 0.40)  // Emerald
    ]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // MARK: - Header Bar (GAUREX + Bell)
                        HStack(alignment: .center) {
                            HStack(spacing: 0) {
                                Text("G")
                                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                                    .foregroundColor(.primary)
                                Text("A")
                                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                                    .foregroundColor(Color(red: 0.90, green: 0.65, blue: 0.15))
                                Text("UREX")
                                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Button {
                                MotionTokens.selection()
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.primary)
                                        .padding(8)
                                        .background(Color(uiColor: .systemBackground))
                                        .clipShape(Circle())
                                        .shadow(color: Color.black.opacity(0.06), radius: 4, y: 2)
                                    
                                    Circle()
                                        .fill(Color(red: 0.90, green: 0.65, blue: 0.15))
                                        .frame(width: 8, height: 8)
                                        .offset(x: -2, y: 2)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        
                        // MARK: - Title
                        Text("Settings")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 24)
                        
                        // MARK: - Founder Profile Card
                        VStack(spacing: 14) {
                            HStack(alignment: .center, spacing: 14) {
                                // Avatar Circle
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.18, green: 0.08, blue: 0.28),
                                                    Color(red: 0.32, green: 0.12, blue: 0.45)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Circle()
                                                .stroke(Color(red: 0.90, green: 0.65, blue: 0.15), lineWidth: 2)
                                        )
                                        .shadow(color: Color.black.opacity(0.12), radius: 6, y: 3)
                                    
                                    Text("GK")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(red: 0.90, green: 0.65, blue: 0.15))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 8) {
                                        Text(store.settings.founderName.isEmpty ? "Gauresh Khairnar" : store.settings.founderName)
                                            .font(.system(size: 17, weight: .bold))
                                            .foregroundColor(.primary)
                                        
                                        // Owner Badge
                                        HStack(spacing: 3) {
                                            Text("👑")
                                                .font(.system(size: 11))
                                            Text("Owner")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(Color(red: 0.70, green: 0.48, blue: 0.05))
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color(red: 0.98, green: 0.92, blue: 0.76))
                                        .clipShape(Capsule())
                                    }
                                    
                                    Text(store.settings.officialEmail.isEmpty ? "gaurex.ai@gmail.com" : store.settings.officialEmail)
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                    
                                    Text(store.settings.officialPhone.isEmpty ? "+91 98765 43210" : store.settings.officialPhone)
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            
                            // Edit Profile Button
                            Button {
                                MotionTokens.selection()
                                founderName = store.settings.founderName.isEmpty ? "Gauresh Khairnar" : store.settings.founderName
                                officialEmail = store.settings.officialEmail.isEmpty ? "gaurex.ai@gmail.com" : store.settings.officialEmail
                                officialPhone = store.settings.officialPhone.isEmpty ? "+91 98765 43210" : store.settings.officialPhone
                                companyName = store.settings.companyName.isEmpty ? "GAUREX" : store.settings.companyName
                                showingEditProfile = true
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Edit Profile")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(red: 0.18, green: 0.08, blue: 0.28))
                                    Spacer()
                                }
                                .padding(.vertical, 10)
                                .background(Color(red: 0.18, green: 0.08, blue: 0.28).opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(16)
                        .background(Color(uiColor: .systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
                        )
                        .padding(.horizontal, 24)
                        
                        // MARK: - Appearance & Theme Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("APPEARANCE & THEME")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 24)
                            
                            // 4 Theme Cards Grid
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                                ThemeCard(
                                    title: "Light",
                                    subtitle: "Clean & Fresh",
                                    icon: "sun.max.fill",
                                    isSelected: theme.currentTheme == .light || theme.currentTheme == .pureWhite,
                                    color: .orange
                                ) {
                                    withAnimation(MotionTokens.interactiveSpring) {
                                        theme.currentTheme = .light
                                        store.settings.activeThemeRaw = AppTheme.light.rawValue
                                        store.saveSettings()
                                    }
                                    MotionTokens.selection()
                                }
                                
                                ThemeCard(
                                    title: "Dark",
                                    subtitle: "Bold & Focused",
                                    icon: "moon.stars.fill",
                                    isSelected: theme.currentTheme == .dark || theme.currentTheme == .midnight,
                                    color: .indigo
                                ) {
                                    withAnimation(MotionTokens.interactiveSpring) {
                                        theme.currentTheme = .dark
                                        store.settings.activeThemeRaw = AppTheme.dark.rawValue
                                        store.saveSettings()
                                    }
                                    MotionTokens.selection()
                                }
                                
                                ThemeCard(
                                    title: "Purple",
                                    subtitle: "Modern & Elegant",
                                    icon: "sparkles",
                                    isSelected: theme.currentTheme == .purple,
                                    color: Color(red: 0.55, green: 0.25, blue: 0.75)
                                ) {
                                    withAnimation(MotionTokens.interactiveSpring) {
                                        theme.currentTheme = .purple
                                        store.settings.activeThemeRaw = AppTheme.purple.rawValue
                                        store.saveSettings()
                                    }
                                    MotionTokens.selection()
                                }
                                
                                ThemeCard(
                                    title: "Gold",
                                    subtitle: "Luxury & Premium",
                                    icon: "crown.fill",
                                    isSelected: theme.currentTheme == .gold || theme.currentTheme == .gaurexAccent,
                                    color: Color(red: 0.90, green: 0.65, blue: 0.15)
                                ) {
                                    withAnimation(MotionTokens.interactiveSpring) {
                                        theme.currentTheme = .gold
                                        store.settings.activeThemeRaw = AppTheme.gold.rawValue
                                        store.saveSettings()
                                    }
                                    MotionTokens.selection()
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // Theme Color Circles
                            HStack(spacing: 16) {
                                ForEach(0..<accentColors.count, id: \.self) { idx in
                                    Button {
                                        withAnimation(MotionTokens.interactiveSpring) {
                                            selectedColorIndex = idx
                                        }
                                        MotionTokens.selection()
                                    } label: {
                                        Circle()
                                            .fill(accentColors[idx])
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.primary.opacity(selectedColorIndex == idx ? 0.8 : 0.15), lineWidth: selectedColorIndex == idx ? 3 : 1)
                                                    .padding(-3)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 4)
                        }
                        
                        // MARK: - Business Settings Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("BUSINESS SETTINGS")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 0) {
                                NavigationLink {
                                    BusinessSettingsView()
                                } label: {
                                    SettingsRow(
                                        icon: "building.2.fill",
                                        iconColor: .purple,
                                        title: "Company Profile",
                                        subtitle: store.settings.companyName.isEmpty ? "GAUREX Executive Suite" : store.settings.companyName
                                    )
                                }
                                
                                Divider().padding(.leading, 56)
                                
                                NavigationLink {
                                    PackageManagementView()
                                } label: {
                                    SettingsRow(
                                        icon: "shippingbox.fill",
                                        iconColor: .orange,
                                        title: "Add Product / Service",
                                        subtitle: "\(store.packages.count) active catalog offerings",
                                        badgeText: "+ Add"
                                    )
                                }
                                
                                Divider().padding(.leading, 56)
                                
                                NavigationLink {
                                    BusinessSettingsView()
                                } label: {
                                    SettingsRow(
                                        icon: "doc.text.fill",
                                        iconColor: .blue,
                                        title: "Invoice Settings",
                                        subtitle: "Terms, prefix, sequential numbering & footer"
                                    )
                                }
                                
                                Divider().padding(.leading, 56)
                                
                                NavigationLink {
                                    MultiCurrencySettingsView()
                                } label: {
                                    SettingsRow(
                                        icon: "creditcard.fill",
                                        iconColor: .green,
                                        title: "Payment Methods",
                                        subtitle: "\(store.activeCurrency.symbol) \(store.activeCurrency.rawValue) & bank wiring"
                                    )
                                }
                                
                                Divider().padding(.leading, 56)
                                
                                NavigationLink {
                                    BusinessSettingsView()
                                } label: {
                                    SettingsRow(
                                        icon: "percent",
                                        iconColor: .indigo,
                                        title: "Taxes & GST",
                                        subtitle: "GSTIN, tax slabs & automatic ledger calculation"
                                    )
                                }
                            }
                            .background(Color(uiColor: .systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
                            )
                            .padding(.horizontal, 24)
                        }
                        
                        // MARK: - App Features Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("APP FEATURES")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 0) {
                                NavigationLink {
                                    NeoAssistantSettingsView()
                                } label: {
                                    SettingsRow(
                                        icon: "sparkles",
                                        iconColor: Color(red: 0.90, green: 0.65, blue: 0.15),
                                        title: "AI Assistant (NEO)",
                                        subtitle: "Voice greeting, speech co-founder & ML models",
                                        badgeText: neoService.isVoiceGreetingEnabled ? "Active" : "Muted"
                                    )
                                }
                                
                                Divider().padding(.leading, 56)
                                
                                NavigationLink {
                                    DocumentVaultView()
                                } label: {
                                    SettingsRow(
                                        icon: "folder.fill",
                                        iconColor: .teal,
                                        title: "Document Vault",
                                        subtitle: "\(store.vaultDocuments.count) stored contracts & receipts"
                                    )
                                }
                                
                                Divider().padding(.leading, 56)
                                
                                Button {
                                    exportBusinessData()
                                    MotionTokens.selection()
                                } label: {
                                    SettingsRow(
                                        icon: "square.and.arrow.up.fill",
                                        iconColor: .blue,
                                        title: "Data & Backup",
                                        subtitle: "Export full business JSON ledger snapshot"
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                Divider().padding(.leading, 56)
                                
                                Button {
                                    showingResetAlert = true
                                } label: {
                                    SettingsRow(
                                        icon: "trash.fill",
                                        iconColor: .red,
                                        title: "Clear All Previous Data",
                                        subtitle: "Purge all test/mock records for clean production use",
                                        badgeText: "Clean Slate"
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            .background(Color(uiColor: .systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
                            )
                            .padding(.horizontal, 24)
                        }
                        
                        // MARK: - System & Support Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("SYSTEM & SUPPORT")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 0) {
                                // Biometrics Row
                                HStack(spacing: 14) {
                                    Image(systemName: "faceid")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.purple)
                                        .frame(width: 32, height: 32)
                                        .background(Color.purple.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Biometric Security")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.primary)
                                        Text("Require Face ID to unlock GAUREX")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $store.settings.biometricUnlockEnabled)
                                        .labelsHidden()
                                        .onChange(of: store.settings.biometricUnlockEnabled) { _ in
                                            store.saveSettings()
                                        }
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                
                                Divider().padding(.leading, 56)
                                
                                NavigationLink {
                                    AuditLogsView()
                                } label: {
                                    SettingsRow(
                                        icon: "shield.lefthalf.filled",
                                        iconColor: .indigo,
                                        title: "Activity Audit Trail",
                                        subtitle: "Immutable event ledger & administrative actions"
                                    )
                                }
                                
                                Divider().padding(.leading, 56)
                                
                                SettingsRow(
                                    icon: "info.circle.fill",
                                    iconColor: .gray,
                                    title: "About GAUREX",
                                    subtitle: "v1.0.0 (Build 4011) • Apple Design System",
                                    badgeText: "v1.0.0"
                                )
                            }
                            .background(Color(uiColor: .systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
                            )
                            .padding(.horizontal, 24)
                        }
                        
                        // MARK: - Log Out Pill Button
                        Button {
                            showingLogoutAlert = true
                            MotionTokens.selection()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Log Out")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 24)
                        .padding(.top, 4)
                        
                        Spacer().frame(height: 110)
                    }
                    .padding(.vertical, 10)
                }
                
                ToastOverlay(toast: $store.activeToast)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingExportSheet) {
                if let data = exportData {
                    ActivityViewController(activityItems: [data])
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileSheet(
                    founderName: $founderName,
                    officialEmail: $officialEmail,
                    officialPhone: $officialPhone,
                    companyName: $companyName,
                    onSave: {
                        store.settings.founderName = founderName
                        store.settings.officialEmail = officialEmail
                        store.settings.officialPhone = officialPhone
                        store.settings.companyName = companyName
                        store.saveSettings()
                    }
                )
            }
            .alert("Confirm Lock / Session Exit", isPresented: $showingLogoutAlert) {
                Button("Lock Application", role: .destructive) {
                    bioAuth.lockApp()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will immediately terminate the current session and require Face ID or passcode to re-enter GAUREX.")
            }
        }
    }
    
    private func exportBusinessData() {
        do {
            let data = try DataBackupService.shared.exportJSON(
                settings: store.settings,
                clients: store.clients,
                packages: store.packages,
                invoices: store.invoices,
                payments: store.payments,
                workers: store.workers,
                payrollRecords: store.payrollRecords,
                expenses: store.expenses,
                projects: store.projects
            )
            exportData = data
            showingExportSheet = true
        } catch {
            print("Failed to export backup: \(error)")
        }
    }
}

// MARK: - Theme Card Component
private struct ThemeCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                        .frame(width: 30, height: 30)
                        .background(color.opacity(0.12))
                        .clipShape(Circle())
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 0.18, green: 0.08, blue: 0.28))
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            .padding(14)
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color(red: 0.18, green: 0.08, blue: 0.28) : Color.primary.opacity(0.06), lineWidth: isSelected ? 2 : 0.8)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Standard Settings Row Component
private struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    var badgeText: String? = nil
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if let badgeText = badgeText {
                Text(badgeText)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red: 0.18, green: 0.08, blue: 0.28))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(red: 0.18, green: 0.08, blue: 0.28).opacity(0.08))
                    .clipShape(Capsule())
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(uiColor: .tertiaryLabel))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - NEO Assistant Settings Subview
private struct NeoAssistantSettingsView: View {
    @ObservedObject private var neo = NeoCoFounderService.shared
    @ObservedObject private var voiceAI = MultilingualVoiceAIService.shared
    @Environment(\.colorScheme) private var colorScheme
    
    private let deepPlum = Color.gaurexDeepPlum
    private let warmGold = Color.gaurexWarmGold
    
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color(red: 0.07, green: 0.07, blue: 0.09) : Color.gaurexMistGray.opacity(0.35))
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // Card 0: Executive Founder Intelligence Status
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 16))
                                .foregroundColor(warmGold)
                            Text("Executive Private Intelligence • Mr. Gauresh")
                                .font(.pjs(14, weight: .bold))
                                .foregroundColor(deepPlum)
                        }
                        
                        Text("GAUREX NEO AI is custom-engineered exclusively for Founder Gauresh Khairnar (OWNER). Powered by ultra-fast private inference, biometric security, and dedicated ledger reasoning.")
                            .font(.pjs(12, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineSpacing(2.5)
                    }
                    .padding(14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(warmGold.opacity(0.35), lineWidth: 1)
                    )
                    
                    // Card 1: Multilingual Voice Engine
                    VStack(alignment: .leading, spacing: 10) {
                        Text("MULTILINGUAL VOICE ENGINE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text("Speech Language")
                                    .font(.system(size: 15, weight: .medium))
                                Spacer()
                                Picker("", selection: $voiceAI.selectedLanguage) {
                                    ForEach(VoiceAILanguage.allCases) { lang in
                                        Text(lang.displayName).tag(lang)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                            .padding(.vertical, 12)
                            
                            Divider()
                            
                            HStack {
                                Text("Autonomous Voice Greeting")
                                    .font(.system(size: 15, weight: .medium))
                                Spacer()
                                Toggle("", isOn: $neo.isVoiceGreetingEnabled)
                                    .labelsHidden()
                            }
                            .padding(.vertical, 12)
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Speaking Speed")
                                        .font(.system(size: 15, weight: .medium))
                                    Spacer()
                                    Text(String(format: "%.2fx", voiceAI.speakingSpeed * 2.0))
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(deepPlum)
                                }
                                Slider(value: $voiceAI.speakingSpeed, in: 0.35...0.70, step: 0.05)
                            }
                            .padding(.vertical, 12)
                            
                            Divider()
                            
                            Button {
                                let testPhrase: String
                                switch voiceAI.selectedLanguage {
                                case .hindi:
                                    testPhrase = "नमस्ते गौरेष जी, गाउरेक्स वॉइस असिस्टेंट पूरी तरह सक्रिय है।"
                                case .marathi:
                                    testPhrase = "शुभ प्रभात गौरेष सर, गाउरेक्स व्हॉईस असिस्टंट सज्ज आहे."
                                default:
                                    testPhrase = "Good morning Gauresh. GAUREX AI Co-Founder voice output is online."
                                }
                                voiceAI.speak(testPhrase)
                            } label: {
                                HStack {
                                    Image(systemName: "waveform")
                                    Text("Test Spoken Audio Voice")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(deepPlum)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                            }
                        }
                        .padding(.horizontal, 24)
                        .background(Color(uiColor: .systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
                    }
                    
                    // Card 2: Speech Quality & Dataset Evaluation Benchmarks (Part 3)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("SPEECH QUALITY BENCHMARKS (100M DATASET HARNESS)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            ForEach(SpeechQualityEvaluation.officialBenchmarks) { bench in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(bench.language)
                                            .font(.system(size: 13, weight: .bold))
                                        Text("WER: \((bench.wordErrorRateWER * 100).formatted())% • CER: \((bench.characterErrorRateCER * 100).formatted())%")
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("F1: \((bench.intentAccuracyMacroF1 * 100).formatted())%")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.green)
                                        Text("Safety: 100%")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundColor(deepPlum)
                                    }
                                }
                                .padding(.vertical, 4)
                                
                                if bench.id != SpeechQualityEvaluation.officialBenchmarks.last?.id {
                                    Divider()
                                }
                            }
                        }
                        .padding(14)
                        .background(Color(uiColor: .systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
                    }
                    
                    // Card 3: Autonomous Intelligence Engines
                    VStack(alignment: .leading, spacing: 10) {
                        Text("INTELLIGENCE ENGINES")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text("Predictive ML Engine")
                                    .font(.system(size: 15, weight: .medium))
                                Spacer()
                                Text("Active (v2.0)")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .padding(.vertical, 14)
                            
                            Divider()
                            
                            HStack {
                                Text("Cash Runway Forecasting")
                                    .font(.system(size: 15, weight: .medium))
                                Spacer()
                                Text("Active")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .padding(.vertical, 14)
                            
                            Divider()
                            
                            HStack {
                                Text("RFM Segmentation & Churn")
                                    .font(.system(size: 15, weight: .medium))
                                Spacer()
                                Text("Active")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .padding(.vertical, 14)
                        }
                        .padding(.horizontal, 24)
                        .background(Color(uiColor: .systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("NEO AI Co-Founder")
    }
}

// MARK: - Edit Profile Sheet
private struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var founderName: String
    @Binding var officialEmail: String
    @Binding var officialPhone: String
    @Binding var companyName: String
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                SwiftUI.Section {
                    TextField("Founder Full Name", text: $founderName)
                    TextField("Company Name", text: $companyName)
                    TextField("Official Email", text: $officialEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Official Phone", text: $officialPhone)
                        .keyboardType(.phonePad)
                } header: {
                    Text("Founder Information")
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                }
            }
        }
    }
}
