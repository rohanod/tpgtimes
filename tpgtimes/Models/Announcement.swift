import Foundation

struct Announcement: Identifiable {
    let id: UUID
    let title: String
    let message: String
    let date: Date
    let type: AnnouncementType
    
    enum AnnouncementType {
        case info
        case alert
        case update
        
        var icon: String {
            switch self {
            case .info: "info.circle.fill"
            case .alert: "exclamationmark.triangle.fill"
            case .update: "arrow.triangle.2.circlepath"
            }
        }
        
        var color: Color {
            switch self {
            case .info: .blue
            case .alert: .red
            case .update: .green
            }
        }
    }
} 