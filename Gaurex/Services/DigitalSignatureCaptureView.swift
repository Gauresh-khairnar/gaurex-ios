//
//  DigitalSignatureCaptureView.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Executive In-App Dual Digital Signature Pad for Client & Founder
//

import SwiftUI
import UIKit

public struct SignatureDrawingPad: View {
    @Binding public var lines: [[CGPoint]]
    @State private var currentLine: [CGPoint] = []
    
    public init(lines: Binding<[[CGPoint]]>) {
        self._lines = lines
    }
    
    public var body: some View {
        Canvas { context, size in
            for line in lines {
                var path = Path()
                guard let first = line.first else { continue }
                path.move(to: first)
                for pt in line.dropFirst() {
                    path.addLine(to: pt)
                }
                context.stroke(path, with: .color(Color(red: 0.12, green: 0.12, blue: 0.35)), lineWidth: 2.5)
            }
            
            var currentPath = Path()
            if let first = currentLine.first {
                currentPath.move(to: first)
                for pt in currentLine.dropFirst() {
                    currentPath.addLine(to: pt)
                }
                context.stroke(currentPath, with: .color(Color(red: 0.12, green: 0.12, blue: 0.35)), lineWidth: 2.5)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    currentLine.append(value.location)
                }
                .onEnded { _ in
                    if !currentLine.isEmpty {
                        lines.append(currentLine)
                        currentLine = []
                    }
                }
        )
    }
}

public struct DigitalSignatureCaptureModal: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    public let signerTitle: String
    public let signerSubtitle: String
    public let onSave: (UIImage) -> Void
    
    @State private var lines: [[CGPoint]] = []
    
    private let deepPurple = Color.gaurexDeepPlum
    private let goldAccent = Color.gaurexWarmGold
    
    public init(
        signerTitle: String = "Client Digital Signature",
        signerSubtitle: String = "Please sign with finger or Apple Pencil to execute contract.",
        onSave: @escaping (UIImage) -> Void
    ) {
        self.signerTitle = signerTitle
        self.signerSubtitle = signerSubtitle
        self.onSave = onSave
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "signature")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(goldAccent)
                        Text(signerTitle)
                            .font(.pjs(18, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .white : deepPurple)
                    }
                    Text(signerSubtitle)
                        .font(.pjs(12, weight: .regular))
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 12)
                
                // Signature Canvas Container
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(goldAccent.opacity(0.4), lineWidth: 1.5)
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                    
                    // Signature Line Guide
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(Color.gray.opacity(0.35))
                            .frame(height: 1)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 38)
                    }
                    
                    SignatureDrawingPad(lines: $lines)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    if lines.isEmpty {
                        Text("Sign on line above")
                            .font(.pjs(13, weight: .medium))
                            .foregroundColor(Color.gray.opacity(0.5))
                            .padding(.bottom, 16)
                    }
                }
                .frame(height: 240)
                .padding(.horizontal, 20)
                
                // Action Buttons
                HStack(spacing: 14) {
                    Button {
                        lines.removeAll()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Clear")
                                .font(.pjs(13, weight: .semibold))
                        }
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color(uiColor: .secondarySystemBackground))
                        )
                    }
                    
                    Button {
                        exportSignature()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill")
                            Text("Confirm & Stamp")
                                .font(.pjs(13, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [deepPurple, Color(red: 0.35, green: 0.10, blue: 0.30)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(goldAccent, lineWidth: 1.0)
                        )
                    }
                    .disabled(lines.isEmpty)
                    .opacity(lines.isEmpty ? 0.5 : 1.0)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.fraction(0.55)])
    }
    
    private func exportSignature() {
        let size = CGSize(width: 400, height: 240)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            // Transparent background
            UIColor.clear.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            
            let strokeColor = UIColor(red: 0.12, green: 0.12, blue: 0.35, alpha: 1.0)
            strokeColor.setStroke()
            
            for line in lines {
                guard let first = line.first else { continue }
                let path = UIBezierPath()
                path.lineWidth = 3.0
                path.lineCapStyle = .round
                path.lineJoinStyle = .round
                path.move(to: first)
                for pt in line.dropFirst() {
                    path.addLine(to: pt)
                }
                path.stroke()
            }
        }
        
        onSave(image)
        dismiss()
    }
}
