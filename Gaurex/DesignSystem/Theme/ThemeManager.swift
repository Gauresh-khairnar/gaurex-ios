//
//  ThemeManager.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

// MARK: - GAUREX Phase 2 Official Brand Palette
extension Color {
    /// Mist Gray (#DDE3E8) - Premium supporting background & subtle surface
    public static let gaurexMistGray = Color(red: 0xDD / 255.0, green: 0xE3 / 255.0, blue: 0xE8 / 255.0)
    
    /// Deep Plum (#3A0F34) - Primary executive brand element & active state
    public static let gaurexDeepPlum = Color(red: 0x3A / 255.0, green: 0x0F / 255.0, blue: 0x34 / 255.0)
    
    /// Warm Gold (#EAAA00) - Precious highlight & status indicator
    public static let gaurexWarmGold = Color(red: 0xEA / 255.0, green: 0xAA / 255.0, blue: 0x00 / 255.0)
}

public enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Pure Light"
    case dark = "Studio Dark"
    case purple = "Purple"
    case gold = "Gold"
    case midnight = "Midnight Black"
    case pureWhite = "Pure White"
    case graphite = "Graphite Slate"
    case oceanBlue = "Ocean Blue"
    case gaurexAccent = "GAUREX Executive"
    
    public var id: String { rawValue }
}

public class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()
    
    @AppStorage("gaurex_selected_theme") public var currentThemeRaw: String = AppTheme.system.rawValue {
        didSet {
            objectWillChange.send()
        }
    }
    
    public var currentTheme: AppTheme {
        get { AppTheme(rawValue: currentThemeRaw) ?? .system }
        set { currentThemeRaw = newValue.rawValue }
    }
    
    public var colorScheme: ColorScheme? {
        switch currentTheme {
        case .system: return nil
        case .light, .pureWhite: return .light
        case .dark, .midnight, .graphite, .oceanBlue, .gaurexAccent, .purple, .gold: return .dark
        }
    }
    
    // Background Colors
    public var backgroundColor: Color {
        switch currentTheme {
        case .system:
            return Color(uiColor: .systemGroupedBackground)
        case .light:
            return Color(red: 0.96, green: 0.97, blue: 0.98)
        case .pureWhite:
            return Color.white
        case .dark:
            return Color(red: 0.08, green: 0.08, blue: 0.09)
        case .purple:
            return Color(red: 0.10, green: 0.05, blue: 0.16)
        case .gold:
            return Color(red: 0.08, green: 0.07, blue: 0.05)
        case .midnight:
            return Color.black
        case .graphite:
            return Color(red: 0.11, green: 0.12, blue: 0.13)
        case .oceanBlue:
            return Color(red: 0.04, green: 0.07, blue: 0.14)
        case .gaurexAccent:
            return Color(red: 0.05, green: 0.05, blue: 0.06)
        }
    }
    
    // Card Surface Colors
    public var cardBackground: Color {
        switch currentTheme {
        case .system:
            return Color(uiColor: .secondarySystemGroupedBackground)
        case .light:
            return Color.white
        case .pureWhite:
            return Color(red: 0.98, green: 0.98, blue: 0.99)
        case .dark:
            return Color(red: 0.13, green: 0.13, blue: 0.15)
        case .purple:
            return Color(red: 0.16, green: 0.09, blue: 0.24)
        case .gold:
            return Color(red: 0.15, green: 0.13, blue: 0.09)
        case .midnight:
            return Color(red: 0.08, green: 0.08, blue: 0.09)
        case .graphite:
            return Color(red: 0.16, green: 0.17, blue: 0.19)
        case .oceanBlue:
            return Color(red: 0.09, green: 0.13, blue: 0.23)
        case .gaurexAccent:
            return Color(red: 0.10, green: 0.10, blue: 0.12)
        }
    }
    
    // Brand Accent Color
    public var accentColor: Color {
        switch currentTheme {
        case .system, .light, .dark, .pureWhite, .midnight, .graphite:
            return Color.primary
        case .purple:
            return Color(red: 0.70, green: 0.40, blue: 0.95)
        case .gold:
            return Color(red: 0.90, green: 0.65, blue: 0.15)
        case .oceanBlue:
            return Color(red: 0.22, green: 0.65, blue: 0.98)
        case .gaurexAccent:
            return Color(red: 0.95, green: 0.77, blue: 0.25) // Luxe subtle gold/brass accent
        }
    }
    
    // Glass Border
    public var glassBorderColor: Color {
        switch currentTheme {
        case .pureWhite, .light:
            return Color.black.opacity(0.08)
        default:
            return Color.white.opacity(0.12)
        }
    }
}
