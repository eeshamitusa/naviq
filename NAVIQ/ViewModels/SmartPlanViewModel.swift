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
            if minutes == 0 {
                return "\(hours)h"
            }
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

    var formattedRemainingTime: String {
        let hours = remainingTimeMinutes / 60
        let minutes = remainingTimeMinutes % 60

        if hours > 0 {
            if minutes == 0 {
                return "\(hours)h"
            }
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var formattedRemainingBudget: String {
        String(format: "AUD %.2f", remainingBudgetAUD)
    }

    var feasibilityLabel: String {
        let timeUsage = Double(totalTravelTimeMinutes) / Double(max(availableTimeMinutes, 1))
        let budgetUsage = totalCostAUD / max(budgetAUD, 1)

        if timeUsage <= 0.75 && budgetUsage <= 0.75 {
            return "Yes"
        } else if timeUsage <= 1.0 && budgetUsage <= 1.0 {
            return "Risky"
        } else {
            return "No"
        }
    }

    var feasibilityExplanation: String {
        switch feasibilityLabel {
        case "Yes":
            return "Comfortably fits within your deadline and budget."
        case "Risky":
            return "Possible, but it leaves a smaller buffer before your deadline."
        default:
            return "This plan does not fit your constraints."
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

        let cleanedCurrentLocation = clean(currentLocationName)
        let cleanedFinalDestination = clean(finalDestinationName)
        let cleanedTransport = clean(selectedTransport).lowercased()

        guard !cleanedCurrentLocation.isEmpty else {
            finishWithError("Please enter your current location.")
            return
        }

        guard !cleanedFinalDestination.isEmpty else {
            finishWithError("Please enter your final destination.")
            return
        }

        guard totalBudget > 0 else {
            finishWithError("Please enter a budget greater than 0.")
            return
        }

        guard normalize(cleanedCurrentLocation) != normalize(cleanedFinalDestination) else {
            finishWithError("Your current location and final destination cannot be the same.")
            return
        }

        let availableTimeMinutes = minutesUntilDeadline(mustArriveTime)

        guard availableTimeMinutes > 0 else {
            finishWithError("Please choose an arrival time later than now.")
            return
        }

        let startInput = ExploreInput(
            originName: cleanedCurrentLocation,
            originCoordinate: originCoordinate(for: cleanedCurrentLocation),
            availableTimeMinutes: availableTimeMinutes,
            budgetAUD: totalBudget
        )

        let firstLegRoutes = await transportService.searchRoutes(input: startInput)

        let possibleMidpointRoutes = firstLegRoutes.filter { route in
            let isNotFinalDestination = normalize(route.destination.name) != normalize(cleanedFinalDestination)
            let isNotStartLocation = normalize(route.destination.name) != normalize(cleanedCurrentLocation)
            let fitsInitialTime = route.travelTimeMinutes < availableTimeMinutes
            let fitsInitialBudget = route.costAUD < totalBudget
            let matchesTransport = transportMatches(
                routeTransportName: route.primaryTransportMode.displayName,
                selectedTransportName: cleanedTransport
            )

            return isNotFinalDestination &&
                isNotStartLocation &&
                fitsInitialTime &&
                fitsInitialBudget &&
                matchesTransport
        }

        var generatedPlans: [SmartPlanResult] = []

        for firstLeg in possibleMidpointRoutes {
            let midpoint = firstLeg.destination
            let remainingTime = availableTimeMinutes - firstLeg.travelTimeMinutes
            let remainingBudget = totalBudget - firstLeg.costAUD

            guard remainingTime > 0, remainingBudget > 0 else {
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

                return isFinalDestination &&
                    fitsRemainingTime &&
                    fitsRemainingBudget &&
                    matchesTransport
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
            score(for: firstPlan) > score(for: secondPlan)
        }

        bestPlan = results.first

        if results.isEmpty {
            errorMessage = "No midpoint plans matched your arrival time and budget. Try choosing a later arrival time, increasing your budget, or selecting Any transport."
        }

        isLoading = false
    }

    private func score(for plan: SmartPlanResult) -> Double {
        let tagValue = Double(plan.midpoint.tags.count) * 8.0
        let timeBufferValue = Double(plan.remainingTimeMinutes) * 0.35
        let budgetBufferValue = plan.remainingBudgetAUD * 0.75
        let shorterTripBonus = 120.0 / Double(max(plan.totalTravelTimeMinutes, 1))

        let feasibilityBonus: Double
        if plan.feasibilityLabel == "Yes" {
            feasibilityBonus = 30.0
        } else if plan.feasibilityLabel == "Risky" {
            feasibilityBonus = 10.0
        } else {
            feasibilityBonus = 0.0
        }

        return tagValue + timeBufferValue + budgetBufferValue + shorterTripBonus + feasibilityBonus
    }

    private func minutesUntilDeadline(_ deadline: Date) -> Int {
        let now = Date()
        var adjustedDeadline = deadline

        if adjustedDeadline <= now {
            adjustedDeadline = Calendar.current.date(byAdding: .day, value: 1, to: deadline) ?? deadline
        }

        let difference = adjustedDeadline.timeIntervalSince(now)
        return max(Int(difference / 60), 0)
    }

    private func transportMatches(
        routeTransportName: String,
        selectedTransportName: String
    ) -> Bool {
        let routeTransport = clean(routeTransportName).lowercased()

        if selectedTransportName == "any" {
            return true
        }

        if selectedTransportName == "walk" || selectedTransportName == "walking" {
            return routeTransport == "walk" || routeTransport == "walking"
        }

        return routeTransport.contains(selectedTransportName) ||
            selectedTransportName.contains(routeTransport)
    }

    private func originCoordinate(for locationName: String) -> Coordinate {
        if let destination = MockData.destinations.first(where: {
            normalize($0.name) == normalize(locationName)
        }) {
            return destination.coordinate
        }

        return MockData.mockOrigin
    }

    private func clean(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func normalize(_ text: String) -> String {
        clean(text).lowercased()
    }

    private func finishWithError(_ message: String) {
        errorMessage = message
        results = []
        bestPlan = nil
        isLoading = false
    }
}
