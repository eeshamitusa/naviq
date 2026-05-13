//
//  APIConfig.swift
//  NAVIQ
//

import Foundation

enum APIConfig {
    static let nswBaseURL = "https://api.transport.nsw.gov.au/v1/tp"
    static let nswAPIKey = "YOUR_API_KEY"
    static var hasValidAPIKey: Bool {
           let trimmedKey = nswAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)

           return !trimmedKey.isEmpty &&
           trimmedKey != "YOUR_API_KEY" &&
           trimmedKey != "PASTE_TOKEN_HERE"
       }
}
