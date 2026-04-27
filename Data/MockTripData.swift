import Foundation

enum MockTripData {

    static let trips: [Destination] = [
        Destination(
            startName: "Darling Harbour",
            name: "Circular Quay",
            address: "31 Alfred Street, Circular Quay NSW 2000",
            travelTimeMinutes: 18,
            cost: 3.20,
            transport: "Light Rail + Walk",
            tags: ["Closest", "Harbour View", "Quick"],
            highlights: [
                "Fast harbour destination",
                "Good for a short walk or ferry view"
            ],
            routeSteps: [
                "Walk to the nearest light rail stop",
                "Take light rail toward Circular Quay",
                "Walk to Alfred Street"
            ],
            leisureScore: 8
        ),
        Destination(
            startName: "Darling Harbour",
            name: "Newtown",
            address: "King Street, Newtown NSW 2042",
            travelTimeMinutes: 27,
            cost: 3.80,
            transport: "Light Rail + Train + Walk",
            tags: ["Food Spot", "Quick Escape", "Artsy"],
            highlights: [
                "Good food and cafes",
                "Still fits into a short trip"
            ],
            routeSteps: [
                "Travel to Central",
                "Take train toward Newtown",
                "Walk to King Street"
            ],
            leisureScore: 8
        ),
        Destination(
            startName: "Darling Harbour",
            name: "Bondi Beach",
            address: "Bondi Pavilion, Queen Elizabeth Drive, Bondi Beach NSW 2026",
            travelTimeMinutes: 43,
            cost: 4.65,
            transport: "Train + Bus + Walk",
            tags: ["Popular", "Scenic", "Within Budget"],
            highlights: [
                "High leisure value",
                "Beach destination within the time limit"
            ],
            routeSteps: [
                "Walk to light rail stop",
                "Travel to Central",
                "Take train and bus toward Bondi Beach",
                "Walk to Bondi Pavilion"
            ],
            leisureScore: 10
        ),
        Destination(
            startName: "Darling Harbour",
            name: "Manly",
            address: "Manly Wharf Forecourt, East Esplanade, Manly NSW 2095",
            travelTimeMinutes: 46,
            cost: 11.20,
            transport: "Train + Ferry + Walk",
            tags: ["Scenic", "Premium Route", "Beach"],
            highlights: [
                "Ferry makes the trip more scenic",
                "Beach and cafe destination"
            ],
            routeSteps: [
                "Travel to Circular Quay",
                "Take ferry to Manly Wharf",
                "Walk to the Manly foreshore"
            ],
            leisureScore: 10
        ),
        Destination(
            startName: "Darling Harbour",
            name: "Parramatta",
            address: "Corner Pitt Street and Macquarie Street, Parramatta NSW 2150",
            travelTimeMinutes: 52,
            cost: 6.80,
            transport: "Train + Walk",
            tags: ["Long Ride", "City Hub", "Riverside"],
            highlights: [
                "Large food and shopping area",
                "Still reachable within 1 hour"
            ],
            routeSteps: [
                "Travel to Central",
                "Take train toward Parramatta",
                "Walk to Macquarie Street"
            ],
            leisureScore: 7
        ),
        Destination(
            startName: "Darling Harbour",
            name: "Sydney Olympic Park",
            address: "5 Olympic Boulevard, Sydney Olympic Park NSW 2127",
            travelTimeMinutes: 63,
            cost: 7.40,
            transport: "Train + Walk",
            tags: ["Events", "Sport", "Outdoors"],
            highlights: [
                "Good for events or outdoor space",
                "Useful longer reachable destination"
            ],
            routeSteps: [
                "Travel to Central",
                "Take train toward Olympic Park",
                "Walk to Olympic Boulevard"
            ],
            leisureScore: 7
        )
    ]
}