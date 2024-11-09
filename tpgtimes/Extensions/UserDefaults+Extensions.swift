import Foundation

extension UserDefaults {
    private enum Keys {
        static let favorites = "favorites"
        static let kioskStops = "kioskStops"
        static let lastUpdateTime = "lastUpdateTime"
        static let cachedDepartures = "cachedDepartures"
    }
    
    var favorites: [TransitStop] {
        get {
            guard let data = data(forKey: Keys.favorites) else { return [] }
            return (try? JSONDecoder().decode([TransitStop].self, from: data)) ?? []
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            setValue(data, forKey: Keys.favorites)
        }
    }
    
    var kioskStops: [TransitStop] {
        get {
            guard let data = data(forKey: Keys.kioskStops) else { return [] }
            return (try? JSONDecoder().decode([TransitStop].self, from: data)) ?? []
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            setValue(data, forKey: Keys.kioskStops)
        }
    }
} 