//
//  UserManagementViewModel.swift
//  HomeWorth
//
//  Created by Subi Suresh on 14/08/2025.
//


// HomeWorth/ViewModels/UserManagementViewModel.swift
import Foundation

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
}