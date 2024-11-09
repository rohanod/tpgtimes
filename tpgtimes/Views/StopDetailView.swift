import SwiftUI

struct StopDetailView: View {
    let stop: TransitStop
    @Environment(\.dismiss) private var dismiss
    @AppStorage("language") private var language = "en"
    @StateObject private var viewModel = TransitViewModel()
    @State private var filteredLines: [String] = []
    @State private var showingFilters = false
    @State private var showingMap = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let coordinates = stop.coordinates {
                        MapView(stop: stop)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .onTapGesture {
                                showingMap = true
                            }
                    }
                    
                    if !stop.lines.isEmpty {
                        // Line filters
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(stop.lines, id: \.self) { line in
                                    FilterChip(
                                        text: line,
                                        isSelected: filteredLines.contains(line)
                                    ) {
                                        if filteredLines.contains(line) {
                                            filteredLines.removeAll { $0 == line }
                                        } else {
                                            filteredLines.append(line)
                                        }
                                        Task {
                                            await viewModel.loadDepartures(for: stop, filteredLines: filteredLines)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Departures grid
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else if viewModel.groupedDepartures.isEmpty {
                        Text(language == "en" ? "No upcoming departures" : "Aucun départ à venir")
                            .foregroundStyle(.secondary)
                            .padding()
                    } else {
                        ForEach(viewModel.groupedDepartures.keys.sorted(), id: \.self) { direction in
                            DirectionSection(
                                direction: direction,
                                departures: viewModel.groupedDepartures[direction] ?? []
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(stop.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            viewModel.toggleFavorite(stop)
                        } label: {
                            Image(systemName: viewModel.isFavorite(stop) ? "star.fill" : "star")
                                .foregroundStyle(.orange)
                        }
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .refreshable {
                await viewModel.loadDepartures(for: stop, filteredLines: filteredLines)
            }
        }
        .sheet(isPresented: $showingMap) {
            MapView(stop: stop)
                .edgesIgnoringSafeArea(.all)
        }
        .task {
            await viewModel.loadDepartures(for: stop)
        }
    }
}

struct FilterChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.orange : Color.orange.opacity(0.1))
                .foregroundStyle(isSelected ? .white : .orange)
                .clipShape(Capsule())
        }
    }
}

struct DirectionSection: View {
    let direction: String
    let departures: [Departure]
    @AppStorage("language") private var language = "en"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(language == "en" ? "To: " : "Vers : ")\(direction)")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 80))
            ], spacing: 8) {
                ForEach(departures.prefix(10)) { departure in
                    Text("\(departure.minutesUntilDeparture) min")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
} 