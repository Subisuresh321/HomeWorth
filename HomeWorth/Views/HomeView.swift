//
//  HomeView.swift
//  HomeWorth
//
//  Created by Subi Suresh on 09/08/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading properties...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else if viewModel.properties.isEmpty {
                    Text("No properties available.")
                        .foregroundColor(.secondary)
                } else {
                    List(viewModel.properties, id: \.id) { property in
                        PropertyCardView(property: property)
                    }
                }
            }
            .navigationTitle("Property Listings")
        }
    }
}
