import Foundation

struct DestinationGroup: Identifiable {
    let id = UUID()
    let title: String
    let routes: [RouteResult]
    let bestRoutePick: RouteResult?

    var destinations: [Destination] {
        routes.map(\.destination)
    }

    var bestPick: Destination? {
        bestRoutePick?.destination
    }
}
