// HomeWorth/ViewModels/AddPropertyViewModel.swift
import Foundation
import CoreML

// MARK: - Enums for Categorical Features (Updated to match Python)
enum WoodQuality: Int, CaseIterable, Identifiable {
    case low = 0, medium = 1, high = 2
    var id: Int { self.rawValue }
    var description: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

enum CementGrade: Int, CaseIterable, Identifiable {
    case grade43 = 43, grade53 = 53
    var id: Int { self.rawValue }
    var description: String {
        switch self {
        case .grade43: return "Grade 43"
        case .grade53: return "Grade 53"
        }
    }
}

enum SteelGrade: Int, CaseIterable, Identifiable {
    case fe415 = 0, fe500 = 1, fe550 = 2
    var id: Int { self.rawValue }
    var description: String {
        switch self {
        case .fe415: return "Fe415"
        case .fe500: return "Fe500"
        case .fe550: return "Fe550"
        }
    }
}

enum BrickType: Int, CaseIterable, Identifiable {
    case flyAsh = 0, redClay = 1, aac = 2
    var id: Int { self.rawValue }
    var description: String {
        switch self {
        case .flyAsh: return "Fly Ash"
        case .redClay: return "Red Clay"
        case .aac: return "AAC"
        }
    }
}

enum FlooringQuality: Int, CaseIterable, Identifiable {
    case basic = 0, standard = 1, premium = 2
    var id: Int { self.rawValue }
    var description: String {
        switch self {
        case .basic: return "Basic"
        case .standard: return "Standard"
        case .premium: return "Premium"
        }
    }
}

enum PaintQuality: Int, CaseIterable, Identifiable {
    case basic = 0, weatherproof = 1, luxury = 2
    var id: Int { self.rawValue }
    var description: String {
        switch self {
        case .basic: return "Basic"
        case .weatherproof: return "Weatherproof"
        case .luxury: return "Luxury"
        }
    }
}

enum PlumbingQuality: Int, CaseIterable, Identifiable {
    case local = 0, brandedBasic = 1, premium = 2
    var id: Int { self.rawValue }
    var description: String {
        switch self {
        case .local: return "Local"
        case .brandedBasic: return "Branded (Basic)"
        case .premium: return "Premium"
        }
    }
}

enum ElectricalQuality: Int, CaseIterable, Identifiable {
    case local = 0, branded = 1, premium = 2
    var id: Int { self.rawValue }
    var description: String {
        switch self {
        case .local: return "Local"
        case .branded: return "Branded"
        case .premium: return "Premium"
        }
    }
}

enum RoofingType: Int, CaseIterable, Identifiable {
    case metal = 0, concrete = 1, tiled = 2
    var id: Int { self.rawValue }
    var description: String {
        switch self {
        case .metal: return "Metal"
        case .concrete: return "Concrete"
        case .tiled: return "Tiled"
        }
    }
}

enum WindowGlassQuality: Int, CaseIterable, Identifiable {
    case singleGlass = 0, doubleGlazed = 1
    var id: Int { self.rawValue }
    var description: String {
        switch self {
        case .singleGlass: return "Single Glass"
        case .doubleGlazed: return "Double Glazed"
        }
    }
}

enum AreaType: Int, CaseIterable, Identifiable {
    case urban = 0, suburban = 1, rural = 2
    var id: Int { self.rawValue }
    var description: String {
        switch self {
        case .urban: return "Urban"
        case .suburban: return "Suburban"
        case .rural: return "Rural"
        }
    }
}

@MainActor
class AddPropertyViewModel: ObservableObject {
    // MARK: - Input Properties (Updated to match Python ranges)
    @Published var totalarea: String = ""  // Renamed from 'area' to match Python
    @Published var bedrooms: String = ""
    @Published var bathrooms: String = ""
    @Published var balconies: String = ""
    @Published var builtYear: String = ""
    @Published var numberOfFloors: String = ""
    @Published var atmDistance: String = ""
    @Published var hospitalDistance: String = ""
    @Published var schoolDistance: String = ""
    
    // Categorical features using enums
    @Published var woodQuality: WoodQuality = .medium
    @Published var cementGrade: CementGrade = .grade43
    @Published var steelGrade: SteelGrade = .fe500
    @Published var brickType: BrickType = .redClay
    @Published var flooringQuality: FlooringQuality = .standard
    @Published var paintQuality: PaintQuality = .basic
    @Published var plumbingQuality: PlumbingQuality = .brandedBasic
    @Published var electricalQuality: ElectricalQuality = .branded
    @Published var roofingType: RoofingType = .concrete
    @Published var windowGlassQuality: WindowGlassQuality = .singleGlass
    @Published var areaType: AreaType = .urban

    // MARK: - Output Properties
    @Published var predictedPrice: Double?
    @Published var formattedPrice: String = "N/A"
    @Published var message: String = ""
    @Published var askingPrice: String = ""

    // The Core ML model instance
    private var model: HomeWorthModel2?

    // Scaling ranges matching Python dataset generation
    private let totalareaRange = (min: 500.0, max: 3000.0)  // Updated range
    private let distanceRange = (min: 0.1, max: 5.0)        // Updated range
    private let ageRange = (min: 0.0, max: 50.0)            // Updated range
    
    // Valid input ranges
    private let builtYearRange = (min: 1974, max: 2024)     // Updated to match age 0-50

    init() {
        do {
            self.model = try HomeWorthModel2(configuration: MLModelConfiguration())
        } catch {
            self.message = "Failed to load CoreML model: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Input Validation and Clamping
    private func clampDistance(_ distance: Double) -> Double {
        return max(distanceRange.min, min(distanceRange.max, distance))
    }
    
    private func clampBuiltYear(_ year: Int) -> Int {
        return max(builtYearRange.min, min(builtYearRange.max, year))
    }
    
    private func clampTotalArea(_ area: Double) -> Double {
        return max(totalareaRange.min, min(totalareaRange.max, area))
    }

    // MARK: - Core ML Prediction Function
    func makePrediction() {
        guard let model = model else {
            self.message = "Model could not be loaded."
            self.predictedPrice = nil
            self.formattedPrice = "N/A"
            return
        }

        // Validate and convert inputs
        guard let totalareaValue = Double(totalarea), totalareaValue > 0,
              let bedroomsValue = Int64(bedrooms), bedroomsValue > 0, bedroomsValue <= 5,
              let bathroomsValue = Int64(bathrooms), bathroomsValue > 0, bathroomsValue <= 4,
              let balconiesValue = Int64(balconies), balconiesValue >= 0, balconiesValue <= 3,
              let builtYearInput = Int(builtYear),
              let numberOfFloorsValue = Int64(numberOfFloors), numberOfFloorsValue > 0, numberOfFloorsValue <= 3,
              let atmDistanceInput = Double(atmDistance), atmDistanceInput > 0,
              let hospitalDistanceInput = Double(hospitalDistance), hospitalDistanceInput > 0,
              let schoolDistanceInput = Double(schoolDistance), schoolDistanceInput > 0
        else {
            self.message = "Invalid input. Please ensure all fields are valid numbers within realistic ranges."
            self.predictedPrice = nil
            self.formattedPrice = "N/A"
            return
        }
        
        // Apply clamping to match Python dataset ranges
        let clampedTotalarea = clampTotalArea(totalareaValue)
        let clampedBuiltYear = clampBuiltYear(builtYearInput)
        let clampedAtmDistance = clampDistance(atmDistanceInput)
        let clampedHospitalDistance = clampDistance(hospitalDistanceInput)
        let clampedSchoolDistance = clampDistance(schoolDistanceInput)
        
        // Calculate derived features matching Python logic
        let age = Double(2024 - clampedBuiltYear)  // Current year - built year
        let avgDistance = (clampedAtmDistance + clampedHospitalDistance + clampedSchoolDistance) / 3.0
        
        // Scale numerical inputs using dataset ranges
        let scaledTotalarea = scaleInput(clampedTotalarea, min: totalareaRange.min, max: totalareaRange.max)
        let scaledAtmDistance = scaleInput(clampedAtmDistance, min: distanceRange.min, max: distanceRange.max)
        let scaledHospitalDistance = scaleInput(clampedHospitalDistance, min: distanceRange.min, max: distanceRange.max)
        let scaledSchoolDistance = scaleInput(clampedSchoolDistance, min: distanceRange.min, max: distanceRange.max)
        let scaledAge = scaleInput(age, min: ageRange.min, max: ageRange.max)
        let scaledAvgDistance = scaleInput(avgDistance, min: distanceRange.min, max: distanceRange.max)

        // Calculate total_quality matching Python algorithm
        let cementGradeNormalized = Double(cementGrade.rawValue - 43) / 10.0  // Normalize cement grade
        
        let qualitySum = Double(woodQuality.rawValue) +
                        cementGradeNormalized +
                        Double(steelGrade.rawValue) +
                        Double(brickType.rawValue) +
                        Double(flooringQuality.rawValue) +
                        Double(paintQuality.rawValue) +
                        Double(plumbingQuality.rawValue) +
                        Double(electricalQuality.rawValue) +
                        Double(roofingType.rawValue) +
                        Double(windowGlassQuality.rawValue)
        
        let totalQuality = qualitySum / 10.0  // Normalize by 10 quality components

        // Create CoreML input using exact Python feature names and values
        do {
            let input = HomeWorthModel2Input(
                totalarea: Int64(scaledTotalarea),                    // Renamed from 'area'
                atmDistance: scaledAtmDistance,
                hospitalDistance: scaledHospitalDistance,
                schoolDistance: scaledSchoolDistance,
                age: Int64(scaledAge),
                avg_distance: scaledAvgDistance,
                wood_quality: Int64(woodQuality.rawValue),
                cement_grade: Int64(cementGrade.rawValue),
                steel_grade: Int64(steelGrade.rawValue),
                brick_type: Int64(brickType.rawValue),
                flooring_quality: Int64(flooringQuality.rawValue),
                paint_quality: Int64(paintQuality.rawValue),
                plumbing_quality: Int64(plumbingQuality.rawValue),
                electrical_quality: Int64(electricalQuality.rawValue),
                roofing_type: Int64(roofingType.rawValue),
                window_glass_quality: Int64(windowGlassQuality.rawValue),
                area_type: Int64(areaType.rawValue),
                balconies: balconiesValue,
                bathrooms: bathroomsValue,
                number_of_floors: numberOfFloorsValue,
                bedrooms: bedroomsValue,
                total_quality: totalQuality
            )
            
            let prediction = try model.prediction(input: input)
            
            // Get predicted price (assuming model outputs final_price directly)
            let predictedPriceValue = prediction.final_price
            
            // Validate price per square foot is realistic (₹800-₹4500)
            
            
            // Store results
            self.predictedPrice = predictedPriceValue
            self.formattedPrice = formatPrice(predictedPriceValue)
            self.message = "Prediction successful!"
            
        } catch {
            self.message = "Prediction failed: \(error.localizedDescription)"
            self.predictedPrice = nil
            self.formattedPrice = "N/A"
        }
    }

    // MARK: - Save Property to Database
    func savePropertyToSupabase() async {
        // Validate all inputs before saving
        guard let askingPriceValue = Double(askingPrice), askingPriceValue > 0,
              let totalareaValue = Double(totalarea), totalareaValue > 0,
              let bedroomsValue = Int(bedrooms), bedroomsValue > 0,
              let bathroomsValue = Int(bathrooms), bathroomsValue > 0,
              let balconiesValue = Int(balconies), balconiesValue >= 0,
              let builtYearInput = Int(builtYear),
              let numberOfFloorsValue = Int(numberOfFloors), numberOfFloorsValue > 0,
              let atmDistanceInput = Double(atmDistance), atmDistanceInput > 0,
              let hospitalDistanceInput = Double(hospitalDistance), hospitalDistanceInput > 0,
              let schoolDistanceInput = Double(schoolDistance), schoolDistanceInput > 0
        else {
            self.message = "Please fill all fields with valid numbers."
            return
        }
        
        // Apply same clamping for consistency
        let clampedTotalarea = clampTotalArea(totalareaValue)
        let clampedBuiltYear = clampBuiltYear(builtYearInput)
        let clampedAtmDistance = clampDistance(atmDistanceInput)
        let clampedHospitalDistance = clampDistance(hospitalDistanceInput)
        let clampedSchoolDistance = clampDistance(schoolDistanceInput)

        // Get current user ID
        do {
            guard let sellerId = try await SupabaseService.shared.currentUserId else {
                self.message = "Please sign in before saving property."
                return
            }

            let newProperty = Property(
                id: nil,
                sellerId: sellerId,
                area: clampedTotalarea,                    // Using clamped values
                bedrooms: bedroomsValue,
                bathrooms: bathroomsValue,
                balconies: balconiesValue,
                builtYear: clampedBuiltYear,
                numberOfFloors: numberOfFloorsValue,
                atmDistance: clampedAtmDistance,
                hospitalDistance: clampedHospitalDistance,
                schoolDistance: clampedSchoolDistance,
                woodQuality: woodQuality.rawValue,
                cementGrade: cementGrade.rawValue,
                steelGrade: steelGrade.rawValue,
                brickType: brickType.rawValue,
                flooringQuality: flooringQuality.rawValue,
                paintQuality: paintQuality.rawValue,
                plumbingQuality: plumbingQuality.rawValue,
                electricalQuality: electricalQuality.rawValue,
                roofingType: roofingType.rawValue,
                windowGlassQuality: windowGlassQuality.rawValue,
                areaType: areaType.rawValue,
                askingPrice: askingPriceValue,
                imageUrls: nil,
                status: "pending",
                createdAt: Date()
            )

            SupabaseService.shared.createProperty(property: newProperty) { error in
                Task { @MainActor in
                    if let error = error {
                        self.message = "Failed to save property: \(error.localizedDescription)"
                    } else {
                        self.message = "Property saved successfully!"
                        self.resetForm()
                    }
                }
            }
        } catch {
            self.message = "Failed to get current user: \(error.localizedDescription)"
        }
    }

    // MARK: - Utility Functions
    private func scaleInput(_ value: Double, min: Double, max: Double) -> Double {
        // Min-Max scaling: (value - min) / (max - min)
        return (value - min) / (max - min)
    }

    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "₹0"
    }

    private func resetForm() {
        totalarea = ""
        bedrooms = ""
        bathrooms = ""
        balconies = ""
        builtYear = ""
        numberOfFloors = ""
        atmDistance = ""
        hospitalDistance = ""
        schoolDistance = ""
        askingPrice = ""
        predictedPrice = nil
        formattedPrice = "N/A"
        message = ""
        
        // Reset to default enum values matching Python probabilities
        woodQuality = .medium
        cementGrade = .grade43
        steelGrade = .fe500
        brickType = .redClay
        flooringQuality = .standard
        paintQuality = .basic
        plumbingQuality = .brandedBasic
        electricalQuality = .branded
        roofingType = .concrete
        windowGlassQuality = .singleGlass
        areaType = .urban
    }
    
    // MARK: - Validation Helpers
    func validateInputs() -> Bool {
        // Comprehensive input validation
        guard let totalareaVal = Double(totalarea),
              totalareaVal > 0 && totalareaVal <= 3000,
              let bedroomsVal = Int(bedrooms),
              bedroomsVal > 0 && bedroomsVal <= 5,
              let bathroomsVal = Int(bathrooms),
              bathroomsVal > 0 && bathroomsVal <= 4,
              let balconiesVal = Int(balconies),
              balconiesVal >= 0 && balconiesVal <= 3,
              let builtYearVal = Int(builtYear),
              builtYearVal >= builtYearRange.min && builtYearVal <= builtYearRange.max,
              let floorsVal = Int(numberOfFloors),
              floorsVal > 0 && floorsVal <= 3,
              let atmDist = Double(atmDistance),
              atmDist > 0 && atmDist <= 5,
              let hospitalDist = Double(hospitalDistance),
              hospitalDist > 0 && hospitalDist <= 5,
              let schoolDist = Double(schoolDistance),
              schoolDist > 0 && schoolDist <= 5
        else {
            return false
        }
        
        return true
    }
    
    // MARK: - Feature Engineering (matching Python)
    private func calculateDerivedFeatures() -> (age: Double, avgDistance: Double) {
        let totalareaVal = Double(totalarea) ?? 0
        let builtYearVal = Int(builtYear) ?? 2024
        let atmDist = Double(atmDistance) ?? 0
        let hospitalDist = Double(hospitalDistance) ?? 0
        let schoolDist = Double(schoolDistance) ?? 0
        
        let age = Double(2024 - builtYearVal)
        let avgDistance = (atmDist + hospitalDist + schoolDist) / 3.0
        
        return (age, avgDistance)
    }
}
