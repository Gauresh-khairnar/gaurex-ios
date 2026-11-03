//
//  ClientDocumentScannerSheet.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Executive Document Attachment Scanner & Vault Uploader
//

import SwiftUI
import UIKit

public struct ClientDocumentScannerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var store = FirestoreDataStore.shared
    
    public let client: Client
    
    @State private var showingPicker = false
    @State private var pickerSource: MediaPickerSource = .camera
    @State private var selectedImage: UIImage? = nil
    
    @State private var docTitle: String = ""
    @State private var selectedCategory: DocumentCategory = .contract
    @State private var ocrTextExtracted: String = ""
    @State private var isProcessingOCR = false
    @State private var extractedFieldsPreview: ParsedClientCardData? = nil
    
    private let deepPurple = Color.gaurexDeepPlum
    private let goldAccent = Color.gaurexWarmGold
    
    public init(client: Client) {
        self.client = client
        self._docTitle = State(initialValue: "Document - \(client.name)")
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    HStack(spacing: 12) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(goldAccent)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Scan & Attach Document")
                                .font(.pjs(18, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                            Text("Attach for \(client.name)")
                                .font(.pjs(12, weight: .regular))
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.22) : Color.white)
                    )
                    
                    // Capture Options (Camera vs Gallery)
                    HStack(spacing: 14) {
                        Button {
                            pickerSource = .camera
                            showingPicker = true
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(deepPurple)
                                Text("Camera Scan")
                                    .font(.pjs(13, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.24) : Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(goldAccent.opacity(0.4), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            pickerSource = .photoLibrary
                            showingPicker = true
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 24))
                                    .foregroundColor(goldAccent)
                                Text("Photo Gallery")
                                    .font(.pjs(13, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.24) : Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(goldAccent.opacity(0.4), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Selected Image Preview
                    if let image = selectedImage {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("CAPTURED ATTACHMENT")
                                .font(.pjs(10, weight: .bold))
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                            
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            
                            if isProcessingOCR {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .tint(goldAccent)
                                    Text("Apple Vision OCR scanning text...")
                                        .font(.pjs(11, weight: .medium))
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                }
                                .padding(.top, 4)
                            } else if let ocr = extractedFieldsPreview, !ocr.rawText.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Image(systemName: "text.viewfinder")
                                            .foregroundColor(goldAccent)
                                        Text("Vision OCR Extracted Metadata")
                                            .font(.pjs(11, weight: .bold))
                                    }
                                    if !ocr.extractedGst.isEmpty {
                                        Text("GSTIN: \(ocr.extractedGst)")
                                            .font(.pjs(11, weight: .medium))
                                    }
                                    if !ocr.extractedEmail.isEmpty {
                                        Text("Email: \(ocr.extractedEmail)")
                                            .font(.pjs(11, weight: .medium))
                                    }
                                }
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color.green.opacity(0.12)))
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(colorScheme == .dark ? Color(red: 0.14, green: 0.14, blue: 0.18) : Color.white)
                        )
                    }
                    
                    // Metadata Configuration
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("DOCUMENT TITLE")
                                .font(.pjs(10, weight: .bold))
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                            TextField("Enter title", text: $docTitle)
                                .textFieldStyle(.roundedBorder)
                                .font(.pjs(13, weight: .medium))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CATEGORY")
                                .font(.pjs(10, weight: .bold))
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                            
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(DocumentCategory.allCases) { cat in
                                    Text(cat.rawValue).tag(cat)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(6)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.1)))
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.22) : Color.white)
                    )
                    
                    // Save Button
                    Button {
                        saveScannedDocument()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.down.doc.fill")
                            Text("Save to Client Vault")
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
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(goldAccent, lineWidth: 1))
                        .shadow(color: deepPurple.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .disabled(selectedImage == nil)
                    .opacity(selectedImage == nil ? 0.5 : 1.0)
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
            .navigationTitle("Attach Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingPicker) {
                NativeMediaPicker(sourceType: pickerSource) { image in
                    self.selectedImage = image
                    self.processVisionOCR(image: image)
                }
            }
        }
    }
    
    private func processVisionOCR(image: UIImage) {
        isProcessingOCR = true
        VisionDocumentOCRService.shared.recognizeText(from: image) { parsed in
            self.isProcessingOCR = false
            self.extractedFieldsPreview = parsed
            self.ocrTextExtracted = parsed.rawText
            if !parsed.extractedCompany.isEmpty && self.docTitle.hasPrefix("Document -") {
                self.docTitle = "\(parsed.extractedCompany) Document"
            }
        }
    }
    
    private func saveScannedDocument() {
        guard let img = selectedImage, let imgData = img.jpegData(compressionQuality: 0.8) else { return }
        
        // Save image to local app documents directory
        let fileName = "CLIENT_\(client.id.prefix(6))_\(UUID().uuidString.prefix(8)).jpg"
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        try? imgData.write(to: fileURL)
        
        let vaultDoc = VaultDocument(
            title: docTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Scanned Document" : docTitle,
            category: selectedCategory,
            fileName: fileName,
            fileSizeBytes: imgData.count,
            mimeType: "image/jpeg",
            tags: [client.name, selectedCategory.rawValue],
            relatedEntityId: client.id,
            extractedFields: ExtractedDocumentFields(
                detectedType: selectedCategory.rawValue,
                documentNumber: extractedFieldsPreview?.extractedGst ?? "DOC-\(UUID().uuidString.prefix(6))",
                entityName: client.name,
                dateString: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none),
                totalAmount: 0.0,
                taxAmount: 0.0,
                currency: "INR",
                confidenceScore: 0.95
            )
        )
        
        store.addVaultDocument(vaultDoc)
        store.showToast(title: "Document Attached to \(client.name)")
        dismiss()
    }
}
