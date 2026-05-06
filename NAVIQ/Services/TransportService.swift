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

    /// Call the NSW API for all 30 destinations in parallel using TaskGroup.
    /// Serial calls would take ~15 seconds (30 x 0.5s). Parallel takes ~1 second.
    private func fetchAllRoutesFromAPI(input: ExploreInput) async -> [RouteResult] {

        return await withTaskGroup(of: RouteResult?.self) { group in

            for destination in MockData.destinations {
                group.addTask { [apiClient] in
                    do {
                        return try await apiClient.fetchTrip(
                            from: input.originCoordinate,
                            to: destination,
                            departureDate: input.departureDate
                        )
                    } catch {
                        print("Warning: \(destination.name) API failed, using mock fallback: \(error.localizedDescription)")
                        return MockData.allRoutes.first { $0.destination.id == destination.id }
                    }
                }
            }

            var results: [RouteResult] = []
            for await result in group {
                if let route = result { results.append(route) }
            }
            return results
        }
    }
}
