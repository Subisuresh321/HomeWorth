// HomeWorth/ViewModels/HomeViewModel.swift
import Foundation
import SwiftUI
import Supabase
import CoreML

class HomeViewModel: ObservableObject {
    @Published var properties: [Property] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // Filter and Sort properties
    @Published var selectedSortOption: SortOption = .priceDescending
    @Published var minPrice: String = ""
    @Published var maxPrice: String = ""

    private var mlModel: HomeWorthModel2?
    private var allApprovedProperties: [Property] = [] // New property to hold raw data

    enum SortOption: String, CaseIterable, Identifiable {
        case priceAscending = "Price (Low to High)"
        case priceDescending = "Price (High to Low)"
        case areaAscending = "Area (Smallest First)"
        case areaDescending = "Area (Largest First)"
        var id: String { self.rawValue }
    }

    init() {
        do {
            self.mlModel = try HomeWorthModel2(configuration: MLModelConfiguration())
        } catch {
            self.errorMessage = "Failed to load CoreML model: \(error.localizedDescription)"
        }
        fetchProperties()
    }
    
    func fetchProperties() {
        isLoading = true
        errorMessage = nil
        
        SupabaseService.shared.fetchProperties { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                guard let self = self else { return }

                switch result {
                case .success(let fetchedProperties):
                    let approvedProperties = fetchedProperties.filter { $0.status == "approved" }
                    
                    self.allApprovedProperties = approvedProperties.compactMap { property in
                        var newProperty = property
                        newProperty.predictedPrice = self.makePrediction(for: property)
                        return newProperty
                    }
                    self.applyFiltersAndSorting()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func applyFiltersAndSorting() {
        var filteredProperties = allApprovedProperties
        
        // Filter by price range
        if let minVal = Double(minPrice), minVal > 0 {
            filteredProperties = filteredProperties.filter { ($0.askingPrice ?? 0) >= minVal }
        }
        if let maxVal = Double(maxPrice), maxVal > 0 {
            filteredProperties = filteredProperties.filter { ($0.askingPrice ?? 0) <= maxVal }
        }
        
        // Sort the filtered list
        switch selectedSortOption {
        case .priceAscending:
            filteredProperties.sort { ($0.askingPrice ?? 0) < ($1.askingPrice ?? 0) }
        case .priceDescending:
            filteredProperties.sort { ($0.askingPrice ?? 0) > ($1.askingPrice ?? 0) }
        case .areaAscending:
            filteredProperties.sort { $0.area < $1.area }
        case .areaDescending:
            filteredProperties.sort { $0.area > $1.area }
        }
        
        self.properties = filteredProperties
    }
    
    private func makePrediction(for property: Property) -> Double? {
        guard let model = mlModel else {
            print("ML model is not loaded.")
            return nil
        }
        
        let totalareaRange = (min: 500.0, max: 3000.0)
        let distanceRange = (min: 0.1, max: 5.0)
        let ageRange = (min: 0.0, max: 50.0)
        
        let age = Double(2024 - property.builtYear)
        let avgDistance = (property.atmDistance + property.hospitalDistance + property.schoolDistance) / 3.0
        
        let scaledTotalarea = (property.area - totalareaRange.min) / (totalareaRange.max - totalareaRange.min)
        let scaledAtmDistance = (property.atmDistance - distanceRange.min) / (distanceRange.max - distanceRange.min)
        let scaledHospitalDistance = (property.hospitalDistance - distanceRange.min) / (distanceRange.max - distanceRange.min)
        let scaledSchoolDistance = (property.schoolDistance - distanceRange.min) / (distanceRange.max - distanceRange.min)
        let scaledAge = (age - ageRange.min) / (ageRange.max - ageRange.min)
        let scaledAvgDistance = (avgDistance - distanceRange.min) / (distanceRange.max - distanceRange.min)
        
        let cementGradeNormalized = Double(property.cementGrade - 43) / 10.0
        let qualitySum = Double(property.woodQuality) + cementGradeNormalized + Double(property.steelGrade) + Double(property.brickType) + Double(property.flooringQuality) + Double(property.paintQuality) + Double(property.plumbingQuality) + Double(property.electricalQuality) + Double(property.roofingType) + Double(property.windowGlassQuality)
        let totalQuality = qualitySum / 10.0

        do {
            let input = HomeWorthModel2Input(
                totalarea: Int64(round(scaledTotalarea)),
                atmDistance: scaledAtmDistance,
                hospitalDistance: scaledHospitalDistance,
                schoolDistance: scaledSchoolDistance,
                age: Int64(round(scaledAge)),
                avg_distance: scaledAvgDistance,
                wood_quality: Int64(property.woodQuality),
                cement_grade: Int64(property.cementGrade),
                steel_grade: Int64(property.steelGrade),
                brick_type: Int64(property.brickType),
                flooring_quality: Int64(property.flooringQuality),
                paint_quality: Int64(property.paintQuality),
                plumbing_quality: Int64(property.plumbingQuality),
                electrical_quality: Int64(property.electricalQuality),
                roofing_type: Int64(property.roofingType),
                window_glass_quality: Int64(property.windowGlassQuality),
                area_type: Int64(property.areaType),
                balconies: Int64(property.balconies),
                bathrooms: Int64(property.bathrooms),
                number_of_floors: Int64(property.numberOfFloors),
                bedrooms: Int64(property.bedrooms),
                total_quality: totalQuality
            )

            let prediction = try model.prediction(input: input)
            return prediction.final_price
        } catch {
            print("Prediction failed for property \(property.id!): \(error.localizedDescription)")
            return nil
        }
    }
}
