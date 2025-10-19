//
//  PropertyLocationCard.swift
//  HomeWorth
//
//  Created by Subi Suresh on 19/10/2025.
//


// HomeWorth/Views/Components/PropertyLocationCard.swift

import SwiftUI
import MapKit

struct PropertyLocationCard: View {
    let property: Property
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PROPERTY LOCATION")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
            
            if let latitude = property.latitude,
               let longitude = property.longitude {
                
                VStack(spacing: 12) {
                    // Map View
                    PropertyMapView(
                        latitude: latitude,
                        longitude: longitude
                    )
                    .frame(height: 200)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.deepBlack.opacity(0.1), lineWidth: 1)
                    )
                    
                    // Address and Actions
                    VStack(alignment: .leading, spacing: 8) {
                        if let address = property.address {
                            HStack(spacing: 8) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 16))
                                Text(address)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.deepBlack.opacity(0.8))
                                    .lineLimit(2)
                            }
                        }
                        
                        // Coordinates
                        HStack(spacing: 8) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 14))
                            Text("Coordinates: \(latitude, specifier: "%.6f"), \(longitude, specifier: "%.6f")")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.deepBlack.opacity(0.6))
                        }
                        
                        // Open in Maps Button
                        Button(action: {
                            openInMaps(latitude: latitude, longitude: longitude)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("OPEN IN APPLE MAPS")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                            }
                            .foregroundColor(.deepBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.homeWorthYellow.opacity(0.8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.deepBlack, lineWidth: 1)
                                    )
                            )
                            .shadow(color: .homeWorthYellow.opacity(0.4), radius: 6, x: 0, y: 3)
                        }
                        .padding(.top, 4)
                    }
                }
                
            } else {
                // No Location Available
                VStack(spacing: 12) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.deepBlack.opacity(0.4))
                    Text("Location not available for this property")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.deepBlack.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
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
    
    private func openInMaps(latitude: Double, longitude: Double) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = "Property Location"
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

// MARK: - Property Map View
struct PropertyMapView: UIViewRepresentable {
    let latitude: Double
    let longitude: Double
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isUserInteractionEnabled = true
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Remove existing annotations
        mapView.removeAnnotations(mapView.annotations)
        
        // Add property annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Property Location"
        mapView.addAnnotation(annotation)
        
        // Set region
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        mapView.setRegion(region, animated: false)
    }
}

// MARK: - Seller Property Location Card
struct SellerPropertyLocationCard: View {
    let property: Property
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PROPERTY LOCATION")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
            
            if let latitude = property.latitude,
               let longitude = property.longitude {
                
                VStack(spacing: 12) {
                    // Map View
                    PropertyMapView(
                        latitude: latitude,
                        longitude: longitude
                    )
                    .frame(height: 200)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.deepBlack.opacity(0.1), lineWidth: 1)
                    )
                    
                    // Address and Actions
                    VStack(alignment: .leading, spacing: 8) {
                        if let address = property.address {
                            HStack(spacing: 8) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 16))
                                Text(address)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.deepBlack.opacity(0.8))
                                    .lineLimit(2)
                            }
                        }
                        
                        // Coordinates
                        HStack(spacing: 8) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 14))
                            Text("Coordinates: \(latitude, specifier: "%.6f"), \(longitude, specifier: "%.6f")")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.deepBlack.opacity(0.6))
                        }
                        
                        // Open in Maps Button
                        Button(action: {
                            openInMaps(latitude: latitude, longitude: longitude)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "map.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("OPEN IN APPLE MAPS")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                            }
                            .foregroundColor(.deepBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.homeWorthYellow.opacity(0.8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.deepBlack, lineWidth: 1)
                                    )
                            )
                            .shadow(color: .homeWorthYellow.opacity(0.4), radius: 6, x: 0, y: 3)
                        }
                        .padding(.top, 4)
                    }
                }
                
            } else {
                // No Location Available
                VStack(spacing: 12) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.deepBlack.opacity(0.4))
                    Text("Location not available for this property")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.deepBlack.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
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
    }
    
    private func openInMaps(latitude: Double, longitude: Double) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = "Property Location"
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}
