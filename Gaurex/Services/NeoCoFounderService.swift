//
//  NeoCoFounderService.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  NEO: Autonomous AI Co-Founder & Executive Speaking Partner
//

import SwiftUI
import Combine
import AVFoundation
import Speech

public final class NeoCoFounderService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    public static let shared = NeoCoFounderService()
    
    @Published public var isSpeaking: Bool = false
    @Published public var isListening: Bool = false
    @Published public var spokenTranscript: String = ""
    @Published public var lastSpokenBriefing: String = ""
    @Published public var isVoiceGreetingMuted: Bool = false
    @Published public var isVoiceGreetingEnabled: Bool = true
    @Published public var speechRate: Double = 0.50
    @Published public var speechPitch: Double = 1.02
    @Published public var audioLevel: CGFloat = 0.2
    
    private let synthesizer = AVSpeechSynthesizer()
    private var hasGreetedThisSession: Bool = false
    
    private override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
    
    // MARK: - Autonomous App Launch Greeting & Executive Briefing
    public func greetFounderOnLaunch(force: Bool = false) {
        guard !hasGreetedThisSession || force else { return }
        guard !isVoiceGreetingMuted else { return }
        
        hasGreetedThisSession = true
        
        let store = FirestoreDataStore.shared
        let hour = Calendar.current.component(.hour, from: Date())
        let timeSalutation: String
        if hour < 12 {
            timeSalutation = "Good Morning Gauresh."
        } else if hour < 17 {
            timeSalutation = "Good Afternoon Gauresh."
        } else {
            timeSalutation = "Good Evening Gauresh."
        }
        
        let collected = Int(store.revenueCollected)
        let activeClients = store.clients.filter { $0.status == .active }.count
        let receivables = Int(store.outstandingPayments)
        let topTask = store.todayTasks.first?.title ?? "Review sales pipeline and pending deliverables"
        let sym = store.settings.currencySymbol
        
        let briefingText = """
        \(timeSalutation) I am NEO, your AI Co-Founder. Here is your GAUREX executive briefing: We have collected \(sym)\(collected) in liquid cash, with \(activeClients) active enterprise contracts and \(sym)\(receivables) in pending receivables. Your top priority today is: \(topTask). I am ready for your command.
        """
        
        self.lastSpokenBriefing = briefingText
        
        // Slight delay so the UI loads smoothly before speaking
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.speak(text: briefingText)
        }
    }
    
    // MARK: - Speech Synthesis
    public func speakBriefing(context: AIAnalysisContext? = nil, force: Bool = false) {
        greetFounderOnLaunch(force: force)
    }

    public func speak(text: String) {
        stopSpeaking()
        guard isVoiceGreetingEnabled && !isVoiceGreetingMuted else { return }
        
        let utterance = AVSpeechUtterance(string: text)
        // High quality natural voice
        if let enVoice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = enVoice
        }
        utterance.rate = Float(speechRate)
        utterance.pitchMultiplier = Float(speechPitch)
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.1
        
        isSpeaking = true
        synthesizer.speak(utterance)
    }
    
    public func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }
    
    public func toggleMute() {
        isVoiceGreetingMuted.toggle()
        if isVoiceGreetingMuted {
            stopSpeaking()
        }
    }
}
