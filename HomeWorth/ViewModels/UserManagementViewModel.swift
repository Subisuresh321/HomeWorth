// HomeWorth/ViewModels/UserManagementViewModel.swift
import Foundation
import Supabase

class UserManagementViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        fetchAllUsers()
    }

    func fetchAllUsers() {
        isLoading = true
        errorMessage = nil

        SupabaseService.shared.fetchAllUsers { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let fetchedUsers):
                    self?.users = fetchedUsers
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func deleteUser(user: User) {
        // The user.id is a non-optional UUID, so no need for guard let
        let userId = user.id

        // Only allow an admin to delete other users, not themselves
        guard user.userType != "admin" else {
            self.errorMessage = "Cannot delete an admin user from the app."
            return
        }

        isLoading = true
        SupabaseService.shared.deleteUser(userId: userId) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Failed to delete user: \(error.localizedDescription)"
                } else {
                    self?.fetchAllUsers() // Refresh the list
                }
            }
        }
    }
}
