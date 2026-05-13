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
        clearResults()

        let cleanedStartLocation = startLocationName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedSelectedTransport = selectedTransport.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !cleanedStartLocation.isEmpty else {
            errorMessage = "Please enter a start location."
            isLoading = false
            return
        }

        guard userTimeMinutes > 0 else {
            errorMessage = "Please enter a valid available time."
            isLoading = false
            return
        }

        guard budget >= 0 else {
            errorMessage = "Please enter a valid budget."
            isLoading = false
            return
        }

        let input = ExploreInput(
            originName: cleanedStartLocation,
            originCoordinate: originCoordinate(for: cleanedStartLocation),
            availableTimeMinutes: userTimeMinutes,
            budgetAUD: budget
        )

        let allRoutes = await transportService.searchRoutes(input: input)

        let matchingRoutes = allRoutes.filter { route in
            let matchesTime = route.travelTimeMinutes <= userTimeMinutes
            let matchesBudget = route.costAUD <= budget

            let routeTransport = route.primaryTransportMode.displayName
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()

            let matchesTransport: Bool

            if cleanedSelectedTransport == "any" {
                matchesTransport = true
            } else if cleanedSelectedTransport == "walk" {
                matchesTransport = routeTransport == "walk" || routeTransport == "walking"
            } else {
                matchesTransport = routeTransport == cleanedSelectedTransport
            }

            return matchesTime && matchesBudget && matchesTransport
        }

        quickTripRoutes = matchingRoutes
            .filter { route in
                route.travelTimeMinutes <= 30
            }
            .sorted { firstRoute, secondRoute in
                if firstRoute.travelTimeMinutes == secondRoute.travelTimeMinutes {
                    return firstRoute.costAUD < secondRoute.costAUD
                }

                return firstRoute.travelTimeMinutes < secondRoute.travelTimeMinutes
            }

        bestLeisureRoutes = matchingRoutes
            .filter { route in
                route.travelTimeMinutes > 30 &&
                route.travelTimeMinutes <= 60
            }
            .sorted { firstRoute, secondRoute in
                if firstRoute.costAUD == secondRoute.costAUD {
                    return firstRoute.travelTimeMinutes < secondRoute.travelTimeMinutes
                }

                return firstRoute.costAUD < secondRoute.costAUD
            }

        longerTripRoutes = matchingRoutes
            .filter { route in
                route.travelTimeMinutes > 60 &&
                route.travelTimeMinutes <= 90
            }
            .sorted { firstRoute, secondRoute in
                if firstRoute.travelTimeMinutes == secondRoute.travelTimeMinutes {
                    return firstRoute.costAUD < secondRoute.costAUD
                }

                return firstRoute.travelTimeMinutes < secondRoute.travelTimeMinutes
            }

        dayTripRoutes = matchingRoutes
            .filter { route in
                route.travelTimeMinutes > 90
            }
            .sorted { firstRoute, secondRoute in
                if firstRoute.travelTimeMinutes == secondRoute.travelTimeMinutes {
                    return firstRoute.costAUD < secondRoute.costAUD
                }

                return firstRoute.travelTimeMinutes < secondRoute.travelTimeMinutes
            }

        quickTripBestRoute = selectBestPick(from: quickTripRoutes)
        bestLeisureRoutePick = selectBestPick(from: bestLeisureRoutes)
        longerTripBestRoute = selectBestPick(from: longerTripRoutes)
        dayTripBestRoute = selectBestPick(from: dayTripRoutes)

        if matchingRoutes.isEmpty {
            errorMessage = "No destinations matched your time, budget, and transport preferences."
        }

        isLoading = false
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
        routes.max { firstRoute, secondRoute in
            bestPickScore(for: firstRoute) < bestPickScore(for: secondRoute)
        }
    }

    private func bestPickScore(for route: RouteResult) -> Double {
        let destinationQualityScore = Double(route.destination.tags.count) * 8
        let categoryValue = categoryScore(for: route.destination.category)
        let timePenalty = Double(route.travelTimeMinutes) * 0.4
        let costPenalty = route.costAUD * 1.5
        let liveDataBonus = route.isLiveData ? 5.0 : 0.0

        return destinationQualityScore
            + categoryValue
            + liveDataBonus
            - timePenalty
            - costPenalty
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
