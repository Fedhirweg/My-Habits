import SwiftUI

struct HabitDetailView: View {
    @Environment(\.dismiss) var dismiss
    let habit: Habit
    @ObservedObject var viewModel: HabitViewModel
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    @State private var showingReminderSettings = false
    @State private var updatedHabit: Habit?
    
    private var currentHabit: Habit {
        if let updated = updatedHabit {
            return updated
        }
        return viewModel.habits.first(where: { $0.id == habit.id }) ?? habit
    }
    
    private var completionsByMonth: [String: Int] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        return Dictionary(grouping: currentHabit.completedDates) { date in
            dateFormatter.string(from: date)
        }.mapValues { $0.count }
    }
    
    var body: some View {
        List {
            Section("Details") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(currentHabit.title)
                            .font(.title2)
                            .bold()
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.toggleHabitCompletion(habit: currentHabit)
                        }) {
                            Image(systemName: currentHabit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(currentHabit.isCompletedToday ? .green : .gray)
                                .imageScale(.large)
                        }
                        .accessibilityLabel(currentHabit.isCompletedToday ? "Mark as incomplete" : "Mark as complete")
                    }
                    
                    Text(currentHabit.description)
                        .foregroundColor(.gray)
                    
                    Text("Frequency: \(currentHabit.frequency.capitalized)")
                        .font(.subheadline)
                    
                    Text("Created: \(currentHabit.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                }
                .padding(.vertical, 8)
            }
            
            Section {
                HStack {
                    StreakView(title: "Current Streak", count: currentHabit.currentStreak)
                    Divider()
                    StreakView(title: "Longest Streak", count: currentHabit.longestStreak)
                }
                .frame(height: 100)
            }
            
            Section("Completion History") {
                ForEach(Array(completionsByMonth.keys.sorted().reversed()), id: \.self) { month in
                    HStack {
                        Text(month)
                        Spacer()
                        Text("\(completionsByMonth[month] ?? 0) times")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section("Recent Activity") {
                ForEach(currentHabit.completedDates.suffix(10).reversed(), id: \.self) { date in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(date.formatted(date: .abbreviated, time: .shortened))
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Completed on \(date.formatted(date: .complete, time: .shortened))")
                }
            }
            
            Section {
                Button {
                    showingEditSheet = true
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit Habit")
                    }
                }
                .accessibilityLabel("Edit habit")
                .accessibilityHint("Double tap to modify this habit's details")
                
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Habit")
                    }
                }
                .accessibilityLabel("Delete this habit")
                .accessibilityHint("Double tap to delete this habit permanently")
                
                Button {
                    showingReminderSettings = true
                } label: {
                    HStack {
                        Image(systemName: "bell")
                        Text("Reminder Settings")
                        
                        Spacer()
                        
                        if currentHabit.isReminderEnabled {
                            Text(currentHabit.reminderTime?.formatted(date: .omitted, time: .shortened) ?? "")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .accessibilityLabel("Reminder settings")
                .accessibilityHint("Set up daily reminders for this habit")
            }
        }
        .navigationTitle("Habit History")
        .sheet(isPresented: $showingEditSheet) {
            EditHabitView(habit: currentHabit, viewModel: viewModel)
        }
        .alert("Delete Habit", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteHabit(currentHabit)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this habit? This action cannot be undone.")
        }
        .sheet(isPresented: $showingReminderSettings) {
            ReminderSettingsView(habit: currentHabit, viewModel: viewModel)
        }
        .onChange(of: viewModel.habits) { oldValue, newValue in
            if let updated = newValue.first(where: { $0.id == habit.id }) {
                updatedHabit = updated
            }
        }
    }
}

struct StreakView: View {
    let title: String
    let count: Int
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("\(count)")
                .font(.system(size: 44, weight: .bold))
            
            Text("days")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(count) days")
    }
} 
