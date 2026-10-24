//
//  VoiceAssistantOverlay.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct VoiceAssistantOverlay: View {
    @ObservedObject private var voiceService = VoiceAssistantService.shared
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Waveform Visualizer
                    HStack(spacing: 6) {
                        ForEach(0..<7) { i in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(theme.accentColor)
                                .frame(width: 6, height: voiceService.isListening ? max(12, voiceService.audioLevel * CGFloat(i % 2 == 0 ? 60 : 40)) : 12)
                                .animation(MotionTokens.interactiveSpring, value: voiceService.audioLevel)
                        }
                    }
                    .frame(height: 70)
                    
                    VStack(spacing: 8) {
                        Text(voiceService.isListening ? "Listening for Executive Command..." : "Tap to Speak")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(voiceService.liveTranscript.isEmpty ? "e.g. \"Show my overdue invoices\", \"Plan my day\", \"Show revenue collected\"" : "\"\(voiceService.liveTranscript)\"")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    if let res = voiceService.lastResult {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(theme.accentColor)
                                    Text("GAUREX Voice Engine")
                                        .font(.system(size: 13, weight: .bold))
                                    Spacer()
                                    OwnerBadge()
                                }
                                
                                Text(res.responseText)
                                    .font(.system(size: 13))
                                    .foregroundColor(.primary)
                                
                                if res.requiresConfirmation, let action = res.proposedActionSummary {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("CONFIRMATION REQUIRED")
                                            .font(TypographyTokens.caption)
                                            .foregroundColor(.orange)
                                        Text(action)
                                            .font(.system(size: 12, weight: .semibold))
                                        
                                        Button("Confirm & Execute") {
                                            store.showToast(title: "Voice Command Executed")
                                            dismiss()
                                        }
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(Color.primary)
                                        .clipShape(Capsule())
                                        .padding(.top, 4)
                                    }
                                    .padding(8)
                                    .background(theme.backgroundColor.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Suggested Voice Queries
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Button("🚗 Fortuner Target") {
                                voiceService.stopListeningAndProcess(spokenQuery: "🚗 Fortuner target status")
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.yellow.opacity(0.12))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.yellow.opacity(0.3), lineWidth: 1))
                            
                            Button("Show Overdue Invoices") {
                                voiceService.stopListeningAndProcess(spokenQuery: "Show my overdue invoices")
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(theme.cardBackground)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(theme.glassBorderColor, lineWidth: 1))
                            
                            Button("Plan My Day") {
                                voiceService.stopListeningAndProcess(spokenQuery: "Plan my day")
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(theme.cardBackground)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(theme.glassBorderColor, lineWidth: 1))
                            
                            Button("Revenue Collected") {
                                voiceService.stopListeningAndProcess(spokenQuery: "Total revenue collected")
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(theme.cardBackground)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(theme.glassBorderColor, lineWidth: 1))
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer()
                    
                    // Microphone Activation Button
                    VStack(spacing: 12) {
                        Button {
                            if voiceService.isListening {
                                voiceService.stopListeningAndProcess()
                            } else {
                                voiceService.startListening()
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(voiceService.isListening ? Color.red : Color.primary)
                                    .frame(width: 72, height: 72)
                                    .shadow(color: (voiceService.isListening ? Color.red : Color.primary).opacity(0.3), radius: 12, x: 0, y: 6)
                                
                                Image(systemName: voiceService.isListening ? "stop.fill" : "mic.fill")
                                    .font(.system(size: 26, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(.plain)
                        .tactilePress(scale: 0.92)
                        
                        if voiceService.isSpeaking {
                            Button {
                                voiceService.stopSpeaking()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "speaker.slash.fill")
                                    Text("Stop Speaking")
                                }
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer().frame(height: 30)
                }
            }
            .navigationTitle("Voice Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
            }
        }
    }
}
