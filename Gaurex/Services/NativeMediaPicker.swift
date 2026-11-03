//
//  NativeMediaPicker.swift
//  GAUREX Dashboard
//  Founder & Owner: Gauresh Khairnar (OWNER)
//  Native Camera & Photo Gallery Picker via UIViewControllerRepresentable
//

import SwiftUI
import UIKit
import PhotosUI

public enum MediaPickerSource {
    case camera
    case photoLibrary
}

public struct NativeMediaPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    public let sourceType: MediaPickerSource
    public let onImagePicked: (UIImage) -> Void
    
    public init(sourceType: MediaPickerSource, onImagePicked: @escaping (UIImage) -> Void) {
        self.sourceType = sourceType
        self.onImagePicked = onImagePicked
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIViewController(context: Context) -> UIViewController {
        if sourceType == .camera && UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            picker.delegate = context.coordinator
            picker.allowsEditing = false
            return picker
        } else {
            var config = PHPickerConfiguration()
            config.selectionLimit = 1
            config.filter = .images
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = context.coordinator
            return picker
        }
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
        let parent: NativeMediaPicker
        
        init(_ parent: NativeMediaPicker) {
            self.parent = parent
        }
        
        // MARK: - Camera Delegate
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
        
        // MARK: - Photo Library PHPicker Delegate
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                if let uiImage = image as? UIImage {
                    DispatchQueue.main.async {
                        self?.parent.onImagePicked(uiImage)
                    }
                }
            }
        }
    }
}
