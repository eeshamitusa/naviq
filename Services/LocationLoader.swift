import Foundation

enum LocationLoader {

    static func loadLocations() -> [Location] {
        guard let url = Bundle.main.url(forResource: "locations", withExtension: "json") else {
            print("Could not find locations.json")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let locations = try JSONDecoder().decode([Location].self, from: data)
            return locations
        } catch {
            print("Failed to load locations.json: \(error)")
            return []
        }
    }
}