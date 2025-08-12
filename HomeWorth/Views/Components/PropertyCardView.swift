//
//  PropertyCardView.swift
//  HomeWorth
//
//  Created by Subi Suresh on 11/08/2025.
//


// HomeWorth/Views/Components/PropertyCardView.swift
import SwiftUI

struct PropertyCardView: View {
    var property: Property

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Area: \(Int(property.area)) sq ft")
                .font(.headline)
            Text("Bedrooms: \(property.bedrooms)")
            Text("Bathrooms: \(property.bathrooms)")
            
            // Display the asking price if available
            if let askingPrice = property.askingPrice {
                Text("Asking Price: ₹\(askingPrice, specifier: "%.2f") lakhs")
                    .foregroundColor(.green)
                    .fontWeight(.bold)
            } else {
                Text("Asking Price: N/A")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}