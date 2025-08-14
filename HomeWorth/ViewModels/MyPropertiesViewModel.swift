//
//  MyPropertiesViewModel.swift
//  HomeWorth
//
//  Created by Subi Suresh on 14/08/2025.
//


// HomeWorth/ViewModels/MyPropertiesViewModel.swift
import Foundation
import Supabase

class MyPropertiesViewModel: ObservableObject {
    @Published var myProperties: [Property] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchMyProperties() {
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                guard let sellerId = try await SupabaseService.shared.currentUserId else {
                    self.errorMessage = "User not authenticated."
                    self.isLoading = false
                    return
                }
                
                SupabaseService.shared.fetchPropertiesBySeller(sellerId: sellerId) { result in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        switch result {
                        case .success(let properties):
                            self.myProperties = properties
                        case .failure(let error):
                            self.errorMessage = error.localizedDescription
                        }
                    }
                }
            } catch {
                self.errorMessage = "Failed to get user ID."
                self.isLoading = false
            }
        }
    }
}