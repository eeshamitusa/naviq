import Foundation

struct Destination: Identifiable, Hashable {
    let id = UUID()

    let startName: String
    let name: String
    let address: String

    let travelTimeMinutes: Int
    let cost: Double
    let transport: String
    let tags: [String]

    let highlights: [String]
    let routeSteps: [String]

    let leisureScore: Int

    var formattedTime: String {
        if travelTimeMinutes < 60 {
            return "\(travelTimeMinutes) min"
        }

        let hours = travelTimeMinutes / 60
        let minutes = travelTimeMinutes % 60

        if minutes == 0 {
            return "\(hours) hr"
        } else {
            return "\(hours) hr \(minutes) min"
        }
    }

    var formattedCost: String {
        String(format: "AUD %.2f", cost)
    }
}