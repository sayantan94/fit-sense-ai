import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var id: UUID
    var date: Date
    var duration: TimeInterval
    var isCompleted: Bool
    var notes: String?

    var workout: Workout?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.session)
    var sets: [WorkoutSet]?

    init(date: Date = Date()) {
        self.id = UUID()
        self.date = date
        self.duration = 0
        self.isCompleted = false
        self.notes = nil
        self.sets = []
    }

    var exerciseCount: Int {
        let exerciseNames = Set(sets?.compactMap { $0.exercise?.name } ?? [])
        return exerciseNames.count
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        }
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }

    var dayOfMonth: Int {
        Calendar.current.component(.day, from: date)
    }

    var weekdayShort: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}
