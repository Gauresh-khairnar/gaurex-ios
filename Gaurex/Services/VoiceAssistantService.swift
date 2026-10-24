//
//  VoiceAssistantService.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI
import Combine

public enum VoiceCommandIntent: Equatable {
    case overdueInvoices
    case todayTasks
    case planMyDay
    case revenueCollected
    case clientFollowUps
    case weeklySummary
    case unknown(query: String)
}

public struct VoiceAssistantResult {
    public let recognizedText: String
    public let intent: VoiceCommandIntent
    public let responseText: String
    public let requiresConfirmation: Bool
    public let proposedActionSummary: String?
}

public final class VoiceAssistantService: ObservableObject {
    public static let shared = VoiceAssistantService()
    
    @Published public var isListening: Bool = false
    @Published public var audioLevel: CGFloat = 0.2
    @Published public var liveTranscript: String = ""
    @Published public var lastResult: VoiceAssistantResult? = nil
    
    private var levelTimer: AnyCancellable?
    
    private init() {}
    
    public func startListening() {
        isListening = true
        liveTranscript = "Listening for executive command..."
        lastResult = nil
        
        // Simulate dynamic audio level waveform
        levelTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isListening else { return }
                self.audioLevel = CGFloat.random(in: 0.25...0.95)
            }
    }
    
    public func stopListeningAndProcess(spokenQuery: String) {
        isListening = false
        levelTimer?.cancel()
        audioLevel = 0.2
        liveTranscript = spokenQuery
        
        processCommand(query: spokenQuery)
    }
    
    private func processCommand(query: String) {
        let lower = query.lowercased()
        let store = FirestoreDataStore.shared
        
        let recognized = query
        var intent: VoiceCommandIntent = .unknown(query: query)
        var responseText = ""
        var requiresConfirmation = false
        var proposedAction: String? = nil
        
        if lower.contains("overdue") {
            intent = .overdueInvoices
            let count = store.overdueInvoicesCount
            let sum = store.outstandingPayments
            responseText = count > 0
                ? "You have \(count) overdue invoice(s) totaling \(store.settings.currencySymbol)\(String(format: "%.2f", sum))."
                : "All client invoices are currently in good standing with zero overdue accounts."
        } else if lower.contains("task") || lower.contains("top three") {
            intent = .todayTasks
            let count = store.todayTasks.count
            responseText = "You have \(count) tasks scheduled for today. Top priority: \(store.todayTasks.first?.title ?? "None pending")."
        } else if lower.contains("plan my day") || lower.contains("plan day") {
            intent = .planMyDay
            responseText = "I have drafted an optimal day schedule with \(min(5, store.tasks.count + 2)) prioritized actions."
            requiresConfirmation = true
            proposedAction = "Apply proposed schedule to Today's Tasks calendar"
        } else if lower.contains("revenue") || lower.contains("collected") {
            intent = .revenueCollected
            let amount = store.revenueCollected
            responseText = "Total revenue collected to date is \(store.settings.currencySymbol)\(String(format: "%.2f", amount))."
        } else if lower.contains("follow") || lower.contains("client") {
            intent = .clientFollowUps
            let count = store.salesLeads.filter { $0.stage != .won && $0.stage != .lost }.count
            responseText = "There are \(count) active opportunities in your sales pipeline requiring contact."
        } else {
            intent = .unknown(query: query)
            responseText = "Recognized: \"\(query)\". How would you like GAUREX Assistant to proceed?"
        }
        
        lastResult = VoiceAssistantResult(
            recognizedText: recognized,
            intent: intent,
            responseText: responseText,
            requiresConfirmation: requiresConfirmation,
            proposedActionSummary: proposedAction
        )
    }
}
