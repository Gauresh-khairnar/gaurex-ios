//
//  DocumentExtractionView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  AI OCR Document Field Extractor Sheet
//

import SwiftUI

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
