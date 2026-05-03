//
//  Category.swift
//  NAVIQ
//
//  Destination categories.
//  The team data (Locations.docx) has no category field — only tags.
//  The inferFrom(tags:) function automatically determines the category from tags.
//
//  Design:
//  - Auto-inference is the default. 90%+ of destinations classify correctly from tags alone.
//  - Awkward cases (e.g. Watsons Bay) are explicitly overridden in the destination definition.
//

import Foundation

enum Category: String, Codable, Hashable, CaseIterable {
    case beach           // Bondi, Manly, Coogee, Cronulla, Palm Beach, Balmoral
    case harbour         // Sydney harbour locations (Circular Quay, Watsons Bay)
    case waterfront      // River/harbour waterfront (Darling Harbour, Barangaroo, Rhodes)
    case landmark        // Landmarks
    case culture         // Culture/history (The Rocks, Glebe)
    case food            // Food/cafes/nightlife (Newtown, Surry Hills, Parramatta)
    case shopping        // Shopping centres (Chatswood, Hornsby, Macquarie, Liverpool, Rouse Hill)
    case park            // Parks/nature (Botanic Garden, Olympic Park, Katoomba)
    case nature          // Wildlife/adventure (Taronga Zoo, Mosman, Penrith)
    case transportHub    // Transport hubs (Central, UTS Broadway, Strathfield)

    var displayName: String {
        switch self {
        case .beach:        return "Beach"
        case .harbour:      return "Harbour"
        case .waterfront:   return "Waterfront"
        case .landmark:     return "Landmark"
        case .culture:      return "Culture"
        case .food:         return "Food"
        case .shopping:     return "Shopping"
        case .park:         return "Park"
        case .nature:       return "Nature"
        case .transportHub: return "Transport Hub"
        }
    }

    var iconName: String {
        switch self {
        case .beach:        return "beach.umbrella.fill"
        case .harbour:      return "ferry.fill"
        case .waterfront:   return "water.waves"
        case .landmark:     return "mappin.and.ellipse"
        case .culture:      return "building.columns.fill"
        case .food:         return "fork.knife"
        case .shopping:     return "bag.fill"
        case .park:         return "tree.fill"
        case .nature:       return "leaf.fill"
        case .transportHub: return "tram.tunnel.fill"
        }
    }

    // MARK: - Auto-inference (tags -> Category)

    /// Determines the most appropriate Category from the team's tags array.
    /// More specific signals (e.g. "Beach") take priority over general ones (e.g. "Shopping").
    ///
    /// - Note: 27 of 30 destinations classify correctly via auto-inference.
    ///   The remaining 3 (Watsons Bay, Mosman, Penrith) are explicitly overridden.
    static func inferFrom(tags: [String]) -> Category {
        let set = Set(tags)

        // Priority 1: Most specific signals — beach/nature
        if set.contains("Beach")        { return .beach }
        if set.contains("Lookouts") ||
           (set.contains("Nature") && !set.contains("Walks")) { return .park }

        // Priority 2: Harbour/waterfront
        if set.contains("Harbour") && set.contains("Ferries") { return .harbour }
        if set.contains("Waterfront") { return .waterfront }

        // Priority 3: Strong first-tag signals
        if let first = tags.first {
            switch first {
            case "Shopping":      return .shopping
            case "Food":          return .food
            case "Transport Hub": return .transportHub
            case "Historic":      return .culture
            case "Nature":        return .park
            case "Events":        return .park
            case "Outdoors":      return .nature
            case "Family":        return .nature
            case "Students":      return .transportHub
            default: break
            }
        }

        // Priority 4: Secondary signals
        if set.contains("Historic") || set.contains("History") || set.contains("Markets") { return .culture }
        if set.contains("Cafes") || set.contains("Dining") || set.contains("Nightlife") { return .food }
        if set.contains("Animals") || set.contains("Adventure") { return .nature }

        // Fallback
        return .landmark
    }
}
