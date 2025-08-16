// HomeWorth/Views/HomeView.swift
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
                        // The fix is here: wrap the card in a NavigationLink
                        NavigationLink(destination: PropertyDetailView(property: property)) {
                            PropertyCardView(property: property)
                        }
                        .listRowSeparator(.hidden) // Optional: Hides the list separator line
                    }
                    .listStyle(.plain) // Optional: To remove the default list style
                }
            }
            .navigationTitle("Property Listings")
        }
    }
}
