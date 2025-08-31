import SwiftUI
import Supabase

struct SellerPropertyDetailView: View {
    @State var property: Property
    @State private var inquiries: [Inquiry] = []
    @State private var isLoadingInquiries = true
    @State private var errorMessage: String?

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
                        }
                        
                        if let predictedPrice = property.predictedPrice {
                            Text("Predicted Fair Price: \(formatPrice(predictedPrice))")
                                .font(.subheadline)
                                .foregroundColor(.homeWorthDarkGray)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    .modifier(CardAnimationModifier()) // <-- Animation applied here
                    
                    // Core Details Section
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
                    
                    // Construction Details
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
                    
                    // Inquiries Section - The new collapsible feature
                    VStack(alignment: .leading, spacing: 8) {
                        DisclosureGroup("Inquiries (\(inquiries.count))") {
                            if isLoadingInquiries {
                                ProgressView()
                            } else if let errorMessage = errorMessage {
                                Text("Error loading inquiries: \(errorMessage)")
                                    .foregroundColor(.red)
                            } else if inquiries.isEmpty {
                                Text("No inquiries yet for this property.")
                                    .foregroundColor(.secondary)
                            } else {
                                ForEach(inquiries) { inquiry in
                                    InquiryCardView(inquiry: inquiry)
                                        .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    .modifier(CardAnimationModifier()) // <-- Animation applied here
                    
                    Spacer()
                }
            }
        }
        .navigationTitle("Property Details")
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

// A custom ViewModifier to create a reusable animation
struct CardAnimationModifier: ViewModifier {
    @State private var scale: CGFloat = 0.95
    @State private var opacity: Double = 0.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.5)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
    }
}
