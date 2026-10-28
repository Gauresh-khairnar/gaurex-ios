//
//  VoiceAssistantOverlay.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Phase 2: Free On-Device Multilingual Voice AI Overlay (Hindi, Marathi, Hinglish, English)
//

import SwiftUI

public struct VoiceAssistantOverlay: View {
    @ObservedObject private var voiceAI = MultilingualVoiceAIService.shared
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    private let deepPlum = Color.gaurexDeepPlum
    private let warmGold = Color.gaurexWarmGold
    private let mistGray = Color.gaurexMistGray
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                (theme.colorScheme == .dark ? Color(red: 0.08, green: 0.08, blue: 0.10) : mistGray.opacity(0.35))
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    // MARK: - Language Selector Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(VoiceAILanguage.allCases) { lang in
                                let isSelected = voiceAI.selectedLanguage == lang
                                Button {
                                    MotionTokens.selection()
                                    voiceAI.setLanguage(lang)
                                } label: {
                                    Text(lang.displayName)
                                        .font(.system(size: 11.5, weight: isSelected ? .bold : .medium))
                                        .foregroundColor(isSelected ? .white : Color(uiColor: .label))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(isSelected ? deepPlum : Color.white)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(isSelected ? warmGold.opacity(0.6) : Color.black.opacity(0.08), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    }
                    
                    Spacer()
                    
                    // MARK: - Live Waveform Visualizer
                    HStack(spacing: 5) {
                        ForEach(0..<9) { i in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    LinearGradient(
                                        colors: [deepPlum, warmGold],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(
                                    width: 5,
                                    height: voiceAI.isListening
                                        ? max(12, voiceAI.audioLevel * CGFloat([35, 65, 45, 80, 55, 75, 40, 60, 30][i]))
                                        : 12
                                )
                                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: voiceAI.audioLevel)
                        }
                    }
                    .frame(height: 85)
                    
                    // Status & Transcript
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(voiceAI.isListening ? Color.green : warmGold)
                                .frame(width: 8, height: 8)
                            Text(voiceAI.isListening ? "Listening / बोलिए / ऐकत आहे..." : "Tap Mic to Speak")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        
                        Text(voiceAI.liveTranscript.isEmpty
                             ? (voiceAI.selectedLanguage == .hindi ? "उदा. \"आज की कमाई कितनी है?\", \"पेंडिंग बिल दिखाओ\"" :
                                voiceAI.selectedLanguage == .marathi ? "उदा. \"आजचे एकूण उत्पन्न किती?\", \"थकबाकी दाखवा\"" :
                                "e.g. \"Show today's revenue\", \"Check overdue payments\"")
                             : "\"\(voiceAI.liveTranscript)\"")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .padding(.horizontal, 32)
                    }
                    
                    // MARK: - Response Card with Speech Controls
                    if let res = voiceAI.lastResult {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(warmGold)
                                Text("NEO AI Co-Founder")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(deepPlum)
                                
                                Spacer()
                                
                                Text(res.detectedLanguage.displayName)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(deepPlum)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(warmGold.opacity(0.18))
                                    .clipShape(Capsule())
                            }
                            
                            Text(res.responseText)
                                .font(.system(size: 13.5, weight: .regular))
                                .foregroundColor(.primary)
                                .lineSpacing(3)
                            
                            // Audio Playback Controls Bar
                            HStack(spacing: 12) {
                                Button {
                                    if voiceAI.isSpeaking {
                                        voiceAI.pauseSpeaking()
                                    } else if voiceAI.isPaused {
                                        voiceAI.resumeSpeaking()
                                    } else {
                                        voiceAI.speak(res.spokenResponseText, languageOverride: res.detectedLanguage)
                                    }
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: voiceAI.isSpeaking ? "pause.fill" : "play.fill")
                                        Text(voiceAI.isSpeaking ? "Pause Audio" : (voiceAI.isPaused ? "Resume Audio" : "Listen"))
                                    }
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(deepPlum)
                                    .clipShape(Capsule())
                                }
                                
                                if voiceAI.isSpeaking || voiceAI.isPaused {
                                    Button {
                                        voiceAI.stopSpeaking()
                                    } label: {
                                        Image(systemName: "stop.fill")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.red)
                                            .padding(6)
                                            .background(Color.red.opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                }
                                
                                Spacer()
                                
                                // Free on-device badge
                                Text("100% Free On-Device AI")
                                    .font(.system(size: 9.5, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 4)
                        }
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // MARK: - Sensitive Action Confirmation Card
                    if let action = voiceAI.pendingAction, !action.isAuthorized {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.shield.fill")
                                    .foregroundColor(action.riskLevel.badgeColor)
                                Text("AUTHORIZATION REQUIRED")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(action.riskLevel.badgeColor)
                                Spacer()
                                Text(action.riskLevel.rawValue)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(action.riskLevel.badgeColor)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(action.riskLevel.badgeColor.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                            
                            Text(action.title)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text(action.description)
                                .font(.system(size: 11.5, weight: .regular))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 10) {
                                Button {
                                    voiceAI.authorizePendingAction(id: action.id)
                                    store.showToast(title: "Action Authorized by Gauresh Khairnar (OWNER)")
                                } label: {
                                    Text("Authorize as Gauresh (OWNER)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(deepPlum)
                                        .clipShape(Capsule())
                                }
                                
                                Button("Cancel") {
                                    voiceAI.cancelPendingAction()
                                }
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            }
                            .padding(.top, 4)
                        }
                        .padding(14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(action.riskLevel.badgeColor.opacity(0.4), lineWidth: 1.2)
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // MARK: - Multilingual Sample Query Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Button("🇮🇳 आज की कमाई") {
                                voiceAI.setLanguage(.hindi)
                                voiceAI.stopListeningAndProcess(explicitText: "गौरेक्स की आज की कमाई कितनी है?")
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.black.opacity(0.08), lineWidth: 1))
                            
                            Button("🚩 आजचे उत्पन्न") {
                                voiceAI.setLanguage(.marathi)
                                voiceAI.stopListeningAndProcess(explicitText: "गौरेक्सचे आजचे एकूण उत्पन्न किती आहे?")
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.black.opacity(0.08), lineWidth: 1))
                            
                            Button("⚠️ Pending Payments") {
                                voiceAI.setLanguage(.hinglish)
                                voiceAI.stopListeningAndProcess(explicitText: "Gaurex ke pending invoices dikhao")
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.black.opacity(0.08), lineWidth: 1))
                            
                            Button("👥 Workers & Payroll") {
                                voiceAI.setLanguage(.english)
                                voiceAI.stopListeningAndProcess(explicitText: "Show total workers and monthly payroll")
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.black.opacity(0.08), lineWidth: 1))
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    // MARK: - Primary Tap-To-Talk Microphone Capsule
                    Button {
                        let feedback = UIImpactFeedbackGenerator(style: .medium)
                        feedback.impactOccurred()
                        if voiceAI.isListening {
                            voiceAI.stopListeningAndProcess()
                        } else {
                            voiceAI.startListening()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(voiceAI.isListening ? warmGold.opacity(0.25) : deepPlum.opacity(0.12))
                                .frame(width: 76, height: 76)
                            
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: voiceAI.isListening
                                            ? [warmGold, Color(red: 0.95, green: 0.70, blue: 0.10)]
                                            : [deepPlum, Color(red: 0.22, green: 0.05, blue: 0.20)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 62, height: 62)
                                .shadow(color: deepPlum.opacity(0.35), radius: 8, y: 4)
                            
                            Image(systemName: voiceAI.isListening ? "stop.fill" : "mic.fill")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 14)
                }
            }
            .navigationTitle("Multilingual Voice Co-Founder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        voiceAI.stopSpeaking()
                        voiceAI.stopListening()
                        dismiss()
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(deepPlum)
                }
            }
        }
        .onAppear {
            if !voiceAI.isListening {
                voiceAI.startListening()
            }
        }
        .onDisappear {
            voiceAI.stopSpeaking()
            voiceAI.stopListening()
        }
    }
}
