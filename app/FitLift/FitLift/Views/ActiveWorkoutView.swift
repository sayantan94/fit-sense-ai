//
//  ActiveWorkoutView.swift
//  FitLift
//
//  Created by Sayantan <sayantanbhow@gmail.com>
//

import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let workoutType: WorkoutType

    @State private var workoutManager = WorkoutManager.shared
    @State private var showingAddExercise = false
    @State private var showingLogSet = false
    @State private var selectedExerciseIndex: Int?
    @State private var selectedSetIndex: Int?
    @State private var showingFinishAlert = false
    @State private var showingCancelAlert = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                navigationBar
                timerView

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(workoutManager.exercises.enumerated()), id: \.element.id) { index, exercise in
                            ExerciseBlock(
                                exercise: Binding(
                                    get: {
                                        guard index < workoutManager.exercises.count else {
                                            return ActiveExercise(name: "")
                                        }
                                        return workoutManager.exercises[index]
                                    },
                                    set: {
                                        guard index < workoutManager.exercises.count else { return }
                                        workoutManager.exercises[index] = $0
                                    }
                                ),
                                onSetTap: { setIndex in
                                    selectedExerciseIndex = index
                                    selectedSetIndex = setIndex
                                    showingLogSet = true
                                },
                                onAddSet: {
                                    workoutManager.addSet(exerciseIndex: index)
                                }
                            )
                        }

                        addExerciseButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            if !workoutManager.isWorkoutActive {
                workoutManager.startWorkout(type: workoutType)
            } else {
                workoutManager.resumeWorkout()
            }
        }
        .onDisappear {
            workoutManager.pauseTimer()
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView(workoutType: workoutType) { exerciseName in
                workoutManager.addExercise(name: exerciseName)
            }
        }
        .sheet(isPresented: $showingLogSet) {
            if let exerciseIndex = selectedExerciseIndex,
               let setIndex = selectedSetIndex,
               exerciseIndex < workoutManager.exercises.count,
               setIndex < workoutManager.exercises[exerciseIndex].sets.count {
                LogSetSheet(
                    exerciseName: workoutManager.exercises[exerciseIndex].name,
                    setNumber: setIndex + 1,
                    previousWeight: getPreviousWeight(exerciseIndex: exerciseIndex, setIndex: setIndex),
                    previousReps: getPreviousReps(exerciseIndex: exerciseIndex, setIndex: setIndex),
                    currentWeight: workoutManager.exercises[exerciseIndex].sets[setIndex].weight,
                    currentReps: workoutManager.exercises[exerciseIndex].sets[setIndex].reps
                ) { weight, reps in
                    workoutManager.updateSet(exerciseIndex: exerciseIndex, setIndex: setIndex, weight: weight, reps: reps)
                }
            }
        }
        .alert("Finish Workout?", isPresented: $showingFinishAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Finish") {
                workoutManager.saveWorkout(modelContext: modelContext)
                dismiss()
            }
        } message: {
            Text("Save this workout session?")
        }
        .alert("Cancel Workout?", isPresented: $showingCancelAlert) {
            Button("Keep Going", role: .cancel) {}
            Button("Discard", role: .destructive) {
                workoutManager.cancelWorkout()
                dismiss()
            }
        } message: {
            Text("Your workout progress will be lost.")
        }
        .preferredColorScheme(.dark)
    }

    private var navigationBar: some View {
        HStack {
            Button("Back") {
                // Just dismiss - workout stays active in background
                dismiss()
            }
            .font(.system(size: 16))
            .foregroundColor(Theme.accent)

            Spacer()

            Text(workoutType.displayName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Theme.textPrimary)

            Spacer()

            Button("Done") {
                showingFinishAlert = true
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(Theme.accent)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private var timerView: some View {
        // Reference timerTick to trigger UI refresh every second
        let _ = workoutManager.timerTick
        return Text(workoutManager.formattedTime)
            .font(.system(size: 28, weight: .semibold))
            .foregroundColor(Theme.textPrimary)
            .monospacedDigit()
            .padding(.bottom, 20)
    }

    private var addExerciseButton: some View {
        Button(action: { showingAddExercise = true }) {
            HStack {
                Image(systemName: "plus")
                Text("Add Exercise")
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(Theme.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Theme.accent.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Theme.accent.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [8]))
            )
        }
    }

    private func getPreviousWeight(exerciseIndex: Int, setIndex: Int) -> Double? {
        guard exerciseIndex < workoutManager.exercises.count,
              setIndex > 0,
              setIndex - 1 < workoutManager.exercises[exerciseIndex].sets.count else {
            return nil
        }
        return workoutManager.exercises[exerciseIndex].sets[setIndex - 1].weight
    }

    private func getPreviousReps(exerciseIndex: Int, setIndex: Int) -> Int? {
        guard exerciseIndex < workoutManager.exercises.count,
              setIndex > 0,
              setIndex - 1 < workoutManager.exercises[exerciseIndex].sets.count else {
            return nil
        }
        return workoutManager.exercises[exerciseIndex].sets[setIndex - 1].reps
    }
}

struct ActiveExercise: Identifiable {
    let id = UUID()
    var name: String
    var sets: [ActiveSet]

    init(name: String) {
        self.name = name
        self.sets = [
            ActiveSet(setNumber: 1),
            ActiveSet(setNumber: 2),
            ActiveSet(setNumber: 3)
        ]
    }
}

struct ActiveSet: Identifiable {
    let id = UUID()
    var setNumber: Int
    var weight: Double = 0
    var reps: Int = 0
    var isCompleted: Bool = false

    var formattedWeight: String {
        if weight == 0 { return "-" }
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(weight)) lbs"
        }
        return String(format: "%.1f lbs", weight)
    }
}

struct ExerciseBlock: View {
    @Binding var exercise: ActiveExercise
    let onSetTap: (Int) -> Void
    let onAddSet: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(exercise.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)

                Spacer()

                Image(systemName: "pencil")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textTertiary)
            }

            // Headers
            HStack {
                Text("SET")
                    .frame(width: 50, alignment: .leading)
                Text("WEIGHT")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("REPS")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("")
                    .frame(width: 40)
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(Theme.textSecondary)
            .textCase(.uppercase)
            .tracking(0.5)
            .padding(.top, 4)

            // Set rows
            ForEach(exercise.sets.indices, id: \.self) { index in
                SetRow(
                    set: exercise.sets[index],
                    onTap: { onSetTap(index) }
                )
            }

            // Add set button
            Button(action: onAddSet) {
                Text("+ Add Set")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct SetRow: View {
    let set: ActiveSet
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text("\(set.setNumber)")
                    .frame(width: 50, alignment: .leading)
                    .foregroundColor(Theme.textSecondary)

                Text(set.formattedWeight)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Theme.textPrimary)

                Text(set.reps > 0 ? "\(set.reps)" : "-")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Theme.textPrimary)

                Image(systemName: set.isCompleted ? "checkmark" : "circle")
                    .frame(width: 40)
                    .foregroundColor(set.isCompleted ? Theme.accent : Theme.textTertiary)
            }
            .font(.system(size: 16, weight: .medium))
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(
            Divider()
                .background(Theme.divider),
            alignment: .bottom
        )
    }
}

#Preview {
    ActiveWorkoutView(workoutType: .push)
        .preferredColorScheme(.dark)
}
