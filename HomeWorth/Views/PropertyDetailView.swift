//
//  PropertyDetailView.swift
//  HomeWorth
//
//  Created by Subi Suresh on 14/08/2025.
//

import SwiftUI
import Supabase

struct PropertyDetailView: View {
    let property: Property
    @State private var showingInquiryAlert = false
    @State private var currentUserId: UUID?
    @State private var inquiryMessage: String = ""
    
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
        // You would need to define these Enums in a globally accessible file or
        // directly in this file for this to compile. Assuming they are in scope.
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
                    // Placeholder if no images are available
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

                // Inquiry button section
                if currentUserId == nil {
                    Text("Sign in to contact the seller.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                } else if currentUserId == property.sellerId {
                    Text("You cannot send an inquiry to your own property.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                } else {
                    Button("Contact Seller") {
                        showingInquiryAlert = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding()
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
                    // TODO: Show an alert to the user about the failure
                } else {
                    print("Inquiry sent successfully for property \(propertyId)!")
                    // TODO: Show a success alert to the user
                }
            }
        }
    }
}

