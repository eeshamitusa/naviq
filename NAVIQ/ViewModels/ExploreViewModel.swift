import Foundation
import Combine

@MainActor
final class ExploreViewModel: ObservableObject {

    @Published private(set) var locations: [Location] = []

    @Published private(set) var quickTripRoutes: [RouteResult] = []
    @Published private(set) var bestLeisureRoutes: [RouteResult] = []
    @Published private(set) var longerTripRoutes: [RouteResult] = []
    @Published private(set) var dayTripRoutes: [RouteResult] = []

    @Published private(set) var quickTripBestRoute: RouteResult?
    @Published private(set) var bestLeisureRoutePick: RouteResult?
    @Published private(set) var longerTripBestRoute: RouteResult?
    @Published private(set) var dayTripBestRoute: RouteResult?

    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
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
        self.locations = LocationLoader.loadLocations()
    }


    func findReachableDestinations(
        startLocationName: String,
        userTimeMinutes: Int,
        budget: Double,
        selectedTransport: String = "Any"
    ) async {
        isLoading = true
        errorMessage = nil

        let input = ExploreInput(
            originName: startLocationName,
            originCoordinate: originCoordinate(for: startLocationName),
            availableTimeMinutes: userTimeMinutes,
            budgetAUD: budget
        )

        let allRoutes = await transportService.searchRoutes(input: input)

        let matchingRoutes = selectedTransport == "Any" ? allRoutes : allRoutes.filter { route in
            route.primaryTransportMode.displayName.lowercased() == selectedTransport.lowercased()
        }
        
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

        if matchingRoutes.isEmpty {
            errorMessage = "No destinations matched your time and budget."
        }

        isLoading = false
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

    func clearResults() {
        quickTripRoutes = []
        bestLeisureRoutes = []
        longerTripRoutes = []
        dayTripRoutes = []

        quickTripBestRoute = nil
        bestLeisureRoutePick = nil
        longerTripBestRoute = nil
        dayTripBestRoute = nil

        errorMessage = nil
        isLoading = false
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
