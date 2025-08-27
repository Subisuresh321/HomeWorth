// HomeWorth/Views/HomeView.swift
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) { // <-- Use a VStack with spacing 0
                // Filter and Sort Section - This will stay at the top
                HStack {
                    TextField("Min Price", text: $viewModel.minPrice)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: viewModel.minPrice) {
                            viewModel.applyFiltersAndSorting()
                        }
                    
                    TextField("Max Price", text: $viewModel.maxPrice)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: viewModel.maxPrice) {
                            viewModel.applyFiltersAndSorting()
                        }
                    
                    Menu {
                        Picker("Sort by", selection: $viewModel.selectedSortOption) {
                            ForEach(HomeViewModel.SortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                    .onChange(of: viewModel.selectedSortOption) {
                        viewModel.applyFiltersAndSorting()
                    }
                }
                .padding() // <-- Give padding to the whole filter bar
                
                // The list or the "no properties" message will be here
                Group {
                    if viewModel.isLoading {
                        ProgressView("Loading properties...")
                    } else if let errorMessage = viewModel.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else if viewModel.properties.isEmpty {
                        VStack {
                            Spacer()
                            Text("No properties available for this filter.")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    } else {
                        List(viewModel.properties, id: \.id) { property in
                            NavigationLink(destination: PropertyDetailView(property: property)) {
                                PropertyCardView(property: property)
                            }
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Property Listings")
            .onAppear {
                viewModel.fetchProperties()
            }
            .refreshable {
                viewModel.fetchProperties()
            }
        }
    }
}
