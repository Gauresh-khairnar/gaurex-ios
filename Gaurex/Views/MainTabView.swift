//
//  MainTabView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab: MainTab = .home
    @ObservedObject private var theme = ThemeManager.shared
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .bottom) {
                AuroraLivingBackground()
                
                Group {
                    switch selectedTab {
                    case .home:
                        DashboardView(selectedTab: $selectedTab)
                    case .tasks:
                        TasksManagementView()
                    case .finance:
                        FinanceProfitCenterView()
                    case .clients:
                        ClientsListView()
                    case .workers:
                        WorkersListView()
                    case .aiModel:
                        AIIntelligenceView()
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 72)
                }
                
                // Persistent Floating Liquid Glass Tab Bar (7 Tabs)
                LiquidGlassTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 8)
            }
            
            // Executive Interactive Dynamic Island HUD
            ExecutiveDynamicIslandHUD()
                .padding(.top, 4)
                .zIndex(100)
        }
        .onAppear {
            NeoCoFounderService.shared.greetFounderOnLaunch()
            DynamicIslandActivityService.shared.requestSystemLiveActivity()
        }
        .preferredColorScheme(theme.colorScheme)
    }
}

public struct BiometricUnlockOverlay: View {
    @ObservedObject private var bioAuth = BiometricAuthService.shared
    @ObservedObject private var theme = ThemeManager.shared
    @State private var authErrorMessage: String? = nil
    
    public init() {}
    
    public var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Image("GaurexLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(theme.glassBorderColor, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
                
                VStack(spacing: 6) {
                    HStack(spacing: 8) {
                        Text("GAUREX")
                            .font(TypographyTokens.executiveTitle)
                            .tracking(2.0)
                        OwnerBadge()
                    }
                    
                    Text("Executive Security Vault")
                        .font(TypographyTokens.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    authenticate()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "faceid")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Unlock with \(bioAuth.biometricTypeString)")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.primary)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .tactilePress()
                .padding(.horizontal, 32)
                
                if let err = authErrorMessage {
                    Text(err)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .padding(.horizontal, 32)
                }
                
                Spacer().frame(height: 40)
            }
        }
        .onAppear {
            authenticate()
        }
    }
    
    private func authenticate() {
        bioAuth.authenticateOwner { success, error in
            if !success {
                authErrorMessage = error ?? "Biometric authentication required."
            }
        }
    }
}
