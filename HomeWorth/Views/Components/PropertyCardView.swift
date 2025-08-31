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
        VStack(alignment: .leading, spacing: 12) {
            // Display the first image of the property
            if let imageUrlString = property.imageUrls?.first, let url = URL(string: imageUrlString) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(15)
                } placeholder: {
                    Color.homeWorthLightGray.frame(height: 200).cornerRadius(15)
                }
            } else {
                Color.homeWorthLightGray.frame(height: 200).cornerRadius(15)
            }
            
            Text("Area: \(Int(property.area)) sq ft")
                .font(.subheadline)
                .foregroundColor(.black)
            
            HStack {
                Text("Bedrooms: \(property.bedrooms)")
                Spacer()
                Text("Bathrooms: \(property.bathrooms)")
            }
            .font(.subheadline)
            .foregroundColor(.black)
            
            if let askingPrice = property.askingPrice {
                Text("Asking Price: \(formatPrice(askingPrice))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.homeWorthYellow)
            } else {
                Text("Asking Price: N/A")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
