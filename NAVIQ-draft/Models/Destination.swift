//
//  Destination.swift
//  NAVIQ
//
//  Static information about a single destination.
//  Reflects the team's Locations.docx format: name + location + tags + (auto-inferred category).
//

import Foundation

struct Destination: Identifiable, Codable, Hashable {
    /// Stable unique ID. Must match FareTable keys. e.g. "bondi-beach"
    let id: String

    /// Display name. e.g. "Bondi Beach"
    let name: String

    /// One-line description for Screen 4 detail header.
    let shortDescription: String

    /// Street address (preserved from team's "location" field).
    /// e.g. "Bondi Pavilion, Queen Elizabeth Drive, Bondi Beach NSW 2026"
    let streetAddress: String

    /// Category — auto-inferred from tags or explicitly set.
    let category: Category

    /// Tags from team data, kept as-is (capitalised keywords like "Beach", "Scenic").
    /// First 2 tags shown as "two highlights" on result cards.
    let tags: [String]

    /// Latitude/longitude from Google Maps official pin coordinates.
    let coordinate: Coordinate

    /// NSW API stop ID (if available). Coordinates work too, but stop IDs are more accurate.
    let nswStopId: String?

    // MARK: - Convenience init (auto-inferred category)

    /// Default initialiser — category is auto-inferred from tags.
    init(
        id: String,
        name: String,
        shortDescription: String,
        streetAddress: String,
        tags: [String],
        coordinate: Coordinate,
        nswStopId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.shortDescription = shortDescription
        self.streetAddress = streetAddress
        self.tags = tags
        self.coordinate = coordinate
        self.nswStopId = nswStopId
        self.category = Category.inferFrom(tags: tags)  // Auto-infer
    }

    /// Explicit category override — used when auto-inference is inaccurate.
    init(
        id: String,
        name: String,
        shortDescription: String,
        streetAddress: String,
        category: Category,
        tags: [String],
        coordinate: Coordinate,
        nswStopId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.shortDescription = shortDescription
        self.streetAddress = streetAddress
        self.category = category
        self.tags = tags
        self.coordinate = coordinate
        self.nswStopId = nswStopId
    }

    // MARK: - FareTable lookup

    /// Convenience property — looks up this destination's fare from FareTable.
    /// Computed property, so it's excluded from Codable automatically.
    var fare: Fare {
        FareTable.fare(for: id)
    }
}
