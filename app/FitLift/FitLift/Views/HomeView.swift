import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [WorkoutSession]
    @State private var selectedWorkoutType: WorkoutType?
    @State private var workoutManager = WorkoutManager.shared
    @State private var pendingWorkoutType: WorkoutType?
    @State private var showingWorkoutConflictAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        headerView

                        // Show active workout banner if one is in progress
                        if workoutManager.isWorkoutActive, let activeType = workoutManager.activeWorkoutType {
                            activeWorkoutBanner(type: activeType)
                        }

                        workoutCardsView
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(item: $selectedWorkoutType) { workoutType in
                ActiveWorkoutView(workoutType: workoutType)
            }
            .alert("Workout in Progress", isPresented: $showingWorkoutConflictAlert) {
                Button("Resume \(workoutManager.activeWorkoutType?.displayName ?? "Current")") {
                    selectedWorkoutType = workoutManager.activeWorkoutType
                }
                Button("Start \(pendingWorkoutType?.displayName ?? "New")", role: .destructive) {
                    workoutManager.cancelWorkout()
                    selectedWorkoutType = pendingWorkoutType
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You have an active \(workoutManager.activeWorkoutType?.displayName ?? "") workout. What would you like to do?")
            }
        }
    }

    private func activeWorkoutBanner(type: WorkoutType) -> some View {
        // Reference timerTick to trigger UI refresh
        let _ = workoutManager.timerTick
        return Button(action: {
            selectedWorkoutType = type
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Workout in Progress")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textSecondary)

                    Text("\(type.displayName) • \(workoutManager.formattedTime)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                }

                Spacer()

                Text("Resume")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(16)
            .background(type.color.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(type.color.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("FitLift")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Theme.textPrimary)

            Text(formattedDate)
                .font(.system(size: 15))
                .foregroundColor(Theme.textSecondary)
        }
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    private var workoutCardsView: some View {
        VStack(spacing: 16) {
            ForEach(WorkoutType.allCases) { workoutType in
                WorkoutCard(
                    workoutType: workoutType,
                    lastWorkout: lastWorkoutText(for: workoutType)
                ) {
                    handleWorkoutSelection(workoutType)
                }
            }
        }
    }

    private func handleWorkoutSelection(_ workoutType: WorkoutType) {
        if workoutManager.isWorkoutActive {
            if workoutManager.activeWorkoutType == workoutType {
                // Same workout type - just resume it
                selectedWorkoutType = workoutType
            } else {
                // Different workout type - show conflict alert
                pendingWorkoutType = workoutType
                showingWorkoutConflictAlert = true
            }
        } else {
            // No active workout - start new one
            selectedWorkoutType = workoutType
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    private func lastWorkoutText(for type: WorkoutType) -> String {
        let typeSessions = sessions.filter {
            $0.workout?.type == type && $0.isCompleted
        }.sorted { $0.date > $1.date }

        guard let lastSession = typeSessions.first else {
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

struct WorkoutCard: View {
    let workoutType: WorkoutType
    let lastWorkout: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(workoutType.displayName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Theme.textPrimary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.textTertiary)
                    }

                    Text(workoutType.muscles)
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textSecondary)

                    Text("Last workout: \(lastWorkout)")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textTertiary)
                }

                Spacer()
            }
            .padding(20)
            .background(Theme.cardBackgroundGradient)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Theme.cardBorder, lineWidth: 1)
            )
            .overlay(
                Rectangle()
                    .fill(workoutType.color)
                    .frame(width: 4)
                    .clipShape(RoundedRectangle(cornerRadius: 2)),
                alignment: .leading
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
