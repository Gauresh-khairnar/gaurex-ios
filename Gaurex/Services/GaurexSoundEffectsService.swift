//
//  GaurexSoundEffectsService.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Bespoke Executive Acoustic Sound Design (Cash Bell, Sub-Bass Click, Air Release)
//

import UIKit
import AudioToolbox
import AVFoundation

public final class GaurexSoundEffectsService {
    public static let shared = GaurexSoundEffectsService()
    
    private init() {}
    
    /// 1. Cash Register Bell: Fired when an invoice is marked paid or cash inflow settles
    public func playCashSettledSound() {
        // Taptic feedback
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        
        // System chime: Resonant high-register settlement bell (ID 1054: AudioServicesPlaySystemSound)
        AudioServicesPlaySystemSound(1054)
    }
    
    /// 2. Sub-Bass Mechanical Latch Click: Fired when toggling Ghost Mode / Stealth Privacy
    public func playStealthModeClick() {
        // Heavy rigid haptic impact
        let feedback = UIImpactFeedbackGenerator(style: .rigid)
        feedback.impactOccurred()
        
        // System tone: Tactile mechanical switch (ID 1104)
        AudioServicesPlaySystemSound(1104)
    }
    
    /// 3. Soft Air Release Chime: Fired when marking a high-leverage milestone or task complete
    public func playMilestoneCompletedSound() {
        // Soft medium haptic pulse
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.impactOccurred()
        
        // System tone: Soft whoosh / air confirmation chime (ID 1025)
        AudioServicesPlaySystemSound(1025)
    }
    
    /// 4. Cryptographic Biometric Seal Chime: Fired when stamping Face ID digital watermark
    public func playBiometricSealSound() {
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        
        // Resonant lock chime (ID 1022 / 1001)
        AudioServicesPlaySystemSound(1022)
    }
}
