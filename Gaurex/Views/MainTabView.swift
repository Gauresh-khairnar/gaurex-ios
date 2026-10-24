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
            // Tab content container
            Group {
                switch selectedTab {
                case .home:
                    DashboardView(selectedTab: $selectedTab)
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
            
            // Persistent Floating Liquid Glass Tab Bar
            LiquidGlassTabBar(selectedTab: $selectedTab)
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
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .tracking(2.0)
                        OwnerBadge()
                    }
                    
                    Text("Executive Security Vault")
                        .font(.system(size: 13, weight: .medium))
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
