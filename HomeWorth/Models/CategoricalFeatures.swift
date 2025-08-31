//
// CategoricalFeatures.swift
//  HomeWorth
//
//  Created by Subi Suresh on 31/08/2025.
//


import Foundation

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
