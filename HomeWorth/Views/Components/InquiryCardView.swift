//
//  InquiryCardView.swift
//  HomeWorth
//
//  Created by Subi Suresh on 14/08/2025.
//


// HomeWorth/Views/Components/InquiryCardView.swift
import SwiftUI

struct InquiryCardView: View {
    @StateObject private var viewModel: InquiryCardViewModel
    
    init(inquiry: Inquiry) {
        _viewModel = StateObject(wrappedValue: InquiryCardViewModel(inquiry: inquiry))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if viewModel.isLoading {
                ProgressView("Loading buyer...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else if let buyer = viewModel.buyer {
                Text("Buyer: \(buyer.name ?? "N/A")")
                    .font(.headline)
                
                HStack {
                    Image(systemName: "envelope.fill")
                    Text(buyer.email)
                }
                .font(.subheadline)
                
                if let phoneNumber = buyer.phoneNumber {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text(phoneNumber)
                    }
                    .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}