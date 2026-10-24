//
//  GaurexApp.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

@main
struct GaurexApp: App {
    @StateObject private var store = FirestoreDataStore.shared
    @StateObject private var theme = ThemeManager.shared
    @StateObject private var bioAuth = BiometricAuthService.shared
    
    @State private var hasCompletedLaunchIntro = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if !hasCompletedLaunchIntro {
                    AppLaunchExperienceView {
                        withAnimation(MotionTokens.interactiveSpring) {
                            hasCompletedLaunchIntro = true
                        }
                    }
                } else if store.settings.biometricUnlockEnabled && !bioAuth.isUnlocked {
                    BiometricUnlockOverlay()
                        .transition(.opacity)
                } else {
                    MainTabView()
                        .transition(.opacity)
                }
            }
            .environmentObject(store)
            .environmentObject(theme)
            .environmentObject(bioAuth)
            .preferredColorScheme(theme.colorScheme)
        }
    }
}
