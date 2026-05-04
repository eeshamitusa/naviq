//
//  NSWTripDTO.swift
//  NAVIQ
//
//  Data Transfer Objects for decoding NSW Trip Planner API responses.
//  Only the fields we actually use are included — the real API response is much larger.
//

import Foundation

/// Top-level API response.
struct NSWTripResponseDTO: Decodable {
    let journeys: [NSWJourneyDTO]?
}

/// A single journey option (one route from origin to destination).
/// The API typically returns 3-6 journey options.
struct NSWJourneyDTO: Decodable {
    let interchanges: Int?
    let legs: [NSWLegDTO]
}

/// A single leg of a journey. Each transfer adds one more leg.
/// Walking segments are also separate legs.
struct NSWLegDTO: Decodable {
    let duration: Int?              // Seconds — convert to minutes when using
    let origin: NSWLocationDTO?
    let destination: NSWLocationDTO?
    let transportation: NSWTransportationDTO?
}

/// Origin/destination info within a leg.
struct NSWLocationDTO: Decodable {
    let id: String?
    let name: String?
    let disassembledName: String?
    let type: String?
}

/// Transport info for a leg.
struct NSWTransportationDTO: Decodable {
    let name: String?               // e.g. "T1 North Shore Line"
    let disassembledName: String?   // e.g. "T1"
    let product: NSWProductDTO?
}

/// Product class identifies the transport type.
struct NSWProductDTO: Decodable {
    let `class`: Int?               // See TransportMode.fromAPIProductClass()
    let name: String?               // e.g. "Suburban Trains"
}
