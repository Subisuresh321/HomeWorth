// HomeWorth/ViewModels/AddPropertyViewModel.swift
import Foundation
import CoreML

// MARK: - Enums for Categorical Features
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
    // MARK: - Input Properties
    @Published var area: String = ""
    @Published var bedrooms: String = ""
    @Published var bathrooms: String = ""
    @Published var balconies: String = ""
    @Published var builtYear: String = ""
    @Published var numberOfFloors: String = ""
    @Published var atmDistance: String = ""
    @Published var hospitalDistance: String = ""
    @Published var schoolDistance: String = ""
    
    // Using the new enum types
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
    private var model: HomeWorthModel?

    // Scaling ranges (must match Python MinMaxScaler)
    private let areaRange = (min: 937.0, max: 5000.0)
    private let distanceRange = (min: 4.0, max: 6.0)
    private let ageRange = (min: 0.0, max: 20.0)
    private let bedroomsPerAreaRange = (min: 0.0, max: 0.01)

    init() {
        do {
            self.model = try HomeWorthModel(configuration: MLModelConfiguration())
        } catch {
            self.message = "Failed to load CoreML model: \(error.localizedDescription)"
        }
    }

    // MARK: - Prediction Function
    func makePrediction() {
        guard let model = model else {
            self.message = "Model could not be loaded."
            self.predictedPrice = nil
            self.formattedPrice = "N/A"
            return
        }

        // Validate and convert inputs
        guard let areaValue = Double(area), areaValue > 0, areaValue <= 5000,
              let bedroomsValue = Int64(bedrooms), bedroomsValue > 0,
              let bathroomsValue = Int64(bathrooms), bathroomsValue > 0,
              let balconiesValue = Int64(balconies), balconiesValue >= 0,
              let builtYearValue = Int64(builtYear), builtYearValue >= 2005, builtYearValue <= 2025,
              let numberOfFloorsValue = Int64(numberOfFloors), numberOfFloorsValue > 0,
              let atmDistanceValue = Double(atmDistance), atmDistanceValue >= 4.0, atmDistanceValue <= 6.0,
              let hospitalDistanceValue = Double(hospitalDistance), hospitalDistanceValue >= 4.0, hospitalDistanceValue <= 6.0,
              let schoolDistanceValue = Double(schoolDistance), schoolDistanceValue >= 4.0, schoolDistanceValue <= 6.0
        else {
            self.message = "Invalid input. Ensure all fields are valid numbers, area ≤ 5000, bedrooms/bathrooms > 0, built year 2005–2025, and distances 4–6 km."
            self.predictedPrice = nil
            self.formattedPrice = "N/A"
            return
        }

        // Scale numerical inputs
        let scaledArea = scaleInput(areaValue, min: areaRange.min, max: areaRange.max)
        let scaledAtmDistance = scaleInput(atmDistanceValue, min: distanceRange.min, max: distanceRange.max)
        let scaledHospitalDistance = scaleInput(hospitalDistanceValue, min: distanceRange.min, max: distanceRange.max)
        let scaledSchoolDistance = scaleInput(schoolDistanceValue, min: distanceRange.min, max: distanceRange.max)
        let age = Double(2025 - builtYearValue)
        let scaledAge = scaleInput(age, min: ageRange.min, max: ageRange.max)
        let avgDistance = (atmDistanceValue + hospitalDistanceValue + schoolDistanceValue) / 3
        let scaledAvgDistance = scaleInput(avgDistance, min: distanceRange.min, max: distanceRange.max)
        let bedroomsPerArea = Double(bedroomsValue) / areaValue
        let scaledBedroomsPerArea = scaleInput(bedroomsPerArea, min: bedroomsPerAreaRange.min, max: bedroomsPerAreaRange.max)

        // Fixed: Calculate total_quality step by step to avoid compiler timeout
        let cementGradeNormalized = cementGrade.rawValue == 43 ? 0.0 : 1.0
        let qualityValues: [Double] = [
            Double(woodQuality.rawValue),
            cementGradeNormalized,
            Double(steelGrade.rawValue),
            Double(brickType.rawValue),
            Double(flooringQuality.rawValue),
            Double(paintQuality.rawValue),
            Double(plumbingQuality.rawValue),
            Double(electricalQuality.rawValue),
            Double(roofingType.rawValue),
            Double(windowGlassQuality.rawValue)
        ]
        let qualitySum = qualityValues.reduce(0, +)
        let totalQuality = qualitySum / 10.0

        // Fixed: Use the correct Core ML prediction method
        do {
            let input = HomeWorthModelInput(
                area: scaledArea,
                atmDistance: scaledAtmDistance,
                hospitalDistance: scaledHospitalDistance,
                schoolDistance: scaledSchoolDistance,
                age: scaledAge,
                avg_distance: scaledAvgDistance,
                bedrooms_per_area: scaledBedroomsPerArea,
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
            
            // Reverse log-transformation (model predicts final_price_log)
            let realPrice = exp(prediction.final_price_log) - 1
            
            // Validate price per square foot (pps) is within 800–4500
            let pps = realPrice / areaValue
            if pps < 800 || pps > 4500 {
                self.message = "Predicted price per square foot (₹\(Int(pps))) is outside realistic range (800–4500). Please check inputs."
                self.predictedPrice = nil
                self.formattedPrice = "N/A"
                return
            }
            
            self.predictedPrice = realPrice
            self.formattedPrice = formatPrice(realPrice)
            self.message = "Predicted fair price: \(self.formattedPrice)"
        } catch {
            self.message = "Prediction failed: \(error.localizedDescription)"
            self.predictedPrice = nil
            self.formattedPrice = "N/A"
        }
    }

    // MARK: - Save to Supabase
    func savePropertyToSupabase() async {
        // Ensure all required fields are filled
        guard let askingPriceValue = Double(askingPrice),
              let areaValue = Double(area), areaValue > 0,
              let bedroomsValue = Int(bedrooms), bedroomsValue > 0,
              let bathroomsValue = Int(bathrooms), bathroomsValue > 0,
              let balconiesValue = Int(balconies), balconiesValue >= 0,
              let builtYearValue = Int(builtYear), builtYearValue >= 2005, builtYearValue <= 2025,
              let numberOfFloorsValue = Int(numberOfFloors), numberOfFloorsValue > 0,
              let atmDistanceValue = Double(atmDistance), atmDistanceValue >= 4.0, atmDistanceValue <= 6.0,
              let hospitalDistanceValue = Double(hospitalDistance), hospitalDistanceValue >= 4.0, hospitalDistanceValue <= 6.0,
              let schoolDistanceValue = Double(schoolDistance), schoolDistanceValue >= 4.0, schoolDistanceValue <= 6.0
        else {
            self.message = "Please fill all fields with valid numbers."
            return
        }

        // Get current user ID asynchronously
        do {
            guard let sellerId = try await SupabaseService.shared.currentUserId else {
                self.message = "Please sign in before saving."
                return
            }

            let newProperty = Property(
                id: nil, // Supabase will generate this
                sellerId: sellerId,
                area: areaValue,
                bedrooms: bedroomsValue,
                bathrooms: bathroomsValue,
                balconies: balconiesValue,
                builtYear: builtYearValue,
                numberOfFloors: numberOfFloorsValue,
                atmDistance: atmDistanceValue,
                hospitalDistance: hospitalDistanceValue,
                schoolDistance: schoolDistanceValue,
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
                imageUrls: nil, // We'll add image upload later
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

    // MARK: - Helper Functions
    private func scaleInput(_ value: Double, min: Double, max: Double) -> Double {
        return (value - min) / (max - min)
    }

    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 0 // Round to nearest rupee
        return formatter.string(from: NSNumber(value: price)) ?? "₹0"
    }

    private func resetForm() {
        area = ""
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
        // Reset categorical defaults
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
}
