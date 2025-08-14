// HomeWorth/Views/MyPropertiesView.swift
import SwiftUI

struct MyPropertiesView: View {
    @StateObject private var viewModel = MyPropertiesViewModel()
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.isLoading {
                    ProgressView("Loading your properties...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else if viewModel.myProperties.isEmpty {
                    Text("You have not listed any properties yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.myProperties) { property in
                        NavigationLink(destination: SellerPropertyDetailView(property: property)) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Property ID: \(property.id?.uuidString ?? "N/A")")
                                    .font(.headline)
                                Text("Status: \(property.status.capitalized)")
                                    .foregroundColor(statusColor(for: property.status))
                                Text("Asking Price: \(property.askingPrice ?? 0, specifier: "₹%.2f lakhs")")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Properties")
            .onAppear {
                viewModel.fetchMyProperties()
            }
            .refreshable {
                viewModel.fetchMyProperties()
            }
        }
    }
    
    private func statusColor(for status: String) -> Color {
        switch status {
        case "pending":
            return .orange
        case "approved":
            return .green
        case "rejected":
            return .red
        default:
            return .secondary
        }
    }
}
