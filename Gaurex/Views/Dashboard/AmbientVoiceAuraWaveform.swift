//
//  AmbientVoiceAuraWaveform.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Ambient Voice Aura Waveform: Audio-Reactive Gold & Deep Plum Liquid Glass Visualizer
//

import SwiftUI

public struct AmbientVoiceAuraWaveform: View {
    @ObservedObject private var neo = NeoCoFounderService.shared
    @Environment(\.colorScheme) private var colorScheme
    @State private var auraPulse = false
    @State private var showingLangPicker = false
    
    private let deepPurple = Color.gaurexDeepPlum
    private let goldAccent = Color.gaurexWarmGold
    
    public init() {}
    
    public var body: some View {
        if neo.isSpeaking {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    // Left: Glowing Live Audio Indicator
                    HStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(goldAccent.opacity(0.35))
                                .frame(width: 22, height: 22)
                                .scaleEffect(auraPulse ? 1.35 : 0.85)
                                .opacity(auraPulse ? 0.3 : 0.8)
                            
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [goldAccent, deepPurple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 14, height: 14)
                            
                            Image(systemName: "waveform")
                                .font(.system(size: 8, weight: .black))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 1) {
                            HStack(spacing: 4) {
                                Text("NEO VOX")
                                    .font(.pjs(10, weight: .black))
                                    .tracking(1.2)
                                    .foregroundColor(goldAccent)
                                
                                Text("• LIVE")
                                    .font(.pjs(9, weight: .bold))
                                    .foregroundColor(.green)
                            }
                            
                            Text(neo.currentBriefingLanguage.rawValue.uppercased())
                                .font(.pjs(8.5, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : deepPurple.opacity(0.8))
                        }
                    }
                    
                    // Center: Audio-Reactive Harmonic Frequency Bars
                    HStack(alignment: .center, spacing: 2.8) {
                        ForEach(0..<neo.harmonicWaveformLevels.count, id: \.self) { index in
                            let height = max(4.0, neo.harmonicWaveformLevels[index] * 24.0)
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(
                                    LinearGradient(
                                        colors: [goldAccent, deepPurple],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 3.2, height: height)
                                .shadow(color: goldAccent.opacity(0.35), radius: 2, x: 0, y: 0)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 28)
                    
                    // Right: Language Switcher & Stop / Mute Action
                    HStack(spacing: 8) {
                        Menu {
                            ForEach(NeoCoFounderService.BriefingLanguage.allCases) { lang in
                                Button {
                                    neo.currentBriefingLanguage = lang
                                    neo.greetFounderOnLaunch(force: true)
                                } label: {
                                    HStack {
                                        Text(lang.rawValue)
                                        if neo.currentBriefingLanguage == lang {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "globe")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(goldAccent)
                                .padding(6)
                                .background(Circle().fill(deepPurple.opacity(0.2)))
                        }
                        
                        Button {
                            MotionTokens.impact(style: .medium)
                            neo.stopSpeaking()
                        } label: {
                            Image(systemName: "stop.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(deepPurple)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        // Liquid Glass Fill
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                colorScheme == .dark
                                    ? Color(red: 0.16, green: 0.12, blue: 0.20).opacity(0.88)
                                    : Color.white.opacity(0.92)
                            )
                        
                        // Shimmering Plum-Gold Border Aura
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        goldAccent.opacity(0.9),
                                        deepPurple.opacity(0.7),
                                        goldAccent.opacity(0.4)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1.4
                            )
                    }
                )
                .shadow(color: goldAccent.opacity(0.18), radius: 12, x: 0, y: 4)
                .padding(.horizontal, 24)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.94, anchor: .top).combined(with: .opacity).combined(with: .move(edge: .top)),
                    removal: .scale(scale: 0.96, anchor: .top).combined(with: .opacity).combined(with: .move(edge: .top))
                ))
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    auraPulse = true
                }
            }
        }
    }
}
