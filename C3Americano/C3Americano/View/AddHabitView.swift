import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var frequency = "daily"
    
    let frequencies = ["daily", "weekly", "monthly"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Habit Details") {
                    TextField("Title", text: $title)
                        .accessibilityLabel("Habit title")
                        .accessibilityHint("Enter the name of your new habit")
                        
                    TextField("Description", text: $description)
                        .accessibilityLabel("Habit description")
                        .accessibilityHint("Enter a description of your habit")
                        
                    Picker("Frequency", selection: $frequency) {
                        ForEach(frequencies, id: \.self) {
                            Text($0.capitalized)
                                .accessibilityLabel("\($0) frequency")
                        }
                    }
                    .accessibilityLabel("Habit frequency")
                    .accessibilityHint("Choose how often you want to perform this habit")
                }
            }
            .navigationTitle("Add New Habit")
            .navigationBarItems(
                leading: Button("Cancel") { 
                    dismiss() 
                }
                .accessibilityLabel("Cancel adding habit"),
                trailing: Button("Save") {
                    viewModel.addHabit(
                        title: title,
                        description: description,
                        frequency: frequency
                    )
                    dismiss()
                }
                .disabled(title.isEmpty)
                .accessibilityLabel("Save new habit")
                .accessibilityHint(title.isEmpty ? "Enter a title to enable saving" : "Save this new habit")
            )
        }
    }
} 

#Preview {
    AddHabitView(viewModel: HabitViewModel())
}
