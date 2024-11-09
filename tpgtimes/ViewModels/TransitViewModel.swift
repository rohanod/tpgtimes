import Foundation

@MainActor
class TransitViewModel: ObservableObject {
    @Published var groupedDepartures: [String: [Departure]] = [:]
    @Published var searchResults: [TransitStop] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isKioskMode = false
    @Published var currentKioskIndex = 0
    
    private let baseURL = "https://transport.opendata.ch/v1"
    
    private let cache = NSCache<NSString, NSData>()
    private let defaults = UserDefaults.standard
    
    func searchStops(query: String) async throws {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        var components = URLComponents(string: "\(baseURL)/locations")!
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "type", value: "station")
        ]
        
        let (data, _) = try await URLSession.shared.data(from: components.url!)
        let response = try JSONDecoder().decode(LocationResponse.self, from: data)
        
        searchResults = response.stations
            .filter { $0.id != nil }
            .map { station in
                TransitStop(
                    id: station.id!,
                    name: station.name,
                    lines: station.lines ?? [],
                    coordinates: station.coordinate.map { coord in
                        TransitStop.Coordinates(
                            latitude: coord.x,
                            longitude: coord.y
                        )
                    }
                )
            }
    }
    
    func loadDepartures(for stop: TransitStop, filteredLines: [String] = []) async {
        isLoading = true
        defer { isLoading = false }
        
        // Try to load from cache first
        if let cachedData = cache.object(forKey: stop.id as NSString) as? NSData,
           let departures = try? JSONDecoder().decode([Departure].self, from: cachedData as Data) {
            groupedDepartures = Dictionary(grouping: departures, by: { $0.destination })
            return
        }
        
        do {
            var components = URLComponents(string: "\(baseURL)/stationboard")!
            components.queryItems = [
                URLQueryItem(name: "id", value: stop.id),
                URLQueryItem(name: "limit", value: "300")
            ]
            
            let (data, _) = try await URLSession.shared.data(from: components.url!)
            let response = try JSONDecoder().decode(StationboardResponse.self, from: data)
            
            let now = Date()
            let departures = response.stationboard
                .filter { $0.stop.departure != nil }
                .filter { entry in
                    filteredLines.isEmpty || filteredLines.contains(entry.number)
                }
                .map { entry -> Departure in
                    let departureDate = ISO8601DateFormatter().date(from: entry.stop.departure!)!
                    return Departure(
                        id: UUID(),
                        vehicleType: entry.category == "T" ? .tram : .bus,
                        lineNumber: entry.number,
                        destination: entry.to,
                        departureTime: departureDate,
                        minutesUntilDeparture: Int(departureDate.timeIntervalSince(now) / 60)
                    )
                }
                .filter { $0.minutesUntilDeparture >= 0 }
            
            // Cache the results
            if let data = try? JSONEncoder().encode(departures) {
                cache.setObject(data as NSData, forKey: stop.id as NSString)
            }
            
            groupedDepartures = Dictionary(
                grouping: departures.filter { departure in
                    filteredLines.isEmpty || filteredLines.contains(departure.lineNumber)
                },
                by: { $0.destination }
            )
        } catch {
            self.error = error
            print("Error loading departures: \(error)")
        }
    }
    
    func toggleFavorite(_ stop: TransitStop) {
        var favorites = defaults.favorites
        if favorites.contains(where: { $0.id == stop.id }) {
            favorites.removeAll { $0.id == stop.id }
        } else {
            favorites.append(stop)
        }
        defaults.favorites = favorites
    }
    
    func isFavorite(_ stop: TransitStop) -> Bool {
        defaults.favorites.contains { $0.id == stop.id }
    }
    
    func startKioskMode() {
        isKioskMode = true
        currentKioskIndex = 0
        kioskTimer?.invalidate()
        kioskTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task {
                await self.showNextKioskStop()
            }
        }
    }
    
    func stopKioskMode() {
        isKioskMode = false
        kioskTimer?.invalidate()
        kioskTimer = nil
    }
    
    private func showNextKioskStop() async {
        let stops = defaults.kioskStops
        guard !stops.isEmpty else { return }
        currentKioskIndex = (currentKioskIndex + 1) % stops.count
        let stop = stops[currentKioskIndex]
        await loadDepartures(for: stop)
    }
}

// Additional Models
struct LocationResponse: Codable {
    let stations: [Station]
}

struct Station: Codable {
    let id: String?
    let name: String
    let coordinate: Coordinate?
    let lines: [String]?
}

struct Coordinate: Codable {
    let type: String
    let x: Double
    let y: Double
}

// Models
struct StationboardResponse: Codable {
    let stationboard: [StationboardEntry]
}

struct StationboardEntry: Codable {
    let category: String
    let number: String
    let to: String
    let stop: StopInfo
}

struct StopInfo: Codable {
    let departure: String?
}

struct Departure: Identifiable {
    let id: UUID
    let vehicleType: VehicleType
    let lineNumber: String
    let destination: String
    let departureTime: Date
    let minutesUntilDeparture: Int
}

enum VehicleType {
    case bus
    case tram
} 