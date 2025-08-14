//
//  AdminPropertyCardView.swift
//  HomeWorth
//
//  Created by Subi Suresh on 14/08/2025.
//


// HomeWorth/Views/Components/AdminPropertyCardView.swift
import SwiftUI

struct AdminPropertyCardView: View {
    let property: Property
    let onApprove: (UUID) -> Void
    let onReject: (UUID) -> Void
    
    // Helper to format currency
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "₹0"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Display property details
            Text("Area: \(Int(property.area)) sq ft")
                .font(.headline)
            Text("Bedrooms: \(property.bedrooms)")
            
            // Display the predicted price
            if let predictedPrice = property.predictedPrice {
                Text("Predicted Fair Price: \(formatPrice(predictedPrice))")
                    .foregroundColor(.blue)
                    .fontWeight(.bold)
            }
            
            // Display the asking price
            if let askingPrice = property.askingPrice {
                Text("Asking Price: \(formatPrice(askingPrice))")
                    .foregroundColor(.green)
                    .fontWeight(.bold)
            }
            
            // Buttons for admin actions
            HStack {
                Button("Approve") {
                    if let id = property.id {
                        onApprove(id)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                Button("Reject") {
                    if let id = property.id {
                        onReject(id)
                    }
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}