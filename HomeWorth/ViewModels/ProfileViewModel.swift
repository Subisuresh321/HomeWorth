// HomeWorth/ViewModels/ProfileViewModel.swift
import Foundation
import Supabase

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var newName: String = ""
    @Published var newPhoneNumber: String = ""
    @Published var isLoading = false
    @Published var message: String?
    
    private var authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        self.currentUser = authViewModel.currentUser
        
        // Initialize editable fields with current user data
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
        
        let updatedUser = User(
            id: userId,
            email: currentUser!.email,
            name: newName,
            phoneNumber: newPhoneNumber,
            userType: currentUser!.userType,
            createdAt: currentUser!.createdAt
        )
        
        SupabaseService.shared.updateUserProfile(user: updatedUser) { [weak self] error in
            Task { @MainActor in
                self?.isLoading = false
                if let error = error {
                    self?.message = "Failed to update profile: \(error.localizedDescription)"
                } else {
                    self?.message = "Profile updated successfully!"
                    self?.authViewModel.currentUser = updatedUser // Update the main user object
                    self?.currentUser = updatedUser
                }
            }
        }
    }
    
    func signOut() {
        authViewModel.signOut()
    }
}
