//
//  ReceiveUPIPaymentModal.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Executive Dynamic UPI Payment Terminal & Scanner for Gauresh Khairnar (9579098477@slc)
//

import SwiftUI
import UIKit

public struct ReceiveUPIPaymentModal: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    // Input Fields
    @State private var clientName: String = ""
    @State private var selectedClientId: String? = nil
    @State private var amountString: String = "50000"
    @State private var paymentNote: String = "Milestone Settlement"
    
    // QR State
    @State private var generatedQRImage: UIImage? = nil
    @State private var isShowingTerminalView: Bool = false
    @State private var isPaymentConfirmed: Bool = false
    
    private let upiId: String = "9579098477@slc"
    private let payeeName: String = "Gauresh Khairnar"
    
    private let quickAmounts: [Double] = [25000, 50000, 100000, 250000, 500000]
    
    public init() {}
    
    private var numericAmount: Double {
        Double(amountString.replacingOccurrences(of: ",", with: "").trimmingCharacters(in: .whitespaces)) ?? 0.0
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        if !isShowingTerminalView {
                            // Step 1: Input Setup View
                            paymentDetailsSetupView
                        } else {
                            // Step 2: Dynamic QR Scanner Terminal Card
                            dynamicTerminalCardView
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Receive UPI Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Step 1: Payment Details Setup View
    @ViewBuilder
    private var paymentDetailsSetupView: some View {
        VStack(alignment: .leading, spacing: 18) {
            
            // Header Card
            HStack(spacing: 12) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.gaurexWarmGold)
                    .frame(width: 48, height: 48)
                    .background(Color.gaurexDeepPlum.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Instant UPI Payment Terminal")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Payee: \(payeeName) • \(upiId)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(14)
            .background(theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(theme.glassBorderColor, lineWidth: 1))
            
            // Client Selection / Name
            VStack(alignment: .leading, spacing: 8) {
                Text("CLIENT / RECIPIENT")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                
                // Existing Clients Picker Chips
                if !store.clients.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(store.clients.prefix(6)) { client in
                                let isSel = selectedClientId == client.id || clientName == client.name
                                Button {
                                    selectedClientId = client.id
                                    clientName = client.name
                                    paymentNote = "\(client.companyName.isEmpty ? client.name : client.companyName) - Settlement"
                                    GaurexSoundEffectsService.shared.playStealthModeClick()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "person.circle.fill")
                                            .font(.system(size: 12))
                                        Text(client.name)
                                            .font(.system(size: 12, weight: isSel ? .bold : .medium))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(isSel ? Color.gaurexDeepPlum : theme.cardBackground)
                                    .foregroundColor(isSel ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSel ? Color.gaurexWarmGold : theme.glassBorderColor, lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                
                TextField("Enter or select client name...", text: $clientName)
                    .font(.system(size: 14))
                    .padding(12)
                    .background(theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(theme.glassBorderColor, lineWidth: 1))
            }
            
            // Amount Input with Quick Increment Chips
            VStack(alignment: .leading, spacing: 8) {
                Text("AMOUNT TO RECEIVE (INR ₹)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 6) {
                    Text("₹")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.gaurexWarmGold)
                    
                    TextField("50000", text: $amountString)
                        .keyboardType(.numberPad)
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                }
                .padding(14)
                .background(theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gaurexWarmGold.opacity(0.4), lineWidth: 1))
                
                // Quick Amount Presets
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(quickAmounts, id: \.self) { amt in
                            Button {
                                amountString = String(format: "%.0f", amt)
                                GaurexSoundEffectsService.shared.playStealthModeClick()
                            } label: {
                                Text("+₹\((amt / 1000).formatted())k")
                                    .font(.system(size: 11, weight: .bold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.gaurexWarmGold.opacity(0.12))
                                    .foregroundColor(Color.gaurexWarmGold)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(Color.gaurexWarmGold.opacity(0.3), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            // Payment Purpose / Note
            VStack(alignment: .leading, spacing: 8) {
                Text("PAYMENT NOTE / MILESTONE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                
                TextField("e.g. Milestone 1 Advance Payment", text: $paymentNote)
                    .font(.system(size: 14))
                    .padding(12)
                    .background(theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(theme.glassBorderColor, lineWidth: 1))
            }
            
            // Generate Dynamic QR Button
            Button {
                generateTerminalQR()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "qrcode")
                        .font(.system(size: 18, weight: .bold))
                    Text("GENERATE GAUREX UPI QR SCANNER")
                        .font(.system(size: 14, weight: .heavy))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Color.gaurexWarmGold)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: Color.gaurexWarmGold.opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(.plain)
            .disabled(numericAmount <= 0)
        }
    }
    
    // MARK: - Step 2: Dynamic QR Scanner Terminal Card View
    @ViewBuilder
    private var dynamicTerminalCardView: some View {
        VStack(spacing: 16) {
            
            // Obsidian & Gold Terminal Card
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.12, green: 0.04, blue: 0.14), Color(red: 0.05, green: 0.03, blue: 0.07)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.gaurexWarmGold.opacity(0.6), lineWidth: 1.5)
                    )
                    .shadow(color: Color.gaurexDeepPlum.opacity(0.4), radius: 16, y: 8)
                
                VStack(spacing: 16) {
                    // Header Brand Crest
                    HStack {
                        HStack(spacing: 6) {
                            Text("G A U R E X")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .tracking(3)
                                .foregroundColor(Color.gaurexWarmGold)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Circle().fill(Color.green).frame(width: 6, height: 6)
                            Text("LIVE GATEWAY")
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    
                    // Client & Purpose
                    VStack(spacing: 3) {
                        Text(clientName.isEmpty ? "Direct Client Payment" : clientName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text(paymentNote.isEmpty ? "Executive Settlement" : paymentNote)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    // Large Crisp QR Code
                    if let qr = generatedQRImage {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white)
                                .frame(width: 220, height: 220)
                                .shadow(color: Color.black.opacity(0.2), radius: 8)
                            
                            Image(uiImage: qr)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                            
                            // Center GAUREX Crest
                            Circle()
                                .fill(Color.gaurexDeepPlum)
                                .frame(width: 38, height: 38)
                                .overlay(
                                    Text("GK")
                                        .font(.system(size: 13, weight: .black))
                                        .foregroundColor(Color.gaurexWarmGold)
                                )
                                .overlay(Circle().stroke(Color.gaurexWarmGold, lineWidth: 1.5))
                        }
                    }
                    
                    // Exact Auto-Detected Amount Display
                    VStack(spacing: 2) {
                        Text("SCAN TO PAY EXACT AMOUNT")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color.gaurexWarmGold)
                            .tracking(1.5)
                        
                        Text(FinancialCalculator.shared.formatCurrency(numericAmount, symbol: "₹"))
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    // Payee Info & Supported Apps
                    VStack(spacing: 4) {
                        Text("Payee: \(payeeName) • \(upiId)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.75))
                        
                        Text("Supports GPay • PhonePe • Paytm • BHIM • CRED")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding(20)
            }
            
            // Action 1: Share on WhatsApp
            Button {
                shareUPIViaWhatsApp()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "message.fill")
                    Text("SHARE PAYMENT LINK VIA WHATSAPP")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(Color(red: 0.12, green: 0.65, blue: 0.35))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            
            // Action 2: Confirm Payment Received (Cash settlement)
            Button {
                confirmPaymentReceived()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                    Text(isPaymentConfirmed ? "PAYMENT SETTLED & LOGGED ✓" : "CONFIRM RECEIVED & SETTLE")
                        .font(.system(size: 13, weight: .heavy))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isPaymentConfirmed ? Color.green : Color.gaurexWarmGold)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(isPaymentConfirmed)
            
            // Back to Edit button
            Button("Edit Amount or Client") {
                withAnimation {
                    isShowingTerminalView = false
                }
            }
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            .padding(.top, 4)
        }
    }
    
    // MARK: - Actions
    private func generateTerminalQR() {
        guard numericAmount > 0 else { return }
        
        let note = paymentNote.isEmpty ? "Payment to GAUREX" : paymentNote
        generatedQRImage = UPIDynamicQRGenerator.shared.generateQRCodeImage(
            amount: numericAmount,
            transactionNote: note,
            upiId: upiId
        )
        
        GaurexSoundEffectsService.shared.playMilestoneCompletedSound()
        withAnimation(.spring()) {
            isShowingTerminalView = true
        }
    }
    
    private func shareUPIViaWhatsApp() {
        let note = paymentNote.isEmpty ? "GAUREX Executive Settlement" : paymentNote
        let upiURI = UPIDynamicQRGenerator.shared.generateUPIURLString(
            amount: numericAmount,
            transactionNote: note
        )
        
        let formattedAmt = FinancialCalculator.shared.formatCurrency(numericAmount, symbol: "₹")
        let message = """
        Dear \(clientName.isEmpty ? "Client" : clientName),

        Please find the GAUREX official settlement request for \(formattedAmt).
        
        • Payee: Gauresh Khairnar (OWNER, GAUREX)
        • UPI ID: \(upiId)
        • Purpose: \(note)

        Click to pay directly via any UPI app:
        \(upiURI)
        
        Thank you,
        GAUREX Executive Office
        """
        
        guard let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "whatsapp://send?text=\(encoded)") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let webUrl = URL(string: "https://api.whatsapp.com/send?text=\(encoded)") {
            UIApplication.shared.open(webUrl)
        }
    }
    
    private func confirmPaymentReceived() {
        isPaymentConfirmed = true
        
        // 1. Play bespoke cash bell acoustic sound
        GaurexSoundEffectsService.shared.playCashSettledSound()
        
        // 2. Create Payment record in FirestoreDataStore
        let payment = Payment(
            invoiceId: selectedClientId ?? UUID().uuidString,
            amount: numericAmount,
            date: Date(),
            method: .upi,
            notes: "UPI Terminal payment received via \(upiId) from \(clientName.isEmpty ? "Client" : clientName)"
        )
        store.addPayment(payment)
        
        // 3. Save receipt into Document Vault
        let receiptDoc = VaultDocument(
            title: "UPI Receipt - \(clientName.isEmpty ? "Client" : clientName) - \(Int(numericAmount))",
            category: .receipt,
            fileName: "UPI_Receipt_\(Int(Date().timeIntervalSince1970)).pdf",
            fileSizeBytes: 185000,
            relatedEntityId: selectedClientId,
            extractedFields: ExtractedDocumentFields(
                detectedType: "UPI Payment Receipt",
                documentNumber: "UPI-\(Date().timeIntervalSince1970.formatted())",
                entityName: clientName.isEmpty ? "Client Payment" : clientName,
                totalAmount: numericAmount,
                confidenceScore: 1.0
            )
        )
        store.addVaultDocument(receiptDoc)
        
        // 4. Auto dismiss after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismiss()
        }
    }
}
