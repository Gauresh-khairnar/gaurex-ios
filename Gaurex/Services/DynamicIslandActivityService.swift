//
//  DynamicIslandActivityService.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Executive Dynamic Island & Live Activities Lifecycle Orchestrator
//

import SwiftUI
import Combine
#if canImport(ActivityKit)
import ActivityKit
#endif

public final class DynamicIslandActivityService: ObservableObject {
    public static let shared = DynamicIslandActivityService()
    
    // Published State for In-App HUD and UI
    @Published public var currentState: GaurexActivityAttributes.ContentState
    @Published public var isHUDVisible: Bool = true
    @Published public var isExpanded: Bool = false
    @Published public var audioWaveHeights: [CGFloat] = [6, 12, 18, 10, 14, 8]
    
    private var waveformTimer: AnyCancellable?
    private var countdownTimer: AnyCancellable?
    
    #if canImport(ActivityKit)
    @available(iOS 16.1, *)
    private var currentSystemActivity: Activity<GaurexActivityAttributes>? {
        get { Activity<GaurexActivityAttributes>.activities.first }
    }
    #endif
    
    private init() {
        self.currentState = GaurexActivityAttributes.ContentState()
        startWaveformAnimation()
        startVelocityCountdown()
        observeSystemServices()
    }
    
    // MARK: - State Switchers
    public func setMode(_ mode: GaurexActivityAttributes.ActivityMode) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.76)) {
            currentState.mode = mode
        }
        pushStateUpdate()
    }
    
    public func toggleExpand() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
            isExpanded.toggle()
        }
    }
    
    public func collapse() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            isExpanded = false
        }
    }
    
    // MARK: - Neo Voice Mode Updates
    public func updateNeoSpeech(snippet: String, isSpeaking: Bool, isListening: Bool) {
        currentState.neoSpeechSnippet = snippet
        currentState.isSpeaking = isSpeaking
        currentState.isListening = isListening
        if isSpeaking || isListening {
            currentState.mode = .neoVoice
        }
        pushStateUpdate()
    }
    
    // MARK: - Cash Inflow Radar Updates
    public func triggerInvoiceAlert(invoice: Invoice) {
        currentState.mode = .cashInflow
        currentState.invoiceNumber = invoice.invoiceNumber
        currentState.invoiceAmount = invoice.totalAmount
        currentState.clientName = invoice.clientName
        currentState.invoiceStatus = invoice.status.rawValue
        
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)
        
        withAnimation(.spring(response: 0.36, dampingFraction: 0.74)) {
            isExpanded = true
        }
        pushStateUpdate()
    }
    
    // MARK: - Focus Velocity Task Updates
    public func completeCurrentMilestone() {
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)
        
        currentState.tasksCompletedCount = min(currentState.totalTasksCount, currentState.tasksCompletedCount + 1)
        currentState.timeRemainingMinutes = 45
        
        // Announce via Neo
        NeoCoFounderService.shared.speak(text: "Executive milestone marked complete, Gauresh. Exceptional velocity.")
        pushStateUpdate()
    }
    
    // MARK: - ActivityKit System Sync (Lock Screen & Hardware Island)
    public func requestSystemLiveActivity() {
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
            
            // End any stale existing activities
            for act in Activity<GaurexActivityAttributes>.activities {
                Task {
                    await act.end(nil, dismissalPolicy: .immediate)
                }
            }
            
            let attributes = GaurexActivityAttributes()
            do {
                if #available(iOS 16.2, *) {
                    let content = ActivityContent(state: currentState, staleDate: nil)
                    _ = try Activity.request(
                        attributes: attributes,
                        content: content,
                        pushType: nil
                    )
                } else {
                    _ = try Activity.request(
                        attributes: attributes,
                        contentState: currentState,
                        pushType: nil
                    )
                }
            } catch {
                print("Failed to start ActivityKit activity: \(error)")
            }
        }
        #endif
    }
    
    private func pushStateUpdate() {
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            Task {
                for act in Activity<GaurexActivityAttributes>.activities {
                    if #available(iOS 16.2, *) {
                        let content = ActivityContent(state: currentState, staleDate: nil)
                        await act.update(content)
                    } else {
                        await act.update(using: currentState)
                    }
                }
            }
        }
        #endif
    }
    
    // MARK: - Internal Timers & Observation
    private func startWaveformAnimation() {
        waveformTimer = Timer.publish(every: 0.12, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self = self else { return }
            if self.currentState.isSpeaking || self.currentState.isListening || self.currentState.mode == .neoVoice {
                self.audioWaveHeights = (0..<6).map { _ in CGFloat.random(in: 4...20) }
            }
        }
    }
    
    private func startVelocityCountdown() {
        countdownTimer = Timer.publish(every: 60.0, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self = self else { return }
            if self.currentState.timeRemainingMinutes > 1 {
                self.currentState.timeRemainingMinutes -= 1
            }
        }
    }
    
    private func observeSystemServices() {
        // Observe live store numbers
        let store = FirestoreDataStore.shared
        let target = 1250000.0
        let collected = store.revenueCollected
        currentState.monthlyTargetAmount = target
        currentState.currentMonthCollected = collected
        currentState.monthlyTargetProgress = min(1.0, max(0.05, collected / target))
        
        if let topTask = store.todayTasks.first {
            currentState.activeTaskTitle = topTask.title
            currentState.totalTasksCount = max(1, store.todayTasks.count)
            currentState.tasksCompletedCount = store.todayTasks.filter { $0.status == .completed }.count
        }
    }
}
