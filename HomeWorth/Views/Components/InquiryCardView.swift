// HomeWorth/Views/Components/InquiryCardView.swift
import SwiftUI

struct InquiryCardView: View {
    @StateObject private var viewModel: InquiryCardViewModel
    
    init(inquiry: Inquiry) {
        _viewModel = StateObject(wrappedValue: InquiryCardViewModel(inquiry: inquiry))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isLoading {
                InquiryLoadingView()
            } else if let errorMessage = viewModel.errorMessage {
                InquiryErrorView(message: errorMessage)
            } else if let buyer = viewModel.buyer {
                InquiryBuyerInfoView(buyer: buyer)
            } else {
                InquiryPlaceholderView()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
        )
        .shadow(color: .deepBlack.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Inquiry Card Components

struct InquiryLoadingView: View {
    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
                .scaleEffect(0.8)
                .tint(.homeWorthYellow)
            
            Text("Loading buyer information...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.deepBlack.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 8)
    }
}

struct InquiryErrorView: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.red)
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.red)
                .multilineTextAlignment(.leading)
        }
    }
}

struct InquiryBuyerInfoView: View {
    let buyer: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Buyer name header
            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.homeWorthYellow)
                
                Text(buyer.name ?? "Anonymous Buyer")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.deepBlack)
            }
            
            // Contact information
            VStack(alignment: .leading, spacing: 8) {
                // Email
                HStack(spacing: 8) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.deepBlack.opacity(0.6))
                        .frame(width: 20)
                    
                    Text(buyer.email)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.deepBlack.opacity(0.8))
                }
                
                // Phone number (if available)
                if let phoneNumber = buyer.phoneNumber, !phoneNumber.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.deepBlack.opacity(0.6))
                            .frame(width: 20)
                        
                        Text(phoneNumber)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.deepBlack.opacity(0.8))
                    }
                }
            }
        }
    }
}

struct InquiryPlaceholderView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.deepBlack.opacity(0.4))
            
            Text("Buyer information unavailable")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.deepBlack.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 8)
    }
}
