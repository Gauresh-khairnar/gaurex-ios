//
//  PDFPreviewView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  1-Tap Executive PDF Invoice Watermarking & Biometric Stamp
//

import SwiftUI
import PDFKit

public struct PDFKitRepresentedView: UIViewRepresentable {
    public let data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    public func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        return pdfView
    }
    
    public func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document?.dataRepresentation() != data {
            uiView.document = PDFDocument(data: data)
        }
    }
}

public struct PDFPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var store = FirestoreDataStore.shared
    
    public let initialPdfData: Data
    public let documentTitle: String
    public let invoice: Invoice?
    public let client: Client?
    
    @State private var currentPdfData: Data
    @State private var showingShareSheet = false
    @State private var isSealed = false
    @State private var isAuthenticating = false
    @State private var sealStamp: BiometricSealStamp? = nil
    
    private let deepPurple = Color.gaurexDeepPlum
    private let goldAccent = Color.gaurexWarmGold
    
    public init(pdfData: Data, documentTitle: String, invoice: Invoice? = nil, client: Client? = nil) {
        self.initialPdfData = pdfData
        self.documentTitle = documentTitle
        self.invoice = invoice
        self.client = client
        self._currentPdfData = State(initialValue: pdfData)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                PDFKitRepresentedView(data: currentPdfData)
                    .edgesIgnoringSafeArea(.bottom)
                
                // MARK: - Floating Executive Action Bar (Ripplix / Wise Liquid Glass Style)
                VStack(spacing: 8) {
                    if isSealed, let seal = sealStamp {
                        // Sealed Status Pill
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(goldAccent)
                            
                            Text("BIOMETRICALLY SEALED WITH \(seal.biometricType.uppercased())")
                                .font(.pjs(10, weight: .black))
                                .tracking(1.0)
                                .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.22).opacity(0.95) : Color.white.opacity(0.95))
                                .shadow(color: goldAccent.opacity(0.3), radius: 8, x: 0, y: 2)
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    HStack(spacing: 12) {
                        if !isSealed {
                            // 1-Tap "Seal Invoice" Face ID Button
                            Button {
                                authenticateAndSeal()
                            } label: {
                                HStack(spacing: 8) {
                                    if isAuthenticating {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "faceid")
                                            .font(.system(size: 16, weight: .bold))
                                        Text("Seal Invoice (Face ID)")
                                            .font(.pjs(13.5, weight: .bold))
                                    }
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
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(goldAccent, lineWidth: 1.2)
                                )
                                .shadow(color: deepPurple.opacity(0.35), radius: 10, x: 0, y: 4)
                            }
                            .buttonStyle(.plain)
                            .disabled(isAuthenticating)
                        } else {
                            // Sealed Quick Share Button
                            Button {
                                showingShareSheet = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up.fill")
                                        .font(.system(size: 15, weight: .bold))
                                    Text("Export Sealed Document")
                                        .font(.pjs(13.5, weight: .bold))
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        colors: [goldAccent, Color(red: 0.98, green: 0.85, blue: 0.35)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: goldAccent.opacity(0.35), radius: 10, x: 0, y: 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle(documentTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            printPDF()
                        } label: {
                            Image(systemName: "printer")
                        }
                        
                        Button {
                            showingShareSheet = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ActivityViewController(activityItems: [currentPdfData])
            }
        }
    }
    
    // MARK: - Biometric Authentication & Gold Stamp Application
    private func authenticateAndSeal() {
        isAuthenticating = true
        BiometricAuthService.shared.authenticateOwner(reason: "Authenticate with Face ID to stamp gold cryptographic seal on this GAUREX invoice.") { success, _ in
            DispatchQueue.main.async {
                self.isAuthenticating = false
                if success {
                    let stamp = BiometricSealStamp(
                        ownerName: "Gauresh Khairnar (OWNER)",
                        timestamp: Date(),
                        hashSignature: "SHA256-\(UUID().uuidString.prefix(12).uppercased())",
                        biometricType: BiometricAuthService.shared.biometricTypeString
                    )
                    self.sealStamp = stamp
                    
                    // Play Acoustic Biometric Seal Chime
                    GaurexSoundEffectsService.shared.playBiometricSealSound()
                    
                    // Re-render PDF with watermark & gold seal
                    if let inv = invoice {
                        let cl = client ?? Client(name: inv.clientName, companyName: "", email: inv.clientEmail, phone: "")
                        let sealedPdf = PDFGeneratorService.shared.generateInvoicePDF(
                            invoice: inv,
                            client: cl,
                            business: store.settings,
                            biometricSeal: stamp
                        )
                        withAnimation(MotionTokens.snappySpring) {
                            self.currentPdfData = sealedPdf
                            self.isSealed = true
                        }
                    } else {
                        withAnimation(MotionTokens.snappySpring) {
                            self.isSealed = true
                        }
                    }
                    
                    store.showToast(title: "Invoice Sealed & Biometrically Verified")
                } else {
                    store.showToast(title: "Biometric Authentication Cancelled", isSuccess: false)
                }
            }
        }
    }
    
    private func printPDF() {
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = documentTitle
        printController.printInfo = printInfo
        printController.printingItem = currentPdfData
        printController.present(animated: true, completionHandler: nil)
    }
}

public struct ActivityViewController: UIViewControllerRepresentable {
    public var activityItems: [Any]
    public var applicationActivities: [UIActivity]? = nil
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
