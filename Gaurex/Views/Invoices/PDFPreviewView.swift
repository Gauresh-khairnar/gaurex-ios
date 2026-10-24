//
//  PDFPreviewView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
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
    public let pdfData: Data
    public let documentTitle: String
    
    @State private var showingShareSheet = false
    
    public init(pdfData: Data, documentTitle: String) {
        self.pdfData = pdfData
        self.documentTitle = documentTitle
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                PDFKitRepresentedView(data: pdfData)
                    .edgesIgnoringSafeArea(.bottom)
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
                ActivityViewController(activityItems: [pdfData])
            }
        }
    }
    
    private func printPDF() {
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = documentTitle
        printController.printInfo = printInfo
        printController.printingItem = pdfData
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
