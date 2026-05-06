//
//  TransportMode.swift
//  NAVIQ
//
//  Enum representing public transport types.
//  Maps to NSW API product.class codes and provides SF Symbols for UI.
//

import Foundation

enum TransportMode: String, Codable, Hashable, CaseIterable {
    case train
    case metro
    case bus
    case ferry
    case lightRail
    case walking
    case driving

    var displayName: String {
        switch self {
        case .train:     return "Train"
        case .metro:     return "Metro"
        case .bus:       return "Bus"
        case .ferry:     return "Ferry"
        case .lightRail: return "Light Rail"
        case .walking:   return "Walk"
        case .driving:   return "Drive"
        }
    }

    var iconName: String {
        switch self {
        case .train:     return "tram.fill"
        case .metro:     return "tram.tunnel.fill"
        case .bus:       return "bus.fill"
        case .ferry:     return "ferry.fill"
        case .lightRail: return "tram"
        case .walking:   return "figure.walk"
        case .driving:   return "car.fill"
        }
    }

    /// Convert NSW API product.class integer to TransportMode.
    /// - 1, 2  -> Train (Suburban / NSW TrainLink)
    /// - 4     -> Light Rail
    /// - 5, 7, 11 -> Bus
    /// - 9     -> Ferry
    /// - 99, 100  -> Walking
    static func fromAPIProductClass(_ classCode: Int) -> TransportMode {
        switch classCode {
        case 1, 2:     return .train
        case 4:        return .lightRail
        case 5, 7, 11: return .bus
        case 9:        return .ferry
        case 99, 100:  return .walking
        default:       return .bus
        }
    }
}
