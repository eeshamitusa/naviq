//
//  RouteStep.swift
//  NAVIQ
//
//  A single leg of a route. Used in Screen 4 step-by-step and Screen 5 next-step.
//

import Foundation

struct RouteStep: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    let order: Int              // Step number (1, 2, 3...)
    let mode: TransportMode     // Transport type for this leg
    let lineName: String?       // e.g. "T1 North Shore Line", nil for walking
    let fromName: String        // e.g. "Central Station"
    let toName: String          // e.g. "Bondi Junction"
    let durationMinutes: Int    // Duration of this leg in minutes
    let instruction: String     // e.g. "Take T1 train to Bondi Junction"
}
