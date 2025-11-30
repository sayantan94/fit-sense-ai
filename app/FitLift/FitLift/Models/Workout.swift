import Foundation
import SwiftData

@Model
final class Workout {
    var id: UUID
    var typeRaw: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSession.workout)
    var sessions: [WorkoutSession]?

    var type: WorkoutType {
        get { WorkoutType(rawValue: typeRaw) ?? .push }
        set { typeRaw = newValue.rawValue }
    }

    init(type: WorkoutType) {
        self.id = UUID()
        self.typeRaw = type.rawValue
        self.createdAt = Date()
        self.sessions = []
    }

    var lastSession: WorkoutSession? {
        sessions?.sorted { $0.date > $1.date }.first
    }

    var lastWorkoutText: String {
        guard let lastSession = lastSession else {
            return "Never"
        }

        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(lastSession.date) {
            return "Today"
        } else if calendar.isDateInYesterday(lastSession.date) {
            return "Yesterday"
        } else {
            let days = calendar.dateComponents([.day], from: lastSession.date, to: now).day ?? 0
            return "\(days) days ago"
        }
    }
}
