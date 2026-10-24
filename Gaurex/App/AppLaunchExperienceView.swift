//
//  AppLaunchExperienceView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct AppLaunchExperienceView: View {
    @ObservedObject private var theme = ThemeManager.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @State private var logoScale: CGFloat = 0.88
    @State private var logoOpacity: Double = 0.0
    @State private var lightSweepPhase: CGFloat = -1.0
    
    public var onFinished: () -> Void
    
    public init(onFinished: @escaping () -> Void) {
        self.onFinished = onFinished
    }
    
    public var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Image("GaurexLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 88, height: 88)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(theme.glassBorderColor, lineWidth: 1.2)
                        )
                        .shadow(color: Color.black.opacity(0.14), radius: 16, x: 0, y: 8)
                    
                    // Restrained light sweep effect
                    if !reduceMotion {
                        GeometryReader { geo in
                            LinearGradient(
                                colors: [Color.clear, Color.white.opacity(0.35), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .frame(width: geo.size.width * 1.5, height: geo.size.height)
                            .offset(x: lightSweepPhase * geo.size.width)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .frame(width: 88, height: 88)
                    }
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                VStack(spacing: 4) {
                    HStack(spacing: 8) {
                        Text("GAUREX")
                            .font(TypographyTokens.executiveTitle)
                            .tracking(2.5)
                        OwnerBadge()
                    }
                    
                    Text("Executive Business OS")
                        .font(TypographyTokens.caption)
                        .foregroundColor(.secondary)
                }
                .opacity(logoOpacity)
            }
        }
        .onAppear {
            if reduceMotion {
                logoOpacity = 1.0
                logoScale = 1.0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    onFinished()
                }
            } else {
                withAnimation(.easeOut(duration: 0.5)) {
                    logoOpacity = 1.0
                    logoScale = 1.0
                }
                
                withAnimation(.easeInOut(duration: 0.8).delay(0.2)) {
                    lightSweepPhase = 1.2
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        onFinished()
                    }
                }
            }
        }
    }
}
