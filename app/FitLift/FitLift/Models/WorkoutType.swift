import SwiftUI

enum WorkoutType: String, Codable, CaseIterable, Identifiable {
    case push = "Push"
    case pull = "Pull"
    case shoulders = "Shoulders"
    case legs = "Legs"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .push: return "Push Day"
        case .pull: return "Pull Day"
        case .shoulders: return "Shoulders"
        case .legs: return "Legs"
        }
    }

    var muscles: String {
        switch self {
        case .push: return "Chest · Triceps · Front Delts"
        case .pull: return "Back · Biceps · Rear Delts"
        case .shoulders: return "Lateral · Front · Rear"
        case .legs: return "Quads · Hamstrings · Calves"
        }
    }

    var color: Color {
        switch self {
        case .push: return Theme.push
        case .pull: return Theme.pull
        case .shoulders: return Theme.shoulders
        case .legs: return Theme.legs
        }
    }

    var defaultExercises: [String] {
        switch self {
        case .push:
            return ["Bench Press", "Incline Dumbbell Press", "Cable Flyes", "Tricep Pushdown", "Overhead Tricep Extension"]
        case .pull:
            return ["Deadlift", "Barbell Row", "Lat Pulldown", "Face Pulls", "Barbell Curl", "Hammer Curl"]
        case .shoulders:
            return ["Overhead Press", "Lateral Raises", "Front Raises", "Rear Delt Flyes", "Shrugs"]
        case .legs:
            return ["Squat", "Romanian Deadlift", "Leg Press", "Leg Curl", "Leg Extension", "Calf Raises"]
        }
    }
}