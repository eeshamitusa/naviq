//
//  MockData+Routes.swift
//  NAVIQ
//
//  Mock route data for all 30 destinations.
//  Origin: UTS Tower (CBD south, Ultimo — lat -33.8838 lng 151.2003)
//
//  Time distribution (for Eesha's grouping):
//    Quick Trips  (<=30 min):    8   [UTS, Central, Darling Harbour, Surry Hills, Glebe,
//                                     Barangaroo, The Rocks, Royal Botanic Garden]
//    Best Leisure (31-60 min):  15   [Circular Quay, Newtown, Bondi, Manly, Coogee,
//                                     Watsons Bay, Taronga, Mosman, Balmoral, Olympic Park,
//                                     Strathfield, Chatswood, Parramatta, Rhodes, Macquarie]
//    Longer Trips (61-90 min):   5   [Cronulla, Hornsby, Liverpool, Rouse Hill, Penrith]
//    Day Trips    (>90 min):     2   [Palm Beach, Katoomba]
//

import Foundation

extension MockData {

    /// UTS Tower coordinates — baseline origin for mock routes
    static let mockOrigin = Coordinate(latitude: -33.8838, longitude: 151.2003)

    static let allRoutes: [RouteResult] = [

        // ============ Quick Trips (<=30 min) ============

        // 1. UTS Broadway — same location (demo purposes)
        makeRoute(
            destinationId: "uts-broadway", travelMin: 1, primary: .walking,
            steps: [
                step(1, .walking, line: nil,
                     from: "UTS Tower", to: "UTS Broadway",
                     min: 1, instr: "You're already here")
            ]
        ),

        // 2. Central Station
        makeRoute(
            destinationId: "central-station", travelMin: 8, primary: .walking,
            steps: [
                step(1, .walking, line: nil,
                     from: "UTS Tower", to: "Central Station",
                     min: 8, instr: "Walk via Quay Street")
            ]
        ),

        // 3. Darling Harbour
        makeRoute(
            destinationId: "darling-harbour", travelMin: 12, primary: .walking,
            steps: [
                step(1, .walking, line: nil,
                     from: "UTS Tower", to: "Darling Harbour",
                     min: 12, instr: "Walk via Harris Street footbridge")
            ]
        ),

        // 4. Glebe
        makeRoute(
            destinationId: "glebe", travelMin: 15, primary: .walking,
            steps: [
                step(1, .walking, line: nil,
                     from: "UTS Tower", to: "Glebe Point Road",
                     min: 15, instr: "Walk via Wattle Street")
            ]
        ),

        // 5. Surry Hills
        makeRoute(
            destinationId: "surry-hills", travelMin: 18, primary: .walking,
            steps: [
                step(1, .walking, line: nil,
                     from: "UTS Tower", to: "Crown Street, Surry Hills",
                     min: 18, instr: "Walk via Foveaux Street")
            ]
        ),

        // 6. Barangaroo
        makeRoute(
            destinationId: "barangaroo", travelMin: 19, primary: .lightRail,
            steps: [
                step(1, .walking, line: nil,
                     from: "UTS Tower", to: "Central Chalmers St",
                     min: 4, instr: "Walk to Chalmers St light rail stop"),
                step(2, .lightRail, line: "L2 / L3",
                     from: "Central", to: "Wynyard",
                     min: 9, instr: "Take L2 or L3 to Wynyard"),
                step(3, .walking, line: nil,
                     from: "Wynyard", to: "Barangaroo",
                     min: 6, instr: "Walk down to Hickson Road")
            ]
        ),

        // 7. The Rocks
        makeRoute(
            destinationId: "the-rocks", travelMin: 20, primary: .train,
            steps: [
                step(1, .walking, line: nil,
                     from: "UTS Tower", to: "Central Station",
                     min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T2 Inner West Line",
                     from: "Central", to: "Circular Quay",
                     min: 7, instr: "Take T2 to Circular Quay"),
                step(3, .walking, line: nil,
                     from: "Circular Quay", to: "The Rocks",
                     min: 5, instr: "Walk west along George Street")
            ]
        ),

        // 8. Royal Botanic Garden
        makeRoute(
            destinationId: "royal-botanic-garden", travelMin: 22, primary: .train,
            steps: [
                step(1, .walking, line: nil,
                     from: "UTS Tower", to: "Central Station",
                     min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T2 Inner West Line",
                     from: "Central", to: "Martin Place",
                     min: 6, instr: "Take T2 to Martin Place"),
                step(3, .walking, line: nil,
                     from: "Martin Place", to: "Royal Botanic Garden",
                     min: 8, instr: "Walk down Macquarie Street")
            ]
        ),

        // ============ Best Leisure (31-60 min) ============

        // 9. Circular Quay
        makeRoute(
            destinationId: "circular-quay", travelMin: 32, primary: .train,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T2 Inner West Line", from: "Central", to: "Circular Quay", min: 7, instr: "Take T2 to Circular Quay"),
                step(3, .walking, line: nil, from: "Circular Quay Station", to: "Quay forecourt", min: 4, instr: "Walk to the wharves"),
                step(4, .walking, line: nil, from: "Forecourt", to: "Alfred Street", min: 13, instr: "Explore the harbour edge")
            ]
        ),

        // 10. Newtown
        makeRoute(
            destinationId: "newtown", travelMin: 32, primary: .train,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T2 Inner West Line", from: "Central", to: "Newtown", min: 6, instr: "Take T2 to Newtown"),
                step(3, .walking, line: nil, from: "Newtown Station", to: "King Street", min: 4, instr: "Walk to King Street strip"),
                step(4, .walking, line: nil, from: "Top of King St", to: "Erskineville end", min: 14, instr: "Wander south along King Street")
            ]
        ),

        // 11. Strathfield
        makeRoute(
            destinationId: "strathfield", travelMin: 32, primary: .train,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T2 Inner West Line", from: "Central", to: "Strathfield", min: 19, instr: "Take T2 to Strathfield"),
                step(3, .walking, line: nil, from: "Strathfield Station", to: "The Boulevarde", min: 5, instr: "Walk to the dining strip")
            ]
        ),

        // 12. Rhodes
        makeRoute(
            destinationId: "rhodes", travelMin: 35, primary: .train,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T9 Northern Line", from: "Central", to: "Rhodes", min: 22, instr: "Take T9 to Rhodes"),
                step(3, .walking, line: nil, from: "Rhodes Station", to: "Rider Boulevard", min: 5, instr: "Walk to the waterfront")
            ]
        ),

        // 13. Bondi Beach
        makeRoute(
            destinationId: "bondi-beach", travelMin: 38, primary: .bus,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .bus, line: "Bus 333", from: "Central", to: "Bondi Beach", min: 28, instr: "Take 333 bus toward Bondi"),
                step(3, .walking, line: nil, from: "Bondi Stop", to: "Pavilion", min: 2, instr: "Walk to the beach")
            ]
        ),

        // 14. Olympic Park
        makeRoute(
            destinationId: "olympic-park", travelMin: 38, primary: .train,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T1 Western Line", from: "Central", to: "Lidcombe", min: 22, instr: "Take T1 to Lidcombe"),
                step(3, .train, line: "T7 Olympic Park Line", from: "Lidcombe", to: "Olympic Park", min: 6, instr: "Transfer to T7 shuttle"),
                step(4, .walking, line: nil, from: "Olympic Park Station", to: "Park venues", min: 2, instr: "Walk into the precinct")
            ]
        ),

        // 15. Coogee Beach
        makeRoute(
            destinationId: "coogee-beach", travelMin: 42, primary: .bus,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .bus, line: "Bus 372", from: "Central", to: "Coogee Beach", min: 32, instr: "Take 372 bus toward Coogee"),
                step(3, .walking, line: nil, from: "Coogee Bay Rd", to: "Beach access", min: 2, instr: "Walk to the sand")
            ]
        ),

        // 16. Taronga Zoo
        makeRoute(
            destinationId: "taronga-zoo", travelMin: 42, primary: .ferry,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T2 Inner West Line", from: "Central", to: "Circular Quay", min: 7, instr: "Take T2 to Circular Quay"),
                step(3, .ferry, line: "Ferry F2 Taronga Zoo", from: "Wharf 2", to: "Taronga Zoo Wharf", min: 12, instr: "Board F2 Taronga Zoo ferry"),
                step(4, .walking, line: nil, from: "Zoo Wharf", to: "Zoo entrance", min: 15, instr: "Take Sky Safari cable car or walk uphill")
            ]
        ),

        // 17. Chatswood
        makeRoute(
            destinationId: "chatswood", travelMin: 42, primary: .train,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T1 North Shore Line", from: "Central", to: "Chatswood", min: 28, instr: "Take T1 to Chatswood"),
                step(3, .walking, line: nil, from: "Chatswood Station", to: "Victoria Avenue", min: 6, instr: "Walk to the shopping strip")
            ]
        ),

        // 18. Parramatta
        makeRoute(
            destinationId: "parramatta", travelMin: 45, primary: .train,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T1 Western Line", from: "Central", to: "Parramatta", min: 30, instr: "Take T1 to Parramatta"),
                step(3, .walking, line: nil, from: "Parramatta Station", to: "Pitt & Macquarie St", min: 7, instr: "Walk to Church Street mall")
            ]
        ),

        // 19. Mosman
        makeRoute(
            destinationId: "mosman", travelMin: 45, primary: .ferry,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T2 Inner West Line", from: "Central", to: "Circular Quay", min: 7, instr: "Take T2 to Circular Quay"),
                step(3, .ferry, line: "Ferry F8 / F2", from: "Wharf 4", to: "Old Cremorne Wharf", min: 18, instr: "Board ferry to Mosman side"),
                step(4, .walking, line: nil, from: "Wharf", to: "Headland Park", min: 12, instr: "Walk via Avenue Road")
            ]
        ),

        // 20. Watsons Bay
        makeRoute(
            destinationId: "watsons-bay", travelMin: 50, primary: .ferry,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T2 Inner West Line", from: "Central", to: "Circular Quay", min: 7, instr: "Take T2 to Circular Quay"),
                step(3, .ferry, line: "Ferry F9 Watsons Bay", from: "Wharf 4", to: "Watsons Bay Wharf", min: 28, instr: "Board F9 Watsons Bay ferry"),
                step(4, .walking, line: nil, from: "Watsons Bay Wharf", to: "Military Road", min: 7, instr: "Walk to The Gap or Camp Cove")
            ]
        ),

        // 21. Manly
        makeRoute(
            destinationId: "manly", travelMin: 50, primary: .ferry,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T2 Inner West Line", from: "Central", to: "Circular Quay", min: 7, instr: "Take T2 to Circular Quay"),
                step(3, .ferry, line: "Ferry F1 Manly", from: "Wharf 3", to: "Manly Wharf", min: 30, instr: "Board F1 Manly ferry"),
                step(4, .walking, line: nil, from: "Manly Wharf", to: "The Corso", min: 5, instr: "Walk along The Corso to the beach")
            ]
        ),

        // 22. Macquarie Centre
        makeRoute(
            destinationId: "macquarie-centre", travelMin: 50, primary: .metro,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T1 North Shore Line", from: "Central", to: "Chatswood", min: 28, instr: "Take T1 to Chatswood"),
                step(3, .metro, line: "Sydney Metro M1", from: "Chatswood", to: "Macquarie Park", min: 8, instr: "Transfer to Metro M1"),
                step(4, .walking, line: nil, from: "Macquarie Park Station", to: "Herring Road mall", min: 6, instr: "Walk to the shopping centre")
            ]
        ),

        // 23. Balmoral Beach
        makeRoute(
            destinationId: "balmoral-beach", travelMin: 55, primary: .bus,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T2 Inner West Line", from: "Central", to: "Wynyard", min: 9, instr: "Take T2 to Wynyard"),
                step(3, .bus, line: "Bus 244", from: "Wynyard", to: "Balmoral Beach", min: 32, instr: "Take 244 bus across Harbour Bridge"),
                step(4, .walking, line: nil, from: "Bus stop", to: "The Esplanade", min: 6, instr: "Walk down to the beach")
            ]
        ),

        // ============ Longer Trips (61-90 min) ============

        // 24. Cronulla
        makeRoute(
            destinationId: "cronulla", travelMin: 65, primary: .train,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T4 Eastern Suburbs & Illawarra Line", from: "Central", to: "Cronulla", min: 52, instr: "Take T4 train to Cronulla"),
                step(3, .walking, line: nil, from: "Cronulla Station", to: "Gerrale Street", min: 5, instr: "Walk down Cronulla Mall to the beach")
            ]
        ),

        // 25. Liverpool
        makeRoute(
            destinationId: "liverpool", travelMin: 65, primary: .train,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T2 Inner West & Leppington Line", from: "Central", to: "Liverpool", min: 50, instr: "Take T2 to Liverpool"),
                step(3, .walking, line: nil, from: "Liverpool Station", to: "Macquarie Street", min: 7, instr: "Walk to the town centre")
            ]
        ),

        // 26. Hornsby
        makeRoute(
            destinationId: "hornsby", travelMin: 70, primary: .train,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T1 North Shore Line", from: "Central", to: "Hornsby", min: 56, instr: "Take T1 north to Hornsby"),
                step(3, .walking, line: nil, from: "Hornsby Station", to: "Westfield Hornsby", min: 6, instr: "Walk to the shopping centre")
            ]
        ),

        // 27. Rouse Hill
        makeRoute(
            destinationId: "rouse-hill", travelMin: 75, primary: .metro,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T1 North Shore Line", from: "Central", to: "Chatswood", min: 28, instr: "Take T1 to Chatswood"),
                step(3, .metro, line: "Sydney Metro M1", from: "Chatswood", to: "Rouse Hill", min: 32, instr: "Transfer to Metro M1 toward Tallawong"),
                step(4, .walking, line: nil, from: "Rouse Hill Station", to: "Town Centre", min: 7, instr: "Walk to the open-air mall")
            ]
        ),

        // 28. Penrith
        makeRoute(
            destinationId: "penrith", travelMin: 75, primary: .train,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T1 Western Line", from: "Central", to: "Penrith", min: 60, instr: "Take T1 west to Penrith"),
                step(3, .walking, line: nil, from: "Penrith Station", to: "High Street", min: 7, instr: "Walk to the town centre")
            ]
        ),

        // ============ Day Trips (>90 min) ============

        // 29. Palm Beach
        makeRoute(
            destinationId: "palm-beach", travelMin: 115, primary: .bus,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "T2 Inner West Line", from: "Central", to: "Wynyard", min: 9, instr: "Take T2 to Wynyard"),
                step(3, .bus, line: "B-Line B1", from: "Wynyard", to: "Mona Vale", min: 60, instr: "Take B1 bus toward Northern Beaches"),
                step(4, .bus, line: "Bus 199", from: "Mona Vale", to: "Palm Beach", min: 32, instr: "Transfer to 199 bus to Palm Beach"),
                step(5, .walking, line: nil, from: "Bus stop", to: "Beach Road", min: 6, instr: "Walk down to the beach")
            ]
        ),

        // 30. Katoomba
        makeRoute(
            destinationId: "katoomba", travelMin: 130, primary: .train,
            steps: [
                step(1, .walking, line: nil, from: "UTS Tower", to: "Central Station", min: 8, instr: "Walk to Central Station"),
                step(2, .train, line: "Blue Mountains Line", from: "Central", to: "Katoomba", min: 110, instr: "Take Blue Mountains intercity train"),
                step(3, .walking, line: nil, from: "Katoomba Station", to: "Echo Point Road", min: 12, instr: "Walk or take 686 bus to Echo Point lookout")
            ]
        )
    ]

    // MARK: - Filtering

    /// Filter routes by user's available time and budget.
    static func routes(filteredBy input: ExploreInput) -> [RouteResult] {
        allRoutes.filter {
            $0.travelTimeMinutes <= input.availableTimeMinutes
            && $0.costAUD <= input.budgetAUD
        }
    }

    // MARK: - Private Helpers

    private static func makeRoute(
        destinationId: String,
        travelMin: Int,
        primary: TransportMode,
        steps: [RouteStep]
    ) -> RouteResult {
        guard let dest = destination(id: destinationId) else {
            fatalError("Mock destination id not found: \(destinationId)")
        }
        return RouteResult(
            destination: dest,
            travelTimeMinutes: travelMin,
            costAUD: dest.fare.adultAUD,
            primaryTransportMode: primary,
            steps: steps,
            isLiveData: false
        )
    }

    private static func step(
        _ order: Int,
        _ mode: TransportMode,
        line: String?,
        from: String,
        to: String,
        min: Int,
        instr: String
    ) -> RouteStep {
        RouteStep(
            order: order, mode: mode, lineName: line,
            fromName: from, toName: to,
            durationMinutes: min, instruction: instr
        )
    }
}
