import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String
    var muscleGroup: String
    var isCustom: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.exercise)
    var sets: [WorkoutSet]?

    init(name: String, muscleGroup: String, isCustom: Bool = false) {
        self.id = UUID()
        self.name = name
        self.muscleGroup = muscleGroup
        self.isCustom = isCustom
        self.createdAt = Date()
        self.sets = []
    }
}

// Default exercises database
enum ExerciseDatabase {
    static let chest: [String] = [
        "Bench Press",
        "Incline Bench Press",
        "Decline Bench Press",
        "Dumbbell Press",
        "Incline Dumbbell Press",
        "Dumbbell Flyes",
        "Cable Crossover",
        "Chest Dips",
        "Push-Ups"
    ]

    static let back: [String] = [
        "Deadlift",
        "Barbell Row",
        "Dumbbell Row",
        "Lat Pulldown",
        "Pull-Ups",
        "Chin-Ups",
        "Seated Cable Row",
        "T-Bar Row",
        "Face Pulls"
    ]

    static let shoulders: [String] = [
        "Overhead Press",
        "Dumbbell Shoulder Press",
        "Arnold Press",
        "Lateral Raises",
        "Front Raises",
        "Rear Delt Flyes",
        "Upright Rows",
        "Shrugs"
    ]

    static let legs: [String] = [
        "Squat",
        "Front Squat",
        "Leg Press",
        "Romanian Deadlift",
        "Leg Curl",
        "Leg Extension",
        "Lunges",
        "Bulgarian Split Squat",
        "Calf Raises",
        "Hip Thrust"
    ]

    static let triceps: [String] = [
        "Tricep Pushdown",
        "Skull Crushers",
        "Overhead Tricep Extension",
        "Dips",
        "Close-Grip Bench Press",
        "Tricep Kickbacks"
    ]

    static let biceps: [String] = [
        "Barbell Curl",
        "Dumbbell Curl",
        "Hammer Curl",
        "Preacher Curl",
        "Concentration Curl",
        "Cable Curl"
    ]

    static let core: [String] = [
        "Plank",
        "Crunches",
        "Leg Raises",
        "Hanging Leg Raises",
        "Russian Twists",
        "Cable Woodchops",
        "Dead Bug",
        "Ab Rollout",
        "Mountain Climbers",
        "Bicycle Crunches",
        "Hollow Body Hold",
        "Side Plank",
        "Head to Toe Touch"
    ]

    static func exercises(for workoutType: WorkoutType) -> [String: [String]] {
        switch workoutType {
        case .push:
            return ["Chest": chest, "Triceps": triceps]
        case .pull:
            return ["Back": back, "Biceps": biceps]
        case .shoulders:
            return ["Shoulders": shoulders]
        case .legs:
            return ["Legs": legs]
        case .core:
            return ["Core": core]
        }
    }
}