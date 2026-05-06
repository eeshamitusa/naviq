//
//  RouteResult.swift
//  NAVIQ
//
//  Core model — one result card on Screen 3 = one RouteResult.
//  Also contains all data needed for Screen 4 detail view.
//

import Foundation

struct RouteResult: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    let destination: Destination
    let travelTimeMinutes: Int
    let costAUD: Double
    let primaryTransportMode: TransportMode
    let steps: [RouteStep]
    let isLiveData: Bool        // true = from NSW API, false = from mock

    // MARK: - UI convenience properties

    /// e.g. "45 min", "1h 20m"
    var formattedTravelTime: String {
        let h = travelTimeMinutes / 60
        let m = travelTimeMinutes % 60
        if h == 0 { return "\(m) min" }
        if m == 0 { return "\(h)h" }
        return "\(h)h \(m)m"
    }

    /// e.g. "$3.79"
    var formattedCost: String {
        String(format: "$%.2f", costAUD)
    }
}
