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
    
    @State private var showingExportSheet = false
    @State private var exportData: Data? = nil
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // MARK: - Founder Profile Card
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 14) {
                                    Image("GaurexLogo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 52, height: 52)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .stroke(theme.glassBorderColor, lineWidth: 1)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 8) {
                                            Text(store.settings.founderName)
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(.primary)
                                            OwnerBadge()
                                        }
                                        
                                        Text("\(store.settings.companyName) • Founder & Executive")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                        
                                        Text(store.settings.officialEmail)
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .tactilePress(scale: MotionTokens.cardPressScale)
                        
                        // MARK: - Appearance & Themes
                        VStack(alignment: .leading, spacing: 10) {
                            Text("APPEARANCE & THEMES")
                                .font(TypographyTokens.sectionHeader)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                            
                            GlassCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Active Theme: \(theme.currentTheme.rawValue)")
                                        .font(.system(size: 13, weight: .semibold))
                                    
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                        ForEach(AppTheme.allCases) { th in
                                            Button {
                                                withAnimation(MotionTokens.interactiveSpring) {
                                                    theme.currentTheme = th
                                                    store.settings.activeThemeRaw = th.rawValue
                                                    store.saveSettings()
                                                }
                                                MotionTokens.selection()
                                            } label: {
                                                HStack(spacing: 8) {
                                                    Circle()
                                                        .fill(themeIndicatorColor(for: th))
                                                        .frame(width: 14, height: 14)
                                                        .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1))
                                                    
                                                    Text(th.rawValue)
                                                        .font(.system(size: 11, weight: theme.currentTheme == th ? .bold : .medium))
                                                        .foregroundColor(.primary)
                                                        .lineLimit(1)
                                                    
                                                    Spacer()
                                                    
                                                    if theme.currentTheme == th {
                                                        Image(systemName: "checkmark")
                                                            .font(.system(size: 10, weight: .bold))
                                                            .foregroundColor(theme.accentColor)
                                                    }
                                                }
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 8)
                                                .background(theme.currentTheme == th ? theme.accentColor.opacity(0.12) : theme.backgroundColor.opacity(0.5))
                                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                        .stroke(theme.currentTheme == th ? theme.accentColor.opacity(0.4) : theme.glassBorderColor, lineWidth: 1)
                                                )
                                            }
                                            .buttonStyle(.plain)
                                            .tactilePress(scale: 0.96)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // MARK: - Commercial Operations & Assets
                        VStack(alignment: .leading, spacing: 10) {
                            Text("COMMERCIAL OPERATIONS")
                                .font(TypographyTokens.sectionHeader)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                            
                            GlassCard(padding: 0) {
                                VStack(spacing: 0) {
                                    NavigationLink {
                                        PackageManagementView()
                                    } label: {
                                        SettingsMenuRow(icon: "shippingbox.fill", title: "Package Catalog", subtitle: "\(store.packages.count) active packages", color: .orange)
                                    }
                                    
                                    Divider().padding(.leading, 52).background(theme.glassBorderColor)
                                    
                                    NavigationLink {
                                        BusinessSettingsView()
                                    } label: {
                                        SettingsMenuRow(icon: "building.2.fill", title: "Business Configuration", subtitle: "GSTIN, PAN, bank wiring & legal terms", color: .blue)
                                    }
                                    
                                    Divider().padding(.leading, 52).background(theme.glassBorderColor)
                                    
                                    NavigationLink {
                                        DocumentVaultView()
                                    } label: {
                                        SettingsMenuRow(icon: "folder.fill", title: "Document Vault", subtitle: "\(store.vaultDocuments.count) stored contracts, proposals & receipts", color: .teal)
                                    }
                                    
                                    Divider().padding(.leading, 52).background(theme.glassBorderColor)
                                    
                                    NavigationLink {
                                        MultiCurrencySettingsView()
                                    } label: {
                                        SettingsMenuRow(icon: "dollarsign.circle.fill", title: "Multi-Currency Management", subtitle: "Active: \(store.activeCurrency.symbol) \(store.activeCurrency.rawValue) with benchmark rates", color: .green)
                                    }
                                    
                                    Divider().padding(.leading, 52).background(theme.glassBorderColor)
                                    
                                    NavigationLink {
                                        IntegrationsHubView()
                                    } label: {
                                        SettingsMenuRow(icon: "network", title: "Integrations Hub", subtitle: "\(store.integrations.filter { $0.isConnected }.count) providers connected (Google, AWS, AI)", color: .purple)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // MARK: - Security & Access Control
                        VStack(alignment: .leading, spacing: 10) {
                            Text("SECURITY & ACCESS CONTROL")
                                .font(TypographyTokens.sectionHeader)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                            
                            GlassCard(padding: 0) {
                                VStack(spacing: 0) {
                                    Toggle(isOn: $store.settings.biometricUnlockEnabled) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "faceid")
                                                .foregroundColor(.purple)
                                                .frame(width: 24)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Biometric Security (\(bioAuth.biometricTypeString))")
                                                    .font(.system(size: 14, weight: .semibold))
                                                Text("Require Face ID to unlock executive dashboard")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .onChange(of: store.settings.biometricUnlockEnabled) { _ in
                                        store.saveSettings()
                                    }
                                    
                                    Divider().padding(.leading, 52).background(theme.glassBorderColor)
                                    
                                    NavigationLink {
                                        AuditLogsView()
                                    } label: {
                                        SettingsMenuRow(icon: "shield.lefthalf.filled", title: "Activity Audit Trail Ledger", subtitle: "Immutable log of all financial & administrative events", color: .indigo)
                                    }
                                    
                                    Divider().padding(.leading, 52).background(theme.glassBorderColor)
                                    
                                    Button {
                                        bioAuth.lockApp()
                                    } label: {
                                        SettingsMenuRow(icon: "lock.fill", title: "Lock Application Now", subtitle: "Immediate session termination", color: .red)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // MARK: - Full Business JSON Export
                        VStack(alignment: .leading, spacing: 10) {
                            Text("BACKUP & RECOVERY")
                                .font(TypographyTokens.sectionHeader)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                            
                            GlassCard(padding: 0) {
                                VStack(spacing: 0) {
                                    Button {
                                        exportBusinessData()
                                    } label: {
                                        SettingsMenuRow(icon: "square.and.arrow.up.fill", title: "Export Full Business JSON", subtitle: "Complete ledger, clients, invoices, payroll & tasks", color: .teal)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // MARK: - App Version
                        VStack(spacing: 4) {
                            Text("GAUREX Executive Suite v1.0.0")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Native SwiftUI • Swift Charts • PDFKit • LocalAuthentication\nEngineered for Founder Gauresh Khairnar")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                        
                        Spacer().frame(height: 80)
                    }
                    .padding(.vertical, 12)
                }
                
                ToastOverlay(toast: $store.activeToast)
            }
            .navigationTitle("Owner Control Center")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingExportSheet) {
                if let data = exportData {
                    ActivityViewController(activityItems: [data])
                }
            }
        }
    }
    
    private func themeIndicatorColor(for theme: AppTheme) -> Color {
        switch theme {
        case .system: return .gray
        case .light, .pureWhite: return .white
        case .dark, .midnight: return .black
        case .graphite: return Color(white: 0.2)
        case .oceanBlue: return Color(red: 0.1, green: 0.3, blue: 0.7)
        case .gaurexAccent: return Color(red: 0.95, green: 0.77, blue: 0.25)
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
