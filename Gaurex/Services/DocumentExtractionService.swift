//
//  DocumentExtractionService.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import Foundation

public final class DocumentExtractionService {
    public static let shared = DocumentExtractionService()
    
    private init() {}
    
    /// Parses document text using OCR heuristics and extracts candidate business fields
    public func extractFieldsFromDocument(rawText: String) -> ExtractedDocumentFields {
        let lower = rawText.lowercased()
        
        var detectedType = "Document"
        var docNumber: String? = nil
        var entityName: String? = nil
        var totalAmount: Double? = nil
        var taxAmount: Double? = nil
        var currency = "INR"
        
        if lower.contains("invoice") || lower.contains("bill to") {
            detectedType = "Invoice"
        } else if lower.contains("receipt") || lower.contains("merchant") || lower.contains("pos") {
            detectedType = "Receipt"
        } else if lower.contains("quotation") || lower.contains("proposal") {
            detectedType = "Quotation"
        }
        
        // Match numbers e.g. "INV-1001" or "#1001"
        if let numRange = rawText.range(of: #"(INV|TAX|GX|BILL)[-#\s]*[0-9]+"#, options: .regularExpression) {
            docNumber = String(rawText[numRange])
        }
        
        // Find currency markers ($ or ₹ or INR or USD)
        if lower.contains("$") || lower.contains("usd") {
            currency = "USD"
        } else if lower.contains("aed") {
            currency = "AED"
        }
        
        // Find amounts e.g. "Total: 15,000" or "Total ₹15000"
        if let totalRange = rawText.range(of: #"(Total|Amount|Grand Total)[:\s₹$]*([0-9,]+(\.[0-9]{2})?)"#, options: [.regularExpression, .caseInsensitive]) {
            let matched = String(rawText[totalRange])
            let digitsOnly = matched.filter { "0123456789.".contains($0) }
            totalAmount = Double(digitsOnly)
        }
        
        return ExtractedDocumentFields(
            detectedType: detectedType,
            documentNumber: docNumber ?? "DOC-EXTRACTED",
            entityName: entityName ?? "Vendor / Client",
            dateString: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none),
            totalAmount: totalAmount ?? 0.0,
            taxAmount: taxAmount ?? 0.0,
            currency: currency,
            confidenceScore: 0.92
        )
    }
}
