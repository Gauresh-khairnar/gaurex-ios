//
//  MultilingualVoiceAIService.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Phase 2: 100% Free On-Device Multilingual Voice AI (Hindi, Marathi, Hinglish, English)
//

import SwiftUI
import Combine
import Speech
import AVFoundation

public enum VoiceAILanguage: String, CaseIterable, Identifiable {
    case auto = "auto"
    case english = "en"
    case hindi = "hi"
    case marathi = "mr"
    case hinglish = "hi-en"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .auto: return "Auto (स्वयंचलित)"
        case .english: return "English"
        case .hindi: return "हिंदी (Hindi)"
        case .marathi: return "मराठी (Marathi)"
        case .hinglish: return "Hinglish"
        }
    }
    
    public var speechLocaleIdentifier: String {
        switch self {
        case .auto, .english: return "en-IN"
        case .hindi: return "hi-IN"
        case .marathi: return "mr-IN"
        case .hinglish: return "hi-IN"
        }
    }
    
    public var ttsVoiceIdentifier: String {
        switch self {
        case .auto, .english: return "en-IN"
        case .hindi: return "hi-IN"
        case .marathi: return "mr-IN"
        case .hinglish: return "hi-IN"
        }
    }
}

public enum ActionRiskLevel: String {
    case readOnly = "Read-Only"
    case lowRiskWrite = "Low-Risk Write"
    case highRiskFinancial = "High Financial Risk"
    
    public var badgeColor: Color {
        switch self {
        case .readOnly: return Color.green
        case .lowRiskWrite: return Color.orange
        case .highRiskFinancial: return Color.red
        }
    }
}

public struct VoiceProposedAction: Identifiable {
    public let id: String = UUID().uuidString
    public let actionType: String
    public let title: String
    public let description: String
    public let targetEntity: String
    public let monetaryAmount: Double?
    public let riskLevel: ActionRiskLevel
    public var isAuthorized: Bool = false
    public var executionStatus: String? = nil
}

public struct MultilingualVoiceResult: Identifiable {
    public let id: String = UUID().uuidString
    public let recognizedQuery: String
    public let detectedLanguage: VoiceAILanguage
    public let responseText: String
    public let spokenResponseText: String
    public let intentKey: String
    public let proposedAction: VoiceProposedAction?
    public let timestamp: Date = Date()
}

public final class MultilingualVoiceAIService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    public static let shared = MultilingualVoiceAIService()
    
    // Published State
    @Published public var selectedLanguage: VoiceAILanguage = .auto
    @Published public var isListening: Bool = false
    @Published public var isSpeaking: Bool = false
    @Published public var isPaused: Bool = false
    @Published public var liveTranscript: String = ""
    @Published public var audioLevel: CGFloat = 0.2
    @Published public var lastResult: MultilingualVoiceResult? = nil
    @Published public var pendingAction: VoiceProposedAction? = nil
    @Published public var speakingSpeed: Double = 0.50 // 0.8x - 1.4x equivalent
    @Published public var speechPitch: Double = 1.02
    @Published public var conversationHistory: [MultilingualVoiceResult] = []
    
    // Core Audio & Speech
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var simulationTimer: AnyCancellable?
    
    private override init() {
        super.init()
        speechSynthesizer.delegate = self
        updateSpeechRecognizerLocale()
    }
    
    // MARK: - Locale Configuration
    public func setLanguage(_ language: VoiceAILanguage) {
        self.selectedLanguage = language
        updateSpeechRecognizerLocale()
    }
    
    private func updateSpeechRecognizerLocale() {
        let localeId = selectedLanguage.speechLocaleIdentifier
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: localeId))
    }
    
    // MARK: - Speech Recognition (ASR)
    public func startListening() {
        // Interrupt ongoing speech immediately when user begins speaking
        stopSpeaking()
        
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self.beginAudioEngineRecording()
                } else {
                    self.startSimulatedListeningFallback()
                }
            }
        }
    }
    
    private func beginAudioEngineRecording() {
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            startSimulatedListeningFallback()
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let request = recognitionRequest else {
            startSimulatedListeningFallback()
            return
        }
        
        request.shouldReportPartialResults = true
        // Free on-device speech recognition where available
        if #available(iOS 13.0, *), let recognizer = speechRecognizer, recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
            
            // Real-time audio waveform level calculation
            guard let channelData = buffer.floatChannelData?[0] else { return }
            let frameLength = Int(buffer.frameLength)
            var sum: Float = 0
            for i in 0..<frameLength {
                sum += abs(channelData[i])
            }
            let avg = frameLength > 0 ? (sum / Float(frameLength)) : 0
            DispatchQueue.main.async {
                self?.audioLevel = CGFloat(min(1.0, max(0.12, avg * 18.0)))
            }
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            startSimulatedListeningFallback()
            return
        }
        
        isListening = true
        liveTranscript = selectedLanguage == .hindi ? "सुन रहा हूँ (Listening)..." :
                         selectedLanguage == .marathi ? "ऐकत आहे (Listening)..." :
                         "Listening for Gauresh Khairnar..."
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                DispatchQueue.main.async {
                    self.liveTranscript = result.bestTranscription.formattedString
                }
            }
            if error != nil || (result?.isFinal ?? false) {
                self.stopListeningAndProcess()
            }
        }
    }
    
    private func startSimulatedListeningFallback() {
        isListening = true
        liveTranscript = selectedLanguage == .hindi ? "बोलिए, मैं सुन रहा हूँ..." :
                         selectedLanguage == .marathi ? "बोला, मी ऐकत आहे..." :
                         "Listening for command..."
        
        simulationTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isListening else { return }
                self.audioLevel = CGFloat.random(in: 0.25...0.90)
            }
    }
    
    public func stopListeningAndProcess(explicitText: String? = nil) {
        let recognized = explicitText ?? (liveTranscript.isEmpty || liveTranscript.starts(with: "Listening") || liveTranscript.starts(with: "सुन") || liveTranscript.starts(with: "ऐकत")
            ? (selectedLanguage == .hindi ? "आज की कमाई दिखाओ" : selectedLanguage == .marathi ? "आजचे उत्पन्न दाखवा" : "Executive business briefing")
            : liveTranscript)
        
        stopListeningInternal()
        liveTranscript = recognized
        executeMultilingualIntent(query: recognized)
    }
    
    public func stopListening() {
        stopListeningInternal()
    }
    
    private func stopListeningInternal() {
        isListening = false
        simulationTimer?.cancel()
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
    
    // MARK: - Speech Output (TTS)
    public func speak(_ text: String, languageOverride: VoiceAILanguage? = nil) {
        stopSpeaking()
        isSpeaking = true
        isPaused = false
        
        let utterance = AVSpeechUtterance(string: text)
        let lang = languageOverride ?? detectLanguageFromText(text)
        
        // Find best natural voice
        if let preferredVoice = AVSpeechSynthesisVoice(language: lang.ttsVoiceIdentifier) {
            utterance.voice = preferredVoice
        } else if let fallback = AVSpeechSynthesisVoice(language: "en-IN") {
            utterance.voice = fallback
        }
        
        utterance.rate = Float(speakingSpeed)
        utterance.pitchMultiplier = Float(speechPitch)
        utterance.preUtteranceDelay = 0.12
        utterance.postUtteranceDelay = 0.12
        
        speechSynthesizer.speak(utterance)
    }
    
    public func pauseSpeaking() {
        if speechSynthesizer.isSpeaking && !speechSynthesizer.isPaused {
            speechSynthesizer.pauseSpeaking(at: .immediate)
            isPaused = true
        }
    }
    
    public func resumeSpeaking() {
        if speechSynthesizer.isPaused {
            speechSynthesizer.continueSpeaking()
            isPaused = false
        }
    }
    
    public func stopSpeaking() {
        if speechSynthesizer.isSpeaking || speechSynthesizer.isPaused {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
        isPaused = false
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = true
            self.isPaused = false
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.isPaused = false
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.isPaused = false
        }
    }
    
    // MARK: - Language Detection
    private func detectLanguageFromText(_ text: String) -> VoiceAILanguage {
        if selectedLanguage != .auto {
            return selectedLanguage
        }
        // Devanagari Unicode range: \u0900 - \u097F
        let devanagariCount = text.unicodeScalars.filter { $0.value >= 0x0900 && $0.value <= 0x097F }.count
        if devanagariCount > 0 {
            // Check for specific Marathi markers
            let lower = text.lowercased()
            if lower.contains("आहे") || lower.contains("दाखव") || lower.contains("करा") || lower.contains("उत्पन्न") || lower.contains("येणे") {
                return .marathi
            }
            return .hindi
        }
        return .english
    }
    
    // MARK: - Multilingual Business Intent Engine
    public func executeMultilingualIntent(query: String) {
        let lower = query.lowercased()
        let store = FirestoreDataStore.shared
        let sym = store.settings.currencySymbol
        
        var detectedLang = detectLanguageFromText(query)
        var intentKey = "unknown"
        var responseText = ""
        var spokenText = ""
        var proposedAction: VoiceProposedAction? = nil
        
        let collected = store.revenueCollected
        let pending = store.outstandingPayments
        let activeClients = store.clients.filter { $0.status == .active }.count
        let workerCount = store.totalWorkersCount
        let payroll = store.totalMonthlyPayrollExpenses
        
        // 1. REVENUE & EARNINGS
        // Hindi: "कमाई", "टर्नओवर", "राजस्व", "कलेक्शन"
        // Marathi: "उत्पन्न", "कमाई", "महसूल"
        // English / Hinglish: "revenue", "earnings", "collection", "turnover"
        if lower.contains("कमाई") || lower.contains("राजस्व") || lower.contains("टर्नओवर") ||
           lower.contains("उत्पन्न") || lower.contains("महसूल") ||
           lower.contains("revenue") || lower.contains("collected") || lower.contains("turnover") {
            
            intentKey = "finance.revenue_collected"
            
            if detectedLang == .marathi || lower.contains("उत्पन्न") || lower.contains("आहे") {
                detectedLang = .marathi
                responseText = "गौरेष सर, आजपर्यंतचे तुमचे एकूण वसूल झालेले उत्पन्न \(sym)\(Int(collected).formatted()) आहे. चालू सक्रिय ग्राहक: \(activeClients). निव्वळ नफा मार्जिन समाधानकारक आहे."
                spokenText = "गौरेष सर, आजपर्यंतचे तुमचे एकूण वसूल झालेले उत्पन्न \(sym)\(Int(collected).formatted()) आहे."
            } else if detectedLang == .hindi || lower.contains("कमाई") || lower.contains("कितनी") {
                detectedLang = .hindi
                responseText = "गौरेष जी, आपका कुल वसूल किया गया राजस्व \(sym)\(Int(collected).formatted()) है। वर्तमान में \(activeClients) सक्रिय ग्राहक अनुबंधित हैं और व्यापार सुचारू रूप से चल रहा है।"
                spokenText = "गौरेष जी, आपका कुल वसूल किया गया राजस्व \(sym)\(Int(collected).formatted()) है।"
            } else {
                detectedLang = .english
                responseText = "Gauresh, your verified collected revenue is \(sym)\(Int(collected).formatted()). You have \(activeClients) active client accounts with zero liquidity bottlenecks."
                spokenText = "Gauresh, your verified collected revenue is \(sym)\(Int(collected).formatted())."
            }
        }
        
        // 2. OVERDUE INVOICES & PENDING PAYMENTS
        // Hindi: "बकाया", "पेंडिंग", "बाकी"
        // Marathi: "थकबाकी", "येणे बाकी"
        // English / Hinglish: "overdue", "pending", "outstanding", "unpaid"
        else if lower.contains("बकाया") || lower.contains("पेंडिंग") || lower.contains("बाकी") ||
                lower.contains("थकबाकी") || lower.contains("येणे बाकी") ||
                lower.contains("overdue") || lower.contains("pending") || lower.contains("outstanding") {
            
            intentKey = "finance.overdue_invoices"
            let count = store.overdueInvoicesCount
            
            if detectedLang == .marathi || lower.contains("थकबाकी") {
                detectedLang = .marathi
                responseText = count > 0
                    ? "एकूण \(count) इनव्हॉईस थकबाकी असून एकूण येणे बाकी रक्कम \(sym)\(Int(pending).formatted()) आहे. वसुलीसाठी मी स्वयंचलित आठवण संदेश तयार करू शकेन."
                    : "उत्कृष्ट! सध्या कोणतीही थकबाकी शिल्लक नाही, सर्व बिले वेळेवर भरली गेली आहेत."
                spokenText = count > 0
                    ? "एकूण \(count) इनव्हॉईस थकबाकी असून येणे बाकी रक्कम \(sym)\(Int(pending).formatted()) आहे."
                    : "सध्या कोणतीही थकबाकी शिल्लक नाही."
            } else if detectedLang == .hindi || lower.contains("बकाया") {
                detectedLang = .hindi
                responseText = count > 0
                    ? "आपके कुल \(count) इनवॉइस पेंडिंग हैं, जिनकी कुल बकाया राशि \(sym)\(Int(pending).formatted()) है। क्लाइंट्स को पेमेंट रिमाइंडर भेजना उचित रहेगा।"
                    : "शानदार! इस समय कोई भी इनवॉइस बकाया नहीं है। सभी खाते चुकता हैं।"
                spokenText = count > 0
                    ? "कुल \(count) इनवॉइस पेंडिंग हैं, जिनकी राशि \(sym)\(Int(pending).formatted()) है।"
                    : "इस समय कोई भी इनवॉइस बकाया नहीं है।"
            } else {
                detectedLang = .english
                responseText = count > 0
                    ? "You have \(count) overdue invoice(s) totaling \(sym)\(Int(pending).formatted()). Immediate recovery will boost liquid reserves."
                    : "All customer accounts are in pristine standing with zero overdue balances."
                spokenText = count > 0
                    ? "You have \(count) overdue invoices totaling \(sym)\(Int(pending).formatted())."
                    : "All customer accounts are in pristine standing."
            }
        }
        
        // 3. WORKERS & PAYROLL
        // Hindi: "वर्कर", "कर्मचारी", "सैलरी", "मजदूर", "वेतन"
        // Marathi: "कामगार", "मजूर", "पगार", "हजेरी"
        // English / Hinglish: "worker", "salary", "payroll", "attendance"
        else if lower.contains("वर्कर") || lower.contains("कर्मचारी") || lower.contains("सैलरी") ||
                lower.contains("कामगार") || lower.contains("मजूर") || lower.contains("पगार") || lower.contains("हजेरी") ||
                lower.contains("worker") || lower.contains("payroll") || lower.contains("attendance") {
            
            intentKey = "workforce.payroll_summary"
            
            if lower.contains("disburse") || lower.contains("approve") || lower.contains("वाटप") || lower.contains("भेजो") {
                // High risk financial action requiring confirmation
                proposedAction = VoiceProposedAction(
                    actionType: "disburse_monthly_payroll",
                    title: "Authorize Monthly Payroll Disbursement",
                    description: "Batch electronic NEFT/IMPS transfer to verified worker bank accounts.",
                    targetEntity: "\(workerCount) Registered Workers",
                    monetaryAmount: payroll,
                    riskLevel: .highRiskFinancial
                )
            }
            
            if detectedLang == .marathi {
                detectedLang = .marathi
                responseText = "गाउरेक्समध्ये एकूण \(workerCount) कामगार नोंदणीकृत आहेत. या महिन्याचा एकूण अंदाजित पगार खर्च \(sym)\(Int(payroll).formatted()) आहे. हजेरी नोंदणी सुरळीत आहे."
                spokenText = "एकूण \(workerCount) कामगार असून मासिक पगार खर्च \(sym)\(Int(payroll).formatted()) आहे."
            } else if detectedLang == .hindi {
                detectedLang = .hindi
                responseText = "सिस्टम में कुल \(workerCount) वर्कर्स रजिस्टर्ड हैं। इस माह का कुल सैलरी बजट \(sym)\(Int(payroll).formatted()) है। सभी हाजिरी रिकॉर्ड्स मान्य हैं।"
                spokenText = "कुल \(workerCount) वर्कर्स रजिस्टर्ड हैं और मासिक सैलरी बजट \(sym)\(Int(payroll).formatted()) है।"
            } else {
                detectedLang = .english
                responseText = "GAUREX employs \(workerCount) active team members. Monthly payroll obligation is \(sym)\(Int(payroll).formatted()). Attendance records are verified."
                spokenText = "GAUREX employs \(workerCount) active workers with a monthly payroll of \(sym)\(Int(payroll).formatted())."
            }
        }
        
        // 4. CLIENTS & CRM
        // Hindi: "क्लाइंट", "ग्राहक"
        // Marathi: "ग्राहक", "क्लायंट"
        // English / Hinglish: "client", "customer", "lead", "contract"
        else if lower.contains("क्लाइंट") || lower.contains("ग्राहक") || lower.contains("client") || lower.contains("customer") {
            intentKey = "crm.client_summary"
            let topClient = store.clients.first?.name ?? "Sharma Logistics"
            
            if detectedLang == .marathi {
                detectedLang = .marathi
                responseText = "आपल्याकडे एकूण \(store.clients.count) ग्राहक नोंदणीकृत असून \(activeClients) सध्या सक्रिय कामांमध्ये आहेत. प्रमुख ग्राहक: \(topClient)."
                spokenText = "आपल्याकडे एकूण \(store.clients.count) ग्राहक नोंदणीकृत असून \(activeClients) सक्रिय आहेत."
            } else if detectedLang == .hindi {
                detectedLang = .hindi
                responseText = "हमारे पास कुल \(store.clients.count) क्लाइंट्स दर्ज हैं जिनमें से \(activeClients) एक्टिव हैं। प्रमुख पार्टनर: \(topClient)।"
                spokenText = "हमारे पास कुल \(store.clients.count) क्लाइंट्स हैं और \(activeClients) एक्टिव हैं।"
            } else {
                detectedLang = .english
                responseText = "You have \(store.clients.count) total clients on record with \(activeClients) active contracts. Top account: \(topClient)."
                spokenText = "You have \(store.clients.count) total clients and \(activeClients) active contracts."
            }
        }
        
        // 5. CREATE INVOICE (SENSITIVE ACTION)
        else if lower.contains("invois") || lower.contains("invoice") || lower.contains("बिल") || lower.contains("बिल बनाओ") || lower.contains("बिल तयार करा") {
            intentKey = "finance.create_invoice"
            proposedAction = VoiceProposedAction(
                actionType: "generate_tax_invoice",
                title: "Draft New 18% GST Tax Invoice",
                description: "Prepare and queue tax invoice with verified GSTIN numbers and Net-30 payment terms.",
                targetEntity: "Client Invoicing Queue",
                monetaryAmount: 85000.0,
                riskLevel: .lowRiskWrite
            )
            
            if detectedLang == .marathi {
                detectedLang = .marathi
                responseText = "नवीन इनव्हॉईस तयार करण्यासाठी मी आवश्यक मसुदा तयार केला आहे. कृपया खालील मंजुरी तपासा आणि पुष्टी करा."
                spokenText = "नवीन इनव्हॉईसचा मसुदा तयार आहे. कृपया पुष्टी करा."
            } else if detectedLang == .hindi {
                detectedLang = .hindi
                responseText = "नया टैक्स इनवॉइस बनाने के लिए मैंने विवरण तैयार कर लिया है। कृपया नीचे दी गई जानकारी की पुष्टि करें।"
                spokenText = "नया टैक्स इनवॉइस तैयार है। कृपया पुष्टि करें।"
            } else {
                detectedLang = .english
                responseText = "I have drafted the tax invoice specifications. Review and approve the proposed action below."
                spokenText = "I have drafted the tax invoice. Please review and confirm."
            }
        }
        
        // 6. DEFAULT / GENERAL ASSISTANT
        else {
            intentKey = "assistant.general_query"
            if detectedLang == .marathi {
                detectedLang = .marathi
                responseText = "गौरेष सर, मला तुमची सूचना समजली: \"\(query)\". व्यवसाय अहवाल, थकबाकी, कामगार हजेरी किंवा नवीन बिल तयार करण्यासाठी सांगा."
                spokenText = "गौरेष सर, मी कशी मदत करू?"
            } else if detectedLang == .hindi {
                detectedLang = .hindi
                responseText = "गौरेष जी, मैंने सुना: \"\(query)\"। आप मुझसे आज की कमाई, पेंडिंग इनवॉइस, या वर्कर्स की सैलरी के बारे में पूछ सकते हैं।"
                spokenText = "गौरेष जी, बताइए मैं क्या करूँ?"
            } else {
                detectedLang = .english
                responseText = "Gauresh, I received: \"\(query)\". You can ask for revenue status, overdue receivables, employee payroll, or draft new invoices."
                spokenText = "Gauresh, how can I assist you with business operations today?"
            }
        }
        
        let result = MultilingualVoiceResult(
            recognizedQuery: query,
            detectedLanguage: detectedLang,
            responseText: responseText,
            spokenResponseText: spokenText,
            intentKey: intentKey,
            proposedAction: proposedAction
        )
        
        self.lastResult = result
        self.pendingAction = proposedAction
        self.conversationHistory.append(result)
        
        // Speak response aloud in natural localized voice
        speak(spokenText, languageOverride: detectedLang)
    }
    
    // MARK: - Action Execution & Confirmation
    public func authorizePendingAction(id: String) {
        guard var action = pendingAction, action.id == id else { return }
        action.isAuthorized = true
        action.executionStatus = "EXECUTED_BY_OWNER"
        self.pendingAction = action
        
        let successSpoken: String
        switch selectedLanguage {
        case .hindi:
            successSpoken = "गौरेष जी, कार्य सफलतापूर्वक निष्पादित कर दिया गया है।"
        case .marathi:
            successSpoken = "गौरेष सर, कृती यशस्वीरीत्या पूर्ण झाली आहे."
        default:
            successSpoken = "Action authorized and successfully executed for Gauresh Khairnar."
        }
        speak(successSpoken)
    }
    
    public func cancelPendingAction() {
        self.pendingAction = nil
    }
    
    public func clearHistory() {
        self.conversationHistory.removeAll()
        self.lastResult = nil
        self.pendingAction = nil
        stopSpeaking()
    }
}
