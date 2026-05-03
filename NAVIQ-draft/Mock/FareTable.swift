//
//  FareTable.swift
//  NAVIQ
//
//  Single source of truth for all destination fares.
//  Update this one file when NSW Opal fares change (usually every July).
//
//  Fare estimation rules (Adult Opal Peak, 2024 basis):
//    Free (walk only):       Walking distance <= 1.5km
//    Light Rail:             $3.20
//    Short train/bus:        $3.79  (within 5km)
//    Medium train:           $4.71  (10-20km)
//    Long train:             $5.42  (20-35km)
//    Short ferry:            $6.43
//    Manly-class ferry:      $8.13
//    Day-trip cap:           $8.99  (weekday daily cap applied)
//
//  Note:
//  - NSW Trip Planner API's Opal Fare component was deprecated Oct 2023.
//  - These are estimates. Actual fares vary by distance, zone, and transfer discounts.
//

import Foundation

enum FareTable {

    static let fares: [String: Fare] = [

        // -- CBD walkable ----------------------------------------
        "uts-broadway":         .free,
        "central-station":      .free,         // 8 min walk from UTS
        "darling-harbour":      .free,         // 12 min walk
        "surry-hills":          .free,         // 18 min walk
        "glebe":                .free,         // 15 min walk
        "barangaroo":           .adult(3.20),  // Light rail
        "the-rocks":            .adult(3.79),  // T2 short train

        // -- Short train/bus ------------------------------------
        "circular-quay":        .adult(3.79),
        "royal-botanic-garden": .adult(3.79),
        "newtown":              .adult(3.79),
        "bondi-beach":          .adult(3.79),  // Bus 333
        "coogee-beach":         .adult(3.79),  // Bus 372

        // -- Ferry -----------------------------------------------
        "watsons-bay":          .adult(6.43),  // Ferry F9
        "manly":                .adult(8.13),  // Ferry F1 (most expensive short ferry)
        "taronga-zoo":          .adult(8.13),  // Train + Ferry F2
        "balmoral-beach":       .adult(6.43),  // Bus + walk

        // -- Medium train (10-20km) ------------------------------
        "strathfield":          .adult(4.71),
        "rhodes":               .adult(4.71),
        "olympic-park":         .adult(4.71),
        "mosman":               .adult(4.71),  // Ferry+bus combo, short distance

        // -- Long train (20-35km) --------------------------------
        "chatswood":            .adult(4.71),
        "macquarie-centre":     .adult(5.42),  // Metro
        "parramatta":           .adult(5.42),
        "cronulla":             .adult(5.42),
        "hornsby":              .adult(5.42),
        "liverpool":            .adult(5.42),

        // -- Day-trip (long distance, daily cap applies) ----------
        "rouse-hill":           .adult(7.41),  // Metro new line
        "penrith":              .adult(7.41),  // T1 long distance
        "katoomba":             .explicit(     // Blue Mountains, furthest destination
            adult: 8.99,
            concession: 4.50,
            child: 4.50
        ),
        "palm-beach":           .explicit(     // Bus L90 + transfer
            adult: 6.43,
            concession: 3.20,
            child: 3.20
        )
    ]

    // MARK: - Lookup

    /// Safe lookup. Returns .free if destination ID is not registered (should never happen).
    static func fare(for destinationId: String) -> Fare {
        if let fare = fares[destinationId] {
            return fare
        }
        #if DEBUG
        print("Warning: FareTable has no entry for destination ID: \(destinationId)")
        #endif
        return .free
    }

    /// Quick adult fare lookup (most common use case in UI).
    static func adultFare(for destinationId: String) -> Double {
        fare(for: destinationId).adultAUD
    }
}
