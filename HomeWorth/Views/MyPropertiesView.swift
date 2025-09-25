// HomeWorth/Views/MyPropertiesView.swift

import SwiftUI

struct MyPropertiesView: View {
    @StateObject private var viewModel = MyPropertiesViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
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
                
                // Grid overlay
                SimpleGrid()
                    .opacity(0.05)
                
                // Content area - direct content without header
                Group {
                    if viewModel.isLoading {
                        MyPropertiesLoadingView()
                    } else if let errorMessage = viewModel.errorMessage {
                        MyPropertiesErrorView(message: errorMessage)
                    } else if viewModel.myProperties.isEmpty {
                        MyPropertiesEmptyView()
                    } else {
                        List(viewModel.myProperties.indices, id: \.self) { index in
                            NavigationLink(destination: PropertyDetailView(property: viewModel.myProperties[index])) {
                                OptimizedPropertyCard(
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

// MARK: - Components (same as before)

struct MyPropertiesLoadingView: View {
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        VStack(spacing: 24) {
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.deepBlack, lineWidth: 4)
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(rotationAngle))
                .onAppear {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                }
            
            Text("LOADING YOUR PROPERTIES...")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MyPropertiesErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("PROPERTY LOAD ERROR")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.deepBlack.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MyPropertiesEmptyView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "house.fill")
                .font(.system(size: 70))
                .foregroundColor(.deepBlack.opacity(0.6))
            
            VStack(spacing: 12) {
                Text("NO PROPERTIES YET")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(.deepBlack)
                
                Text("Add your first property to get started with HomeWorth valuation.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.deepBlack.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

