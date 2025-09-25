// HomeWorth/Views/Components/PropertyCardView.swift

import SwiftUI

struct PropertyCardView: View {
    var property: Property

    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "₹0"
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "pending": return .orange
        case "approved", "active": return .green
        case "rejected", "inactive": return .red
        default: return .gray
        }
    }
    
    private func statusText(for status: String) -> String {
        switch status.lowercased() {
        case "pending": return "PENDING"
        case "approved": return "APPROVED"
        case "active": return "ACTIVE"
        case "rejected": return "REJECTED"
        case "inactive": return "INACTIVE"
        default: return status.uppercased()
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image section
            ZStack {
                if let imageUrlString = property.imageUrls?.first, let url = URL(string: imageUrlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                    } placeholder: {
                        ZStack {
                            Rectangle()
                                .fill(Color.homeWorthLightGray)
                                .frame(height: 200)
                            
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(.homeWorthYellow)
                        }
                    }
                } else {
                    ZStack {
                        Rectangle()
                            .fill(Color.homeWorthLightGray)
                            .frame(height: 200)
                        
                        Image(systemName: "house.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.homeWorthDarkGray.opacity(0.5))
                    }
                }
                
                // Simple gradient overlay
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)
                
                // Static price badge
                VStack {
                    HStack {
                        Spacer()
                        if let askingPrice = property.askingPrice {
                            StaticPriceBadge(price: askingPrice)
                        }
                    }
                    Spacer()
                }
                .padding(16)
            }
            .cornerRadius(20, corners: [.topLeft, .topRight])
            
            // Content section
            VStack(alignment: .leading, spacing: 16) {
                // Area info with static icon
                HStack(spacing: 12) {
                    Image(systemName: "square.resize")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.deepBlack)
                        .frame(width: 24, height: 24)
                    
                    Text("\(Int(property.area)) sq ft")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.homeWorthDarkGray)
                    
                    Spacer()
                    
                    // CHANGED: Status indicator with circle + text
                    HStack(spacing: 8) {
                        Circle()
                            .fill(statusColor(for: property.status))
                            .frame(width: 12, height: 12)
                            .shadow(color: statusColor(for: property.status).opacity(0.6), radius: 3)
                        
                        Text(statusText(for: property.status))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(statusColor(for: property.status))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(statusColor(for: property.status).opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(statusColor(for: property.status).opacity(0.4), lineWidth: 1)
                            )
                    )
                }
                
                // Room details
                HStack(spacing: 20) {
                    HStack(spacing: 8) {
                        Image(systemName: "bed.double.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.deepBlack)
                        Text("\(property.bedrooms)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.homeWorthDarkGray)
                        Text("Beds")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.homeWorthDarkGray.opacity(0.7))
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "toilet.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.deepBlack)
                        Text("\(property.bathrooms)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.homeWorthDarkGray)
                        Text("Baths")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.homeWorthDarkGray.opacity(0.7))
                    }
                    
                    Spacer()
                }
                
                // Static AI price analysis
                if let predictedPrice = property.predictedPrice,
                   let askingPrice = property.askingPrice {
                    StaticAIAnalysis(
                        predictedPrice: predictedPrice,
                        askingPrice: askingPrice
                    )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.6), lineWidth: 1)
                    )
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .deepBlack.opacity(0.15), radius: 12, x: 0, y: 6)
        )
    }
}
