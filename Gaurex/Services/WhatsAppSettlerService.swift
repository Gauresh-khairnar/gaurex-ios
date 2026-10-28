//
//  WhatsAppSettlerService.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Multilingual WhatsApp Payment Settlement Generator (English, Hindi, Marathi)
//

import SwiftUI

public enum ReminderLanguage: String, CaseIterable, Identifiable {
    case english = "English"
    case hindi = "Hindi (हिंदी)"
    case marathi = "Marathi (मराठी)"
    
    public var id: String { rawValue }
}

public struct WhatsAppSettlerSheet: View {
    public let invoice: Invoice
    @ObservedObject private var store = FirestoreDataStore.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedLanguage: ReminderLanguage = .english
    @State private var customNotes: String = ""
    
    private let deepPurple = Color.gaurexDeepPlum
    private let goldAccent = Color.gaurexWarmGold
    
    public init(invoice: Invoice) {
        self.invoice = invoice
    }
    
    private var reminderMessage: String {
        let sym = store.settings.currencySymbol
        let amt = "\(sym)\(Int(invoice.balanceDue).formatted())"
        
        switch selectedLanguage {
        case .english:
            return """
            Dear \(invoice.clientName),
            
            This is an executive payment reminder from GAUREX regarding Invoice #\(invoice.invoiceNumber) for \(amt).
            
            Status: Outstanding Balance
            Due Date: \(invoice.dueDate.formatted(date: .abbreviated, time: .omitted))
            
            Kindly process the settlement via NEFT/UPI at your earliest convenience to maintain project delivery milestones.
            
            Warm regards,
            Gauresh Khairnar (OWNER)
            GAUREX Technologies
            """
            
        case .hindi:
            return """
            नमस्ते \(invoice.clientName),
            
            यह GAUREX की ओर से इनवॉइस #\(invoice.invoiceNumber) (राशि: \(amt)) के संबंध में एक औपचारिक व्यावसायिक अनुस्मारक है।
            
            अंतिम तिथि: \(invoice.dueDate.formatted(date: .abbreviated, time: .omitted))
            
            कृपया UPI या NEFT के माध्यम से देय राशि का भुगतान शीघ्र सुनिश्चित करें ताकि परियोजना सुचारू रूप से आगे बढ़ सके।
            
            सादर,
            गौरेष खैरनार (OWNER)
            GAUREX Technologies
            """
            
        case .marathi:
            return """
            सस्नेह नमस्कार \(invoice.clientName),
            
            हे GAUREX तर्फे इनव्हॉइस #\(invoice.invoiceNumber) (रक्कम: \(amt)) च्या पेमेंटबाबत अधिकृत स्मरणपत्र आहे.
            
            पेमेंट देय दिनांक: \(invoice.dueDate.formatted(date: .abbreviated, time: .omitted))
            
            कृपया UPI किंवा बँक ट्रान्सफरद्वारे लवकरात लवकर बिल सेटलमेंट पूर्ण करावे ही नम्र विनंती.
            
            आपला नम्र,
            गौरेष खैरनार (OWNER)
            GAUREX Technologies
            """
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                (colorScheme == .dark ? Color(red: 0.08, green: 0.08, blue: 0.10) : Color(red: 0.96, green: 0.95, blue: 0.97))
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 18) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("1-Tap WhatsApp Settler")
                                .font(.pjs(18, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                            Text("Auto-generated multilingual payment recovery")
                                .font(.pjs(11.5, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.secondary.opacity(0.7))
                        }
                    }
                    .padding(.top, 10)
                    
                    // Language Picker
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(ReminderLanguage.allCases) { lang in
                            Text(lang.rawValue).tag(lang)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // Preview Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "message.fill")
                                .foregroundColor(Color(red: 0.15, green: 0.75, blue: 0.38))
                            Text("Generated WhatsApp Dispatch")
                                .font(.pjs(12, weight: .bold))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(selectedLanguage.rawValue)
                                .font(.pjs(10.5, weight: .bold))
                                .foregroundColor(goldAccent)
                        }
                        
                        Text(reminderMessage)
                            .font(.pjs(12, weight: .regular))
                            .lineSpacing(3)
                            .foregroundColor(Color.primary)
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(colorScheme == .dark ? Color(red: 0.14, green: 0.14, blue: 0.18) : Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    Spacer()
                    
                    // Launch WhatsApp Button
                    Button {
                        MotionTokens.impact(style: .medium)
                        sendWhatsAppMessage()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "paperplane.fill")
                            Text("Send via WhatsApp")
                        }
                        .font(.pjs(15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color(red: 0.15, green: 0.75, blue: 0.38))
                        .clipShape(Capsule())
                        .shadow(color: Color(red: 0.15, green: 0.75, blue: 0.38).opacity(0.35), radius: 8, y: 3)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 16)
                }
                .padding(.horizontal, 24)
            }
            .navigationBarHidden(true)
        }
    }
    
    private func sendWhatsAppMessage() {
        guard let encoded = reminderMessage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let clientPhone = store.clients.first(where: { $0.id == invoice.clientId })?.phone.replacingOccurrences(of: " ", with: "") ?? ""
        let cleanPhone = clientPhone.replacingOccurrences(of: "+", with: "")
        
        let urlString: String
        if !cleanPhone.isEmpty {
            urlString = "whatsapp://send?phone=\(cleanPhone)&text=\(encoded)"
        } else {
            urlString = "whatsapp://send?text=\(encoded)"
        }
        
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            dismiss()
        } else if let webUrl = URL(string: "https://api.whatsapp.com/send?text=\(encoded)") {
            UIApplication.shared.open(webUrl)
            dismiss()
        }
    }
}
