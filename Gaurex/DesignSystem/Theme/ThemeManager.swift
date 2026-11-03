//
//  ThemeManager.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Executive Theme & Accent Color Manager with War Game Simulation
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
    
    // Backwards Compatibility Aliases
    public static let deepPurple = gaurexDeepPlum
    public static let goldAccent = gaurexWarmGold
    
    // Spacious Apple Bezel Padding
    public static let bezelPadding: CGFloat = 24.0
}

// MARK: - Executive Application Accent Colors
public enum AppAccentColor: String, CaseIterable, Identifiable {
    case plum = "Imperial Plum"
    case gold = "24K Bullion Gold"
    case sapphire = "Cyber Sapphire"
    case emerald = "Emerald Vault"
    case ruby = "Crimson Ruby"
    case amethyst = "Royal Amethyst"
    case amber = "Sunset Amber"
    case cyan = "Cyber Cyan"
    
    public var id: String { rawValue }
    
    public var color: Color {
        switch self {
        case .plum:
            return Color.gaurexDeepPlum
        case .gold:
            return Color.gaurexWarmGold
        case .sapphire:
            return Color(red: 0x1E / 255.0, green: 0x60 / 255.0, blue: 0xFF / 255.0)
        case .emerald:
            return Color(red: 0x0F / 255.0, green: 0xA9 / 255.0, blue: 0x58 / 255.0)
        case .ruby:
            return Color(red: 0xE0 / 255.0, green: 0x24 / 255.0, blue: 0x5E / 255.0)
        case .amethyst:
            return Color(red: 0x8B / 255.0, green: 0x5C / 255.0, blue: 0xF6 / 255.0)
        case .amber:
            return Color(red: 0xF5 / 255.0, green: 0x9E / 255.0, blue: 0x0B / 255.0)
        case .cyan:
            return Color(red: 0x06 / 255.0, green: 0xB6 / 255.0, blue: 0xD4 / 255.0)
        }
    }
    
    public var hexString: String {
        switch self {
        case .plum: return "#3A0F34"
        case .gold: return "#EAAA00"
        case .sapphire: return "#1E60FF"
        case .emerald: return "#0FA958"
        case .ruby: return "#E0245E"
        case .amethyst: return "#8B5CF6"
        case .amber: return "#F59E0B"
        case .cyan: return "#06B6D4"
        }
    }
}

// MARK: - Supported Themes
public enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System Dynamic"
    case light = "Pure Light"
    case dark = "Studio Dark"
    case midnight = "Obsidian Midnight"
    case gaurexAccent = "GAUREX Executive"
    case gold = "24K Bullion Gold"
    case purple = "Imperial Plum"
    case oceanBlue = "Cyber Sapphire"
    case graphite = "Graphite Slate"
    case pureWhite = "Crisp Minimal"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .system: return "iphone"
        case .light, .pureWhite: return "sun.max.fill"
        case .dark: return "moon.stars.fill"
        case .midnight: return "circle.slash.fill"
        case .gaurexAccent: return "shield.fill"
        case .gold: return "crown.fill"
        case .purple: return "sparkles"
        case .oceanBlue: return "water.waves"
        case .graphite: return "square.stack.3d.down.right.fill"
        }
    }
    
    public var subtitle: String {
        switch self {
        case .system: return "Follows iOS System Appearance"
        case .light: return "Clean Mist Gray & Crisp White"
        case .dark: return "Deep Studio Obsidian Contrast"
        case .midnight: return "Pure OLED True Black"
        case .gaurexAccent: return "Royal Plum with Warm Gold Trim"
        case .gold: return "Gilded 24K Bullion Luxury"
        case .purple: return "Rich Amethyst Velvet Surfaces"
        case .oceanBlue: return "Deep Electric Oceanic Depth"
        case .graphite: return "Matte Stealth Slate Texture"
        case .pureWhite: return "Architectural Monochrome Finish"
        }
    }
}

public class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()
    public static let bezelPadding: CGFloat = 24.0
    
    // MARK: - Persistent Theme Selection
    @AppStorage("gaurex_selected_theme") public var currentThemeRaw: String = AppTheme.gaurexAccent.rawValue {
        didSet {
            objectWillChange.send()
        }
    }
    
    // MARK: - Persistent Accent Color Selection
    @AppStorage("gaurex_accent_color") public var currentAccentColorRaw: String = AppAccentColor.gold.rawValue {
        didSet {
            objectWillChange.send()
        }
    }
    
    // MARK: - War Game Simulation Mode State
    @AppStorage("gaurex_war_game_active") public var isWarGameActive: Bool = false {
        didSet {
            objectWillChange.send()
        }
    }
    
    @AppStorage("gaurex_war_game_defcon") public var warGameDefconLevel: Int = 1 {
        didSet {
            objectWillChange.send()
        }
    }
    
    public var currentTheme: AppTheme {
        get { AppTheme(rawValue: currentThemeRaw) ?? .gaurexAccent }
        set { currentThemeRaw = newValue.rawValue }
    }
    
    public var currentAccentColor: AppAccentColor {
        get { AppAccentColor(rawValue: currentAccentColorRaw) ?? .gold }
        set { currentAccentColorRaw = newValue.rawValue }
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
            return Color(red: 0.95, green: 0.96, blue: 0.98)
        case .pureWhite:
            return Color(red: 0.99, green: 0.99, blue: 1.0)
        case .dark:
            return Color(red: 0.07, green: 0.07, blue: 0.09)
        case .purple:
            return Color(red: 0.09, green: 0.03, blue: 0.12)
        case .gold:
            return Color(red: 0.08, green: 0.07, blue: 0.04)
        case .midnight:
            return Color.black
        case .graphite:
            return Color(red: 0.09, green: 0.10, blue: 0.12)
        case .oceanBlue:
            return Color(red: 0.03, green: 0.06, blue: 0.13)
        case .gaurexAccent:
            return Color(red: 0.06, green: 0.02, blue: 0.08)
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
            return Color(red: 0.97, green: 0.97, blue: 0.99)
        case .dark:
            return Color(red: 0.12, green: 0.12, blue: 0.15)
        case .purple:
            return Color(red: 0.16, green: 0.08, blue: 0.22)
        case .gold:
            return Color(red: 0.15, green: 0.13, blue: 0.08)
        case .midnight:
            return Color(red: 0.07, green: 0.07, blue: 0.08)
        case .graphite:
            return Color(red: 0.14, green: 0.16, blue: 0.19)
        case .oceanBlue:
            return Color(red: 0.08, green: 0.12, blue: 0.22)
        case .gaurexAccent:
            return Color(red: 0.14, green: 0.06, blue: 0.17)
        }
    }
    
    // Dynamic Active Brand Accent Color
    public var accentColor: Color {
        return currentAccentColor.color
    }
    
    public var activeBrandColor: Color {
        return currentAccentColor.color
    }
    
    // Glass Border Color
    public var glassBorderColor: Color {
        switch currentTheme {
        case .pureWhite, .light:
            return Color.black.opacity(0.08)
        case .gold:
            return Color.gaurexWarmGold.opacity(0.25)
        case .purple, .gaurexAccent:
            return Color.gaurexWarmGold.opacity(0.20)
        default:
            return Color.white.opacity(0.12)
        }
    }
    
    // Primary Text Color
    public var primaryTextColor: Color {
        switch currentTheme {
        case .light, .pureWhite:
            return Color(red: 0.08, green: 0.08, blue: 0.10)
        default:
            return Color.white
        }
    }
    
    // Secondary Text Color
    public var secondaryTextColor: Color {
        switch currentTheme {
        case .light, .pureWhite:
            return Color(red: 0.40, green: 0.42, blue: 0.46)
        default:
            return Color.white.opacity(0.65)
        }
    }
}
