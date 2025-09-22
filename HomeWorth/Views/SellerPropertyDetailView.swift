// HomeWorth/Views/SellerPropertyDetailView.swift
import SwiftUI
import Supabase

struct SellerPropertyDetailView: View {
    @State var property: Property
    @State private var inquiries: [Inquiry] = []
    @State private var isLoadingInquiries = true
    @State private var errorMessage: String?
    
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
                    SellerPropertyImageCarousel(imageUrls: property.imageUrls)
                    
                    // Enhanced Pricing Analysis Section
                    SellerPricingAnalysisCard(property: property)
                    
                    // Core Property Details Section
                    SellerPropertyDetailsCard(property: property)
                    
                    // Construction Quality Section
                    SellerConstructionDetailsCard(property: property)
                    
                    // Description Section (if available)
                    if let description = property.description, !description.isEmpty {
                        SellerPropertyDescriptionCard(description: description)
                    }
                    
                    // Enhanced Inquiries Section with Management
                    SellerInquiriesManagementCard(
                        inquiries: inquiries,
                        isLoading: isLoadingInquiries,
                        errorMessage: errorMessage
                    )
                    
                    // Bottom spacing for better scrolling
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
        .navigationTitle("My Property Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchInquiries()
        }
    }
    
    private func fetchInquiries() {
        guard let propertyId = property.id else { return }
        isLoadingInquiries = true
        SupabaseService.shared.fetchInquiries(forPropertyId: propertyId) { result in
            DispatchQueue.main.async {
                self.isLoadingInquiries = false
                switch result {
                case .success(let fetchedInquiries):
                    self.inquiries = fetchedInquiries
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Seller Property Detail Components

struct SellerPropertyImageCarousel: View {
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

struct SellerPricingAnalysisCard: View {
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
                // Your Asking Price
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Asking Price")
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
                    
                    // Property status indicator
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Status")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.deepBlack.opacity(0.7))
                        
                        Text(property.status.uppercased())
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(statusColor(for: property.status))
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
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "pending": return .orange
        case "approved": return .green
        case "rejected": return .red
        default: return .secondary
        }
    }
}

struct SellerPropertyDetailsCard: View {
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

struct SellerConstructionDetailsCard: View {
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

struct SellerPropertyDescriptionCard: View {
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

struct SellerInquiriesManagementCard: View {
    let inquiries: [Inquiry]
    let isLoading: Bool
    let errorMessage: String?
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with expand/collapse
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text("INQUIRIES (\(inquiries.count))")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.deepBlack)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.deepBlack)
                }
            }
            
            // Expandable content
            if isExpanded {
                VStack(spacing: 12) {
                    if isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading inquiries...")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.deepBlack.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                    } else if let errorMessage = errorMessage {
                        Text("Error loading inquiries: \(errorMessage)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.red)
                            .padding(.vertical, 20)
                    } else if inquiries.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "questionmark.bubble")
                                .font(.system(size: 40))
                                .foregroundColor(.deepBlack.opacity(0.4))
                            
                            Text("No inquiries yet for this property.")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.deepBlack.opacity(0.6))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        ForEach(inquiries) { inquiry in
                            InquiryCardView(inquiry: inquiry)
                                .padding(.vertical, 4)
                        }
                    }
                }
                .transition(.opacity)
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
