//
//  ClientAgreementPDFService.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Automated Legal Contract & Agreement Generation Engine (MSA, Milestone, NDA)
//

import UIKit
import PDFKit

public enum AgreementTemplateType: String, CaseIterable, Identifiable, Codable {
    case msa = "Master Services Agreement (MSA)"
    case milestone = "Project Milestone Contract"
    case nda = "Mutual Non-Disclosure Agreement (NDA)"
    
    public var id: String { rawValue }
    
    public var subtitle: String {
        switch self {
        case .msa: return "Comprehensive legal & deliverable framework for ongoing tech retainers."
        case .milestone: return "Fixed-deliverable scope with milestone-based payment tranches."
        case .nda: return "Strict mutual confidentiality and proprietary trade secret protection."
        }
    }
}

public struct AgreementCustomizationData {
    public var templateType: AgreementTemplateType
    public var scopeDescription: String
    public var paymentTermsOverride: String
    public var governingLaw: String
    public var clientSignatureImage: UIImage?
    public var biometricSeal: BiometricSealStamp?
    
    public init(
        templateType: AgreementTemplateType = .msa,
        scopeDescription: String = "",
        paymentTermsOverride: String = "",
        governingLaw: String = "Mumbai, Maharashtra, India",
        clientSignatureImage: UIImage? = nil,
        biometricSeal: BiometricSealStamp? = nil
    ) {
        self.templateType = templateType
        self.scopeDescription = scopeDescription
        self.paymentTermsOverride = paymentTermsOverride
        self.governingLaw = governingLaw
        self.clientSignatureImage = clientSignatureImage
        self.biometricSeal = biometricSeal
    }
}

public final class ClientAgreementPDFService {
    public static let shared = ClientAgreementPDFService()
    
    private init() {}
    
    public func generateAgreementPDF(
        client: Client,
        business: BusinessSettings = BusinessSettings(),
        customization: AgreementCustomizationData
    ) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "GAUREX Executive Legal Suite",
            kCGPDFContextAuthor: "Gauresh Khairnar (OWNER)",
            kCGPDFContextTitle: "\(customization.templateType.rawValue) - \(client.name)"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let margin: CGFloat = 42.0
        let contentWidth = pageWidth - (margin * 2)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        return renderer.pdfData { context in
            context.beginPage()
            var currentY: CGFloat = margin
            
            // 1. Top Decorative Brand Bar
            let brandBar = UIBezierPath(roundedRect: CGRect(x: margin, y: currentY, width: contentWidth, height: 4), cornerRadius: 2)
            UIColor(red: 0.23, green: 0.06, blue: 0.20, alpha: 1.0).setFill()
            brandBar.fill()
            currentY += 14
            
            // 2. Executive Header
            let titleFont = UIFont.systemFont(ofSize: 20, weight: .black)
            let titleText = business.companyName.uppercased()
            let titleAttrs: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: UIColor(red: 0.23, green: 0.06, blue: 0.20, alpha: 1.0)]
            titleText.draw(at: CGPoint(x: margin, y: currentY), withAttributes: titleAttrs)
            
            let goldAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: .bold),
                .foregroundColor: UIColor(red: 0.85, green: 0.62, blue: 0.05, alpha: 1.0)
            ]
            "[ EXECUTIVE LEGAL INSTRUMENT ]".draw(at: CGPoint(x: pageWidth - margin - 170, y: currentY + 6), withAttributes: goldAttrs)
            currentY += 30
            
            // 3. Agreement Document Title Banner
            let docBannerRect = CGRect(x: margin, y: currentY, width: contentWidth, height: 28)
            UIColor(white: 0.94, alpha: 1.0).setFill()
            UIBezierPath(roundedRect: docBannerRect, cornerRadius: 6).fill()
            
            let docTitleFont = UIFont.systemFont(ofSize: 11, weight: .heavy)
            let docTitleAttrs: [NSAttributedString.Key: Any] = [.font: docTitleFont, .foregroundColor: UIColor.black]
            customization.templateType.rawValue.uppercased().draw(at: CGPoint(x: margin + 12, y: currentY + 7), withAttributes: docTitleAttrs)
            
            let df = DateFormatter()
            df.dateFormat = "d MMMM yyyy"
            let dateStr = "Executed: \(df.string(from: Date()))"
            let dateFont = UIFont.systemFont(ofSize: 9.5, weight: .semibold)
            let dateSize = dateStr.size(withAttributes: [.font: dateFont])
            dateStr.draw(at: CGPoint(x: pageWidth - margin - dateSize.width - 12, y: currentY + 8), withAttributes: [.font: dateFont, .foregroundColor: UIColor.darkGray])
            currentY += 40
            
            // 4. Parties Involved (Dual Column)
            let colWidth = (contentWidth - 16) / 2
            let leftBox = CGRect(x: margin, y: currentY, width: colWidth, height: 90)
            let rightBox = CGRect(x: margin + colWidth + 16, y: currentY, width: colWidth, height: 90)
            
            UIColor(white: 0.97, alpha: 1.0).setFill()
            UIBezierPath(roundedRect: leftBox, cornerRadius: 8).fill()
            UIBezierPath(roundedRect: rightBox, cornerRadius: 8).fill()
            
            // Service Provider Details
            let partyHeadingFont = UIFont.systemFont(ofSize: 9, weight: .bold)
            let partyHeadingAttrs: [NSAttributedString.Key: Any] = [.font: partyHeadingFont, .foregroundColor: UIColor(red: 0.85, green: 0.62, blue: 0.05, alpha: 1.0)]
            "SERVICE PROVIDER (FIRST PARTY)".draw(at: CGPoint(x: leftBox.minX + 10, y: leftBox.minY + 8), withAttributes: partyHeadingAttrs)
            
            let providerDetails = "\(business.founderName)\nExecutive Founder & Owner, GAUREX\nEmail: info@gaurex.com\nJurisdiction: \(customization.governingLaw)"
            let textFont = UIFont.systemFont(ofSize: 8.5, weight: .regular)
            providerDetails.draw(in: CGRect(x: leftBox.minX + 10, y: leftBox.minY + 24, width: colWidth - 20, height: 60), withAttributes: [.font: textFont, .foregroundColor: UIColor.black])
            
            // Client Details
            "CLIENT / CUSTOMER (SECOND PARTY)".draw(at: CGPoint(x: rightBox.minX + 10, y: rightBox.minY + 8), withAttributes: partyHeadingAttrs)
            let clientCompany = client.companyName.isEmpty ? client.name : client.companyName
            let clientDetails = "\(client.name)\nOrganization: \(clientCompany)\nCategory: \(client.businessCategory)\nContact: \(client.phone) | \(client.email)"
            clientDetails.draw(in: CGRect(x: rightBox.minX + 10, y: rightBox.minY + 24, width: colWidth - 20, height: 60), withAttributes: [.font: textFont, .foregroundColor: UIColor.black])
            currentY += 104
            
            // 5. Commercials & Deliverables Summary Box
            let commRect = CGRect(x: margin, y: currentY, width: contentWidth, height: 50)
            UIColor(red: 0.23, green: 0.06, blue: 0.20, alpha: 0.06).setFill()
            UIBezierPath(roundedRect: commRect, cornerRadius: 8).fill()
            
            let commFont = UIFont.systemFont(ofSize: 9.5, weight: .bold)
            let cSym = business.currencySymbol
            let totalStr = "\(cSym)\(Int(client.totalInvoiced))"
            let advanceStr = "\(cSym)\(Int(client.totalCollected))"
            let balanceStr = "\(cSym)\(Int(client.outstandingBalance))"
            
            "TOTAL CONTRACT VALUE: \(totalStr)".draw(at: CGPoint(x: commRect.minX + 12, y: commRect.minY + 10), withAttributes: [.font: commFont, .foregroundColor: UIColor.black])
            "ADVANCE SETTLED: \(advanceStr)".draw(at: CGPoint(x: commRect.minX + 220, y: commRect.minY + 10), withAttributes: [.font: commFont, .foregroundColor: UIColor(red: 0.1, green: 0.6, blue: 0.2, alpha: 1.0)])
            "BALANCE PAYABLE: \(balanceStr)".draw(at: CGPoint(x: commRect.minX + 370, y: commRect.minY + 10), withAttributes: [.font: commFont, .foregroundColor: UIColor.red])
            
            let pTerms = customization.paymentTermsOverride.isEmpty ? "Standard net terms: 15 days upon milestone verification." : customization.paymentTermsOverride
            "Commercial Payment Terms: \(pTerms)".draw(at: CGPoint(x: commRect.minX + 12, y: commRect.minY + 28), withAttributes: [.font: UIFont.systemFont(ofSize: 8, weight: .medium), .foregroundColor: UIColor.darkGray])
            currentY += 62
            
            // 6. Contract Clauses
            let clauses = self.clausesForTemplate(customization.templateType, client: client, customization: customization)
            let clauseTitleFont = UIFont.systemFont(ofSize: 9, weight: .bold)
            let clauseBodyFont = UIFont.systemFont(ofSize: 8, weight: .regular)
            
            for (index, clause) in clauses.prefix(4).enumerated() {
                let heading = "\(index + 1). \(clause.title.uppercased())"
                heading.draw(at: CGPoint(x: margin, y: currentY), withAttributes: [.font: clauseTitleFont, .foregroundColor: UIColor.black])
                currentY += 13
                
                let bodyRect = CGRect(x: margin, y: currentY, width: contentWidth, height: 38)
                clause.body.draw(in: bodyRect, withAttributes: [.font: clauseBodyFont, .foregroundColor: UIColor(white: 0.25, alpha: 1.0)])
                currentY += 42
            }
            
            currentY = max(currentY, pageHeight - 160)
            
            // 7. Dual Signature Sign-Off Block
            let signY = currentY
            let sigWidth = (contentWidth - 40) / 2
            
            // Provider Signature (Gauresh Khairnar)
            let provSignRect = CGRect(x: margin, y: signY, width: sigWidth, height: 80)
            let clientSignRect = CGRect(x: margin + sigWidth + 40, y: signY, width: sigWidth, height: 80)
            
            let signLine1 = UIBezierPath()
            signLine1.move(to: CGPoint(x: provSignRect.minX, y: signY + 45))
            signLine1.addLine(to: CGPoint(x: provSignRect.maxX, y: signY + 45))
            UIColor.black.setStroke()
            signLine1.lineWidth = 0.8
            signLine1.stroke()
            
            let signLine2 = UIBezierPath()
            signLine2.move(to: CGPoint(x: clientSignRect.minX, y: signY + 45))
            signLine2.addLine(to: CGPoint(x: clientSignRect.maxX, y: signY + 45))
            signLine2.stroke()
            
            let sigTitleFont = UIFont.systemFont(ofSize: 8, weight: .bold)
            let sigSubFont = UIFont.systemFont(ofSize: 7.5, weight: .regular)
            
            "FIRST PARTY (PROVIDER)".draw(at: CGPoint(x: provSignRect.minX, y: signY + 50), withAttributes: [.font: sigTitleFont])
            "Gauresh Khairnar (OWNER), GAUREX".draw(at: CGPoint(x: provSignRect.minX, y: signY + 62), withAttributes: [.font: sigSubFont, .foregroundColor: UIColor.darkGray])
            
            "SECOND PARTY (CLIENT)".draw(at: CGPoint(x: clientSignRect.minX, y: signY + 50), withAttributes: [.font: sigTitleFont])
            "\(client.name), Authorized Representative".draw(at: CGPoint(x: clientSignRect.minX, y: signY + 62), withAttributes: [.font: sigSubFont, .foregroundColor: UIColor.darkGray])
            
            // If Client Signed in-app, render signature image above client sign line
            if let clientSig = customization.clientSignatureImage {
                let imgRect = CGRect(x: clientSignRect.minX + 10, y: signY - 2, width: 110, height: 42)
                clientSig.draw(in: imgRect)
            }
            
            // 8. Founder Biometric Seal & Watermark
            if let seal = customization.biometricSeal {
                let sealSize: CGFloat = 72.0
                let sealRect = CGRect(x: provSignRect.minX + 35, y: signY - 32, width: sealSize, height: sealSize)
                let goldColor = UIColor(red: 0.88, green: 0.64, blue: 0.05, alpha: 1.0)
                let plumColor = UIColor(red: 0.23, green: 0.06, blue: 0.20, alpha: 1.0)
                
                goldColor.setStroke()
                let outer = UIBezierPath(ovalIn: sealRect)
                outer.lineWidth = 1.6
                outer.stroke()
                
                let inner = UIBezierPath(ovalIn: sealRect.insetBy(dx: 3, dy: 3))
                inner.setLineDash([3, 2], count: 2, phase: 0)
                inner.lineWidth = 0.8
                inner.stroke()
                
                let gkFont = UIFont.systemFont(ofSize: 11, weight: .black)
                let gkText = "GK"
                let gkSize = gkText.size(withAttributes: [.font: gkFont])
                gkText.draw(at: CGPoint(x: sealRect.midX - gkSize.width / 2, y: sealRect.midY - 7), withAttributes: [.font: gkFont, .foregroundColor: plumColor])
                
                let sFont = UIFont.systemFont(ofSize: 5.5, weight: .black)
                "★ VERIFIED SEAL ★".draw(at: CGPoint(x: sealRect.midX - 22, y: sealRect.minY + 9), withAttributes: [.font: sFont, .foregroundColor: goldColor])
                "\(seal.biometricType.uppercased())".draw(at: CGPoint(x: sealRect.midX - 14, y: sealRect.maxY - 16), withAttributes: [.font: sFont, .foregroundColor: goldColor])
                
                // Cryptographic verification string
                let hashAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.monospacedSystemFont(ofSize: 5.8, weight: .medium),
                    .foregroundColor: UIColor.darkGray
                ]
                "SECURED BY \(seal.biometricType.uppercased()) • \(seal.hashSignature)".draw(at: CGPoint(x: margin, y: pageHeight - margin + 8), withAttributes: hashAttrs)
            }
        }
    }
    
    private func clausesForTemplate(_ type: AgreementTemplateType, client: Client, customization: AgreementCustomizationData) -> [(title: String, body: String)] {
        let clientCompany = client.companyName.isEmpty ? client.name : client.companyName
        let scope = customization.scopeDescription.isEmpty
            ? "Comprehensive engineering, digital transformation, and business consulting deliverables as mutually specified."
            : customization.scopeDescription
        
        switch type {
        case .msa:
            return [
                ("Scope of Deliverables & Services", "The Service Provider shall execute the project deliverables: \(scope). Any revisions, enhancements, or additional scope shall be documented via formal addendum."),
                ("Intellectual Property & Licensing", "All bespoke code, architecture diagrams, and custom artifacts developed hereunder shall transfer to \(clientCompany) exclusively upon receipt of final contract settlement."),
                ("Confidentiality & Non-Disclosure", "Both parties agree to treat all business records, proprietary methodologies, trade secrets, and financial details as strictly confidential with indefinite validity."),
                ("Termination & Dispute Resolution", "Either party may terminate upon 14 days written notice. All disputes shall be subject to the exclusive jurisdiction of the courts of \(customization.governingLaw).")
            ]
        case .milestone:
            return [
                ("Milestone Phasing & Acceptance", "Project deliverables shall be delivered in progressive milestone sprints: \(scope). Acceptance shall be deemed confirmed upon 5 working days of staging deployment."),
                ("Milestone Payment Tranches", "Payments shall be released strictly in accordance with certified milestones: Advance payment prior to commencement, with final balance payable on handover."),
                ("Defect Warranty & SLA", "Service Provider provides a 90-day defect correction warranty following production deployment covering all core functional specifications."),
                ("Governing Law & Legal Venue", "This contract shall be construed in accordance with the statutory laws of \(customization.governingLaw).")
            ]
        case .nda:
            return [
                ("Definition of Confidential Material", "Confidential information includes, without limitation, source code, financial spreadsheets, client rosters, and technical architectures disclosed between GAUREX and \(clientCompany)."),
                ("Non-Use & Protection Standard", "The receiving party agrees to hold all disclosed trade secrets with the highest degree of fiduciary care and refrain from unauthorized duplication or commercial derivation."),
                ("Exclusions from Protection", "Obligations shall not apply to information that is already in public domain, independently developed, or mandated for legal disclosure under statutory judicial order."),
                ("Term & Return of Materials", "This covenant remains binding for three (3) calendar years from execution. Upon termination, all confidential documents shall be destroyed or returned.")
            ]
        }
    }
}
