import SwiftUI
import MapKit

struct MapView: View {
    let stop: TransitStop
    
    var body: some View {
        if let coordinates = stop.coordinates {
            Map(initialPosition: .region(region(for: coordinates))) {
                Marker(stop.name, coordinate: CLLocationCoordinate2D(
                    latitude: coordinates.latitude,
                    longitude: coordinates.longitude
                ))
            }
        } else {
            Text("Location not available")
                .foregroundStyle(.secondary)
        }
    }
    
    private func region(for coordinates: TransitStop.Coordinates) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: coordinates.latitude,
                longitude: coordinates.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
} 