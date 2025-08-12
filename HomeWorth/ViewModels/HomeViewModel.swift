//
//  HomeViewModel 2.swift
//  HomeWorth
//
//  Created by Subi Suresh on 11/08/2025.
//


// HomeWorth/ViewModels/HomeViewModel.swift
import Foundation
import SwiftUI
import Supabase

class HomeViewModel: ObservableObject {
    @Published var properties: [Property] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    init() {
        fetchProperties()
    }
    
    func fetchProperties() {
        isLoading = true
        errorMessage = nil
        
        SupabaseService.shared.fetchProperties { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let fetchedProperties):
                    // Filter for properties with a status of "approved"
                    self.properties = fetchedProperties.filter { $0.status == "approved" }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}