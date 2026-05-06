//
//  MockData+Destinations.swift
//  NAVIQ
//
//  30 Sydney destinations from the team's Locations.docx.
//
//  Field mapping:
//    Team "name"     -> Destination.name + id (kebab-case)
//    Team "location" -> Destination.streetAddress
//    Team "tags"     -> Destination.tags (preserved as-is)
//    Added fields:
//      shortDescription -> Written for all 30 (one-liner, consistent length)
//      coordinate       -> Google Maps official pin coordinates
//      category         -> Auto-inferred from tags (3 explicit overrides)
//

import Foundation

enum MockData {

    static let destinations: [Destination] = [

        // 1. Circular Quay
        Destination(
            id: "circular-quay",
            name: "Circular Quay",
            shortDescription: "Sydney's transport heart where ferries, trains and walks all meet.",
            streetAddress: "31 Alfred Street, Circular Quay NSW 2000",
            tags: ["Harbour", "Ferries", "Landmarks"],
            coordinate: Coordinate(latitude: -33.8615, longitude: 151.2108),
            nswStopId: "200060"
        ),

        // 2. Bondi Beach
        Destination(
            id: "bondi-beach",
            name: "Bondi Beach",
            shortDescription: "Australia's most famous surf beach with a buzzing cafe strip.",
            streetAddress: "Bondi Pavilion, Queen Elizabeth Drive, Bondi Beach NSW 2026",
            tags: ["Beach", "Scenic", "Surf"],
            coordinate: Coordinate(latitude: -33.8908, longitude: 151.2743)
        ),

        // 3. Manly
        Destination(
            id: "manly",
            name: "Manly",
            shortDescription: "Beachside suburb reached by a scenic 30-minute ferry from Circular Quay.",
            streetAddress: "Manly Wharf Forecourt, East Esplanade, Manly NSW 2095",
            tags: ["Beach", "Ferry", "Cafes"],
            coordinate: Coordinate(latitude: -33.7969, longitude: 151.2876)
        ),

        // 4. Newtown
        Destination(
            id: "newtown",
            name: "Newtown",
            shortDescription: "Eclectic inner-west strip with vegan eats, indie bars and street art.",
            streetAddress: "King Street, Newtown NSW 2042",
            tags: ["Food", "Nightlife", "Artsy"],
            coordinate: Coordinate(latitude: -33.8965, longitude: 151.1786)
        ),

        // 5. Chatswood
        Destination(
            id: "chatswood",
            name: "Chatswood",
            shortDescription: "North Shore retail hub with two shopping malls and Asian dining.",
            streetAddress: "Victoria Avenue, Chatswood NSW 2067",
            tags: ["Shopping", "Dining", "Convenient"],
            coordinate: Coordinate(latitude: -33.7969, longitude: 151.1830)
        ),

        // 6. Parramatta
        Destination(
            id: "parramatta",
            name: "Parramatta",
            shortDescription: "Sydney's second CBD with riverside dining and historic landmarks.",
            streetAddress: "Corner Pitt Street and Macquarie Street, Parramatta NSW 2150",
            tags: ["Food", "History", "Riverside"],
            coordinate: Coordinate(latitude: -33.8150, longitude: 151.0010)
        ),

        // 7. Darling Harbour
        Destination(
            id: "darling-harbour",
            name: "Darling Harbour",
            shortDescription: "Waterfront precinct packed with restaurants and family attractions.",
            streetAddress: "14 Darling Drive, Darling Harbour NSW 2000",
            tags: ["Waterfront", "Dining", "Family"],
            coordinate: Coordinate(latitude: -33.8740, longitude: 151.1989)
        ),

        // 8. Barangaroo
        Destination(
            id: "barangaroo",
            name: "Barangaroo",
            shortDescription: "Modern harbourfront district with award-winning bars and headland walks.",
            streetAddress: "Hickson Road, Barangaroo NSW 2000",
            tags: ["Waterfront", "Dining", "Walks"],
            coordinate: Coordinate(latitude: -33.8617, longitude: 151.2010)
        ),

        // 9. The Rocks
        Destination(
            id: "the-rocks",
            name: "The Rocks",
            shortDescription: "Sydney's oldest neighbourhood with weekend markets and historic pubs.",
            streetAddress: "66 Harrington Street, The Rocks NSW 2000",
            tags: ["Historic", "Markets", "Walking"],
            coordinate: Coordinate(latitude: -33.8599, longitude: 151.2090)
        ),

        // 10. Cronulla
        Destination(
            id: "cronulla",
            name: "Cronulla",
            shortDescription: "The only Sydney beach reachable by train, with a long sandy stretch.",
            streetAddress: "20-38 Gerrale Street, Cronulla NSW 2230",
            tags: ["Beach", "Relaxed", "Coastal"],
            coordinate: Coordinate(latitude: -34.0537, longitude: 151.1538),
            nswStopId: "219110"
        ),

        // 11. Watsons Bay — explicit category override (harbour fits better than landmark)
        Destination(
            id: "watsons-bay",
            name: "Watsons Bay",
            shortDescription: "Harbourside village famous for fish-and-chips and The Gap clifftop.",
            streetAddress: "Military Road, Watsons Bay NSW 2030",
            category: .harbour,
            tags: ["Scenic", "Harbour", "Seafood"],
            coordinate: Coordinate(latitude: -33.8420, longitude: 151.2818)
        ),

        // 12. Taronga Zoo Sydney
        Destination(
            id: "taronga-zoo",
            name: "Taronga Zoo Sydney",
            shortDescription: "Harbour-view zoo with a cable car and stunning skyline panoramas.",
            streetAddress: "Bradleys Head Road, Mosman NSW 2088",
            tags: ["Family", "Animals", "Views"],
            coordinate: Coordinate(latitude: -33.8430, longitude: 151.2410)
        ),

        // 13. Mosman — explicit category override (nature fits better than food)
        Destination(
            id: "mosman",
            name: "Mosman",
            shortDescription: "Leafy lower-north-shore suburb with bushland walks and harbour views.",
            streetAddress: "Headland Park, Middle Head Road, Mosman NSW 2088",
            category: .nature,
            tags: ["Scenic", "Walks", "Cafes"],
            coordinate: Coordinate(latitude: -33.8290, longitude: 151.2480)
        ),

        // 14. Sydney Olympic Park
        Destination(
            id: "olympic-park",
            name: "Sydney Olympic Park",
            shortDescription: "Sporting precinct from the 2000 Games with parklands and major events.",
            streetAddress: "5 Olympic Boulevard, Sydney Olympic Park NSW 2127",
            tags: ["Events", "Sport", "Outdoors"],
            coordinate: Coordinate(latitude: -33.8473, longitude: 151.0685)
        ),

        // 15. Katoomba
        Destination(
            id: "katoomba",
            name: "Katoomba",
            shortDescription: "Blue Mountains gateway town with the Three Sisters lookout.",
            streetAddress: "Echo Point Road, Katoomba NSW 2780",
            tags: ["Nature", "Lookouts", "Scenic"],
            coordinate: Coordinate(latitude: -33.7320, longitude: 150.3120)
        ),

        // 16. Central Station
        Destination(
            id: "central-station",
            name: "Central Station",
            shortDescription: "Sydney's largest rail hub, gateway to every corner of the city.",
            streetAddress: "1 Eddy Avenue, Haymarket NSW 2000",
            tags: ["Transport Hub", "Convenient", "Shopping"],
            coordinate: Coordinate(latitude: -33.8830, longitude: 151.2070),
            nswStopId: "200080"
        ),

        // 17. UTS Broadway
        Destination(
            id: "uts-broadway",
            name: "UTS Broadway",
            shortDescription: "University of Technology Sydney's main campus with student-friendly cafes.",
            streetAddress: "15 Broadway, Ultimo NSW 2007",
            tags: ["Students", "Cafes", "Convenient"],
            coordinate: Coordinate(latitude: -33.8838, longitude: 151.2003)
        ),

        // 18. Coogee Beach
        Destination(
            id: "coogee-beach",
            name: "Coogee Beach",
            shortDescription: "Family-friendly beach with calmer waters and the famous coastal walk.",
            streetAddress: "Coogee Beach Access Road, Coogee NSW 2034",
            tags: ["Beach", "Walks", "Scenic"],
            coordinate: Coordinate(latitude: -33.9205, longitude: 151.2576)
        ),

        // 19. Surry Hills
        Destination(
            id: "surry-hills",
            name: "Surry Hills",
            shortDescription: "Trendy inner-city neighbourhood famous for brunch spots and small bars.",
            streetAddress: "Crown Street, Surry Hills NSW 2010",
            tags: ["Food", "Nightlife", "Artsy"],
            coordinate: Coordinate(latitude: -33.8842, longitude: 151.2130)
        ),

        // 20. Glebe
        Destination(
            id: "glebe",
            name: "Glebe",
            shortDescription: "Bohemian inner-west pocket with weekend markets and heritage cottages.",
            streetAddress: "Glebe Point Road, Glebe NSW 2037",
            tags: ["Markets", "Cafes", "Historic"],
            coordinate: Coordinate(latitude: -33.8800, longitude: 151.1860)
        ),

        // 21. Rhodes
        Destination(
            id: "rhodes",
            name: "Rhodes",
            shortDescription: "Modern waterside precinct with a shopping centre and Parramatta River views.",
            streetAddress: "Rhodes Waterside, 1 Rider Boulevard, Rhodes NSW 2138",
            tags: ["Waterfront", "Shopping", "Dining"],
            coordinate: Coordinate(latitude: -33.8290, longitude: 151.0880)
        ),

        // 22. Strathfield
        Destination(
            id: "strathfield",
            name: "Strathfield",
            shortDescription: "Inner-west transit junction with Korean restaurants and tree-lined streets.",
            streetAddress: "The Boulevarde, Strathfield NSW 2135",
            tags: ["Dining", "Convenient", "Transport Hub"],
            coordinate: Coordinate(latitude: -33.8730, longitude: 151.0930)
        ),

        // 23. Hornsby
        Destination(
            id: "hornsby",
            name: "Hornsby",
            shortDescription: "Northern Sydney shopping hub anchored by Westfield and rail interchange.",
            streetAddress: "Westfield Hornsby, 236 Pacific Highway, Hornsby NSW 2077",
            tags: ["Shopping", "Dining", "Relaxed"],
            coordinate: Coordinate(latitude: -33.7030, longitude: 151.0990)
        ),

        // 24. Penrith — explicit category override (nature fits better than landmark)
        Destination(
            id: "penrith",
            name: "Penrith",
            shortDescription: "Western Sydney gateway to outdoor adventure and the Nepean River.",
            streetAddress: "High Street, Penrith NSW 2750",
            category: .nature,
            tags: ["Outdoors", "Food", "Adventure"],
            coordinate: Coordinate(latitude: -33.7510, longitude: 150.6940)
        ),

        // 25. Liverpool
        Destination(
            id: "liverpool",
            name: "Liverpool",
            shortDescription: "South-west Sydney centre with Westfield and multicultural dining.",
            streetAddress: "Macquarie Street, Liverpool NSW 2170",
            tags: ["Shopping", "Dining", "Convenient"],
            coordinate: Coordinate(latitude: -33.9200, longitude: 150.9230)
        ),

        // 26. Royal Botanic Garden
        Destination(
            id: "royal-botanic-garden",
            name: "Royal Botanic Garden",
            shortDescription: "Heritage gardens beside the Opera House with free entry.",
            streetAddress: "Mrs Macquaries Road, Sydney NSW 2000",
            tags: ["Nature", "Scenic", "Walks"],
            coordinate: Coordinate(latitude: -33.8642, longitude: 151.2166)
        ),

        // 27. Balmoral Beach
        Destination(
            id: "balmoral-beach",
            name: "Balmoral Beach",
            shortDescription: "Calm harbour beach in Mosman with picnic-friendly grassy headlands.",
            streetAddress: "The Esplanade, Balmoral NSW 2088",
            tags: ["Beach", "Harbour", "Relaxed"],
            coordinate: Coordinate(latitude: -33.8240, longitude: 151.2520)
        ),

        // 28. Macquarie Centre
        Destination(
            id: "macquarie-centre",
            name: "Macquarie Centre",
            shortDescription: "Major North Ryde shopping mall with metro station access.",
            streetAddress: "Herring Road, North Ryde NSW 2113",
            tags: ["Shopping", "Dining", "Convenient"],
            coordinate: Coordinate(latitude: -33.7770, longitude: 151.1280)
        ),

        // 29. Palm Beach
        Destination(
            id: "palm-beach",
            name: "Palm Beach",
            shortDescription: "Northern Beaches escape famous as the Home and Away filming location.",
            streetAddress: "1 Beach Road, Palm Beach NSW 2108",
            tags: ["Beach", "Scenic", "Coastal"],
            coordinate: Coordinate(latitude: -33.5990, longitude: 151.3230)
        ),

        // 30. Rouse Hill Town Centre
        Destination(
            id: "rouse-hill",
            name: "Rouse Hill Town Centre",
            shortDescription: "Open-air shopping village in Sydney's north-west, accessible via Metro.",
            streetAddress: "Windsor Road, Rouse Hill NSW 2155",
            tags: ["Shopping", "Family", "Outdoors"],
            coordinate: Coordinate(latitude: -33.6810, longitude: 150.9180)
        )
    ]

    // MARK: - Lookup

    static func destination(id: String) -> Destination? {
        destinations.first { $0.id == id }
    }
}
