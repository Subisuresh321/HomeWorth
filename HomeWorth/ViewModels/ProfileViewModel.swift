import Foundation
import Supabase
import UIKit

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var newName: String = ""
    @Published var newPhoneNumber: String = ""
    @Published var selectedImage: UIImage? = nil
    @Published var isLoading = false
    @Published var message: String?
    
    private var authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        self.currentUser = authViewModel.currentUser
        
        if let user = currentUser {
            self.newName = user.name ?? ""
            self.newPhoneNumber = user.phoneNumber ?? ""
        }
    }
    
    func saveProfileChanges() {
        guard let userId = currentUser?.id else {
            self.message = "User not authenticated."
            return
        }
        
        isLoading = true
        message = nil
        
        Task {
            var updatedUser = User(
                id: userId,
                email: currentUser!.email,
                name: newName,
                phoneNumber: newPhoneNumber,
                userType: currentUser!.userType,
                profilePhotoUrl: currentUser!.profilePhotoUrl,
                createdAt: currentUser!.createdAt
            )
            
            // Handle image update if a new one was selected
            if let newImage = selectedImage {
                self.message = "Uploading profile photo..."
                
                do {
                    // Correctly call the service function with image and userId
                    let url = try await self.uploadProfileImage(image: newImage, userId: userId)
                    updatedUser.profilePhotoUrl = url.absoluteString
                } catch {
                    self.isLoading = false
                    self.message = "Failed to upload photo: \(error.localizedDescription)"
                    return
                }
            }

            SupabaseService.shared.updateUserProfile(user: updatedUser) { [weak self] error in
                Task { @MainActor in
                    self?.isLoading = false
                    if let error = error {
                        self?.message = "Failed to update profile: \(error.localizedDescription)"
                    } else {
                        self?.message = "Profile updated successfully!"
                        self?.authViewModel.currentUser = updatedUser
                        self?.currentUser = updatedUser
                    }
                }
            }
        }
    }
    
    func signOut() {
        authViewModel.signOut()
    }
    
    // MARK: - Helper Functions
    private func uploadProfileImage(image: UIImage, userId: UUID) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            SupabaseService.shared.uploadProfileImage(image: image, userId: userId) { result in
                continuation.resume(with: result)
            }
        }
    }
}
