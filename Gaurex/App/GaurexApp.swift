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
    
    var body: some Scene {
        WindowGroup {
            Group {
                if store.settings.biometricUnlockEnabled && !bioAuth.isUnlocked {
                    BiometricUnlockOverlay()
                } else {
                    MainTabView()
                }
            }
            .environmentObject(store)
            .environmentObject(theme)
            .environmentObject(bioAuth)
            .preferredColorScheme(theme.colorScheme)
        }
    }
}
