//
//  ExecutiveDynamicIslandHUD.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Pixel-Perfect Interactive Dynamic Island HUD with 5 Executive Modes
//

import SwiftUI

public struct ExecutiveDynamicIslandHUD: View {
    @ObservedObject private var islandService = DynamicIslandActivityService.shared
    @ObservedObject private var neoVoice = NeoCoFounderService.shared
    @ObservedObject private var store = FirestoreDataStore.shared
    @Environment(\.colorScheme) private var colorScheme
    
    private let deepPlum = Color.gaurexDeepPlum
    private let warmGold = Color.gaurexWarmGold
    private let mistGray = Color.gaurexMistGray
    
    @State private var orbRotation: Double = 0
    @State private var haloPulse: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if islandService.isExpanded {
                    expandedIslandView
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.85, anchor: .top).combined(with: .opacity),
                            removal: .scale(scale: 0.9, anchor: .top).combined(with: .opacity)
                        ))
                } else {
                    compactIslandPill
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.9, anchor: .top).combined(with: .opacity),
                            removal: .scale(scale: 0.85, anchor: .top).combined(with: .opacity)
                        ))
                }
            }
            .animation(.spring(response: 0.38, dampingFraction: 0.78), value: islandService.isExpanded)
            .animation(.spring(response: 0.34, dampingFraction: 0.76), value: islandService.currentState.mode)
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onEnded { value in
                        if value.translation.height > 20 && !islandService.isExpanded {
                            islandService.toggleExpand()
                        } else if value.translation.height < -15 && islandService.isExpanded {
                            islandService.collapse()
                        }
                    }
            )
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .padding(.top, 2)
    }
    
    // MARK: - 1. Compact Dynamic Island Hardware Pill
    private var compactIslandPill: some View {
        Button {
            islandService.toggleExpand()
        } label: {
            HStack(spacing: 8) {
                // Leading Island Element
                leadingCompactElement
                
                Spacer(minLength: 8)
                
                // Trailing Island Element
                trailingCompactElement
            }
            .padding(.horizontal, 12)
            .frame(width: compactWidthForMode, height: 38)
            .background(
                Capsule()
                    .fill(Color.black)
                    .shadow(color: Color.black.opacity(0.35), radius: 10, y: 4)
            )
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.18),
                                Color.white.opacity(0.04)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.8
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private var compactWidthForMode: CGFloat {
        switch islandService.currentState.mode {
        case .neoVoice: return 205
        case .cashInflow: return 210
        case .focusTimer: return 195
        case .revenueRunway: return 200
        case .securityAuth: return 185
        }
    }
    
    // MARK: - Leading Compact Elements
    @ViewBuilder
    private var leadingCompactElement: some View {
        switch islandService.currentState.mode {
        case .neoVoice:
            HStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [deepPlum, Color(red: 0.16, green: 0.04, blue: 0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 22, height: 22)
                        .overlay(Circle().stroke(warmGold.opacity(0.6), lineWidth: 1))
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(warmGold)
                        .rotationEffect(.degrees(orbRotation))
                }
                
                Text("NEO")
                    .font(.pjs(11.5, weight: .bold))
                    .foregroundColor(.white)
            }
            
        case .cashInflow:
            HStack(spacing: 5) {
                Circle()
                    .fill(Color(red: 0.06, green: 0.72, blue: 0.44))
                    .frame(width: 8, height: 8)
                    .shadow(color: Color(red: 0.06, green: 0.72, blue: 0.44).opacity(0.8), radius: 3)
                
                Text("Cash In")
                    .font(.pjs(11, weight: .bold))
                    .foregroundColor(Color(red: 0.06, green: 0.72, blue: 0.44))
            }
            
        case .focusTimer:
            HStack(spacing: 5) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(warmGold)
                
                Text("\(islandService.currentState.tasksCompletedCount)/\(islandService.currentState.totalTasksCount)")
                    .font(.pjs(11, weight: .bold))
                    .foregroundColor(.white)
            }
            
        case .revenueRunway:
            HStack(spacing: 5) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(warmGold)
                
                Text("Runway")
                    .font(.pjs(11, weight: .bold))
                    .foregroundColor(.white)
            }
            
        case .securityAuth:
            HStack(spacing: 5) {
                Image(systemName: "faceid")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(warmGold)
                
                Text("Vault")
                    .font(.pjs(11, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - Trailing Compact Elements
    @ViewBuilder
    private var trailingCompactElement: some View {
        switch islandService.currentState.mode {
        case .neoVoice:
            // Oscillating audio visualizer bars
            HStack(spacing: 2.2) {
                ForEach(0..<islandService.audioWaveHeights.count, id: \.self) { idx in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(warmGold)
                        .frame(width: 2.2, height: islandService.audioWaveHeights[idx])
                }
            }
            .frame(width: 28, height: 18)
            
        case .cashInflow:
            let sym = store.settings.currencySymbol
            Text("\(sym)\(Int(islandService.currentState.invoiceAmount).formatted())")
                .font(.pjs(11.5, weight: .bold))
                .foregroundColor(Color(red: 0.06, green: 0.72, blue: 0.44))
            
        case .focusTimer:
            HStack(spacing: 3) {
                Image(systemName: "timer")
                    .font(.system(size: 10))
                    .foregroundColor(Color.secondary)
                Text("\(islandService.currentState.timeRemainingMinutes)m")
                    .font(.pjs(11.5, weight: .bold))
                    .foregroundColor(warmGold)
            }
            
        case .revenueRunway:
            Text("\(Int(islandService.currentState.monthlyTargetProgress * 100))%")
                .font(.pjs(11.5, weight: .bold))
                .foregroundColor(warmGold)
            
        case .securityAuth:
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 12))
                .foregroundColor(Color(red: 0.06, green: 0.72, blue: 0.44))
        }
    }
    
    // MARK: - 2. Expanded Dynamic Island Command Center
    private var expandedIslandView: some View {
        VStack(spacing: 12) {
            // Mode Selector Bar
            HStack(spacing: 6) {
                ForEach(GaurexActivityAttributes.ActivityMode.allCases) { mode in
                    let isSelected = islandService.currentState.mode == mode
                    Button {
                        islandService.setMode(mode)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: mode.iconName)
                                .font(.system(size: 10, weight: .bold))
                            Text(mode.title)
                                .font(.pjs(10, weight: isSelected ? .bold : .medium))
                        }
                        .foregroundColor(isSelected ? warmGold : Color.white.opacity(0.6))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isSelected ? deepPlum : Color.white.opacity(0.08))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(isSelected ? warmGold.opacity(0.5) : Color.clear, lineWidth: 0.8)
                        )
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                // Collapse Button
                Button {
                    islandService.collapse()
                } label: {
                    Image(systemName: "chevron.up.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color.white.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
            
            Divider().background(Color.white.opacity(0.12)).padding(.horizontal, 12)
            
            // Mode Body
            Group {
                switch islandService.currentState.mode {
                case .neoVoice:
                    neoVoiceExpandedContent
                case .cashInflow:
                    cashInflowExpandedContent
                case .focusTimer:
                    focusTimerExpandedContent
                case .revenueRunway:
                    revenueRunwayExpandedContent
                case .securityAuth:
                    securityAuthExpandedContent
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: 360)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.black)
                .shadow(color: Color.black.opacity(0.5), radius: 18, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.22), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    // MARK: - Expanded Content 1: Neo Voice Capsule
    private var neoVoiceExpandedContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(deepPlum)
                        .frame(width: 36, height: 36)
                        .overlay(Circle().stroke(warmGold, lineWidth: 1.2))
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(warmGold)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("NEO AI Co-Founder")
                        .font(.pjs(13, weight: .bold))
                        .foregroundColor(.white)
                    Text(neoVoice.isSpeaking ? "Speaking executive briefing..." : "Standby for executive voice prompt")
                        .font(.pjs(11, weight: .regular))
                        .foregroundColor(Color.white.opacity(0.7))
                }
                
                Spacer()
                
                // Mute Toggle
                Button {
                    neoVoice.toggleMute()
                } label: {
                    Image(systemName: neoVoice.isVoiceGreetingMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(neoVoice.isVoiceGreetingMuted ? .red : warmGold)
                        .padding(8)
                        .background(Color.white.opacity(0.10))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            
            Text("\"\(islandService.currentState.neoSpeechSnippet)\"")
                .font(.pjs(12, weight: .medium))
                .foregroundColor(Color.white.opacity(0.9))
                .lineLimit(2)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            HStack(spacing: 10) {
                Button {
                    if neoVoice.isSpeaking {
                        neoVoice.stopSpeaking()
                    } else {
                        neoVoice.greetFounderOnLaunch(force: true)
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: neoVoice.isSpeaking ? "stop.fill" : "play.fill")
                        Text(neoVoice.isSpeaking ? "Stop Briefing" : "Replay Briefing")
                    }
                    .font(.pjs(11.5, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(deepPlum)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("Gauresh Khairnar (OWNER)")
                    .font(.pjs(10, weight: .bold))
                    .foregroundColor(warmGold)
            }
        }
    }
    
    // MARK: - Expanded Content 2: Cash Inflow Radar
    private var cashInflowExpandedContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            let sym = store.settings.currencySymbol
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cash Collections Radar")
                        .font(.pjs(13, weight: .bold))
                        .foregroundColor(.white)
                    Text("Latest Invoice Settlement")
                        .font(.pjs(10.5, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(sym)\(Int(islandService.currentState.invoiceAmount).formatted())")
                    .font(.pjs(17, weight: .bold))
                    .foregroundColor(Color(red: 0.06, green: 0.72, blue: 0.44))
            }
            
            HStack(spacing: 8) {
                Text(islandService.currentState.invoiceNumber)
                    .font(.pjs(11, weight: .bold))
                    .foregroundColor(.white)
                Text("•")
                    .foregroundColor(.secondary)
                Text(islandService.currentState.clientName)
                    .font(.pjs(11, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.8))
                Spacer()
                Text(islandService.currentState.invoiceStatus)
                    .font(.pjs(10, weight: .bold))
                    .foregroundColor(Color(red: 0.06, green: 0.72, blue: 0.44))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color(red: 0.06, green: 0.72, blue: 0.44).opacity(0.15))
                    .clipShape(Capsule())
            }
            .padding(8)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            HStack(spacing: 10) {
                Button {
                    islandService.collapse()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Verified in Ledger")
                    }
                    .font(.pjs(11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(deepPlum)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("Zero Settlement Delay")
                    .font(.pjs(10, weight: .medium))
                    .foregroundColor(Color(red: 0.06, green: 0.72, blue: 0.44))
            }
        }
    }
    
    // MARK: - Expanded Content 3: Focus Timer
    private var focusTimerExpandedContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Founder Velocity Focus")
                        .font(.pjs(13, weight: .bold))
                        .foregroundColor(.white)
                    Text("Active High-Leverage Milestone")
                        .font(.pjs(10.5, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.system(size: 12))
                        .foregroundColor(warmGold)
                    Text("\(islandService.currentState.timeRemainingMinutes)m")
                        .font(.pjs(16, weight: .bold))
                        .foregroundColor(warmGold)
                }
            }
            
            Text(islandService.currentState.activeTaskTitle)
                .font(.pjs(12, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.9))
                .lineLimit(2)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            HStack(spacing: 10) {
                Button {
                    islandService.completeCurrentMilestone()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                        Text("Mark Milestone Complete")
                    }
                    .font(.pjs(11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color(red: 0.06, green: 0.72, blue: 0.44))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("\(islandService.currentState.tasksCompletedCount) of \(islandService.currentState.totalTasksCount) Completed")
                    .font(.pjs(10.5, weight: .bold))
                    .foregroundColor(warmGold)
            }
        }
    }
    
    // MARK: - Expanded Content 4: Revenue Runway
    private var revenueRunwayExpandedContent: some View {
        let sym = store.settings.currencySymbol
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Monthly Revenue Goal Runway")
                        .font(.pjs(13, weight: .bold))
                        .foregroundColor(.white)
                    Text("Target: \(sym)\(Int(islandService.currentState.monthlyTargetAmount).formatted())")
                        .font(.pjs(10.5, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(Int(islandService.currentState.monthlyTargetProgress * 100))%")
                    .font(.pjs(18, weight: .bold))
                    .foregroundColor(warmGold)
            }
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [deepPlum, warmGold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(14, geo.size.width * CGFloat(islandService.currentState.monthlyTargetProgress)), height: 8)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("Collected: \(sym)\(Int(islandService.currentState.currentMonthCollected).formatted())")
                    .font(.pjs(11, weight: .bold))
                    .foregroundColor(Color(red: 0.06, green: 0.72, blue: 0.44))
                
                Spacer()
                
                Text("NEO ML: On Track")
                    .font(.pjs(10.5, weight: .bold))
                    .foregroundColor(warmGold)
            }
        }
    }
    
    // MARK: - Expanded Content 5: Security Guard
    private var securityAuthExpandedContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 16))
                        .foregroundColor(warmGold)
                    
                    Text("Executive Security Vault")
                        .font(.pjs(13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Face ID Ready")
                    .font(.pjs(10.5, weight: .bold))
                    .foregroundColor(Color(red: 0.06, green: 0.72, blue: 0.44))
            }
            
            Text(islandService.currentState.pendingActionTitle)
                .font(.pjs(12, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.9))
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            HStack {
                Button {
                    let impact = UINotificationFeedbackGenerator()
                    impact.notificationOccurred(.success)
                    islandService.collapse()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "faceid")
                        Text("Approve with Face ID")
                    }
                    .font(.pjs(11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(deepPlum)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(warmGold.opacity(0.4), lineWidth: 0.8))
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("Audit Logging Active")
                    .font(.pjs(10, weight: .regular))
                    .foregroundColor(.secondary)
            }
        }
    }
}
