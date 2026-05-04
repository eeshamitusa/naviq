//
//  Coordinate.swift
//  NAVIQ
//
//  Latitude/longitude wrapper.
//  CLLocationCoordinate2D doesn't conform to Codable/Hashable, so we define our own.
//

import Foundation
import CoreLocation

struct Coordinate: Codable, Hashable {
    let latitude: Double
    let longitude: Double

    /// Convert to CLLocationCoordinate2D for MapKit.
    var clLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// NSW API coordinate format: "longitude:latitude:EPSG:4326"
    /// Note: NSW puts longitude first, which is the opposite of the usual order.
    var nswAPIString: String {
        "\(longitude):\(latitude):EPSG:4326"
    }
}
