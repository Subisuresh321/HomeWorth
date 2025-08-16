// HomeWorth/Utilities/ImagePicker.swift
import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 4 // Set to a maximum of 4 images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            if results.isEmpty { return }

            var newImages: [UIImage] = []
            let itemProviders = results.map { $0.itemProvider }
            
            for itemProvider in itemProviders {
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                        guard let self = self, let image = image as? UIImage else { return }
                        
                        // Ensure we append on the main thread
                        DispatchQueue.main.async {
                            if newImages.count < 4 { // Add a check to respect the limit
                                newImages.append(image)
                            }
                            // When all images are loaded, update the parent's binding
                            if newImages.count == results.count {
                                self.parent.selectedImages = newImages
                            }
                        }
                    }
                }
            }
        }
    }
}
