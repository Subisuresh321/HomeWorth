// HomeWorth/Views/PropertyDetailView.swift
import SwiftUI
import Supabase

struct PropertyDetailView: View {
    let property: Property
    @State private var showingInquiryAlert = false
    @State private var currentUserId: UUID?
    @State private var inquiryMessage: String = ""

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
                        Text("Asking Price: \(String(format: "₹%.2f lakhs", askingPrice))")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    } else {
                        Text("Asking Price: N/A")
                            .font(.largeTitle)
                            .fontWeight(.bold)
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
                    // Corrected line 65
                    DetailRow(icon: "pin.fill", label: "ATM", value: "\(String(format: "%.2f", property.atmDistance)) km")
                    // Corrected line 66
                    DetailRow(icon: "cross.case.fill", label: "Hospital", value: "\(String(format: "%.2f", property.hospitalDistance)) km")
                    // Corrected line 67
                    DetailRow(icon: "graduationcap.fill", label: "School", value: "\(String(format: "%.2f", property.schoolDistance)) km")
                    
                    Divider()
                    
                    Text("Construction Details")
                        .font(.headline)
                    // You'll need helper functions to convert these raw values to strings
                    // For now, let's just display the raw integer values
                    DetailRow(icon: "tree.fill", label: "Wood Quality", value: "\(property.woodQuality)")
                    DetailRow(icon: "building.columns.fill", label: "Cement Grade", value: "\(property.cementGrade)")
                    DetailRow(icon: "gearshape.fill", label: "Steel Grade", value: "\(property.steelGrade)")
                    DetailRow(icon: "list.bullet.rectangle.portrait", label: "Flooring", value: "\(property.flooringQuality)")
                    DetailRow(icon: "paintbrush.fill", label: "Paint Quality", value: "\(property.paintQuality)")
                    DetailRow(icon: "wrench.and.screwdriver.fill", label: "Plumbing", value: "\(property.plumbingQuality)")
                    DetailRow(icon: "bolt.fill", label: "Electrical", value: "\(property.electricalQuality)")
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
            sellerId: property.sellerId, // Direct access, no unwrapping needed
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
