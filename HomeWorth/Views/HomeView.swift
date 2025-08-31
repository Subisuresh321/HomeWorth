import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color.homeWorthGradientStart, Color.homeWorthGradientEnd]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter and Sort Section
                    HStack(spacing: 8) {
                        TextField("Min Price", text: $viewModel.minPrice)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(12)
                            .tint(.black) // <-- The fix: a black cursor
                            .onChange(of: viewModel.minPrice) {
                                viewModel.applyFiltersAndSorting()
                            }
                        
                        TextField("Max Price", text: $viewModel.maxPrice)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(12)
                            .tint(.black) // <-- The fix: a black cursor
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
                                .padding()
                                .background(Color.homeWorthYellow)
                                .cornerRadius(12)
                                .foregroundColor(.homeWorthDarkGray)
                        }
                        .onChange(of: viewModel.selectedSortOption) {
                            viewModel.applyFiltersAndSorting()
                        }
                    }
                    .padding()
                    
                    // Property List Section
                    Group {
                        if viewModel.isLoading {
                            ProgressView("Loading properties...")
                                .tint(.homeWorthDarkGray)
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
                                .listRowBackground(Color.clear)
                            }
                            .listStyle(.plain)
                            .padding(.top)
                        }
                    }
                }
            }
            .navigationTitle("HomeWorth")
            .onAppear {
                viewModel.fetchProperties()
            }
            .refreshable {
                viewModel.fetchProperties()
            }
        }
    }
}
