//
//  TypographyTokens.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Plus Jakarta Sans - Stylish geometric typography with premium startup aesthetic
//

import SwiftUI

// MARK: - Plus Jakarta Sans Font Extensions
extension Font {
    /// Loads Plus Jakarta Sans with the specified size and weight, falling back gracefully to system rounded font
    public static func pjs(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .black, .heavy:
            fontName = "PlusJakartaSans-ExtraBold"
        case .bold:
            fontName = "PlusJakartaSans-Bold"
        case .semibold:
            fontName = "PlusJakartaSans-SemiBold"
        case .medium:
            fontName = "PlusJakartaSans-Medium"
        default:
            fontName = "PlusJakartaSans-Regular"
        }
        return .custom(fontName, size: size)
    }
}

public enum TypographyTokens {
    // Large Executive Dashboard Headers
    public static let executiveTitle = Font.pjs(26, weight: .bold)
    
    // Section Headers
    public static let sectionHeader = Font.pjs(12, weight: .bold)
    
    // Financial Metrics & Numbers (Tabular Figures)
    public static let metricLarge = Font.pjs(24, weight: .bold)
    public static let metricMedium = Font.pjs(18, weight: .bold)
    public static let metricSmall = Font.pjs(13, weight: .semibold)
    
    // Body & Labels
    public static let bodyPrimary = Font.pjs(14, weight: .regular)
    public static let bodySemibold = Font.pjs(14, weight: .semibold)
    public static let caption = Font.pjs(11, weight: .medium)
    public static let code = Font.system(size: 11, weight: .bold, design: .monospaced)
}

// MARK: - Animated Number View (With Tabular Digits & Fluid Numeric Transitions)
public struct AnimatedNumberView: View {
    public var value: Double
    public var prefix: String
    public var suffix: String
    public var specifier: String
    public var font: Font
    public var color: Color
    
    public init(
        value: Double,
        prefix: String = "",
        suffix: String = "",
        specifier: String = "%.2f",
        font: Font = TypographyTokens.metricLarge,
        color: Color = .primary
    ) {
        self.value = value
        self.prefix = prefix
        self.suffix = suffix
        self.specifier = specifier
        self.font = font
        self.color = color
    }
    
    public var body: some View {
        HStack(spacing: 1) {
            if !prefix.isEmpty {
                Text(prefix)
                    .font(font)
                    .foregroundColor(color)
            }
            
            Text(String(format: specifier, value))
                .font(font)
                .monospacedDigit()
                .foregroundColor(color)
                .contentTransition(.numericText(value: value))
            
            if !suffix.isEmpty {
                Text(suffix)
                    .font(font)
                    .foregroundColor(color)
            }
        }
    }
}
