// HomeWorth/ViewModels/AuthViewModel.swift
import Foundation
import Supabase
import UIKit // Needed for UIImage

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var message: String = ""
    @Published var currentUser: User? = nil

    init() {
        Task {
            await checkAuthenticationState()
        }
    }
    
    func checkAuthenticationState() async {
        do {
            let userId = try await SupabaseService.shared.currentUserId
            self.isAuthenticated = userId != nil
            
            if self.isAuthenticated {
                SupabaseService.shared.fetchCurrentUserProfile { result in
                    Task { @MainActor in
                        switch result {
                        case .success(let user):
                            self.currentUser = user
                        case .failure(let error):
                            print("Failed to fetch user profile: \(error.localizedDescription)")
                        }
                    }
                }
            }
        } catch {
            self.isAuthenticated = false
            self.currentUser = nil
            if !error.localizedDescription.contains("session") {
                self.message = "Authentication check failed: \(error.localizedDescription)"
            }
        }
    }

    // Updated signUp function to accept name, phoneNumber, and profileImage
    func signUp(email: String, password: String, name: String?, phoneNumber: String?, userType: String, profileImage: UIImage?) {
        SupabaseService.shared.signUp(email: email, password: password, name: name, phoneNumber: phoneNumber, userType: userType, profileImage: profileImage) { result in
            Task { @MainActor in
                switch result {
                case .success(let user):
                    self.isAuthenticated = true
                    self.currentUser = user
                    self.message = "Signed up and logged in successfully! Welcome, \(user.email)"
                case .failure(let error):
                    self.message = "Sign up failed: \(error.localizedDescription)"
                    self.isAuthenticated = false
                }
            }
        }
    }

    func signIn(email: String, password: String) {
        SupabaseService.shared.signIn(email: email, password: password) { result in
            Task { @MainActor in
                switch result {
                case .success(let user):
                    self.isAuthenticated = true
                    self.currentUser = user
                    self.message = "Signed in successfully! Welcome, \(user.email)"
                case .failure(let error):
                    self.message = "Sign in failed: \(error.localizedDescription)"
                    self.isAuthenticated = false
                }
            }
        }
    }

    func signOut() {
        SupabaseService.shared.signOut { error in
            Task { @MainActor in
                if let error = error {
                    self.message = "Sign out failed: \(error.localizedDescription)"
                } else {
                    self.isAuthenticated = false
                    self.currentUser = nil
                    self.message = "You have been signed out."
                }
            }
        }
    }
}
