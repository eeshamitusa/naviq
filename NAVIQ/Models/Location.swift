import Foundation

struct Location: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let location: String
    let tags: [String]

    enum CodingKeys: String, CodingKey {
        case name
        case location
        case tags
    }
}