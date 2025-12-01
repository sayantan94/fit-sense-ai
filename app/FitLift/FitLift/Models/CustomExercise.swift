//
//  CustomExercise.swift
//  FitLift
//
//  Created by Sayantan <sayantanbhow@gmail.com>
//

import Foundation
import SwiftData

@Model
final class CustomExercise {
    var id: UUID
    var name: String
    var workoutTypeRaw: String
    var createdAt: Date

    var workoutType: WorkoutType {
        get { WorkoutType(rawValue: workoutTypeRaw) ?? .push }
        set { workoutTypeRaw = newValue.rawValue }
    }

    init(name: String, workoutType: WorkoutType) {
        self.id = UUID()
        self.name = name
        self.workoutTypeRaw = workoutType.rawValue
        self.createdAt = Date()
    }
}
