import SwiftUI

// MARK: - Native iOS Alert Replica
struct NativeAlertView: View {
    let title: String
    let message: String
    let primaryButtonTitle: String
    let primaryButtonColor: Color
    let primaryButtonAction: () -> Void
    let secondaryButtonTitle: String = "Cancel"
    let secondaryButtonColor: Color
    let secondaryButtonAction: () -> Void
    
    var body: some View {
        ZStack {
            // Dark overlay - exactly like iOS
            Color.black.opacity(0.25)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Alert content area
                VStack(spacing: 16) {
                    // Title
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(.label))
                        .multilineTextAlignment(.center)
                    
                    // Message
                    Text(message)
                        .font(.system(size: 13))
                        .foregroundColor(Color(.label))
                        .multilineTextAlignment(.center)
                        .opacity(0.85)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)
                
                // Horizontal divider
                Divider()
                    .background(Color(.separator))
                
                // Buttons area
                HStack(spacing: 0) {
                    // Cancel button
                    Button(action: secondaryButtonAction) {
                        Text(secondaryButtonTitle)
                            .font(.system(size: 17))
                            .foregroundColor(secondaryButtonColor)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    
                    // Vertical divider
                    Divider()
                        .background(Color(.separator))
                        .frame(height: 44)
                    
                    // Primary action button
                    Button(action: primaryButtonAction) {
                        Text(primaryButtonTitle)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(primaryButtonColor)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                }
                .frame(height: 44)
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
            )
            .frame(width: 270) // Exact iOS alert width
        }
    }
}

// MARK: - Updated AdminPropertyCardView with Native Alert
struct AdminPropertyCardView: View {
    let property: Property
    let onApprove: (UUID) -> Void
    let onReject: (UUID) -> Void
    @State private var showApproveAlert = false
    @State private var showRejectAlert = false
    @State private var showPropertyDetail = false

    // Helper to format currency
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "₹0"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Main property header section
            HStack(spacing: 16) {
                // Property status indicator
                Circle()
                    .fill(statusColor(for: property.status))
                    .frame(width: 16, height: 16)
                    .shadow(color: statusColor(for: property.status).opacity(0.6), radius: 4)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Area: \(Int(property.area)) sq ft")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.deepBlack)
                    
                    Text("STATUS: \(property.status.uppercased())")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.deepBlack.opacity(0.7))
                }
                
                Spacer()
                
                // Bedrooms info
                HStack(spacing: 6) {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.deepBlack)
                    Text("\(property.bedrooms)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.deepBlack)
                }
            }
            
            // Property pricing details
            if let predictedPrice = property.predictedPrice {
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue.opacity(0.7))
                    Text("Predicted Fair Price: \(formatPrice(predictedPrice))")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
            
            if let askingPrice = property.askingPrice {
                HStack(spacing: 8) {
                    Image(systemName: "indianrupeesign.circle.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.deepBlack.opacity(0.6))
                    Text("Asking Price: \(formatPrice(askingPrice))")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.deepBlack)
                }
            }
            
            // Admin action buttons
            HStack(spacing: 8) {
                // View Details button
                Button(action: {
                    showPropertyDetail = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Details")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.deepBlack)
                    .frame(minWidth: 80, minHeight: 36)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.homeWorthYellow.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.deepBlack.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .shadow(color: .homeWorthYellow.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                
                // Approve button
                Button(action: {
                    showApproveAlert = true
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Approve")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(minWidth: 90, minHeight: 36)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.green)
                    )
                    .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                
                // Reject button
                Button(action: {
                    showRejectAlert = true
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Reject")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.red)
                    .frame(minWidth: 80, minHeight: 36)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.9))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                
                Spacer()
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.7),
                                    Color.homeWorthYellow.opacity(0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .shadow(color: .deepBlack.opacity(0.08), radius: 12, x: 0, y: 6)
        .sheet(isPresented: $showPropertyDetail) {
            NavigationView {
                PropertyDetailView(property: property)
                    .navigationTitle("Property Details")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(
                        trailing: Button("Done") {
                            showPropertyDetail = false
                        }
                    )
            }
        }
        .overlay(
            showApproveAlert ?
            NativeAlertView(
                title: "Approve Property",
                message: "Are you sure you want to approve this property listing?",
                primaryButtonTitle: "Approve",
                primaryButtonColor: .green, // Green for approve
                primaryButtonAction: {
                    if let id = property.id {
                        onApprove(id)
                    }
                    showApproveAlert = false
                },
                secondaryButtonColor: .blue, // Blue for cancel
                secondaryButtonAction: {
                    showApproveAlert = false
                }
            ) : nil
        )
        .overlay(
            showRejectAlert ?
            NativeAlertView(
                title: "Reject Property",
                message: "Are you sure you want to reject this property listing? This action cannot be undone.",
                primaryButtonTitle: "Reject",
                primaryButtonColor: .red, // Red for reject
                primaryButtonAction: {
                    if let id = property.id {
                        onReject(id)
                    }
                    showRejectAlert = false
                },
                secondaryButtonColor: .blue, // Red for cancel in reject
                secondaryButtonAction: {
                    showRejectAlert = false
                }
            ) : nil
        )
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "pending": return .orange
        case "approved": return .green
        case "rejected": return .red
        default: return .gray
        }
    }
}
