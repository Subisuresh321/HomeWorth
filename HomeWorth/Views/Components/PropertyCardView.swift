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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image section with overlay and badge
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
                // Area info with icon
                HStack(spacing: 12) {
                    Image(systemName: "square.resize")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.deepBlack)
                        .frame(width: 24, height: 24)
                    Text("\(Int(property.area)) sq ft")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.homeWorthDarkGray)
                    Spacer()
                    // Static status indicator
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                }

                // Room details with icon
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
                if let predictedPrice = property.predictedPrice, let askingPrice = property.askingPrice {
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
                .fill(Color.homeWorthYellow.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial.opacity(0.6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.homeWorthYellow.opacity(0.8), lineWidth: 1.5)
                )
        )
        .shadow(color: .homeWorthYellow.opacity(0.3), radius: 6, x: 0, y: 3)
    }
}

