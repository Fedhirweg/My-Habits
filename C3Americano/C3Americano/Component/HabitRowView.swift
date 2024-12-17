import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let viewModel: HabitViewModel
    
    var body: some View {
        NavigationLink(destination: HabitDetailView(habit: habit, viewModel: viewModel)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(habit.title)
                        .font(.headline)
                    Text(habit.description)
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(.gray)
                    Text("Frequency: \(habit.frequency)")
                        .font(.caption)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.toggleHabitCompletion(habit: habit)
                }) {
                    Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(
                            habit.isCompletedToday ? Color(.customgreen) : .gray
                        )
                        .imageScale(.large)
                }
                .buttonStyle(BorderlessButtonStyle())
                .accessibilityLabel(habit.isCompletedToday ? "Mark \(habit.title) as incomplete" : "Mark \(habit.title) as complete")
            }
            .padding(.vertical, 8)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(habit.title), \(habit.frequency) habit")
            .accessibilityHint("Double tap to view details")
            .accessibilityValue(habit.description)
        }
    }
} 

#Preview {
    HabitRowView(habit: Habit.example, viewModel: HabitViewModel())
}
