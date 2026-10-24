//
//  SecurityServices.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//

import Foundation
import LocalAuthentication
import Security

// MARK: - Biometric Authentication Service
public final class BiometricAuthService: ObservableObject {
    public static let shared = BiometricAuthService()
    
    @Published public var isUnlocked: Bool = false
    @Published public var biometricTypeString: String = "Face ID"
    
    private init() {
        determineBiometricType()
    }
    
    public func determineBiometricType() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                biometricTypeString = "Face ID"
            case .touchID:
                biometricTypeString = "Touch ID"
            case .opticID:
                biometricTypeString = "Optic ID"
            default:
                biometricTypeString = "Biometrics"
            }
        } else {
            biometricTypeString = "Passcode"
        }
    }
    
    public func authenticateOwner(reason: String = "Unlock GAUREX Executive Dashboard", completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                        completion(true, nil)
                    } else {
                        self.isUnlocked = false
                        completion(false, authError?.localizedDescription ?? "Authentication failed.")
                    }
                }
            }
        } else {
            // Fallback to device passcode
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authError in
                    DispatchQueue.main.async {
                        self.isUnlocked = success
                        completion(success, authError?.localizedDescription)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isUnlocked = true // Development mode or simulator without passcode
                    completion(true, nil)
                }
            }
        }
    }
    
    public func lockApp() {
        DispatchQueue.main.async {
            self.isUnlocked = false
        }
    }
}

// MARK: - Keychain Secure Storage Service
public final class KeychainService {
    public static let shared = KeychainService()
    private let serviceName = "com.gaurex.dashboard.keychain"
    
    private init() {}
    
    public func saveSecret(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        // Delete existing item if present
        deleteSecret(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    public func readSecret(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    @discardableResult
    public func deleteSecret(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
