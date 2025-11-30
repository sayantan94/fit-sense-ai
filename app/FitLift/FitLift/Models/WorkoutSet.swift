import Foundation
import SwiftData

@Model
final class WorkoutSet {
    var id: UUID
    var setNumber: Int
    var weight: Double
    var reps: Int
    var isCompleted: Bool
    var completedAt: Date?

    var exercise: Exercise?
    var session: WorkoutSession?

    init(setNumber: Int, weight: Double = 0, reps: Int = 0, isCompleted: Bool = false) {
        self.id = UUID()
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
        self.completedAt = nil
    }

    func complete(weight: Double, reps: Int) {
        self.weight = weight
        self.reps = reps
        self.isCompleted = true
        self.completedAt = Date()
    }

    var formattedWeight: String {
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(weight)) lbs"
        }
        return String(format: "%.1f lbs", weight)
    }
}