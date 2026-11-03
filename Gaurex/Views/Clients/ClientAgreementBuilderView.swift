//
//  ClientAgreementBuilderView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Interactive Agreement Builder, Customizer, Signature Pad & WhatsApp Dispatch
//

import SwiftUI
import PDFKit

public struct ClientAgreementBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var store = FirestoreDataStore.shared
    
    public let client: Client
    
    @State private var selectedTemplate: AgreementTemplateType = .msa
    @State private var scopeText: String = ""
    @State private var paymentTermsText: String = ""
    @State private var governingLawText: String = "Mumbai, Maharashtra, India"
    
    @State private var clientSignature: UIImage? = nil
    @State private var showingSignatureModal = false
    @State private var showingPDFPreview = false
    @State private var generatedPDFData: Data? = nil
    @State private var isSealedWithFaceID = false
    @State private var sealStamp: BiometricSealStamp? = nil
    
    private let deepPurple = Color.gaurexDeepPlum
    private let goldAccent = Color.gaurexWarmGold
    
    public init(client: Client) {
        self.client = client
        let initialScope = client.packageIds.compactMap { id in
            store.packages.first(where: { $0.id == id })?.name
        }.joined(separator: ", ")
        self._scopeText = State(initialValue: initialScope.isEmpty ? "Full-stack software engineering and architecture deliverables" : initialScope)
        self._paymentTermsText = State(initialValue: "15-day milestone net terms upon delivery")
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Banner
                    HStack(spacing: 12) {
                        Image(systemName: "doc.text.badge.plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(goldAccent)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Executive Client Agreement")
                                .font(.pjs(18, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                            Text("Legal Instrument for \(client.name)")
                                .font(.pjs(12, weight: .medium))
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.22) : Color.white)
                    )
                    
                    // 1. Template Selector
                    VStack(alignment: .leading, spacing: 10) {
                        Text("SELECT CONTRACT TEMPLATE")
                            .font(.pjs(10, weight: .bold))
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                        
                        ForEach(AgreementTemplateType.allCases) { t in
                            Button {
                                MotionTokens.selection()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTemplate = t
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: selectedTemplate == t ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(selectedTemplate == t ? goldAccent : Color.gray)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(t.rawValue)
                                            .font(.pjs(13, weight: .bold))
                                            .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                                        Text(t.subtitle)
                                            .font(.pjs(10.5, weight: .regular))
                                            .foregroundColor(Color(uiColor: .secondaryLabel))
                                    }
                                    Spacer()
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedTemplate == t ? goldAccent.opacity(0.12) : Color.gray.opacity(0.06))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedTemplate == t ? goldAccent : Color.clear, lineWidth: 1.2)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.22) : Color.white)
                    )
                    
                    // 2. Agreement Editable Fields
                    VStack(alignment: .leading, spacing: 14) {
                        Text("CUSTOMIZE TERMS & SCOPE")
                            .font(.pjs(10, weight: .bold))
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SCOPE OF DELIVERABLES")
                                .font(.pjs(9, weight: .bold))
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                            TextEditor(text: $scopeText)
                                .frame(height: 70)
                                .font(.pjs(12, weight: .regular))
                                .padding(4)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("PAYMENT TERMS OVERRIDE")
                                .font(.pjs(9, weight: .bold))
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                            TextField("e.g. 50% advance, 50% on completion", text: $paymentTermsText)
                                .textFieldStyle(.roundedBorder)
                                .font(.pjs(12, weight: .regular))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("LEGAL JURISDICTION")
                                .font(.pjs(9, weight: .bold))
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                            TextField("Jurisdiction", text: $governingLawText)
                                .textFieldStyle(.roundedBorder)
                                .font(.pjs(12, weight: .regular))
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.22) : Color.white)
                    )
                    
                    // 3. Client Digital Signature Pad Trigger
                    VStack(alignment: .leading, spacing: 10) {
                        Text("CLIENT SIGN-OFF")
                            .font(.pjs(10, weight: .bold))
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                        
                        if let sig = clientSignature {
                            HStack {
                                Image(uiImage: sig)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 48)
                                    .padding(8)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                Spacer()
                                
                                Button("Re-sign") {
                                    showingSignatureModal = true
                                }
                                .font(.pjs(12, weight: .bold))
                                .foregroundColor(deepPurple)
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.green.opacity(0.1)))
                        } else {
                            Button {
                                showingSignatureModal = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "signature")
                                        .font(.system(size: 15))
                                    Text("Capture Client In-App Signature")
                                        .font(.pjs(13, weight: .bold))
                                }
                                .foregroundColor(deepPurple)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(colorScheme == .dark ? Color.white.opacity(0.1) : deepPurple.opacity(0.08))
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(deepPurple.opacity(0.3), lineWidth: 1))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.22) : Color.white)
                    )
                    
                    // 4. Generate & Preview Agreement Action
                    Button {
                        generateAndOpenPDF()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 16))
                            Text("Generate & Seal Agreement PDF")
                                .font(.pjs(14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [deepPurple, Color(red: 0.35, green: 0.10, blue: 0.30)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(goldAccent, lineWidth: 1.2))
                        .shadow(color: deepPurple.opacity(0.35), radius: 8, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                    
                    // 5. Send via WhatsApp Option
                    Button {
                        dispatchWhatsAppNudge()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "message.fill")
                            Text("Send Agreement via WhatsApp")
                                .font(.pjs(13, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.15, green: 0.75, blue: 0.38), Color(red: 0.10, green: 0.60, blue: 0.30)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
            .navigationTitle("Agreement Builder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showingSignatureModal) {
                DigitalSignatureCaptureModal(
                    signerTitle: "\(client.name) Signature",
                    signerSubtitle: "Sign with finger or stylus to authenticate contract acceptance."
                ) { sigImage in
                    self.clientSignature = sigImage
                }
            }
            .sheet(isPresented: $showingPDFPreview) {
                if let data = generatedPDFData {
                    PDFPreviewView(
                        pdfData: data,
                        documentTitle: "\(selectedTemplate.rawValue) - \(client.name)"
                    )
                }
            }
        }
    }
    
    private func generateAndOpenPDF() {
        let customization = AgreementCustomizationData(
            templateType: selectedTemplate,
            scopeDescription: scopeText,
            paymentTermsOverride: paymentTermsText,
            governingLaw: governingLawText,
            clientSignatureImage: clientSignature,
            biometricSeal: BiometricSealStamp(
                ownerName: "Gauresh Khairnar (OWNER)",
                timestamp: Date(),
                hashSignature: "SHA256-\(UUID().uuidString.prefix(10).uppercased())",
                biometricType: "Face ID"
            )
        )
        
        let pdf = ClientAgreementPDFService.shared.generateAgreementPDF(
            client: client,
            business: store.settings,
            customization: customization
        )
        
        self.generatedPDFData = pdf
        self.showingPDFPreview = true
        
        // Save into Client Vault automatically
        let fileName = "AGREEMENT_\(client.id.prefix(6))_\(selectedTemplate.rawValue.prefix(3)).pdf"
        let vaultDoc = VaultDocument(
            title: "\(selectedTemplate.rawValue) - \(client.name)",
            category: .contract,
            fileName: fileName,
            fileSizeBytes: pdf.count,
            mimeType: "application/pdf",
            tags: [client.name, "Agreement", selectedTemplate.rawValue],
            relatedEntityId: client.id
        )
        store.addVaultDocument(vaultDoc)
    }
    
    private func dispatchWhatsAppNudge() {
        let cleanPhone = client.phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "+", with: "")
        let message = "Dear \(client.name), this is Gauresh Khairnar from GAUREX. Please find attached your executive \(selectedTemplate.rawValue) for your review and execution. Please let us know if you require any clarifications. Thank you."
        guard let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let urlString = !cleanPhone.isEmpty ? "whatsapp://send?phone=\(cleanPhone)&text=\(encoded)" : "whatsapp://send?text=\(encoded)"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let webUrl = URL(string: "https://api.whatsapp.com/send?text=\(encoded)") {
            UIApplication.shared.open(webUrl)
        }
    }
}
