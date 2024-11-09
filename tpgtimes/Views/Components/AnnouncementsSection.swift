import SwiftUI

struct AnnouncementsSection: View {
    let announcements: [Announcement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Service Updates")
                .font(.title2)
                .fontWeight(.bold)
            
            if announcements.isEmpty {
                Text("No current service updates")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(announcements) { announcement in
                    AnnouncementCard(announcement: announcement)
                }
            }
        }
    }
}

struct AnnouncementCard: View {
    let announcement: Announcement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: announcement.type.icon)
                    .foregroundStyle(announcement.type.color)
                Text(announcement.title)
                    .font(.headline)
                Spacer()
                Text(announcement.date.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(announcement.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
} 