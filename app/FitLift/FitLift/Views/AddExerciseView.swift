import SwiftUI
import SwiftData

struct AddExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allCustomExercises: [CustomExercise]

    let workoutType: WorkoutType
    let onAdd: (String) -> Void

    @State private var searchText = ""
    @State private var selectedExercises: Set<String> = []
    @State private var showingCustomExercise = false
    @State private var customExerciseName = ""

    private var customExercisesForType: [String] {
        allCustomExercises
            .filter { $0.workoutType == workoutType }
            .map { $0.name }
            .sorted()
    }

    private var exercises: [String: [String]] {
        var base = ExerciseDatabase.exercises(for: workoutType)
        if !customExercisesForType.isEmpty {
            base["Custom"] = customExercisesForType
        }
        return base
    }

    private var filteredExercises: [String: [String]] {
        if searchText.isEmpty {
            return exercises
        }

        var filtered: [String: [String]] = [:]
        for (category, exerciseList) in exercises {
            let matchingExercises = exerciseList.filter {
                $0.localizedCaseInsensitiveContains(searchText)
            }
            if !matchingExercises.isEmpty {
                filtered[category] = matchingExercises
            }
        }
        return filtered
    }

    // Sort categories with "Custom" at the end
    private var sortedCategories: [String] {
        let keys = filteredExercises.keys.sorted()
        if let customIndex = keys.firstIndex(of: "Custom") {
            var sorted = keys
            sorted.remove(at: customIndex)
            sorted.append("Custom")
            return sorted
        }
        return keys
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    navigationBar
                    searchBar

                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(sortedCategories, id: \.self) { category in
                                categorySection(category: category)
                            }

                            createCustomButton
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCustomExercise) {
                CustomExerciseSheet(
                    exerciseName: $customExerciseName,
                    onAdd: {
                        let name = customExerciseName.trimmingCharacters(in: .whitespaces)
                        if !name.isEmpty {
                            // Save to database for future use
                            let customExercise = CustomExercise(name: name, workoutType: workoutType)
                            modelContext.insert(customExercise)

                            // Also select it for current workout
                            selectedExercises.insert(name)
                            customExerciseName = ""
                        }
                        showingCustomExercise = false
                    },
                    onCancel: {
                        customExerciseName = ""
                        showingCustomExercise = false
                    }
                )
                .presentationDetents([.height(200)])
                .presentationDragIndicator(.visible)
            }
            .preferredColorScheme(.dark)
        }
    }

    private var navigationBar: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .font(.system(size: 16))
            .foregroundColor(Theme.accent)

            Spacer()

            Text("Add Exercise")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Theme.textPrimary)

            Spacer()

            Button("Done") {
                for exercise in selectedExercises {
                    onAdd(exercise)
                }
                dismiss()
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(selectedExercises.isEmpty ? Theme.textTertiary : Theme.accent)
            .disabled(selectedExercises.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(Theme.textTertiary)

            TextField("Search exercises...", text: $searchText)
                .font(.system(size: 16))
                .foregroundColor(Theme.textPrimary)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.textTertiary)
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private func categorySection(category: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(category.uppercased())
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.textSecondary)
                .tracking(1)
                .padding(.vertical, 16)

            ForEach(filteredExercises[category] ?? [], id: \.self) { exercise in
                ExerciseRow(
                    name: exercise,
                    isSelected: selectedExercises.contains(exercise)
                ) {
                    if selectedExercises.contains(exercise) {
                        selectedExercises.remove(exercise)
                    } else {
                        selectedExercises.insert(exercise)
                    }
                }
            }
        }
    }

    private var createCustomButton: some View {
        Button(action: { showingCustomExercise = true }) {
            HStack {
                Image(systemName: "plus")
                Text("Create Custom Exercise")
            }
            .font(.system(size: 16))
            .foregroundColor(Theme.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.top, 20)
    }
}

struct ExerciseRow: View {
    let name: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(name)
                    .font(.system(size: 16))
                    .foregroundColor(Theme.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.accent)
                }
            }
            .padding(.vertical, 14)
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

struct CustomExerciseSheet: View {
    @Binding var exerciseName: String
    let onAdd: () -> Void
    let onCancel: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Custom Exercise")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)

                TextField("Exercise name", text: $exerciseName)
                    .font(.system(size: 16))
                    .foregroundColor(Theme.textPrimary)
                    .padding(14)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .focused($isFocused)

                HStack(spacing: 12) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .font(.system(size: 16))
                    .foregroundColor(Theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button("Add") {
                        onAdd()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(20)
        }
        .onAppear {
            isFocused = true
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    AddExerciseView(workoutType: .push) { _ in }
        .preferredColorScheme(.dark)
}
