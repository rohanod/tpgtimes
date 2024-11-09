struct TransitStop: Identifiable {
    let id: String
    let name: String
    let lines: [String]
    var coordinates: Coordinates?
    
    struct Coordinates {
        let latitude: Double
        let longitude: Double
    }
} 