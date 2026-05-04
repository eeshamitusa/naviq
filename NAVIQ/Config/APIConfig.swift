//
//  APIConfig.swift
//  NAVIQ
//
//  Created by Matthew Ashley on 4/5/2026.
//

import Foundation

enum APIConfig {
    static let nswBaseURL = "https://api.transport.nsw.gov.au/v1/tp"
    static let nswAPIKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJhOVo0NW1WLW02TGNQUXI3dkZTZlhQeFFuWnB4bWhZRW91dGlva0NmNVk4IiwiaWF0IjoxNzc3ODg3OTQyfQ.2JSjb9o7g0ym25mpGo5GLgk9uHugWG_LW5VCB2Y8NgY"
    static var hasValidAPIKey: Bool {
           let trimmedKey = nswAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)

           return !trimmedKey.isEmpty &&
           trimmedKey != "YOUR_API_KEY" &&
           trimmedKey != "PASTE_TOKEN_HERE"
       }
}
