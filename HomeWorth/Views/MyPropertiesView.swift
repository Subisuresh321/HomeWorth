// HomeWorth/Views/MyPropertiesView.swift

import SwiftUI

struct MyPropertiesView: View {
    @StateObject private var viewModel = MyPropertiesViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Simplified background - removed heavy animations
                GeometryReader { geometry in
                    ZStack {
                        // Static gradient background
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.homeWorthGradientStart,
                                Color.homeWorthGradientEnd,
                                Color.homeWorthYellow.opacity(0.9)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()
                        
                        // Light grid overlay - no animation
                        SimpleGrid()
                            .opacity(0.05)
                    }
                }
                
                VStack {
                    
                    // Simplified content area
                    Group {
                        if viewModel.isLoading {
                            SimpleLoadingView()
                        } else if let errorMessage = viewModel.errorMessage {
                            SimpleErrorView(message: errorMessage)
                        } else if viewModel.myProperties.isEmpty {
                            SimpleEmptyView()
                        } else {
                            // Optimized property list
                            List(viewModel.myProperties.indices, id: \.self) { index in
                                NavigationLink(destination: PropertyDetailView(property: viewModel.myProperties[index])) {
                                    PropertyCardView(
                                        property: viewModel.myProperties[index]
                                    )
                                    .padding(.vertical, 8)
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchMyProperties()
            }
            .refreshable {
                viewModel.fetchMyProperties()
            }
        }
    }
}
