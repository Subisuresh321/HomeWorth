// HomeWorth/Views/PropertyDetailView.swift
import SwiftUI
import Supabase
import MapKit

struct PropertyDetailView: View {
    let property: Property
    @State private var showingInquiryAlert = false
    @State private var currentUserId: UUID?
    @State private var isLoading = false
    
    // Helper functions for property descriptions
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "₹0"
    }
    
    private func woodQualityDescription(for value: Int) -> String {
        return WoodQuality(rawValue: value)?.description ?? "N/A"
    }
    
    private func cementGradeDescription(for value: Int) -> String {
        return CementGrade(rawValue: value)?.description ?? "N/A"
    }
    
    private func steelGradeDescription(for value: Int) -> String {
        return SteelGrade(rawValue: value)?.description ?? "N/A"
    }
    
    private func brickTypeDescription(for value: Int) -> String {
        return BrickType(rawValue: value)?.description ?? "N/A"
    }
    
    private func flooringQualityDescription(for value: Int) -> String {
        return FlooringQuality(rawValue: value)?.description ?? "N/A"
    }
    
    private func paintQualityDescription(for value: Int) -> String {
        return PaintQuality(rawValue: value)?.description ?? "N/A"
    }
    
    private func plumbingQualityDescription(for value: Int) -> String {
        return PlumbingQuality(rawValue: value)?.description ?? "N/A"
    }
    
    private func electricalQualityDescription(for value: Int) -> String {
        return ElectricalQuality(rawValue: value)?.description ?? "N/A"
    }
    
    private func roofingTypeDescription(for value: Int) -> String {
        return RoofingType(rawValue: value)?.description ?? "N/A"
    }
    
    private func windowGlassQualityDescription(for value: Int) -> String {
        return WindowGlassQuality(rawValue: value)?.description ?? "N/A"
    }
    
    private func areaTypeDescription(for value: Int) -> String {
        return AreaType(rawValue: value)?.description ?? "N/A"
    }
    
    var body: some View {
        ZStack {
            // Futuristic background gradient
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
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Enhanced Image Carousel Section
                    PropertyImageCarousel(imageUrls: property.imageUrls)
                    
                    // Pricing Analysis Section
                    PricingAnalysisCard(property: property)
                    
                    // Core Property Details Section
                    PropertyDetailsCard(property: property)
                    
                    // Construction Quality Section
                    ConstructionDetailsCard(property: property)
                    
                    // Location Section - NEW
                    PropertyLocationCard(property: property)
                    
                    // Description Section (if available)
                    if let description = property.description, !description.isEmpty {
                        PropertyDescriptionCard(description: description)
                    }
                    
                    // Contact Seller Section
                    if currentUserId != nil && currentUserId != property.sellerId {
                        ContactSellerCard(action: { showingInquiryAlert = true })
                    }
                    
                    // Bottom spacing for better scrolling
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
        .navigationTitle("Property Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                currentUserId = try? await SupabaseService.shared.currentUserId
            }
        }
        .alert("Send Inquiry", isPresented: $showingInquiryAlert) {
            Button("Cancel", role: .cancel) { }
                .foregroundColor(.black)
            Button("Send") {
                isLoading = true
                sendInquiry()
            }
            .foregroundColor(.homeWorthYellow)
        } message: {
            Text("Do you want to send a message to the seller of this property? This will share your contact details with the seller.")
        }
    }
    
    private func sendInquiry() {
        guard let buyerId = currentUserId,
              let propertyId = property.id else {
            print("Error: Required information for inquiry is missing.")
            isLoading = false
            return
        }
        
        let newInquiry = Inquiry(
            id: nil,
            propertyId: propertyId,
            buyerId: buyerId,
            sellerId: property.sellerId,
            message: "I am interested in your property!",
            createdAt: Date()
        )
        
        SupabaseService.shared.createInquiry(inquiry: newInquiry) { error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    print("Error creating inquiry: \(error.localizedDescription)")
                } else {
                    print("Inquiry sent successfully for property \(propertyId)!")
                }
            }
        }
    }
}

// MARK: - Property Detail Components

struct PropertyImageCarousel: View {
    let imageUrls: [String]?
    
    var body: some View {
        Group {
            if let imageUrls = imageUrls, !imageUrls.isEmpty {
                TabView {
                    ForEach(imageUrls, id: \.self) { imageUrl in
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 300)
                                .clipped()
                        } placeholder: {
                            ZStack {
                                Rectangle()
                                    .fill(Color.homeWorthLightGray)
                                    .frame(height: 300)
                                
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .tint(.homeWorthYellow)
                            }
                        }
                    }
                }
                .frame(height: 300)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .cornerRadius(20)
                .shadow(color: .deepBlack.opacity(0.15), radius: 12, x: 0, y: 6)
            } else {
                ZStack {
                    Rectangle()
                        .fill(Color.homeWorthLightGray)
                        .frame(height: 300)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.homeWorthDarkGray.opacity(0.6))
                        
                        Text("No Images Available")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.homeWorthDarkGray.opacity(0.7))
                    }
                }
                .cornerRadius(20)
                .shadow(color: .deepBlack.opacity(0.15), radius: 12, x: 0, y: 6)
            }
        }
    }
}

struct PricingAnalysisCard: View {
    let property: Property
    
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "₹0"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PRICING ANALYSIS")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
            
            VStack(alignment: .leading, spacing: 12) {
                // Asking Price
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Asking Price")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.deepBlack.opacity(0.7))
                        
                        if let askingPrice = property.askingPrice {
                            Text(formatPrice(askingPrice))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                        } else {
                            Text("N/A")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                
                // AI Predicted Price & Analysis
                if let predictedPrice = property.predictedPrice,
                   let askingPrice = property.askingPrice {
                    StaticAIAnalysis(
                        predictedPrice: predictedPrice,
                        askingPrice: askingPrice
                    )
                }
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
        .shadow(color: .deepBlack.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

struct PropertyDetailsCard: View {
    let property: Property
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PROPERTY DETAILS")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
            
            VStack(alignment: .leading, spacing: 12) {
                DetailRow(icon: "square.fill", label: "Area", value: "\(Int(property.area)) sq. ft.")
                DetailRow(icon: "bed.double.fill", label: "Bedrooms", value: "\(property.bedrooms)")
                DetailRow(icon: "shower.fill", label: "Bathrooms", value: "\(property.bathrooms)")
                DetailRow(icon: "ruler.fill", label: "Number of Floors", value: "\(property.numberOfFloors)")
                DetailRow(icon: "calendar", label: "Built Year", value: "\(property.builtYear)")
                
                Divider()
                    .background(Color.deepBlack.opacity(0.2))
                
                Text("NEARBY AMENITIES (KM)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.deepBlack.opacity(0.8))
                
                DetailRow(icon: "pin.fill", label: "ATM", value: String(format: "%.2f km", property.atmDistance))
                DetailRow(icon: "cross.case.fill", label: "Hospital", value: String(format: "%.2f km", property.hospitalDistance))
                DetailRow(icon: "graduationcap.fill", label: "School", value: String(format: "%.2f km", property.schoolDistance))
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
        .shadow(color: .deepBlack.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

struct ConstructionDetailsCard: View {
    let property: Property
    
    private func woodQualityDescription(for value: Int) -> String {
        return WoodQuality(rawValue: value)?.description ?? "N/A"
    }
    
    private func cementGradeDescription(for value: Int) -> String {
        return CementGrade(rawValue: value)?.description ?? "N/A"
    }
    
    private func steelGradeDescription(for value: Int) -> String {
        return SteelGrade(rawValue: value)?.description ?? "N/A"
    }
    
    private func flooringQualityDescription(for value: Int) -> String {
        return FlooringQuality(rawValue: value)?.description ?? "N/A"
    }
    
    private func paintQualityDescription(for value: Int) -> String {
        return PaintQuality(rawValue: value)?.description ?? "N/A"
    }
    
    private func plumbingQualityDescription(for value: Int) -> String {
        return PlumbingQuality(rawValue: value)?.description ?? "N/A"
    }
    
    private func electricalQualityDescription(for value: Int) -> String {
        return ElectricalQuality(rawValue: value)?.description ?? "N/A"
    }
    
    private func roofingTypeDescription(for value: Int) -> String {
        return RoofingType(rawValue: value)?.description ?? "N/A"
    }
    
    private func windowGlassQualityDescription(for value: Int) -> String {
        return WindowGlassQuality(rawValue: value)?.description ?? "N/A"
    }
    
    private func areaTypeDescription(for value: Int) -> String {
        return AreaType(rawValue: value)?.description ?? "N/A"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CONSTRUCTION QUALITY")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
            
            VStack(alignment: .leading, spacing: 12) {
                DetailRow(icon: "tree.fill", label: "Wood Quality", value: woodQualityDescription(for: property.woodQuality))
                DetailRow(icon: "building.columns.fill", label: "Cement Grade", value: cementGradeDescription(for: property.cementGrade))
                DetailRow(icon: "gearshape.fill", label: "Steel Grade", value: steelGradeDescription(for: property.steelGrade))
                DetailRow(icon: "list.bullet.rectangle.portrait", label: "Flooring", value: flooringQualityDescription(for: property.flooringQuality))
                DetailRow(icon: "paintbrush.fill", label: "Paint Quality", value: paintQualityDescription(for: property.paintQuality))
                DetailRow(icon: "wrench.and.screwdriver.fill", label: "Plumbing", value: plumbingQualityDescription(for: property.plumbingQuality))
                DetailRow(icon: "bolt.fill", label: "Electrical", value: electricalQualityDescription(for: property.electricalQuality))
                DetailRow(icon: "house.fill", label: "Roofing Type", value: roofingTypeDescription(for: property.roofingType))
                DetailRow(icon: "sparkle.magnifyingglass", label: "Window Glass", value: windowGlassQualityDescription(for: property.windowGlassQuality))
                DetailRow(icon: "mappin.and.ellipse", label: "Area Type", value: areaTypeDescription(for: property.areaType))
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
        .shadow(color: .deepBlack.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

struct PropertyDescriptionCard: View {
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("DESCRIPTION")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
            
            Text(description)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.deepBlack.opacity(0.8))
                .lineSpacing(4)
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
        .shadow(color: .deepBlack.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

struct ContactSellerCard: View {
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("INTERESTED IN THIS PROPERTY?")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
                .multilineTextAlignment(.center)
            
            Button(action: action) {
                HStack(spacing: 12) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("CONTACT SELLER")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                }
                .foregroundColor(.deepBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.homeWorthYellow)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.deepBlack, lineWidth: 2)
                        )
                )
                .shadow(color: .homeWorthYellow.opacity(0.4), radius: 8, x: 0, y: 4)
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
        .shadow(color: .deepBlack.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}
