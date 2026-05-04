//
//  Fare.swift
//  NAVIQ
//
//  Fare struct with adult / concession / child tiers.
//

import Foundation

struct Fare: Codable, Hashable {
    let adultAUD: Double
    let concessionAUD: Double  // Students, seniors, disability (~50% discount)
    let childAUD: Double       // Ages 4-15

    /// Auto-calculate concession and child from adult fare (both 50%).
    static func adult(_ amount: Double) -> Fare {
        Fare(adultAUD: amount, concessionAUD: amount * 0.5, childAUD: amount * 0.5)
    }

    /// Specify all three tiers explicitly (e.g. day-trip cap fares).
    static func explicit(adult: Double, concession: Double, child: Double) -> Fare {
        Fare(adultAUD: adult, concessionAUD: concession, childAUD: child)
    }

    static let free = Fare(adultAUD: 0, concessionAUD: 0, childAUD: 0)
}
