import SwiftUI

struct HabitDetailView: View {
    @Environment(\.dismiss) var dismiss
    let habit: Habit
    @ObservedObject var viewModel: HabitViewModel
    @State private var showingDeleteAlert = false
    
    private var completionsByMonth: [String: Int] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        return Dictionary(grouping: habit.completedDates) { date in
            dateFormatter.string(from: date)
        }.mapValues { $0.count }
    }
    
    var body: some View {
        List {
            Section("Details") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(habit.title)
                            .font(.title2)
                            .bold()
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.toggleHabitCompletion(habit: habit)
                        }) {
                            Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(habit.isCompletedToday ? .green : .gray)
                                .imageScale(.large)
                        }
                        .accessibilityLabel(habit.isCompletedToday ? "Mark as incomplete" : "Mark as complete")
                    }
                    
                    Text(habit.description)
                        .foregroundColor(.gray)
                    
                    Text("Frequency: \(habit.frequency.capitalized)")
                        .font(.subheadline)
                    
                    Text("Created: \(habit.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                }
                .padding(.vertical, 8)
            }
            
            Section {
                HStack {
                    StreakView(title: "Current Streak", count: habit.currentStreak)
                    Divider()
                    StreakView(title: "Longest Streak", count: habit.longestStreak)
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
                ForEach(habit.completedDates.suffix(10).reversed(), id: \.self) { date in
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
            }
        }
        .navigationTitle("Habit History")
        .alert("Delete Habit", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteHabit(habit)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this habit? This action cannot be undone.")
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