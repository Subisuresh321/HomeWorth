// HomeWorth/Views/MyPropertiesView.swift
import SwiftUI

struct MyPropertiesView: View {
    @StateObject private var viewModel = MyPropertiesViewModel()
    
    var body: some View {
        ZStack {
            // Futuristic background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.homeWorthGradientStart.opacity(0.3),
                    Color.homeWorthGradientEnd.opacity(0.2),
                    Color.homeWorthYellow.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            NavigationView {
                VStack(spacing: 0) {
                    // Futuristic header
                    HStack {
                        Text("MY PROPERTIES")
                            .font(.system(size: 28, weight: .black, design: .monospaced))
                            .foregroundColor(.deepBlack)
                            .shadow(color: .white.opacity(0.6), radius: 2, x: 1, y: 1)
                        
                        Spacer()
                        
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.deepBlack)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Content area
                    Group {
                        if viewModel.isLoading {
                            MyPropertiesLoadingView()
                        } else if let errorMessage = viewModel.errorMessage {
                            MyPropertiesErrorView(message: errorMessage)
                        } else if viewModel.myProperties.isEmpty {
                            EmptyPropertiesView()
                        } else {
                            // Enhanced properties list
                            List(viewModel.myProperties, id: \.id) { property in
                                NavigationLink(destination: SellerPropertyDetailView(property: property)) {
                                    MyPropertyCard(property: property)
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
                .navigationBarHidden(true)
                .refreshable {
                    viewModel.fetchMyProperties()
                }
            }
        }
        .onAppear {
            viewModel.fetchMyProperties()
        }
    }
}

// MARK: - My Properties Components

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
            
            Text("FETCH ERROR")
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

struct EmptyPropertiesView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "house.badge.plus")
                .font(.system(size: 70))
                .foregroundColor(.deepBlack.opacity(0.6))
            
            VStack(spacing: 12) {
                Text("NO PROPERTIES LISTED")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(.deepBlack)
                
                Text("You haven't listed any properties yet. Add your first property to get started!")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.deepBlack.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MyPropertyCard: View {
    let property: Property
    
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "₹0"
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
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
    
    private func statusIcon(for status: String) -> String {
        switch status.lowercased() {
        case "pending":
            return "clock.fill"
        case "approved":
            return "checkmark.circle.fill"
        case "rejected":
            return "xmark.circle.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Property header with status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("PROPERTY ID")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.deepBlack.opacity(0.6))
                    
                    Text(property.id?.uuidString.prefix(8).uppercased() ?? "N/A")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.deepBlack)
                }
                
                Spacer()
                
                // Status badge
                HStack(spacing: 6) {
                    Image(systemName: statusIcon(for: property.status))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(statusColor(for: property.status))
                    
                    Text(property.status.uppercased())
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(statusColor(for: property.status))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(statusColor(for: property.status).opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(statusColor(for: property.status).opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            // Property details
            VStack(alignment: .leading, spacing: 12) {
                // Area and price
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "square.resize")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.deepBlack.opacity(0.6))
                        
                        Text("\(Int(property.area)) sq ft")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.deepBlack)
                    }
                    
                    Spacer()
                    
                    if let askingPrice = property.askingPrice {
                        Text(formatPrice(askingPrice))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.homeWorthYellow)
                    }
                }
                
                // Room details
                HStack(spacing: 20) {
                    HStack(spacing: 4) {
                        Image(systemName: "bed.double.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.deepBlack.opacity(0.6))
                        Text("\(property.bedrooms)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.deepBlack.opacity(0.8))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "toilet.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.deepBlack.opacity(0.6))
                        Text("\(property.bathrooms)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.deepBlack.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // View details indicator
                    HStack(spacing: 4) {
                        Text("VIEW DETAILS")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.deepBlack.opacity(0.6))
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.deepBlack.opacity(0.6))
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.6), Color.homeWorthYellow.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: .deepBlack.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.vertical, 4)
    }
}
