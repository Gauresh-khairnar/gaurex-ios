//
//  DocumentVaultView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Executive Document Vault with Native Camera Scan & Gallery Upload
//

import SwiftUI
import UIKit

public struct DocumentVaultView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedCategory: DocumentCategory? = nil
    @State private var searchText = ""
    @State private var showingUploadModal = false
    @State private var docToDelete: VaultDocument? = nil
    @State private var showingDeleteDocAlert = false
    @State private var selectedDocForPreview: VaultDocument? = nil
    
    public init() {}
    
    private var filteredDocuments: [VaultDocument] {
        var list = store.vaultDocuments
        if let cat = selectedCategory {
            list = list.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            list = list.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.fileName.localizedCaseInsensitiveContains(searchText) }
        }
        return list
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    searchAndFilterHeader
                    
                    Divider()
                    
                    cameraGalleryActionBanner
                    
                    documentListView
                }
            }
            .navigationTitle("Document Vault")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("Delete Document?", isPresented: $showingDeleteDocAlert, titleVisibility: .visible) {
                Button("Delete Document", role: .destructive) {
                    if let d = docToDelete {
                        withAnimation {
                            store.deleteDocument(id: d.id)
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to permanently delete '\(docToDelete?.title ?? "this document")'?")
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingUploadModal = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add")
                        }
                        .font(.system(size: 14, weight: .bold))
                    }
                }
            }
            .sheet(isPresented: $showingUploadModal) {
                VaultDocumentUploaderSheet()
            }
            .sheet(item: $selectedDocForPreview) { doc in
                DocumentAttachmentPreviewModal(doc: doc)
            }
        }
    }
    
    // MARK: - Subviews to optimize Swift compile times
    @ViewBuilder
    private var searchAndFilterHeader: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search documents, contracts, receipts...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
            }
            .padding(10)
            .background(theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "All (\(store.vaultDocuments.count))", isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }
                    ForEach(DocumentCategory.allCases) { cat in
                        let count = store.vaultDocuments.filter { $0.category == cat }.count
                        FilterChip(title: "\(cat.rawValue) (\(count))", isSelected: selectedCategory == cat) {
                            selectedCategory = cat
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
    
    @ViewBuilder
    private var cameraGalleryActionBanner: some View {
        HStack(spacing: 12) {
            Button {
                showingUploadModal = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "camera.fill")
                        .foregroundColor(.white)
                    Text("Scan via Camera")
                        .font(.pjs(12.5, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(Color.gaurexDeepPlum)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            
            Button {
                showingUploadModal = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .foregroundColor(Color.gaurexDeepPlum)
                    Text("Upload Gallery")
                        .font(.pjs(12.5, weight: .bold))
                        .foregroundColor(Color.gaurexDeepPlum)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(Color.gaurexWarmGold.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gaurexWarmGold.opacity(0.4), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
    
    @ViewBuilder
    private var documentListView: some View {
        if filteredDocuments.isEmpty {
            EmptyStateView(
                icon: "doc.text.magnifyingglass",
                title: "Vault is Empty",
                description: searchText.isEmpty ? "Tap 'Scan via Camera' or 'Upload Gallery' to add business contracts, GST certificates, and receipts." : "No documents match '\(searchText)'",
                actionTitle: searchText.isEmpty ? "Add First Document" : nil,
                action: {
                    showingUploadModal = true
                }
            )
            .frame(maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(filteredDocuments) { doc in
                        documentCard(for: doc)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                Spacer().frame(height: 60)
            }
        }
    }
    
    @ViewBuilder
    private func documentCard(for doc: VaultDocument) -> some View {
        Button {
            selectedDocForPreview = doc
        } label: {
            GlassCard(padding: 12) {
                HStack(spacing: 12) {
                    Image(systemName: doc.category.iconName)
                        .font(.system(size: 20))
                        .foregroundColor(Color.gaurexWarmGold)
                        .frame(width: 38, height: 38)
                        .background(Color.gaurexDeepPlum.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(doc.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                        Text("\(doc.category.rawValue) • \(doc.formattedSize)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(doc.createdAt, style: .date)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        
                        Button(role: .destructive) {
                            docToDelete = doc
                            showingDeleteDocAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 11))
                                .foregroundColor(.red.opacity(0.85))
                                .padding(5)
                                .background(Color.red.opacity(0.08))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                docToDelete = doc
                showingDeleteDocAlert = true
            } label: {
                Label("Delete Document", systemImage: "trash")
            }
        }
    }
}

// MARK: - Dedicated Camera & Gallery Uploader Modal for Document Vault
public struct VaultDocumentUploaderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var store = FirestoreDataStore.shared
    
    @State private var showingPicker = false
    @State private var pickerSource: MediaPickerSource = .camera
    @State private var selectedImage: UIImage? = nil
    
    @State private var docTitle: String = ""
    @State private var selectedCategory: DocumentCategory = .contract
    @State private var relatedClientName: String = ""
    @State private var isProcessingOCR = false
    @State private var extractedData: ParsedClientCardData? = nil
    
    private let deepPurple = Color.gaurexDeepPlum
    private let goldAccent = Color.gaurexWarmGold
    
    public init() {}
    
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
                            Text("Add Document to Vault")
                                .font(.pjs(18, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                            Text("Capture with camera or select from photo library")
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
                    
                    // Source Selection Buttons
                    HStack(spacing: 14) {
                        Button {
                            pickerSource = .camera
                            showingPicker = true
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(deepPurple)
                                Text("Camera Scan")
                                    .font(.pjs(13, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
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
                                    .font(.system(size: 26))
                                    .foregroundColor(goldAccent)
                                Text("Photo Gallery")
                                    .font(.pjs(13, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
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
                    
                    // Preview of captured image
                    if let img = selectedImage {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("DOCUMENT PREVIEW")
                                .font(.pjs(10, weight: .bold))
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                            
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            if isProcessingOCR {
                                HStack(spacing: 8) {
                                    ProgressView().tint(goldAccent)
                                    Text("Apple Vision OCR scanning...")
                                        .font(.pjs(11, weight: .medium))
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                }
                            } else if let ocr = extractedData, !ocr.rawText.isEmpty {
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                        Text("Vision OCR Extracted").font(.pjs(11, weight: .bold))
                                    }
                                    if !ocr.extractedCompany.isEmpty {
                                        Text("Entity: \(ocr.extractedCompany)").font(.pjs(11, weight: .medium))
                                    }
                                    if !ocr.extractedGst.isEmpty {
                                        Text("GSTIN: \(ocr.extractedGst)").font(.pjs(11, weight: .medium))
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
                    
                    // Metadata Configuration Form
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("DOCUMENT TITLE *")
                                .font(.pjs(10, weight: .bold))
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                            TextField("e.g. GST Registration Certificate", text: $docTitle)
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
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("LINK TO CLIENT (OPTIONAL)")
                                .font(.pjs(10, weight: .bold))
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                            Picker("Link Client", selection: $relatedClientName) {
                                Text("None / General Business").tag("")
                                ForEach(store.clients) { c in
                                    Text(c.name).tag(c.name)
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
                        saveDocumentToVault()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.shield.fill")
                            Text("Save to Document Vault")
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
                    }
                    .disabled(selectedImage == nil || docTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity((selectedImage != nil && !docTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? 1.0 : 0.5)
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
            .navigationTitle("Add Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showingPicker) {
                NativeMediaPicker(sourceType: pickerSource) { image in
                    self.selectedImage = image
                    self.isProcessingOCR = true
                    VisionDocumentOCRService.shared.recognizeText(from: image) { parsed in
                        self.isProcessingOCR = false
                        self.extractedData = parsed
                        if self.docTitle.isEmpty {
                            if !parsed.extractedCompany.isEmpty {
                                self.docTitle = "\(parsed.extractedCompany) Document"
                            } else {
                                self.docTitle = "\(selectedCategory.rawValue) Scan"
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func saveDocumentToVault() {
        guard let img = selectedImage, let imgData = img.jpegData(compressionQuality: 0.8) else { return }
        
        let fileName = "VAULT_\(UUID().uuidString.prefix(8)).jpg"
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        try? imgData.write(to: fileURL)
        
        let linkedClient = store.clients.first(where: { $0.name == relatedClientName })
        var tags = [selectedCategory.rawValue]
        if !relatedClientName.isEmpty { tags.append(relatedClientName) }
        
        let doc = VaultDocument(
            title: docTitle,
            category: selectedCategory,
            fileName: fileName,
            fileSizeBytes: imgData.count,
            mimeType: "image/jpeg",
            tags: tags,
            relatedEntityId: linkedClient?.id,
            extractedFields: ExtractedDocumentFields(
                detectedType: selectedCategory.rawValue,
                documentNumber: extractedData?.extractedGst ?? "DOC-\(UUID().uuidString.prefix(6))",
                entityName: relatedClientName.isEmpty ? "GAUREX" : relatedClientName,
                dateString: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none),
                totalAmount: 0.0,
                taxAmount: 0.0,
                currency: "INR",
                confidenceScore: 0.95
            )
        )
        
        store.addVaultDocument(doc)
        store.showToast(title: "Document Saved to Vault")
        dismiss()
    }
}
