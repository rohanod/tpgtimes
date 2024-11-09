import SwiftUI

struct StopSearch: View {
    @StateObject private var viewModel = TransitViewModel()
    @State private var stopName = ""
    @State private var vehicleNumbers = ""
    @State private var showingDetails: TransitStop?
    @AppStorage("language") private var language = "en"
    
    var body: some View {
        VStack(spacing: 16) {
            // Search inputs
            VStack(spacing: 12) {
                TextField(language == "en" ? "Enter stop name" : "Nom de l'arrêt", text: $stopName)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                
                TextField(
                    language == "en" ? "Enter bus/tram numbers (optional)" : "Numéros de bus/tram (optionnel)",
                    text: $vehicleNumbers
                )
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
            }
            .padding(.horizontal)
            
            // Results
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.searchResults.isEmpty && !stopName.isEmpty {
                Text(language == "en" ? "No results found" : "Aucun résultat trouvé")
                    .foregroundStyle(.secondary)
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(viewModel.searchResults) { stop in
                            StopCard(stop: stop)
                                .onTapGesture {
                                    showingDetails = stop
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(item: $showingDetails) { stop in
            StopDetailView(stop: stop)
        }
        .onChange(of: stopName) { _, newValue in
            Task {
                do {
                    try await viewModel.searchStops(query: newValue)
                } catch {
                    print("Error searching stops: \(error)")
                }
            }
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }
}

struct TransitStop: Identifiable {
    let id: String
    let name: String
    let lines: [String]
    let coordinates: [Coordinates]
}

struct StopCard: View {
    let stop: TransitStop
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(stop.name)
                .font(.headline)
            
            HStack {
                ForEach(stop.lines, id: \.self) { line in
                    Text(line)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
} 