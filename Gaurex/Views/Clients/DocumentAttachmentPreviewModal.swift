//
//  DocumentAttachmentPreviewModal.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Executive Full-Screen Interactive Document & Photo Viewer
//

import SwiftUI
import PDFKit

public struct DocumentAttachmentPreviewModal: View {
    @Environment(\.dismiss) private var dismiss
    public let doc: VaultDocument
    
    @State private var showingShareSheet = false
    
    public init(doc: VaultDocument) {
        self.doc = doc
    }
    
    private var localFileURL: URL? {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let candidate = docs.appendingPathComponent(doc.fileName)
        if FileManager.default.fileExists(atPath: candidate.path) {
            return candidate
        }
        return nil
    }
    
    private var loadedImage: UIImage? {
        guard let url = localFileURL, let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
    
    private var loadedPDFData: Data? {
        guard let url = localFileURL, let data = try? Data(contentsOf: url) else { return nil }
        return data
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if doc.mimeType == "image/jpeg" || doc.mimeType == "image/png", let img = loadedImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .padding()
                } else if doc.mimeType == "application/pdf", let pdfData = loadedPDFData {
                    PDFKitRepresentedView(data: pdfData)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: doc.category.iconName)
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.7))
                        Text(doc.title)
                            .font(.pjs(16, weight: .bold))
                            .foregroundColor(.white)
                        Text("Size: \(doc.fileSizeBytes / 1024) KB • \(doc.category.rawValue)")
                            .font(.pjs(12, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle(doc.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let url = localFileURL {
                        Button {
                            showingShareSheet = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = localFileURL {
                    ActivityViewController(activityItems: [url])
                }
            }
        }
    }
}
