// HomeWorth/ViewModels/AdminDashboardViewModel.swift
import Foundation
import CoreML
import Supabase

class AdminDashboardViewModel: ObservableObject {
    @Published var allProperties: [Property] = [] // To hold all properties
    @Published var pendingProperties: [Property] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedFilter: String = "pending" // "pending", "approved", "rejected", "all"

    // ML model instance
    private var mlModel: HomeWorthModel2?

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
                    self.allProperties = fetchedProperties
                    self.applyFilter()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func applyFilter() {
        switch selectedFilter {
        case "approved":
            self.pendingProperties = self.allProperties.filter { $0.status == "approved" }.compactMap(self.createAdminProperty)
        case "rejected":
            self.pendingProperties = self.allProperties.filter { $0.status == "rejected" }.compactMap(self.createAdminProperty)
        case "all":
            self.pendingProperties = self.allProperties.compactMap(self.createAdminProperty)
        default: // "pending"
            self.pendingProperties = self.allProperties.filter { $0.status == "pending" }.compactMap(self.createAdminProperty)
        }
    }

    private func createAdminProperty(from property: Property) -> Property? {
        var newProperty = property
        if let predictedPrice = self.makePrediction(for: property) {
            newProperty.predictedPrice = predictedPrice
        }
        return newProperty
    }

    private func makePrediction(for property: Property) -> Double? {
        // (existing ML prediction logic from the previous step)
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
                totalarea: Int64(scaledTotalarea),
                atmDistance: scaledAtmDistance,
                hospitalDistance: scaledHospitalDistance,
                schoolDistance: scaledSchoolDistance,
                age: Int64(scaledAge),
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
    
    func approveProperty(propertyId: UUID) {
        // (existing approveProperty logic)
        SupabaseService.shared.updatePropertyStatus(propertyId: propertyId, newStatus: "approved") { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to approve property: \(error.localizedDescription)"
                }
            } else {
                self?.fetchProperties() // Fetch all properties to update the list
            }
        }
    }

    func rejectProperty(propertyId: UUID) {
        // (existing rejectProperty logic)
        SupabaseService.shared.updatePropertyStatus(propertyId: propertyId, newStatus: "rejected") { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to reject property: \(error.localizedDescription)"
                }
            } else {
                self?.fetchProperties() // Fetch all properties to update the list
            }
        }
    }
}
