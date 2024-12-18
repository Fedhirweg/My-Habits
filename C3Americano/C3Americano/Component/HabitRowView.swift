import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let viewModel: HabitViewModel
    
    private var completionImage: String {
        habit.isCompleted ? "checkmark.circle.fill" : "circle"
    }
    
    private var completionColor: Color {
        habit.isCompleted ? Color(.customgreen) : .gray
    }
    
    var body: some View {
        NavigationLink {
            HabitDetailView(habit: habit, viewModel: viewModel)
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(habit.title)
                        .font(.headline)
                    Text(habit.description)
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(.gray)
                    //Text("Frequency: \(habit.frequency)")
                      //  .font(.caption)
                }
                
                Spacer()
                
                Button {
                    viewModel.toggleHabitCompletion(habit: habit)
                } label: {
                    Image(systemName: completionImage)
                        .foregroundColor(completionColor)
                        .imageScale(.large)
                }
                .buttonStyle(.borderless)
            }
            .padding(.vertical, 8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(habit.title), \(habit.frequency) habit")
        .accessibilityHint("Double tap to view details")
        .accessibilityValue(habit.description)
    }
}

#Preview {
    HabitRowView(habit: Habit.example, viewModel: HabitViewModel())
}
