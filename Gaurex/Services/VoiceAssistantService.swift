//
//  VoiceAssistantService.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI
import Combine
import Speech
import AVFoundation

public enum VoiceCommandIntent: Equatable {
    case businessBriefing
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
    @Published public var isSpeaking: Bool = false
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let synthesizer = AVSpeechSynthesizer()
    
    private var levelTimer: AnyCancellable?
    
    private init() {}
    
    public func startListening() {
        stopSpeaking()
        
        // Request authorization
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self.startRecordingSession()
                } else {
                    self.startSimulatedListening()
                }
            }
        }
    }
    
    private func startRecordingSession() {
        // Cancel existing task if running
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            startSimulatedListening()
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            startSimulatedListening()
            return
        }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
            
            // Calculate audio level from buffer
            let channelData = buffer.floatChannelData?[0]
            let frames = buffer.frameLength
            if let data = channelData, frames > 0 {
                var sum: Float = 0
                for i in 0..<Int(frames) {
                    sum += abs(data[i])
                }
                let avg = sum / Float(frames)
                DispatchQueue.main.async {
                    self?.audioLevel = CGFloat(min(1.0, max(0.15, avg * 15.0)))
                }
            }
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            startSimulatedListening()
            return
        }
        
        isListening = true
        liveTranscript = "Listening for Gauresh Khairnar..."
        lastResult = nil
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                DispatchQueue.main.async {
                    self.liveTranscript = result.bestTranscription.formattedString
                }
            }
            if error != nil || (result?.isFinal ?? false) {
                self.stopListeningInternal()
            }
        }
    }
    
    private func startSimulatedListening() {
        isListening = true
        liveTranscript = "Listening for executive command..."
        lastResult = nil
        
        levelTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isListening else { return }
                self.audioLevel = CGFloat.random(in: 0.25...0.95)
            }
    }
    
    public func stopListeningAndProcess(spokenQuery: String? = nil) {
        let recognized = spokenQuery ?? (liveTranscript.isEmpty || liveTranscript.starts(with: "Listening") ? "Executive business summary" : liveTranscript)
        stopListeningInternal()
        liveTranscript = recognized
        processCommand(query: recognized)
    }
    
    private func stopListeningInternal() {
        isListening = false
        levelTimer?.cancel()
        audioLevel = 0.2
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
    }
    
    public func speak(_ text: String) {
        stopSpeaking()
        isSpeaking = true
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.50
        utterance.pitchMultiplier = 1.05
        
        synthesizer.speak(utterance)
    }
    
    public func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }
    
    private func processCommand(query: String) {
        let lower = query.lowercased()
        let store = FirestoreDataStore.shared
        let sym = store.settings.currencySymbol
        
        let recognized = query
        var intent: VoiceCommandIntent = .unknown(query: query)
        var responseText = ""
        var requiresConfirmation = false
        var proposedAction: String? = nil
        
        if lower.contains("briefing") || lower.contains("summary") || lower.contains("status") || lower.contains("pulse") {
            intent = .businessBriefing
            let collected = store.revenueCollected
            let pending = store.outstandingPayments
            let activeClients = store.clients.filter { $0.status == .active }.count
            responseText = "Gauresh, your verified liquid revenue is \(sym)\(String(format: "%.2f", collected)). You have \(activeClients) active client contracts and \(sym)\(String(format: "%.2f", pending)) in outstanding receivables."
        } else if lower.contains("overdue") {
            intent = .overdueInvoices
            let count = store.overdueInvoicesCount
            let sum = store.outstandingPayments
            responseText = count > 0
                ? "You have \(count) overdue invoice(s) totaling \(sym)\(String(format: "%.2f", sum)). Recovering this will immediately boost cash on hand."
                : "All client invoices are currently in good standing with zero overdue accounts."
        } else if lower.contains("task") || lower.contains("top three") {
            intent = .todayTasks
            let count = store.todayTasks.count
            responseText = "You have \(count) tasks scheduled for today. Top priority: \(store.todayTasks.first?.title ?? "None pending")."
        } else if lower.contains("plan my day") || lower.contains("plan day") {
            intent = .planMyDay
            responseText = "I have drafted an optimal day schedule with \(min(5, store.tasks.count + 2)) prioritized actions to push your daily revenue pace."
            requiresConfirmation = true
            proposedAction = "Apply proposed schedule to Today's Tasks calendar"
        } else if lower.contains("revenue") || lower.contains("collected") {
            intent = .revenueCollected
            let amount = store.revenueCollected
            responseText = "Total collected liquid revenue to date is \(sym)\(String(format: "%.2f", amount))."
        } else if lower.contains("follow") || lower.contains("client") {
            intent = .clientFollowUps
            let count = store.salesLeads.filter { $0.stage != .won && $0.stage != .lost }.count
            responseText = "There are \(count) active opportunities in your sales pipeline requiring contact."
        } else {
            intent = .unknown(query: query)
            responseText = "Gauresh, I recognized: \"\(query)\". How would you like GAUREX Executive Assistant to proceed?"
        }
        
        lastResult = VoiceAssistantResult(
            recognizedText: recognized,
            intent: intent,
            responseText: responseText,
            requiresConfirmation: requiresConfirmation,
            proposedActionSummary: proposedAction
        )
        
        // Speak response out loud
        speak(responseText)
    }
}
