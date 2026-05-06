//
//  TransportService.swift
//  NAVIQ
//
//  Main entry point for the whole team.
//
//  Eesha's ViewModel only calls service.searchRoutes(input:).
//  Internally:
//    - useMockOnly == true  -> return mock data immediately
//    - API mode             -> call 30 destinations in parallel
//    - Partial failure      -> failed destinations fall back to mock
//    - Total failure        -> entire result falls back to mock
//

import Foundation

protocol TransportServiceProtocol {
    func searchRoutes(input: ExploreInput) async -> [RouteResult]
}

final class TransportService: TransportServiceProtocol {

    private let apiClient: NSWAPIClient
    private let useMockOnly: Bool

    init(
        apiClient: NSWAPIClient = NSWAPIClient(),
        useMockOnly: Bool? = nil
    ) {
        self.apiClient = apiClient
        // Auto-detect: if no API key is set, use mock-only mode
        self.useMockOnly = useMockOnly ?? !APIConfig.hasValidAPIKey
    }

    /// Search for routes. Never throws — always returns results (mock fallback guaranteed).
    func searchRoutes(input: ExploreInput) async -> [RouteResult] {

        if useMockOnly {
            return MockData.routes(filteredBy: input)
        }

        let liveRoutes = await fetchAllRoutesFromAPI(input: input)

        let filtered = liveRoutes.filter {
            $0.travelTimeMinutes <= input.availableTimeMinutes
            && $0.costAUD <= input.budgetAUD
        }

        if filtered.isEmpty {
            print("Warning: API returned no results. Falling back to mock data.")
            return MockData.routes(filteredBy: input)
        }

        return filtered
    }

    /// Call the NSW API for all destinations one at a time.
    /// This avoids HTTP 429 rate-limit errors from sending too many requests at once.
    private func fetchAllRoutesFromAPI(input: ExploreInput) async -> [RouteResult] {

        var results: [RouteResult] = []

        for destination in MockData.destinations {
            do {
                let route = try await apiClient.fetchTrip(
                    from: input.originCoordinate,
                    to: destination,
                    departureDate: input.departureDate
                )

                results.append(route)

                // Small delay to avoid hitting the NSW API rate limit.
                try? await Task.sleep(nanoseconds: 500_000_000)

            } catch {
                print("Warning: \(destination.name) API failed, using mock fallback: \(error.localizedDescription)")

                if let fallback = MockData.allRoutes.first(where: { $0.destination.id == destination.id }) {
                    results.append(fallback)
                }

                // If rate limited, wait longer before trying the next destination.
                if error.localizedDescription.contains("429") {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                }
            }
        }

        return results
    }
}
