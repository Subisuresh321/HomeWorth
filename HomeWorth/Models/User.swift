//
//  User.swift
//  HomeWorth
//
//  Created by Subi Suresh on 09/08/2025.
//

// HomeWorth/Models/User.swift
import Foundation

struct User: Codable, Identifiable {
    var id: UUID
    var email: String
    var name: String?
    var phoneNumber: String?
    var userType: String // "buyer", "seller", "admin"
    var profilePhotoUrl: String? //
    var createdAt: Date? // Supabase timestamp

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case phoneNumber = "phone_number"
        case userType = "user_type"
        case profilePhotoUrl = "profile_photo_url" 
        case createdAt = "created_at"
    }
}
