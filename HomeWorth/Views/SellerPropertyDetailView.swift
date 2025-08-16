//
//  SellerPropertyDetailView.swift
//  HomeWorth
//
//  Created by Subi Suresh on 14/08/2025.
//

import SwiftUI
import Supabase

struct SellerPropertyDetailView: View {
    @State var property: Property
    @State private var inquiries: [Inquiry] = []
    @State private var isLoadingInquiries = true
    @State private var errorMessage: String?
    
    // MARK: - Helper Functions
    
    // Helper to format currency as a whole number
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "₹0"
    }

    // Helpers to get descriptive strings for categorical features
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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Display the property images
                if let imageUrls = property.imageUrls, !imageUrls.isEmpty {
                    TabView {
                        ForEach(imageUrls, id: \.self) { imageUrl in
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipped()
                            } placeholder: {
                                Color.gray
                            }
                        }
                    }
                    .frame(height: 300)
                    .tabViewStyle(PageTabViewStyle())
                } else {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                        .foregroundColor(.secondary)
                        .padding()
                }

                // Property details section
                VStack(alignment: .leading, spacing: 8) {
                    if let askingPrice = property.askingPrice {
                        Text("Asking Price: \(formatPrice(askingPrice))")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    } else {
                        Text("Asking Price: N/A")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }
                    
                    if let predictedPrice = property.predictedPrice {
                        Text("Predicted Fair Price: \(formatPrice(predictedPrice))")
                            .font(.headline)
                            .foregroundColor(.blue)
                    } else {
                        Text("Predicted Fair Price: N/A")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()

                    DetailRow(icon: "square.foot.fill", label: "Area", value: "\(Int(property.area)) sq. ft.")
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
                    
                    Divider()
                    
                    Text("Construction Details")
                        .font(.headline)
                    
                    // Displaying descriptive values instead of raw integers
                    DetailRow(icon: "tree.fill", label: "Wood Quality", value: woodQualityDescription(for: property.woodQuality))
                    DetailRow(icon: "building.columns.fill", label: "Cement Grade", value: cementGradeDescription(for: property.cementGrade))
                    DetailRow(icon: "gearshape.fill", label: "Steel Grade", value: steelGradeDescription(for: property.steelGrade))
                    DetailRow(icon: "list.bullet.rectangle.portrait", label: "Flooring", value: flooringQualityDescription(for: property.flooringQuality))
                    DetailRow(icon: "paintbrush.fill", label: "Paint Quality", value: paintQualityDescription(for: property.paintQuality))
                    DetailRow(icon: "wrench.and.screwdriver.fill", label: "Plumbing", value: plumbingQualityDescription(for: property.plumbingQuality))
                    DetailRow(icon: "bolt.fill", label: "Electrical", value: electricalQualityDescription(for: property.electricalQuality))

                    if let description = property.description {
                        Divider()
                        Text("Description")
                            .font(.headline)
                        Text(description)
                            .font(.body)
                    }
                }
                .padding()
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Inquiries")
                        .font(.title2)
                        .fontWeight(.bold)
                    
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
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Property Details")
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

// A helper view for consistent styling of detail rows
struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// NOTE: The InquiryCardView is a separate file. Do not include its definition here.
