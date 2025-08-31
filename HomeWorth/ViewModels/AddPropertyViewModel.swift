// HomeWorth/ViewModels/AddPropertyViewModel.swift
import Foundation
import CoreML
import UIKit

@MainActor
class AddPropertyViewModel: ObservableObject {
    // MARK: - Input Properties
    @Published var totalarea: String = ""
    @Published var bedrooms: String = ""
    @Published var bathrooms: String = ""
    @Published var balconies: String = ""
    @Published var builtYear: String = ""
    @Published var numberOfFloors: String = ""
    @Published var atmDistance: String = ""
    @Published var hospitalDistance: String = ""
    @Published var schoolDistance: String = ""
    @Published var propertyDescription: String = ""
    @Published var selectedImages: [UIImage] = []
    
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
    private let totalareaRange = (min: 500.0, max: 3000.0)
    private let distanceRange = (min: 0.1, max: 5.0)
    private let ageRange = (min: 0.0, max: 50.0)
    
    // Valid input ranges
    private let builtYearRange = (min: 1974, max: 2024)

    init() {
        do {
            self.model = try HomeWorthModel2(configuration: MLModelConfiguration())
        } catch {
            self.message = "Failed to load CoreML model: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Image Compression Helper
    private func compressImage(_ image: UIImage, targetSizeKB: Int = 500) -> UIImage? {
        // First, resize the image to a reasonable size
        let targetSize = CGSize(width: 1024, height: 1024)
        let resizedImage = resizeImage(image, targetSize: targetSize)
        
        // Compress with JPEG
        var compressionQuality: CGFloat = 0.8
        let targetBytes = targetSizeKB * 1024
        
        while compressionQuality > 0.1 {
            if let imageData = resizedImage.jpegData(compressionQuality: compressionQuality),
               imageData.count <= targetBytes {
                return UIImage(data: imageData)
            }
            compressionQuality -= 0.1
        }
        
        // If still too large, return the image with minimum quality
        if let imageData = resizedImage.jpegData(compressionQuality: 0.1) {
            return UIImage(data: imageData)
        }
        
        return resizedImage
    }
    
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Determine what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
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
    
        let clampedTotalarea = clampTotalArea(totalareaValue)
        let clampedBuiltYear = clampBuiltYear(builtYearInput)
        let clampedAtmDistance = clampDistance(atmDistanceInput)
        let clampedHospitalDistance = clampDistance(hospitalDistanceInput)
        let clampedSchoolDistance = clampDistance(schoolDistanceInput)
        
        let age = Double(2024 - clampedBuiltYear)
        let avgDistance = (clampedAtmDistance + clampedHospitalDistance + clampedSchoolDistance) / 3.0
        
        let scaledTotalarea = scaleInput(clampedTotalarea, min: totalareaRange.min, max: totalareaRange.max)
        let scaledAtmDistance = scaleInput(clampedAtmDistance, min: distanceRange.min, max: distanceRange.max)
        let scaledHospitalDistance = scaleInput(clampedHospitalDistance, min: distanceRange.min, max: distanceRange.max)
        let scaledSchoolDistance = scaleInput(clampedSchoolDistance, min: distanceRange.min, max: distanceRange.max)
        let scaledAge = scaleInput(age, min: ageRange.min, max: ageRange.max)
        let scaledAvgDistance = scaleInput(avgDistance, min: distanceRange.min, max: distanceRange.max)

        let cementGradeNormalized = Double(cementGrade.rawValue - 43) / 10.0
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
        
        let totalQuality = qualitySum / 10.0

        do {
            let input = HomeWorthModel2Input(
                totalarea: Int64(scaledTotalarea),
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
            let predictedPriceValue = prediction.final_price
            
            self.predictedPrice = predictedPriceValue
            self.formattedPrice = formatPrice(predictedPriceValue)
            self.message = "Prediction successful!"
            
        } catch {
            self.message = "Prediction failed: \(error.localizedDescription)"
            self.predictedPrice = nil
            self.formattedPrice = "N/A"
        }
    }

    // MARK: - Save Property to Database (Updated with Batch Upload)
    func savePropertyToSupabase() async {
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
        
        guard !selectedImages.isEmpty else {
            self.message = "Please select at least one image for your property."
            return
        }
        
        guard !propertyDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.message = "Please provide a description for your property."
            return
        }
        
        self.message = "Compressing and uploading images..."
        
        do {
            let imageURLs = try await uploadImagesWithCompression(images: selectedImages)
            
            guard let sellerId = try await SupabaseService.shared.currentUserId else {
                self.message = "Please sign in before saving property."
                return
            }

            let newProperty = Property(
                id: nil,
                sellerId: sellerId,
                area: totalareaValue,
                bedrooms: bedroomsValue,
                bathrooms: bathroomsValue,
                balconies: balconiesValue,
                builtYear: builtYearInput,
                numberOfFloors: numberOfFloorsValue,
                atmDistance: atmDistanceInput,
                hospitalDistance: hospitalDistanceInput,
                schoolDistance: schoolDistanceInput,
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
                predictedPrice: self.predictedPrice,
                askingPrice: askingPriceValue,
                imageUrls: imageURLs,
                description: propertyDescription,
                status: "pending",
                createdAt: Date()
            )

            SupabaseService.shared.createProperty(property: newProperty) { [weak self] error in
                Task { @MainActor in
                    if let error = error {
                        self?.message = "Failed to save property: \(error.localizedDescription)"
                    } else {
                        self?.message = "Property saved successfully and awaiting admin approval!"
                        self?.resetForm()
                    }
                }
            }
        } catch {
            self.message = "Failed to upload images: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Enhanced Image Upload with Compression and Progress
    private func uploadImagesWithCompression(images: [UIImage]) async throws -> [String] {
        var imageUrls: [String] = []
        
        for (index, image) in images.enumerated() {
            // Update progress message
            self.message = "Compressing and uploading image \(index + 1) of \(images.count)..."
            
            // Compress the image
            guard let compressedImage = compressImage(image, targetSizeKB: 500) else {
                throw NSError(domain: "ImageCompression", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image \(index + 1)"])
            }
            
            let uniqueFileName = UUID().uuidString + ".jpeg"
            
            let url = try await withCheckedThrowingContinuation { continuation in
                SupabaseService.shared.uploadImage(image: compressedImage, to: "property-images", path: uniqueFileName) { result in
                    continuation.resume(with: result)
                }
            }
            imageUrls.append(url.absoluteString)
        }
        
        return imageUrls
    }

    // MARK: - Alternative Batch Upload Method
    private func uploadImagesBatch(images: [UIImage]) async throws -> [String] {
        // Compress all images first
        var compressedImages: [(UIImage, String)] = []
        
        for (index, image) in images.enumerated() {
            self.message = "Compressing image \(index + 1) of \(images.count)..."
            
            guard let compressedImage = compressImage(image, targetSizeKB: 300) else {
                throw NSError(domain: "ImageCompression", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image \(index + 1)"])
            }
            
            let uniqueFileName = UUID().uuidString + ".jpeg"
            compressedImages.append((compressedImage, uniqueFileName))
        }
        
        // Upload compressed images
        var imageUrls: [String] = []
        
        for (index, (compressedImage, fileName)) in compressedImages.enumerated() {
            self.message = "Uploading image \(index + 1) of \(compressedImages.count)..."
            
            let url = try await withCheckedThrowingContinuation { continuation in
                SupabaseService.shared.uploadImage(image: compressedImage, to: "property-images", path: fileName) { result in
                    continuation.resume(with: result)
                }
            }
            imageUrls.append(url.absoluteString)
        }
        
        return imageUrls
    }

    // MARK: - Utility Functions
    private func scaleInput(_ value: Double, min: Double, max: Double) -> Double {
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
        propertyDescription = ""
        selectedImages = []
        askingPrice = ""
        predictedPrice = nil
        formattedPrice = "N/A"
        message = ""
        
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
}
