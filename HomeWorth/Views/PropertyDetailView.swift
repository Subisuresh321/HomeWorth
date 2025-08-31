import SwiftUI
import Supabase

struct PropertyDetailView: View {
    let property: Property
    @State private var showingInquiryAlert = false
    @State private var currentUserId: UUID?
    
    // MARK: - Helper Functions
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
            LinearGradient(gradient: Gradient(colors: [Color.homeWorthGradientStart, Color.homeWorthGradientEnd]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Image Carousel
                    if let imageUrls = property.imageUrls, !imageUrls.isEmpty {
                        TabView {
                            ForEach(imageUrls, id: \.self) { imageUrl in
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .clipped()
                                        .cornerRadius(12)
                                } placeholder: {
                                    Color.homeWorthLightGray
                                        .frame(height: 300)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .frame(height: 300)
                        .tabViewStyle(PageTabViewStyle())
                    } else {
                        Color.homeWorthLightGray.frame(height: 300)
                    }

                    // Prices Section
                    VStack(alignment: .leading, spacing: 8) {
                        if let askingPrice = property.askingPrice {
                            Text("Asking Price: \(formatPrice(askingPrice))")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.homeWorthYellow)
                        } else {
                            Text("Asking Price: N/A")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                        }
                        
                        if let predictedPrice = property.predictedPrice {
                            Text("Predicted Fair Price: \(formatPrice(predictedPrice))")
                                .font(.subheadline)
                                .foregroundColor(.homeWorthDarkGray)
                        } else {
                            Text("Predicted Fair Price: N/A")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    .modifier(CardAnimationModifier()) // <-- Animation applied here
                    
                    // Core Details Card
                    VStack(alignment: .leading, spacing: 12) {
                        DetailRow(icon: "square.fill", label: "Area", value: "\(Int(property.area)) sq. ft.")
                        DetailRow(icon: "bed.double.fill", label: "Bedrooms", value: "\(property.bedrooms)")
                        DetailRow(icon: "shower.fill", label: "Bathrooms", value: "\(property.bathrooms)")
                        DetailRow(icon: "ruler.fill", label: "Number of Floors", value: "\(property.numberOfFloors)")
                        DetailRow(icon: "calendar", label: "Built Year", value: "\(property.builtYear)")
                        
                        Divider()

                        Text("Distances (in km)")
                            .font(.headline)
                        DetailRow(icon: "pin.fill", label: "ATM", value: "\(String(format: "%.2f", property.atmDistance)) km")
                        DetailRow(icon: "cross.case.fill", label: "Hospital", value: "\(String(format: "%.2f", property.hospitalDistance)) km")
                        DetailRow(icon: "graduationcap.fill", label: "School", value: "\(String(format: "%.2f", property.schoolDistance)) km")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    .modifier(CardAnimationModifier()) // <-- Animation applied here
                    
                    // Construction Details Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Construction Details")
                            .font(.headline)
                        DetailRow(icon: "tree.fill", label: "Wood Quality", value: woodQualityDescription(for: property.woodQuality))
                        DetailRow(icon: "building.columns.fill", label: "Cement Grade", value: cementGradeDescription(for: property.cementGrade))
                        DetailRow(icon: "gearshape.fill", label: "Steel Grade", value: steelGradeDescription(for: property.steelGrade))
                        DetailRow(icon: "list.bullet.rectangle.portrait", label: "Flooring", value: flooringQualityDescription(for: property.flooringQuality))
                        DetailRow(icon: "paintbrush.fill", label: "Paint Quality", value: paintQualityDescription(for: property.paintQuality))
                        DetailRow(icon: "wrench.and.screwdriver.fill", label: "Plumbing", value: plumbingQualityDescription(for: property.plumbingQuality))
                        DetailRow(icon: "bolt.fill", label: "Electrical", value: electricalQualityDescription(for: property.electricalQuality))
                        DetailRow(icon: "house.fill", label: "Roofing Type", value: roofingTypeDescription(for: property.roofingType))
                        DetailRow(icon: "sparkle.magnifyingglass", label: "Window Glass Quality", value: windowGlassQualityDescription(for: property.windowGlassQuality))
                        DetailRow(icon: "mappin.and.ellipse", label: "Area Type", value: areaTypeDescription(for: property.areaType))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    .modifier(CardAnimationModifier()) // <-- Animation applied here

                    if let description = property.description {
                        VStack(alignment: .leading) {
                            Text("Description")
                                .font(.headline)
                            Text(description)
                                .font(.body)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)
                        .modifier(CardAnimationModifier()) // <-- Animation applied here
                    }
                    
                    // Inquiry button section
                    if currentUserId != nil && currentUserId != property.sellerId {
                        Button("Contact Seller") {
                            showingInquiryAlert = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.homeWorthYellow)
                        .foregroundColor(.homeWorthDarkGray)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .padding()
                    }
                }
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
            Button("Cancel", role: .cancel) {}
            Button("Send") {
                sendInquiry()
            }
        } message: {
            Text("Do you want to send a message to the seller of this property? This will share your contact details with the seller.")
        }
    }
    
    private func sendInquiry() {
        guard let buyerId = currentUserId,
              let propertyId = property.id else {
            print("Error: Required information for inquiry is missing.")
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
                if let error = error {
                    print("Error creating inquiry: \(error.localizedDescription)")
                } else {
                    print("Inquiry sent successfully for property \(propertyId)!")
                }
            }
        }
    }
}
