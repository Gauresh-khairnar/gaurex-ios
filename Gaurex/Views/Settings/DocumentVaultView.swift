//
//  DocumentVaultView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import SwiftUI

public struct DocumentVaultView: View {
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory: DocumentCategory? = nil
    @State private var searchText = ""
    @State private var showingExtractor = false
    
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
                    // Search & Category Filters
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
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(theme.glassBorderColor, lineWidth: 1))
                        .padding(.horizontal, 16)
                        
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
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                    
                    if filteredDocuments.isEmpty {
                        EmptyStateView(
                            icon: "folder.badge.gearshape",
                            title: searchText.isEmpty ? "Vault is Empty" : "No Matching Documents",
                            description: searchText.isEmpty
                                ? "Import client contracts, legal agreements, vendor receipts, and company compliance files."
                                : "No documents match the search criteria.",
                            actionTitle: searchText.isEmpty ? "Scan / Import Document" : nil
                        ) {
                            showingExtractor = true
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(filteredDocuments) { doc in
                                    GlassCard(padding: 12) {
                                        HStack(spacing: 12) {
                                            Image(systemName: doc.category.iconName)
                                                .font(.system(size: 20))
                                                .foregroundColor(theme.accentColor)
                                                .frame(width: 36, height: 36)
                                                .background(theme.accentColor.opacity(0.12))
                                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(doc.title)
                                                    .font(.system(size: 14, weight: .semibold))
                                                Text("\(doc.category.rawValue) • \(doc.formattedSize)")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Text(doc.createdAt, style: .date)
                                                .font(.system(size: 10))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            Spacer().frame(height: 60)
                        }
                    }
                }
            }
            .navigationTitle("Document Vault")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingExtractor = true
                    } label: {
                        Image(systemName: "camera.badge.ellipsis")
                    }
                }
            }
            .sheet(isPresented: $showingExtractor) {
                DocumentExtractionView()
            }
        }
    }
}

public struct DocumentExtractionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = FirestoreDataStore.shared
    @ObservedObject private var theme = ThemeManager.shared
    
    @State private var sampleDocumentText: String = "TAX INVOICE #GX-INV-4029\nFrom: Cloudflare Enterprise CDN\nDate: 24 Oct 2026\nBill To: GAUREX\nDescription: High Availability Edge Security\nTotal: ₹42,500.00"
    @State private var candidateFields: ExtractedDocumentFields? = nil
    @State private var docTitle: String = "Cloudflare Enterprise CDN Invoice"
    @State private var selectedCategory: DocumentCategory = .invoice
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Source Document Simulation")) {
                    TextEditor(text: $sampleDocumentText)
                        .frame(minHeight: 80)
                        .font(.system(size: 12, design: .monospaced))
                    
                    Button("Extract Fields with AI OCR") {
                        let fields = DocumentExtractionService.shared.extractFieldsFromDocument(rawText: sampleDocumentText)
                        candidateFields = fields
                        docTitle = "\(fields.entityName ?? "Document") - \(fields.documentNumber ?? "")"
                    }
                    .font(.system(size: 13, weight: .bold))
                }
                
                if let fields = candidateFields {
                    Section(header: Text("AI Candidate Extractions (Review Required)")) {
                        HStack {
                            Text("Detected Type")
                            Spacer()
                            Text(fields.detectedType ?? "Unknown")
                                .fontWeight(.bold)
                        }
                        HStack {
                            Text("Document #")
                            Spacer()
                            Text(fields.documentNumber ?? "—")
                                .monospaced()
                        }
                        HStack {
                            Text("Extracted Total")
                            Spacer()
                            Text("₹\(String(format: "%.2f", fields.totalAmount ?? 0.0))")
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        HStack {
                            Text("Confidence Score")
                            Spacer()
                            Text("\(String(format: "%.0f%%", fields.confidenceScore * 100))")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Section(header: Text("Vault Archival")) {
                        TextField("Document Title", text: $docTitle)
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(DocumentCategory.allCases) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }
                    }
                }
            }
            .navigationTitle("AI Document Extraction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save to Vault") {
                        guard let fields = candidateFields else { return }
                        let doc = VaultDocument(
                            title: docTitle,
                            category: selectedCategory,
                            fileName: "\(docTitle).pdf",
                            fileSizeBytes: 245000,
                            extractedFields: fields
                        )
                        store.addVaultDocument(doc)
                        dismiss()
                    }
                    .disabled(candidateFields == nil)
                    .fontWeight(.bold)
                }
            }
        }
    }
}
