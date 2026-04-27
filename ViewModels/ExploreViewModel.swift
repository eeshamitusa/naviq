import Foundation

final class ExploreViewModel {

    private(set) var locations: [Location] = []

    private(set) var quickTrips: [Destination] = []
    private(set) var bestLeisure: [Destination] = []
    private(set) var longerTrips: [Destination] = []

    private(set) var quickTripBestPick: Destination?
    private(set) var bestLeisurePick: Destination?
    private(set) var longerTripBestPick: Destination?

    init() {
        locations = LocationLoader.loadLocations()
    }

    func findReachableDestinations(
        startLocationName: String,
        userTimeMinutes: Int,
        budget: Double
    ) {
        let allTrips = MockTripData.trips

        let matchingTrips = allTrips.filter { trip in
            trip.startName == startLocationName &&
            trip.travelTimeMinutes <= userTimeMinutes &&
            trip.cost <= budget
        }

        quickTrips = matchingTrips.filter { trip in
            trip.travelTimeMinutes <= 30
        }

        bestLeisure = matchingTrips.filter { trip in
            trip.travelTimeMinutes > 30 &&
            trip.travelTimeMinutes <= 60 &&
            trip.leisureScore >= 7
        }

        longerTrips = matchingTrips.filter { trip in
            trip.travelTimeMinutes > 60
        }

        quickTripBestPick = selectBestPick(from: quickTrips)
        bestLeisurePick = selectBestPick(from: bestLeisure)
        longerTripBestPick = selectBestPick(from: longerTrips)
    }

    func groupedResults() -> [DestinationGroup] {
        [
            DestinationGroup(
                title: "Quick Trips",
                destinations: quickTrips,
                bestPick: quickTripBestPick
            ),
            DestinationGroup(
                title: "Best Leisure",
                destinations: bestLeisure,
                bestPick: bestLeisurePick
            ),
            DestinationGroup(
                title: "Longer Trips",
                destinations: longerTrips,
                bestPick: longerTripBestPick
            )
        ].filter { group in
            !group.destinations.isEmpty
        }
    }

    private func selectBestPick(from destinations: [Destination]) -> Destination? {
        destinations.max { first, second in
            score(for: first) < score(for: second)
        }
    }

    private func score(for destination: Destination) -> Double {
        let leisureValue = Double(destination.leisureScore) * 10
        let timePenalty = Double(destination.travelTimeMinutes) * 0.4
        let costPenalty = destination.cost * 1.5

        return leisureValue - timePenalty - costPenalty
    }
}