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

    init() {
        self.model = try? HomeWorthModel(configuration: MLModelConfiguration())
    }

    func makePrediction() {
        guard let model = model else {
            self.message = "Model could not be loaded."
            return
        }

        guard let areaValue = Int64(area),
              let bedroomsValue = Int64(bedrooms),
              let bathroomsValue = Int64(bathrooms),
              let balconiesValue = Int64(balconies),
              let builtYearValue = Int64(builtYear),
              let numberOfFloorsValue = Int64(numberOfFloors),
              let atmDistanceValue = Double(atmDistance),
              let hospitalDistanceValue = Double(hospitalDistance),
              let schoolDistanceValue = Double(schoolDistance)
        else {
            self.message = "Invalid input. Please enter valid numbers for all fields."
            self.predictedPrice = nil
            self.formattedPrice = "N/A"
            return
        }
        
        // Call the Core ML model's prediction method
        do {
            let prediction = try model.prediction(
                area: areaValue,
                atmDistance: atmDistanceValue,
                balconies: balconiesValue,
                bathrooms: bathroomsValue,
                hospitalDistance: hospitalDistanceValue,
                schoolDistance: schoolDistanceValue,
                Built_Year: builtYearValue,
                number_of_floors: numberOfFloorsValue,
                bedrooms: bedroomsValue,
                wood_quality: Int64(woodQuality.rawValue), // Use rawValue from the enum
                cement_grade: Int64(cementGrade.rawValue),
                steel_grade: Int64(steelGrade.rawValue),
                brick_type: Int64(brickType.rawValue),
                flooring_quality: Int64(flooringQuality.rawValue),
                paint_quality: Int64(paintQuality.rawValue),
                plumbing_quality: Int64(plumbingQuality.rawValue),
                electrical_quality: Int64(electricalQuality.rawValue),
                roofing_type: Int64(roofingType.rawValue),
                window_glass_quality: Int64(windowGlassQuality.rawValue),
                area_type: Int64(areaType.rawValue)
            )
            
            let realPrice = exp(prediction.log_price) - 1
            self.predictedPrice = realPrice
            self.formattedPrice = formatPrice(realPrice)
            self.message = "Predicted fair price."
        } catch {
            self.message = "Prediction failed: \(error.localizedDescription)"
            self.predictedPrice = nil
            self.formattedPrice = "N/A"
        }
    }
    
    // MARK: - Save to Supabase (Fixed: Now async)
    func savePropertyToSupabase() async {
        // Ensure all required fields are filled
        guard let askingPriceValue = Double(askingPrice) else {
            self.message = "Please fill all fields before saving."
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
                area: Double(area) ?? 0,
                bedrooms: Int(bedrooms) ?? 0,
                bathrooms: Int(bathrooms) ?? 0,
                balconies: Int(balconies) ?? 0,
                builtYear: Int(builtYear) ?? 0,
                numberOfFloors: Int(numberOfFloors) ?? 0,
                atmDistance: Double(atmDistance) ?? 0,
                hospitalDistance: Double(hospitalDistance) ?? 0,
                schoolDistance: Double(schoolDistance) ?? 0,
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
                        // Reset the form after successful save
                        self.resetForm()
                    }
                }
            }
            
        } catch {
            self.message = "Failed to get current user: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Helper Functions
    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: price)) ?? "₹0"
    }
    
    private func resetForm() {
        area = ""; bedrooms = ""; bathrooms = ""; balconies = ""; builtYear = ""
        numberOfFloors = ""; atmDistance = ""; hospitalDistance = ""; schoolDistance = ""
        askingPrice = ""
        predictedPrice = nil
        formattedPrice = "N/A"
        message = ""
    }
}
