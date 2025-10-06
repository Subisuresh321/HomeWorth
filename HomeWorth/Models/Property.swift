// HomeWorth/Models/Property.swift
import Foundation

struct Property: Codable, Identifiable {
    var id: UUID?
    var sellerId: UUID
    var area: Double
    var bedrooms: Int
    var bathrooms: Int
    var balconies: Int
    var builtYear: Int
    var numberOfFloors: Int
    var atmDistance: Double
    var hospitalDistance: Double
    var schoolDistance: Double
    var woodQuality: Int
    var cementGrade: Int
    var steelGrade: Int
    var brickType: Int
    var flooringQuality: Int
    var paintQuality: Int
    var plumbingQuality: Int
    var electricalQuality: Int
    var roofingType: Int
    var windowGlassQuality: Int
    var areaType: Int
    var predictedPrice: Double?
    var askingPrice: Double?
    var imageUrls: [String]?
    var description: String?
    var status: String
    var createdAt: Date?
    var latitude: Double?
    var longitude: Double?
    var address: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case sellerId = "seller_id"
        case area
        case bedrooms
        case bathrooms
        case balconies
        case builtYear = "built_year"
        case numberOfFloors = "number_of_floors"
        case atmDistance = "atm_distance"
        case hospitalDistance = "hospital_distance"
        case schoolDistance = "school_distance"
        case woodQuality = "wood_quality"
        case cementGrade = "cement_grade"
        case steelGrade = "steel_grade"
        case brickType = "brick_type"
        case flooringQuality = "flooring_quality"
        case paintQuality = "paint_quality"
        case plumbingQuality = "plumbing_quality"
        case electricalQuality = "electrical_quality"
        case roofingType = "roofing_type"
        case windowGlassQuality = "window_glass_quality"
        case areaType = "area_type"
        case askingPrice = "asking_price"
        case imageUrls = "image_urls"
        case description
        case status
        case createdAt = "created_at"
        case latitude
        case longitude
        case address
    }
}
