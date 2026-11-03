//
//  VisionDocumentOCRService.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Apple Vision OCR Scanning Engine for Camera & Gallery Images
//

import UIKit
import Vision

public struct ParsedClientCardData {
    public var extractedName: String = ""
    public var extractedCompany: String = ""
    public var extractedEmail: String = ""
    public var extractedPhone: String = ""
    public var extractedGst: String = ""
    public var rawText: String = ""
}

public final class VisionDocumentOCRService {
    public static let shared = VisionDocumentOCRService()
    
    private init() {}
    
    public func recognizeText(from image: UIImage, completion: @escaping (ParsedClientCardData) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(ParsedClientCardData())
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                DispatchQueue.main.async { completion(ParsedClientCardData()) }
                return
            }
            
            var allLines: [String] = []
            for observation in observations {
                if let topCandidate = observation.topCandidates(1).first {
                    allLines.append(topCandidate.string)
                }
            }
            
            let fullText = allLines.joined(separator: "\n")
            let parsed = self.parseExtractedText(lines: allLines, fullText: fullText)
            
            DispatchQueue.main.async {
                completion(parsed)
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                DispatchQueue.main.async { completion(ParsedClientCardData()) }
            }
        }
    }
    
    private func parseExtractedText(lines: [String], fullText: String) -> ParsedClientCardData {
        var result = ParsedClientCardData()
        result.rawText = fullText
        
        // 1. Email Regex
        if let emailRange = fullText.range(of: #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}"#, options: .regularExpression) {
            result.extractedEmail = String(fullText[emailRange])
        }
        
        // 2. Phone / WhatsApp Regex
        if let phoneRange = fullText.range(of: #"(\+?[0-9]{1,3}[-.\s]?)?(\(?[0-9]{3,5}\)?[-.\s]?)?[0-9]{3,5}[-.\s]?[0-9]{4,6}"#, options: .regularExpression) {
            let phoneCandidate = String(fullText[phoneRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            if phoneCandidate.filter({ $0.isNumber }).count >= 8 {
                result.extractedPhone = phoneCandidate
            }
        }
        
        // 3. GST / Tax Number Regex (Indian 15-character GST: 2 digits + 10 alphanumeric PAN + 3 chars)
        if let gstRange = fullText.range(of: #"\b[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}\b"#, options: .regularExpression) {
            result.extractedGst = String(fullText[gstRange])
        }
        
        // 4. Name & Company heuristic
        for line in lines {
            let clean = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if clean.isEmpty || clean.contains("@") || clean.filter({ $0.isNumber }).count > 4 { continue }
            
            let lower = clean.lowercased()
            if lower.contains("pvt") || lower.contains("ltd") || lower.contains("technologies") || lower.contains("solutions") || lower.contains("services") || lower.contains("agency") || lower.contains("corp") || lower.contains("inc") {
                if result.extractedCompany.isEmpty {
                    result.extractedCompany = clean
                }
            } else if result.extractedName.isEmpty && clean.split(separator: " ").count in 2...4 {
                result.extractedName = clean
            }
        }
        
        return result
    }
}
