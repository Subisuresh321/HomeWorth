// HomeWorth/ViewModels/AuthViewModel.swift
import Foundation
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var message: String = ""

    init() {
        Task {
            await checkAuthenticationState()
        }
    }
    
    func checkAuthenticationState() async {
        do {
            // Fixed: Use the async currentUserId property instead of currentSession
            let userId = try await SupabaseService.shared.currentUserId
            self.isAuthenticated = userId != nil
        } catch {
            self.isAuthenticated = false
            // Only show error message if it's not just "no session" scenario
            if !error.localizedDescription.contains("session") {
                self.message = "Authentication check failed: \(error.localizedDescription)"
            }
        }
    }

    func signUp(email: String, password: String) {
        SupabaseService.shared.signUp(email: email, password: password) { result in
            Task { @MainActor in
                switch result {
                case .success(let user):
                    self.isAuthenticated = true
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
                    self.message = "You have been signed out."
                }
            }
        }
    }
}
