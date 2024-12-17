import SwiftUI

struct EditHabitView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitViewModel
    let habit: Habit
    
    @State private var title: String
    @State private var description: String
    @State private var frequency: String
    @State private var showingReminderAlert = false
    
    let frequencies = ["daily", "weekly", "monthly"]
    
    init(habit: Habit, viewModel: HabitViewModel) {
        self.habit = habit
        self.viewModel = viewModel
        _title = State(initialValue: habit.title)
        _description = State(initialValue: habit.description)
        _frequency = State(initialValue: habit.frequency)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Habit Details") {
                    TextField("Title", text: $title)
                        .accessibilityLabel("Habit title")
                        .accessibilityHint("Edit the name of your habit")
                        
                    TextField("Description", text: $description)
                        .accessibilityLabel("Habit description")
                        .accessibilityHint("Edit the description of your habit")
                        
                    Picker("Frequency", selection: $frequency) {
                        ForEach(frequencies, id: \.self) {
                            Text($0.capitalized)
                                .accessibilityLabel("\($0) frequency")
                        }
                    }
                    .onChange(of: frequency) { oldValue, newValue in
                        if newValue != habit.frequency && habit.isReminderEnabled {
                            showingReminderAlert = true
                        }
                    }
                }
            }
            .navigationTitle("Edit Habit")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    viewModel.updateHabit(
                        habit,
                        title: title,
                        description: description,
                        frequency: frequency
                    )
                    dismiss()
                }
                .disabled(title.isEmpty)
            )
            .alert("Reminder Settings", isPresented: $showingReminderAlert) {
                Button("OK") { }
            } message: {
                Text("Changing the frequency will reset your reminder settings. You'll need to set up reminders again after saving.")
            }
        }
    }
} 

#Preview {
    EditHabitView(habit: Habit.example, viewModel: HabitViewModel())
}
