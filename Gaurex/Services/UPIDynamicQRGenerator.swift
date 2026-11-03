//
//  UPIDynamicQRGenerator.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Native Dynamic UPI Payment Gateway & QR Code Generator (NPCI Protocol)
//

import UIKit
import CoreImage

public final class UPIDynamicQRGenerator {
    public static let shared = UPIDynamicQRGenerator()
    private let context = CIContext()
    
    // Official Executive Founder UPI Configuration
    public let defaultUPIId: String = "9579098477@slc"
    public let defaultPayeeName: String = "Gauresh Khairnar"
    public let companyName: String = "GAUREX"
    
    private init() {}
    
    /// Generates standard NPCI-compliant UPI payment intent string:
    /// upi://pay?pa=9579098477@slc&pn=Gauresh%20Khairnar&am=50000.00&cu=INR&tn=Invoice%20Settlement
    public func generateUPIURLString(
        upiId: String? = nil,
        payeeName: String? = nil,
        amount: Double,
        transactionNote: String
    ) -> String {
        let pa = upiId ?? defaultUPIId
        let pn = (payeeName ?? defaultPayeeName).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Gauresh Khairnar"
        let tn = transactionNote.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "GAUREX Executive Payment"
        let am = String(format: "%.2f", max(1.0, amount))
        
        return "upi://pay?pa=\(pa)&pn=\(pn)&am=\(am)&cu=INR&tn=\(tn)"
    }
    
    /// Generates high-resolution, pixel-crisp UIImage QR Code for the specific payment amount
    public func generateQRCodeImage(
        amount: Double,
        transactionNote: String,
        upiId: String? = nil
    ) -> UIImage? {
        let upiURI = generateUPIURLString(upiId: upiId, amount: amount, transactionNote: transactionNote)
        guard let data = upiURI.data(using: .utf8) else { return nil }
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel") // 30% error resilience
        
        guard let outputCI = filter.outputImage else { return nil }
        
        // Upscale transform to avoid pixelation on high-DPI Retina screens
        let scaleX: CGFloat = 12.0
        let scaleY: CGFloat = 12.0
        let transformedCI = outputCI.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        guard let cgImage = context.createCGImage(transformedCI, from: transformedCI.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
