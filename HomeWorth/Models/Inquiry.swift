//
//  Inquiry.swift
//  HomeWorth
//
//  Created by Subi Suresh on 14/08/2025.
//


import Foundation

struct Inquiry: Codable, Identifiable {
    let id: UUID?
    let propertyId: UUID
    let buyerId: UUID
    let sellerId: UUID
    let message: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case propertyId = "property_id"
        case buyerId = "buyer_id"
        case sellerId = "seller_id"
        case message
        case createdAt = "created_at"
    }
}