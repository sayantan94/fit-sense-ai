//
//  WorkoutManager.swift
//  FitLift
//
//  Created by Sayantan <sayantanbhow@gmail.com>
//

import SwiftUI
import SwiftData

@Observable
class WorkoutManager {
    static let shared = WorkoutManager()

    var isWorkoutActive: Bool = false
    var activeWorkoutType: WorkoutType?
    var exercises: [ActiveExercise] = []
    var elapsedTime: TimeInterval = 0
    var startTime: Date?

    private var timer: Timer?

    private init() {}

    func startWorkout(type: WorkoutType) {
        activeWorkoutType = type
        isWorkoutActive = true
        startTime = Date()
        elapsedTime = 0

        // Setup default exercises
        let defaultNames = type.defaultExercises.prefix(3)
        exercises = defaultNames.map { ActiveExercise(name: $0) }

        startTimer()
    }

    func resumeWorkout() {
        if isWorkoutActive {
            startTimer()
        }
    }

    func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
        }
    }

    func addExercise(name: String) {
        exercises.append(ActiveExercise(name: name))
    }

    func addSet(exerciseIndex: Int) {
        guard exerciseIndex < exercises.count else { return }
        let newSetNumber = exercises[exerciseIndex].sets.count + 1
        exercises[exerciseIndex].sets.append(ActiveSet(setNumber: newSetNumber))
    }

    func updateSet(exerciseIndex: Int, setIndex: Int, weight: Double, reps: Int) {
        guard exerciseIndex < exercises.count,
              setIndex < exercises[exerciseIndex].sets.count else { return }

        exercises[exerciseIndex].sets[setIndex].weight = weight
        exercises[exerciseIndex].sets[setIndex].reps = reps
        exercises[exerciseIndex].sets[setIndex].isCompleted = true
    }

    func saveWorkout(modelContext: ModelContext) {
        guard activeWorkoutType != nil else { return }

        // Stop timer first
        timer?.invalidate()
        timer = nil

        // Save workout to SwiftData on background to avoid UI freeze
        let workoutType = activeWorkoutType!
        let duration = elapsedTime
        let workoutStartTime = startTime ?? Date()
        let exercisesCopy = exercises.map { exercise in
            (name: exercise.name, sets: exercise.sets.filter { $0.isCompleted }.map { (weight: $0.weight, reps: $0.reps, setNumber: $0.setNumber) })
        }

        // Reset state immediately so UI can update
        resetState()

        // Then save in background
        Task { @MainActor in
            let workout = Workout(type: workoutType)
            modelContext.insert(workout)

            let session = WorkoutSession(date: workoutStartTime)
            session.duration = duration
            session.isCompleted = true
            modelContext.insert(session)
            session.workout = workout

            for exerciseData in exercisesCopy {
                let exercise = Exercise(name: exerciseData.name, muscleGroup: "")
                modelContext.insert(exercise)

                for setData in exerciseData.sets {
                    let workoutSet = WorkoutSet(
                        setNumber: setData.setNumber,
                        weight: setData.weight,
                        reps: setData.reps,
                        isCompleted: true
                    )
                    modelContext.insert(workoutSet)
                    workoutSet.exercise = exercise
                    workoutSet.session = session
                }
            }
        }
    }

    private func resetState() {
        isWorkoutActive = false
        activeWorkoutType = nil
        exercises = []
        elapsedTime = 0
        startTime = nil
    }

    func cancelWorkout() {
        timer?.invalidate()
        timer = nil
        isWorkoutActive = false
        activeWorkoutType = nil
        exercises = []
        elapsedTime = 0
        startTime = nil
    }

    var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
