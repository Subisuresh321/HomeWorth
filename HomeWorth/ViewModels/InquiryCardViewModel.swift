//
//  InquiryCardViewModel.swift
//  HomeWorth
//
//  Created by Subi Suresh on 14/08/2025.
//


// HomeWorth/ViewModels/InquiryCardViewModel.swift
import Foundation

class InquiryCardViewModel: ObservableObject {
    @Published var buyer: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let inquiry: Inquiry
    
    init(inquiry: Inquiry) {
        self.inquiry = inquiry
        fetchBuyerDetails()
    }
    
    private func fetchBuyerDetails() {
        isLoading = true
        errorMessage = nil
        
        SupabaseService.shared.fetchUserProfile(userId: inquiry.buyerId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let user):
                    self?.buyer = user
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch buyer details: \(error.localizedDescription)"
                }
            }
        }
    }
}