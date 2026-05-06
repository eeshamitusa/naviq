//
//  NSWAPIClient.swift
//  NAVIQ
//
//  Calls the NSW Trip Planner /trip endpoint and converts responses to RouteResult.
//  Handles one (origin, destination) pair at a time.
//  Parallel calls across 30 destinations are managed by TransportService.
//

import Foundation

// MARK: - Errors

enum NSWAPIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed(underlying: Error)
    case noJourneysFound

    var errorDescription: String? {
        switch self {
        case .invalidURL:                return "Invalid URL constructed."
        case .invalidResponse:           return "Unrecognised server response."
        case .httpError(let code):       return "HTTP error: \(code)"
        case .decodingFailed(let error): return "Failed to decode response: \(error.localizedDescription)"
        case .noJourneysFound:           return "No journeys found for this route."
        }
    }
}

// MARK: - Client

final class NSWAPIClient {

    private let session: URLSession
    private let apiKey: String
    private let baseURL: String

    init(
        apiKey: String = APIConfig.nswAPIKey,
        baseURL: String = APIConfig.nswBaseURL,
        session: URLSession = .shared
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.session = session
    }

    /// Fetch a trip for one (origin, destination) pair.
    /// - Returns: RouteResult (cost comes from FareTable since the API no longer provides fares)
    func fetchTrip(
        from origin: Coordinate,
        to destination: Destination,
        departureDate: Date
    ) async throws -> RouteResult {

        let url = try makeTripURL(
            origin: origin,
            destinationCoord: destination.coordinate,
            destinationStopId: destination.nswStopId,
            departureDate: departureDate
        )

        var request = URLRequest(url: url)
        request.setValue("apikey \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw NSWAPIError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw NSWAPIError.httpError(statusCode: http.statusCode)
        }

        let dto: NSWTripResponseDTO
        do {
            dto = try JSONDecoder().decode(NSWTripResponseDTO.self, from: data)
        } catch {
            throw NSWAPIError.decodingFailed(underlying: error)
        }

        guard let journey = dto.journeys?.first else {
            throw NSWAPIError.noJourneysFound
        }

        return convertToRouteResult(journey: journey, destination: destination)
    }

    // MARK: - URL Construction

    private func makeTripURL(
        origin: Coordinate,
        destinationCoord: Coordinate,
        destinationStopId: String?,
        departureDate: Date
    ) throws -> URL {

        var components = URLComponents(string: "\(baseURL)/trip")
        guard components != nil else { throw NSWAPIError.invalidURL }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HHmm"

        let destType = "coord"
        let destName = destinationCoord.nswAPIString

        components?.queryItems = [
            URLQueryItem(name: "outputFormat", value: "rapidJSON"),
            URLQueryItem(name: "coordOutputFormat", value: "EPSG:4326"),
            URLQueryItem(name: "depArrMacro", value: "dep"),
            URLQueryItem(name: "itdDate", value: dateFormatter.string(from: departureDate)),
            URLQueryItem(name: "itdTime", value: timeFormatter.string(from: departureDate)),
            URLQueryItem(name: "type_origin", value: "coord"),
            URLQueryItem(name: "name_origin", value: origin.nswAPIString),
            URLQueryItem(name: "type_destination", value: destType),
            URLQueryItem(name: "name_destination", value: destName),
            URLQueryItem(name: "calcNumberOfTrips", value: "3"),
            URLQueryItem(name: "TfNSWTR", value: "true"),
            URLQueryItem(name: "version", value: "10.2.1.42")
        ]

        guard let url = components?.url else {
            throw NSWAPIError.invalidURL
        }

        return url
    }

    // MARK: - DTO to Domain Conversion

    private func convertToRouteResult(
        journey: NSWJourneyDTO,
        destination: Destination
    ) -> RouteResult {

        let steps: [RouteStep] = journey.legs.enumerated().map { (idx, leg) in
            convertToStep(leg: leg, order: idx + 1)
        }

        let totalSeconds = journey.legs.reduce(0) { $0 + ($1.duration ?? 0) }
        let totalMinutes = Int(ceil(Double(totalSeconds) / 60.0))

        // Primary mode = longest non-walking leg
        let primary: TransportMode = {
            let nonWalking = journey.legs.filter { leg in
                let cls = leg.transportation?.product?.`class` ?? 99
                return cls != 99 && cls != 100
            }
            if let longest = nonWalking.max(by: { ($0.duration ?? 0) < ($1.duration ?? 0) }),
               let cls = longest.transportation?.product?.`class` {
                return TransportMode.fromAPIProductClass(cls)
            }
            return .walking
        }()

        return RouteResult(
            destination: destination,
            travelTimeMinutes: totalMinutes,
            // Cost from FareTable — Opal Fare API was deprecated Oct 2023
            costAUD: FareTable.adultFare(for: destination.id),
            primaryTransportMode: primary,
            steps: steps,
            isLiveData: true
        )
    }

    private func convertToStep(leg: NSWLegDTO, order: Int) -> RouteStep {
        let classCode = leg.transportation?.product?.`class` ?? 99
        let mode = TransportMode.fromAPIProductClass(classCode)

        let lineName: String? = {
            if mode == .walking { return nil }
            return leg.transportation?.disassembledName ?? leg.transportation?.name
        }()

        let fromName = leg.origin?.name ?? "Unknown"
        let toName   = leg.destination?.name ?? "Unknown"
        let duration = Int(ceil(Double(leg.duration ?? 0) / 60.0))

        let instruction: String = {
            switch mode {
            case .walking:                   return "Walk to \(toName)"
            case .train, .metro, .lightRail: return "Take \(lineName ?? "train") to \(toName)"
            case .bus:                       return "Take \(lineName ?? "bus") to \(toName)"
            case .ferry:                     return "Board \(lineName ?? "ferry") to \(toName)"
            case .driving:                   return "Drive to \(toName)"
            }
        }()

        return RouteStep(
            order: order, mode: mode, lineName: lineName,
            fromName: fromName, toName: toName,
            durationMinutes: duration, instruction: instruction
        )
    }
}
