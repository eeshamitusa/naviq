import Foundation

final class ExploreViewModel {

    private(set) var locations: [Location] = []

    private(set) var quickTripRoutes: [RouteResult] = []
    private(set) var bestLeisureRoutes: [RouteResult] = []
    private(set) var longerTripRoutes: [RouteResult] = []
    private(set) var dayTripRoutes: [RouteResult] = []

    private(set) var quickTripBestRoute: RouteResult?
    private(set) var bestLeisureRoutePick: RouteResult?
    private(set) var longerTripBestRoute: RouteResult?
    private(set) var dayTripBestRoute: RouteResult?

    var quickTrips: [Destination] {
        quickTripRoutes.map(\.destination)
    }

    var bestLeisure: [Destination] {
        bestLeisureRoutes.map(\.destination)
    }

    var longerTrips: [Destination] {
        longerTripRoutes.map(\.destination)
    }

    var dayTrips: [Destination] {
        dayTripRoutes.map(\.destination)
    }

    var quickTripBestPick: Destination? {
        quickTripBestRoute?.destination
    }

    var bestLeisurePick: Destination? {
        bestLeisureRoutePick?.destination
    }

    var longerTripBestPick: Destination? {
        longerTripBestRoute?.destination
    }

    var dayTripBestPick: Destination? {
        dayTripBestRoute?.destination
    }

    private let transportService: TransportServiceProtocol

    init(transportService: TransportServiceProtocol = TransportService()) {
        self.transportService = transportService
        locations = LocationLoader.loadLocations()
    }

    func findReachableDestinations(
        startLocationName: String,
        userTimeMinutes: Int,
        budget: Double
    ) async {
        let input = ExploreInput(
            originName: startLocationName,
            originCoordinate: originCoordinate(for: startLocationName),
            availableTimeMinutes: userTimeMinutes,
            budgetAUD: budget
        )

        let matchingRoutes = await transportService.searchRoutes(input: input)

        quickTripRoutes = matchingRoutes.filter { route in
            route.travelTimeMinutes <= 30
        }

        bestLeisureRoutes = matchingRoutes.filter { route in
            route.travelTimeMinutes > 30 &&
            route.travelTimeMinutes <= 60
        }

        longerTripRoutes = matchingRoutes.filter { route in
            route.travelTimeMinutes > 60 &&
            route.travelTimeMinutes <= 90
        }

        dayTripRoutes = matchingRoutes.filter { route in
            route.travelTimeMinutes > 90
        }

        quickTripBestRoute = selectBestPick(from: quickTripRoutes)
        bestLeisureRoutePick = selectBestPick(from: bestLeisureRoutes)
        longerTripBestRoute = selectBestPick(from: longerTripRoutes)
        dayTripBestRoute = selectBestPick(from: dayTripRoutes)
    }

    func groupedResults() -> [DestinationGroup] {
        [
            DestinationGroup(
                title: "Quick Trips",
                routes: quickTripRoutes,
                bestRoutePick: quickTripBestRoute
            ),
            DestinationGroup(
                title: "Best Leisure",
                routes: bestLeisureRoutes,
                bestRoutePick: bestLeisureRoutePick
            ),
            DestinationGroup(
                title: "Longer Trips",
                routes: longerTripRoutes,
                bestRoutePick: longerTripBestRoute
            ),
            DestinationGroup(
                title: "Day Trips",
                routes: dayTripRoutes,
                bestRoutePick: dayTripBestRoute
            )
        ].filter { group in
            !group.routes.isEmpty
        }
    }

    private func selectBestPick(from routes: [RouteResult]) -> RouteResult? {
        routes.max { first, second in
            score(for: first) < score(for: second)
        }
    }

    private func score(for route: RouteResult) -> Double {
        let tagValue = Double(route.destination.tags.count) * 8
        let categoryValue = categoryScore(for: route.destination.category)
        let timePenalty = Double(route.travelTimeMinutes) * 0.4
        let costPenalty = route.costAUD * 1.5

        return tagValue + categoryValue - timePenalty - costPenalty
    }

    private func categoryScore(for category: Category) -> Double {
        switch category {
        case .beach, .harbour, .waterfront, .park, .nature:
            return 20
        case .culture, .food, .landmark:
            return 16
        case .shopping, .transportHub:
            return 10
        }
    }

    private func originCoordinate(for locationName: String) -> Coordinate {
        if let destination = MockData.destinations.first(where: { $0.name == locationName }) {
            return destination.coordinate
        }

        return MockData.mockOrigin
    }
}
