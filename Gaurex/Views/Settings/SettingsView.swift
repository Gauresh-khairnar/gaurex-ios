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
    @State private var showingClearConfirmation = false
    
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
                        
                        // MARK: - Appearance & Themes
                        VStack(alignment: .leading, spacing: 10) {
                            Text("APPEARANCE & THEMES")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                            
                            GlassCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Active Interface Theme: \(theme.currentTheme.rawValue)")
                                        .font(.system(size: 13, weight: .semibold))
                                    
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                        ForEach(AppTheme.allCases) { th in
                                            Button {
                                                withAnimation(.easeInOut(duration: 0.25)) {
                                                    theme.currentTheme = th
                                                    store.settings.activeThemeRaw = th.rawValue
                                                    store.saveSettings()
                                                }
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
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // MARK: - Commercial Operations
                        VStack(alignment: .leading, spacing: 10) {
                            Text("COMMERCIAL OPERATIONS")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
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
                                        SettingsMenuRow(icon: "building.2.fill", title: "Business Configuration", subtitle: "GSTIN, PAN, bank details & legal terms", color: .blue)
                                    }
                                    
                                    Divider().padding(.leading, 52).background(theme.glassBorderColor)
                                    
                                    NavigationLink {
                                        InvoicesListView()
                                    } label: {
                                        SettingsMenuRow(icon: "doc.text.fill", title: "Invoice Registry", subtitle: "\(store.invoices.count) invoices on file", color: .green)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // MARK: - Security & Authentication
                        VStack(alignment: .leading, spacing: 10) {
                            Text("SECURITY & ACCESS CONTROL")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
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
                                                Text("Require authentication to unlock executive suite")
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
                                        SettingsMenuRow(icon: "shield.lefthalf.filled", title: "Audit Trail Ledger", subtitle: "Immutable log of all financial & admin events", color: .indigo)
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
                        
                        // MARK: - Data Management & Backup
                        VStack(alignment: .leading, spacing: 10) {
                            Text("BACKUP & EXPORT")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                            
                            GlassCard(padding: 0) {
                                VStack(spacing: 0) {
                                    Button {
                                        exportBusinessData()
                                    } label: {
                                        SettingsMenuRow(icon: "square.and.arrow.up.fill", title: "Export Full Business JSON", subtitle: "Complete ledger, clients, invoices & payroll", color: .teal)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // MARK: - App Information
                        VStack(spacing: 6) {
                            Text("GAUREX Executive Suite v1.0.0")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.primary)
                            Text("Built with Native SwiftUI, Swift Charts & PDFKit\nDeveloped for Founder Gauresh Khairnar")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                        
                        Spacer().frame(height: 80)
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Owner Settings")
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

public struct SettingsMenuRow: View {
    public var icon: String
    public var title: String
    public var subtitle: String
    public var color: Color
    
    public var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
