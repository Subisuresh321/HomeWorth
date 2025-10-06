//
//  LocationPickerView.swift
//  HomeWorth
//
//  Created by Subi Suresh on 06/10/2025.
//


// HomeWorth/Views/Components/LocationPickerView.swift

import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var latitude: Double?
    @Binding var longitude: Double?
    @Binding var address: String?
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629), // Center of India
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )
    
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var searchText = ""
    @State private var isSearching = false
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        ZStack {
            // Futuristic background
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
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.deepBlack)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.7))
                            )
                    }
                    
                    Spacer()
                    
                    Text("SELECT LOCATION")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.deepBlack)
                    
                    Spacer()
                    
                    Button(action: saveLocation) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.deepBlack)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color.homeWorthYellow.opacity(0.8))
                            )
                    }
                    .disabled(selectedCoordinate == nil)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.deepBlack.opacity(0.6))
                    
                    TextField("Search for location...", text: $searchText)
                        .font(.system(size: 16))
                        .foregroundColor(.deepBlack)
                        .onSubmit {
                            searchLocation()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.deepBlack.opacity(0.6))
                        }
                    }
                    
                    Button(action: locationManager.requestCurrentLocation) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.white)
                            )
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.9))
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                
                // Map
                MapViewWrapper(
                    region: $region,
                    selectedCoordinate: $selectedCoordinate,
                    userLocation: locationManager.userLocation
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(20)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // Selected Location Info
                if let coordinate = selectedCoordinate {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SELECTED LOCATION")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.deepBlack)
                        
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                            Text("Lat: \(coordinate.latitude, specifier: "%.6f"), Lon: \(coordinate.longitude, specifier: "%.6f")")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.deepBlack.opacity(0.8))
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.9))
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        // NEW:
        .onChange(of: locationManager.userLocation) { oldValue, newValue in
            if let location = newValue {
                region.center = location.coordinate
                region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            }
        }
    }
    
    private func searchLocation() {
        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            isSearching = false
            
            if let response = response, let item = response.mapItems.first {
                let coordinate = item.placemark.coordinate
                region.center = coordinate
                region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                selectedCoordinate = coordinate
            }
        }
    }
    
    private func saveLocation() {
        if let coordinate = selectedCoordinate {
            latitude = coordinate.latitude
            longitude = coordinate.longitude
            
            // Reverse geocode to get address
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let geocoder = CLGeocoder()
            
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let placemark = placemarks?.first {
                    let addressComponents = [
                        placemark.name,
                        placemark.locality,
                        placemark.administrativeArea,
                        placemark.country
                    ].compactMap { $0 }
                    
                    address = addressComponents.joined(separator: ", ")
                }
                dismiss()
            }
        }
    }
}

// MARK: - MapView Wrapper
struct MapViewWrapper: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    var userLocation: CLLocation?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)
        
        // Update pin
        mapView.removeAnnotations(mapView.annotations)
        
        if let coordinate = selectedCoordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Selected Location"
            mapView.addAnnotation(annotation)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewWrapper
        
        init(_ parent: MapViewWrapper) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            parent.selectedCoordinate = coordinate
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
            
            let identifier = "SelectedLocation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            annotationView?.markerTintColor = .red
            return annotationView
        }
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestCurrentLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
