import Foundation
import Combine

struct SmartPlanResult: Identifiable {
    let id = UUID()

    let midpoint: Destination
    let firstLegRoute: RouteResult
    let secondLegRoute: RouteResult
    let totalTravelTimeMinutes: Int
    let totalCostAUD: Double
    let availableTimeMinutes: Int
    let budgetAUD: Double

    var formattedTotalTime: String {
        let hours = totalTravelTimeMinutes / 60
        let minutes = totalTravelTimeMinutes % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var formattedTotalCost: String {
        String(format: "AUD %.2f", totalCostAUD)
    }

    var remainingTimeMinutes: Int {
        max(availableTimeMinutes - totalTravelTimeMinutes, 0)
    }

    var remainingBudgetAUD: Double {
        max(budgetAUD - totalCostAUD, 0)
    }

    var feasibilityLabel: String {
        if totalTravelTimeMinutes <= Int(Double(availableTimeMinutes) * 0.8) &&
            totalCostAUD <= budgetAUD * 0.8 {
            return "Yes"
        } else {
            return "Risky"
        }
    }

    var feasibilityExplanation: String {
        if feasibilityLabel == "Yes" {
            return "Comfortably fits within your time and budget."
        } else {
            return "Possible, but leaves less buffer before your deadline."
        }
    }
}

@MainActor
final class SmartPlanViewModel: ObservableObject {

    @Published private(set) var results: [SmartPlanResult] = []
    @Published private(set) var bestPlan: SmartPlanResult?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    private let transportService: TransportServiceProtocol

    init(transportService: TransportServiceProtocol = TransportService()) {
        self.transportService = transportService
    }

    func findSmartPlans(
        currentLocationName: String,
        finalDestinationName: String,
        totalBudget: Double,
        mustArriveTime: Date,
        selectedTransport: String = "Any"
    ) async {
        isLoading = true
        errorMessage = nil
        results = []
        bestPlan = nil

        let cleanedCurrentLocation = currentLocationName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedFinalDestination = finalDestinationName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedTransport = selectedTransport.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !cleanedCurrentLocation.isEmpty else {
            errorMessage = "Please enter your current location."
            isLoading = false
            return
        }

        guard !cleanedFinalDestination.isEmpty else {
            errorMessage = "Please enter a final destination."
            isLoading = false
            return
        }

        guard totalBudget >= 0 else {
            errorMessage = "Please enter a valid budget."
            isLoading = false
            return
        }

        let availableTimeMinutes = minutesUntilDeadline(mustArriveTime)

        guard availableTimeMinutes > 0 else {
            errorMessage = "Your must-arrive time needs to be later than the current time."
            isLoading = false
            return
        }

        let startInput = ExploreInput(
            originName: cleanedCurrentLocation,
            originCoordinate: originCoordinate(for: cleanedCurrentLocation),
            availableTimeMinutes: availableTimeMinutes,
            budgetAUD: totalBudget
        )

        let firstLegRoutes = await transportService.searchRoutes(input: startInput)

        let possibleFirstLegs = firstLegRoutes.filter { route in
            let isNotFinalDestination = normalize(route.destination.name) != normalize(cleanedFinalDestination)
            let fitsTime = route.travelTimeMinutes < availableTimeMinutes
            let fitsBudget = route.costAUD <= totalBudget
            let matchesTransport = transportMatches(
                routeTransportName: route.primaryTransportMode.displayName,
                selectedTransportName: cleanedTransport
            )

            return isNotFinalDestination && fitsTime && fitsBudget && matchesTransport
        }

        var generatedPlans: [SmartPlanResult] = []

        for firstLeg in possibleFirstLegs {
            let midpoint = firstLeg.destination
            let remainingTime = availableTimeMinutes - firstLeg.travelTimeMinutes
            let remainingBudget = totalBudget - firstLeg.costAUD

            guard remainingTime > 0, remainingBudget >= 0 else {
                continue
            }

            let midpointInput = ExploreInput(
                originName: midpoint.name,
                originCoordinate: midpoint.coordinate,
                availableTimeMinutes: remainingTime,
                budgetAUD: remainingBudget
            )

            let secondLegRoutes = await transportService.searchRoutes(input: midpointInput)

            guard let secondLeg = secondLegRoutes.first(where: { route in
                let isFinalDestination = normalize(route.destination.name) == normalize(cleanedFinalDestination)
                let fitsRemainingTime = route.travelTimeMinutes <= remainingTime
                let fitsRemainingBudget = route.costAUD <= remainingBudget
                let matchesTransport = transportMatches(
                    routeTransportName: route.primaryTransportMode.displayName,
                    selectedTransportName: cleanedTransport
                )

                return isFinalDestination && fitsRemainingTime && fitsRemainingBudget && matchesTransport
            }) else {
                continue
            }

            let totalTime = firstLeg.travelTimeMinutes + secondLeg.travelTimeMinutes
            let totalCost = firstLeg.costAUD + secondLeg.costAUD

            guard totalTime <= availableTimeMinutes, totalCost <= totalBudget else {
                continue
            }

            let plan = SmartPlanResult(
                midpoint: midpoint,
                firstLegRoute: firstLeg,
                secondLegRoute: secondLeg,
                totalTravelTimeMinutes: totalTime,
                totalCostAUD: totalCost,
                availableTimeMinutes: availableTimeMinutes,
                budgetAUD: totalBudget
            )

            generatedPlans.append(plan)
        }

        results = generatedPlans.sorted { firstPlan, secondPlan in
            let firstScore = score(for: firstPlan)
            let secondScore = score(for: secondPlan)

            return firstScore > secondScore
        }

        bestPlan = results.first

        if results.isEmpty {
            errorMessage = "No midpoint plans matched your deadline and budget."
        }

        isLoading = false
    }

    private func score(for plan: SmartPlanResult) -> Double {
        let destinationValue = Double(plan.midpoint.tags.count) * 8.0
        let timeBufferValue = Double(plan.remainingTimeMinutes) * 0.25
        let budgetBufferValue = plan.remainingBudgetAUD * 0.5
        let shorterTripBonus = 100.0 / Double(max(plan.totalTravelTimeMinutes, 1))

        return destinationValue + timeBufferValue + budgetBufferValue + shorterTripBonus
    }

    private func minutesUntilDeadline(_ deadline: Date) -> Int {
        let difference = deadline.timeIntervalSince(Date())
        return max(Int(difference / 60), 0)
    }

    private func transportMatches(
        routeTransportName: String,
        selectedTransportName: String
    ) -> Bool {
        let routeTransport = routeTransportName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if selectedTransportName == "any" {
            return true
        }

        if selectedTransportName == "walk" {
            return routeTransport == "walk" || routeTransport == "walking"
        }

        return routeTransport == selectedTransportName
    }

    private func normalize(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private func originCoordinate(for locationName: String) -> Coordinate {
        if let destination = MockData.destinations.first(where: {
            normalize($0.name) == normalize(locationName)
        }) {
            return destination.coordinate
        }

        return MockData.mockOrigin
    }
}
