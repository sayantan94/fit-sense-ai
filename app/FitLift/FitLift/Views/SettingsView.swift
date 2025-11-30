import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [WorkoutSession]

    @State private var showingClearDataAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerView
                        statsSection
                        preferencesSection
                        dataSection
                        aboutSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
            .alert("Clear All Data?", isPresented: $showingClearDataAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will permanently delete all your workout history. This action cannot be undone.")
            }
        }
    }

    private var headerView: some View {
        Text("Settings")
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(Theme.textPrimary)
            .padding(.top, 20)
            .padding(.bottom, 8)
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("YOUR STATS")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.textSecondary)
                .tracking(1)

            VStack(spacing: 0) {
                StatRow(title: "Total Workouts", value: "\(totalWorkouts)")
                StatRow(title: "This Month", value: "\(workoutsThisMonth)")
                StatRow(title: "Total Time", value: totalTimeFormatted, isLast: true)
            }
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PREFERENCES")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.textSecondary)
                .tracking(1)

            VStack(spacing: 0) {
                SettingsRow(
                    icon: "scalemass",
                    title: "Weight Unit",
                    value: "lbs"
                )
                SettingsRow(
                    icon: "bell",
                    title: "Notifications",
                    value: "Off",
                    isLast: true
                )
            }
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DATA")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.textSecondary)
                .tracking(1)

            VStack(spacing: 0) {
                Button(action: {}) {
                    SettingsRow(
                        icon: "square.and.arrow.up",
                        title: "Export Data",
                        showChevron: true
                    )
                }
                .buttonStyle(.plain)

                Button(action: { showingClearDataAlert = true }) {
                    HStack {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                            .frame(width: 28)

                        Text("Clear All Data")
                            .font(.system(size: 16))
                            .foregroundColor(.red)

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
            }
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ABOUT")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.textSecondary)
                .tracking(1)

            VStack(spacing: 0) {
                SettingsRow(
                    icon: "info.circle",
                    title: "Version",
                    value: "1.0.0"
                )
                SettingsRow(
                    icon: "star",
                    title: "Rate App",
                    showChevron: true
                )
                SettingsRow(
                    icon: "envelope",
                    title: "Send Feedback",
                    showChevron: true,
                    isLast: true
                )
            }
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Computed Properties

    private var totalWorkouts: Int {
        sessions.filter { $0.isCompleted }.count
    }

    private var workoutsThisMonth: Int {
        let calendar = Calendar.current
        let now = Date()
        return sessions.filter { session in
            session.isCompleted && calendar.isDate(session.date, equalTo: now, toGranularity: .month)
        }.count
    }

    private var totalTimeFormatted: String {
        let totalMinutes = Int(sessions.reduce(0) { $0 + $1.duration }) / 60
        if totalMinutes < 60 {
            return "\(totalMinutes) min"
        } else {
            let hours = totalMinutes / 60
            let minutes = totalMinutes % 60
            return "\(hours)h \(minutes)m"
        }
    }

    private func clearAllData() {
        for session in sessions {
            modelContext.delete(session)
        }
        try? modelContext.save()
    }
}

struct StatRow: View {
    let title: String
    let value: String
    var isLast: Bool = false

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(Theme.textPrimary)

            Spacer()

            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Theme.accent)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .overlay(
            Group {
                if !isLast {
                    Divider()
                        .background(Theme.divider)
                }
            },
            alignment: .bottom
        )
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    var showChevron: Bool = false
    var isLast: Bool = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Theme.textSecondary)
                .frame(width: 28)

            Text(title)
                .font(.system(size: 16))
                .foregroundColor(Theme.textPrimary)

            Spacer()

            if let value = value {
                Text(value)
                    .font(.system(size: 16))
                    .foregroundColor(Theme.textSecondary)
            }

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textTertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .overlay(
            Group {
                if !isLast {
                    Divider()
                        .background(Theme.divider)
                }
            },
            alignment: .bottom
        )
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
