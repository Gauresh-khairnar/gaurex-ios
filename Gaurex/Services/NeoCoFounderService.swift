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
    @Published public var harmonicWaveformLevels: [CGFloat] = Array(repeating: 0.15, count: 18)
    @Published public var currentBriefingLanguage: BriefingLanguage = .english
    
    public enum BriefingLanguage: String, CaseIterable, Identifiable {
        case english = "English"
        public var id: String { rawValue }
        
        public var voiceCode: String {
            return "en-US"
        }
    }
    
    private let synthesizer = AVSpeechSynthesizer()
    private var hasGreetedThisSession: Bool = false
    private var waveformTimer: Timer?
    
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
            self.startWaveformSimulation()
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.stopWaveformSimulation()
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.stopWaveformSimulation()
        }
    }
    
    // MARK: - Audio-Reactive Waveform Simulator
    private func startWaveformSimulation() {
        waveformTimer?.invalidate()
        let timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
            guard let self = self, self.isSpeaking else { return }
            // Generate organic frequency bars mimicking voice harmonics & cadence
            var nextBars: [CGFloat] = []
            let count = 18
            for i in 0..<count {
                // Bell curve weighted center with natural voice fluctuation
                let normalizedCenter = 1.0 - abs(CGFloat(i) - CGFloat(count) / 2.0) / (CGFloat(count) / 2.0)
                let jitter = CGFloat.random(in: 0.25...0.95)
                let barHeight = max(0.12, min(1.0, normalizedCenter * jitter * 1.1))
                nextBars.append(barHeight)
            }
            withAnimation(.interactiveSpring(response: 0.12, dampingFraction: 0.72)) {
                self.harmonicWaveformLevels = nextBars
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        waveformTimer = timer
    }
    
    private func stopWaveformSimulation() {
        waveformTimer?.invalidate()
        waveformTimer = nil
        withAnimation(.easeOut(duration: 0.35)) {
            self.harmonicWaveformLevels = Array(repeating: 0.08, count: 18)
        }
    }
    
    // MARK: - Autonomous App Launch Greeting & Executive Briefing
    public func greetFounderOnLaunch(force: Bool = false) {
        guard !hasGreetedThisSession || force else { return }
        guard !isVoiceGreetingMuted else { return }
        
        hasGreetedThisSession = true
        
        let store = FirestoreDataStore.shared
        let hour = Calendar.current.component(.hour, from: Date())
        let collected = Int(store.revenueCollected)
        let activeClients = store.clients.filter { $0.status == .active }.count
        let receivables = Int(store.outstandingPayments)
        let topTask = store.todayTasks.first?.title ?? "Review pipeline and cash reserves"
        let sym = store.settings.currencySymbol
        
        let timeSalutation: String
        if hour < 12 { timeSalutation = "Good Morning Gauresh." }
        else if hour < 17 { timeSalutation = "Good Afternoon Gauresh." }
        else { timeSalutation = "Good Evening Gauresh." }
        let briefingText = "\(timeSalutation) I am NEO, your AI Co-Founder. Here is your GAUREX executive briefing: We have collected \(sym)\(collected) in liquid cash, with \(activeClients) active enterprise contracts and \(sym)\(receivables) in pending receivables. Your top priority today: \(topTask)."
        
        self.lastSpokenBriefing = briefingText
        
        // Slight delay so the UI loads smoothly before speaking
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.speak(text: briefingText, language: self.currentBriefingLanguage)
        }
    }
    
    // MARK: - Speech Synthesis
    public func speakBriefing(context: AIAnalysisContext? = nil, force: Bool = false) {
        greetFounderOnLaunch(force: force)
    }

    public func speak(text: String, language: BriefingLanguage = .english) {
        stopSpeaking()
        guard isVoiceGreetingEnabled && !isVoiceGreetingMuted else { return }
        
        let utterance = AVSpeechUtterance(string: text)
        if let voice = AVSpeechSynthesisVoice(language: language.voiceCode) {
            utterance.voice = voice
        } else if let fallback = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = fallback
        }
        utterance.rate = Float(speechRate)
        utterance.pitchMultiplier = Float(speechPitch)
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.1
        
        isSpeaking = true
        startWaveformSimulation()
        synthesizer.speak(utterance)
    }
    
    public func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
        stopWaveformSimulation()
    }
    
    public func toggleMute() {
        isVoiceGreetingMuted.toggle()
        if isVoiceGreetingMuted {
            stopSpeaking()
        }
    }
}
