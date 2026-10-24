//
//  TypographyTokens.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public enum TypographyTokens {
    // Large Executive Dashboard Headers
    public static let executiveTitle = Font.system(size: 26, weight: .black, design: .rounded)
    
    // Section Headers
    public static let sectionHeader = Font.system(size: 11, weight: .bold, design: .rounded)
    
    // Financial Metrics & Numbers (Tabular Figures)
    public static let metricLarge = Font.system(size: 22, weight: .bold, design: .rounded)
    public static let metricMedium = Font.system(size: 16, weight: .bold, design: .rounded)
    public static let metricSmall = Font.system(size: 13, weight: .semibold, design: .rounded)
    
    // Body & Labels
    public static let bodyPrimary = Font.system(size: 14, weight: .regular)
    public static let bodySemibold = Font.system(size: 14, weight: .semibold)
    public static let caption = Font.system(size: 11, weight: .medium)
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
