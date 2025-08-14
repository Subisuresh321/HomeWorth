//
//  SellerPropertyDetailView.swift
//  HomeWorth
//
//  Created by Subi Suresh on 14/08/2025.
//


// HomeWorth/Views/SellerPropertyDetailView.swift
import SwiftUI
import Supabase

struct SellerPropertyDetailView: View {
    @State var property: Property // Use @State for potential updates
    @State private var inquiries: [Inquiry] = []
    @State private var isLoadingInquiries = true
    @State private var errorMessage: String?
    
    // Helper to format currency
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "₹0"
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
                    
                    if let predictedPrice = property.predictedPrice {
                        Text("Predicted Fair Price: \(String(format: "₹%.2f lakhs", predictedPrice))")
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
                }
                .padding()
                
                // Inquiries Section
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
                            // This uses the InquiryCardView from its separate file
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
