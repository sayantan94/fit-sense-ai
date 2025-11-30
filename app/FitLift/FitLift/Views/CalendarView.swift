import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [WorkoutSession]

    @State private var currentMonth = Date()
    @State private var selectedDate = Date()

    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        headerView
                        streakCard
                        calendarHeader
                        weekdaysHeader
                        calendarGrid
                        selectedDayWorkouts
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var headerView: some View {
        Text("Calendar")
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(Theme.textPrimary)
            .padding(.top, 20)
            .padding(.bottom, 8)
    }

    private var streakCard: some View {
        HStack(spacing: 16) {
            Text("🔥")
                .font(.system(size: 32))

            VStack(alignment: .leading, spacing: 2) {
                Text("\(currentStreak) days")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.accent)

                Text("Current workout streak")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Theme.accent.opacity(0.2), Theme.accent.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var calendarHeader: some View {
        HStack {
            Text(monthYearString)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Theme.textPrimary)

            Spacer()

            HStack(spacing: 16) {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.accent)
                        .frame(width: 36, height: 36)
                        .background(Theme.accent.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.accent)
                        .frame(width: 36, height: 36)
                        .background(Theme.accent.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(.top, 8)
    }

    private var weekdaysHeader: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
            ForEach(daysOfWeek, id: \.self) { day in
                Text(day)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
            ForEach(daysInMonth(), id: \.self) { date in
                CalendarDayCell(
                    date: date,
                    isCurrentMonth: isCurrentMonth(date),
                    isToday: calendar.isDateInToday(date),
                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                    workoutType: workoutType(for: date)
                )
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
    }

    private var selectedDayWorkouts: some View {
        let dayWorkouts = workoutsForSelectedDate

        return VStack(alignment: .leading, spacing: 12) {
            Text(formattedSelectedDate)
                .font(.system(size: 14))
                .foregroundColor(Theme.textSecondary)

            if dayWorkouts.isEmpty {
                Text("No workouts on this day")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(dayWorkouts, id: \.id) { session in
                    if let workout = session.workout {
                        CalendarWorkoutRow(session: session, workoutType: workout.type)
                    }
                }
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.top, 8)
    }

    // MARK: - Helper Properties & Methods

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: selectedDate)
    }

    private var workoutsForSelectedDate: [WorkoutSession] {
        sessions.filter { session in
            calendar.isDate(session.date, inSameDayAs: selectedDate) && session.isCompleted
        }
    }

    private var currentStreak: Int {
        var streak = 0
        var checkDate = Date()

        // Check if today has a workout, if not start from yesterday
        let todayWorkouts = sessions.filter { calendar.isDateInToday($0.date) && $0.isCompleted }
        if todayWorkouts.isEmpty {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }

        while true {
            let dayWorkouts = sessions.filter { session in
                calendar.isDate(session.date, inSameDayAs: checkDate) && session.isCompleted
            }

            if dayWorkouts.isEmpty {
                break
            }

            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }

        return streak
    }

    private func daysInMonth() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else { return [] }

        var dates: [Date] = []
        var currentDate = monthFirstWeek.start

        while currentDate < monthLastWeek.end {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return dates
    }

    private func isCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }

    private func workoutType(for date: Date) -> WorkoutType? {
        sessions.first { session in
            calendar.isDate(session.date, inSameDayAs: date) && session.isCompleted
        }?.workout?.type
    }

    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }

    private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
}

struct CalendarDayCell: View {
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    let workoutType: WorkoutType?

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16))
                .foregroundColor(textColor)

            if let type = workoutType {
                Circle()
                    .fill(type.color)
                    .frame(width: 8, height: 8)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 8, height: 8)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isToday ? Theme.accent : Color.clear, lineWidth: 2)
        )
    }

    private var textColor: Color {
        if !isCurrentMonth {
            return Theme.textPrimary.opacity(0.2)
        }
        return Theme.textPrimary
    }

    private var backgroundColor: Color {
        if isSelected {
            return Theme.accent.opacity(0.2)
        }
        if workoutType != nil {
            return Color.white.opacity(0.08)
        }
        return Color.clear
    }
}

struct CalendarWorkoutRow: View {
    let session: WorkoutSession
    let workoutType: WorkoutType
    @State private var isExpanded = false

    private var exerciseSummaries: [(name: String, sets: [WorkoutSet])] {
        guard let sets = session.sets else { return [] }

        var exerciseDict: [String: [WorkoutSet]] = [:]
        for set in sets {
            let name = set.exercise?.name ?? "Unknown"
            if exerciseDict[name] == nil {
                exerciseDict[name] = []
            }
            exerciseDict[name]?.append(set)
        }

        return exerciseDict.map { (name: $0.key, sets: $0.value.sorted { $0.setNumber < $1.setNumber }) }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() } }) {
                HStack(spacing: 12) {
                    Text(workoutType.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(workoutType.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(workoutType.color.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(workoutType.displayName)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Theme.textPrimary)

                        Text("\(session.exerciseCount) exercises · \(session.formattedDuration)")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textTertiary)
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .background(Theme.divider)

                    if exerciseSummaries.isEmpty {
                        Text("No exercise data recorded")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textTertiary)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(exerciseSummaries, id: \.name) { exercise in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(exercise.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Theme.textPrimary)

                                ForEach(exercise.sets, id: \.id) { set in
                                    HStack {
                                        Text("Set \(set.setNumber)")
                                            .font(.system(size: 13))
                                            .foregroundColor(Theme.textTertiary)
                                            .frame(width: 50, alignment: .leading)

                                        Text(set.formattedWeight)
                                            .font(.system(size: 13))
                                            .foregroundColor(Theme.textSecondary)
                                            .frame(width: 80, alignment: .leading)

                                        Text("\(set.reps) reps")
                                            .font(.system(size: 13))
                                            .foregroundColor(Theme.textSecondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding(.leading, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

#Preview {
    CalendarView()
        .preferredColorScheme(.dark)
}
