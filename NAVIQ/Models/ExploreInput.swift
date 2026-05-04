//
//  ExploreInput.swift
//  NAVIQ
//
//  User input from Screen 2 (Explore Input).
//

import Foundation

struct ExploreInput: Hashable {
    let originName: String
    let originCoordinate: Coordinate
    let availableTimeMinutes: Int
    let budgetAUD: Double
    let departureDate: Date

    init(
        originName: String,
        originCoordinate: Coordinate,
        availableTimeMinutes: Int,
        budgetAUD: Double,
        departureDate: Date = Date()
    ) {
        self.originName = originName
        self.originCoordinate = originCoordinate
        self.availableTimeMinutes = availableTimeMinutes
        self.budgetAUD = budgetAUD
        self.departureDate = departureDate
    }
}
