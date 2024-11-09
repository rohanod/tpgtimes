import SwiftUI

struct HomeView: View {
    // State for managing dynamic content
    @State private var isLoading = false
    @State private var announcements: [Announcement] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header section
                    HeaderView()
                    
                    // Quick actions
                    QuickActionsGrid()
                    
                    // Latest announcements
                    AnnouncementsSection(announcements: announcements)
                }
                .padding()
            }
            .navigationTitle("TPG Times")
            .refreshable {
                // Pull to refresh functionality
                await loadAnnouncements()
            }
        }
        .task {
            await loadAnnouncements()
        }
    }
    
    private func loadAnnouncements() async {
        // Implement your data loading logic here
        isLoading = true
        // Simulated delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isLoading = false
    }
}

// Supporting views
struct HeaderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image("logo") // Add your app logo to assets
                .resizable()
                .scaledToFit()
                .frame(height: 60)
            
            Text("Welcome to TPG Times")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Your daily transit companion")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical)
    }
}

struct QuickActionsGrid: View {
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            QuickActionButton(
                title: "Next Bus",
                icon: "bus.fill",
                action: { /* Implementation */ }
            )
            QuickActionButton(
                title: "Favorites",
                icon: "star.fill",
                action: { /* Implementation */ }
            )
            QuickActionButton(
                title: "Route Map",
                icon: "map.fill",
                action: { /* Implementation */ }
            )
            QuickActionButton(
                title: "Alerts",
                icon: "exclamationmark.triangle.fill",
                action: { /* Implementation */ }
            )
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.callout)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.tint.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .tint(.primary)
    }
} 