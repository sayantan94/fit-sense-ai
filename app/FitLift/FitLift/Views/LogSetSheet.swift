import SwiftUI

struct LogSetSheet: View {
    @Environment(\.dismiss) private var dismiss

    let exerciseName: String
    let setNumber: Int
    let previousWeight: Double?
    let previousReps: Int?

    @State private var weight: Double
    @State private var reps: Int

    let onSave: (Double, Int) -> Void

    init(
        exerciseName: String,
        setNumber: Int,
        previousWeight: Double?,
        previousReps: Int?,
        currentWeight: Double,
        currentReps: Int,
        onSave: @escaping (Double, Int) -> Void
    ) {
        self.exerciseName = exerciseName
        self.setNumber = setNumber
        self.previousWeight = previousWeight
        self.previousReps = previousReps
        self._weight = State(initialValue: currentWeight > 0 ? currentWeight : (previousWeight ?? 0))
        self._reps = State(initialValue: currentReps > 0 ? currentReps : (previousReps ?? 0))
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.white.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)

            // Title
            Text(exerciseName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Theme.textPrimary)

            Text("Set \(setNumber)")
                .font(.system(size: 15))
                .foregroundColor(Theme.textSecondary)
                .padding(.top, 4)
                .padding(.bottom, 30)

            // Input fields
            HStack(spacing: 40) {
                // Weight input
                VStack(spacing: 8) {
                    WeightInputBox(value: $weight)
                    Text("lbs")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textSecondary)
                }

                // Reps input
                VStack(spacing: 8) {
                    RepsInputBox(value: $reps)
                    Text("reps")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textSecondary)
                }
            }
            .padding(.bottom, 20)

            // Previous hint
            if let prevWeight = previousWeight, let prevReps = previousReps {
                Text("Previous: \(Int(prevWeight)) lbs × \(prevReps) reps")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textTertiary)
                    .padding(.bottom, 24)
            } else {
                Spacer().frame(height: 37)
            }

            // Save button
            Button(action: save) {
                Text("Save Set")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background(Color(hex: "1c1c1e"))
        .presentationDetents([.height(340)])
        .presentationDragIndicator(.hidden)
    }

    private func save() {
        onSave(weight, reps)
        dismiss()
    }
}

struct WeightInputBox: View {
    @Binding var value: Double
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            HStack(spacing: 4) {
                Button(action: { if value >= 5 { value -= 5 } }) {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.accent)
                }

                TextField("", value: $value, format: .number)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .frame(width: 60)

                Button(action: { value += 5 }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.accent)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .frame(width: 140, height: 80)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct RepsInputBox: View {
    @Binding var value: Int
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            HStack(spacing: 4) {
                Button(action: { if value > 0 { value -= 1 } }) {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.accent)
                }

                TextField("", value: $value, format: .number)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .frame(width: 50)

                Button(action: { value += 1 }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.accent)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .frame(width: 140, height: 80)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    LogSetSheet(
        exerciseName: "Bench Press",
        setNumber: 3,
        previousWeight: 135,
        previousReps: 8,
        currentWeight: 0,
        currentReps: 0
    ) { _, _ in }
    .preferredColorScheme(.dark)
}
