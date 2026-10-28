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
        .onAppear {
            NeoCoFounderService.shared.greetFounderOnLaunch()
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
            AuroraLivingBackground()
            
            VStack(spacing: 24) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.gaurexDeepPlum)
                        .frame(width: 90, height: 90)
                        .overlay(Circle().stroke(Color.gaurexWarmGold.opacity(0.8), lineWidth: 2))
                    
                    Image(systemName: "faceid")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundColor(Color.gaurexWarmGold)
                }
                
                VStack(spacing: 8) {
                    Text("GAUREX Executive Vault")
                        .font(.pjs(22, weight: .bold))
                        .foregroundColor(theme.colorScheme == .dark ? .white : Color.gaurexDeepPlum)
                    
                    Text("Founder authentication required")
                        .font(.pjs(13, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("Founder & Owner: Gauresh Khairnar (OWNER)")
                        .font(.pjs(11, weight: .semibold))
                        .foregroundColor(Color.gaurexWarmGold)
                        .padding(.top, 4)
                }
                
                if let err = authErrorMessage {
                    Text(err)
                        .font(.pjs(12, weight: .semibold))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    bioAuth.authenticateUser { success, error in
                        if !success {
                            authErrorMessage = error ?? "Biometric verification unsuccessful"
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "faceid")
                        Text("Authenticate with Face ID")
                    }
                    .font(.pjs(14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color.gaurexDeepPlum)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.gaurexWarmGold.opacity(0.5), lineWidth: 1))
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            bioAuth.authenticateUser { success, error in
                if !success {
                    authErrorMessage = error
                }
            }
        }
    }
}
