import Foundation

struct DestinationGroup: Identifiable {
    let id = UUID()
    let title: String
    let destinations: [Destination]
    let bestPick: Destination?
}