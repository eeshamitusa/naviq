# NAVIQ — Data Layer & Transport Service

Seungmin's deliverable for **Task 1 (Data + Models)** and **API Integration**.
Based on the team's 30 Sydney destinations from `Locations.docx`.

---
---

## GitHub Repository

The source code for this project is available at:

https://github.com/EeshaMITUSA/NAVIQ

---

## Folder Structure

| Folder | File | Role |
|---|---|---|
| `Models/` | `RouteResult.swift` | **Core model** — 1 result card = 1 RouteResult |
| `Models/` | `Destination.swift` | 30 destinations (name/address/tags/coordinate) |
| `Models/` | `Fare.swift` | Fare struct (adult/concession/child tiers) |
| `Models/` | `RouteStep.swift` | One leg of a route |
| `Models/` | `TransportMode.swift` | train/metro/bus/ferry/lightRail/walking enum |
| `Models/` | `Category.swift` | Category enum + auto-inference from tags |
| `Models/` | `Coordinate.swift` | Lat/lng wrapper |
| `Models/` | `ExploreInput.swift` | User input struct |
| `Mock/` | `MockData+Destinations.swift` | 30 Sydney destinations |
| `Mock/` | `MockData+Routes.swift` | 30 mock routes (from UTS) |
| `Mock/` | `FareTable.swift` | **Single source of truth** for all fares |
| `Services/` | `TransportService.swift` | **Main entry point** — call this one function |
| `Services/` | `NSWAPIClient.swift` | NSW API caller |
| `Services/` | `NSWTripDTO.swift` | API response decoding |
| `Config/` | `APIConfig.swift` | API key (must be in .gitignore!) |
| `Tests/` | `DataLayerTests.swift` | Unit tests for data integrity + filtering |
| `Preview/` | `DataLayerPreviewView.swift` | Debug preview UI |

---

## ViewModel Usage 

```swift
@MainActor
final class ExploreViewModel: ObservableObject {
    @Published var quickTrips: [RouteResult] = []
    @Published var bestLeisure: [RouteResult] = []
    @Published var longerTrips: [RouteResult] = []

    private let service: TransportServiceProtocol = TransportService()

    func search(originName: String,
                originCoord: Coordinate,
                availableMinutes: Int,
                budget: Double) async {

        let input = ExploreInput(
            originName: originName,
            originCoordinate: originCoord,
            availableTimeMinutes: availableMinutes,
            budgetAUD: budget
        )

        let routes = await service.searchRoutes(input: input)

        quickTrips  = routes.filter { $0.travelTimeMinutes <= 30 }
        bestLeisure = routes.filter { $0.travelTimeMinutes > 30 && $0.travelTimeMinutes <= 60 }
        longerTrips = routes.filter { $0.travelTimeMinutes > 60 }
    }
}
```

---

## UI Usage

```swift
// Result card (Screen 3)
Text(result.destination.name)                     // "Bondi Beach"
Text(result.formattedTravelTime)                  // "38 min"
Text(result.formattedCost)                        // "$3.79"
Image(systemName: result.primaryTransportMode.iconName)

// Tag highlights
ForEach(result.destination.tags.prefix(2), id: \.self) { tag in
    Text(tag)
}
```

## Detail / Map Usage

```swift
// Screen 4 detail
Text(result.destination.shortDescription)
Text(result.destination.streetAddress)

ForEach(result.steps) { step in
    HStack {
        Image(systemName: step.mode.iconName)
        Text(step.instruction)
        Text("\(step.durationMinutes) min")
    }
}

// Screen 5 map
Map(coordinateRegion: ..., annotationItems: [result.destination]) { dest in
    MapMarker(coordinate: dest.coordinate.clLocation)
}

