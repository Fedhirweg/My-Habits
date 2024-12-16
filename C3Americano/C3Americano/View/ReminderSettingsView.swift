import SwiftUI

struct ReminderSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HabitViewModel
    let habit: Habit
    
    @State private var isReminderEnabled: Bool
    @State private var reminderTime: Date
    @State private var selectedWeekday: Int
    @State private var selectedDayOfMonth: Int
    @State private var showingAuthAlert = false
    
    let weekdays = Calendar.current.weekdaySymbols
    let daysOfMonth = Array(1...31)
    
    init(habit: Habit, viewModel: HabitViewModel) {
        self.habit = habit
        self.viewModel = viewModel
        _isReminderEnabled = State(initialValue: habit.isReminderEnabled)
        _reminderTime = State(initialValue: habit.reminderTime ?? Date())
        _selectedWeekday = State(initialValue: habit.selectedWeekday ?? Calendar.current.component(.weekday, from: Date()))
        _selectedDayOfMonth = State(initialValue: habit.selectedDayOfMonth ?? Calendar.current.component(.day, from: Date()))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Enable Reminder", isOn: $isReminderEnabled)
                        .accessibilityLabel("Enable or disable reminder")
                    
                    if isReminderEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .accessibilityLabel("Select reminder time")
                        
                        if habit.frequency == "weekly" {
                            Picker("Day of Week", selection: $selectedWeekday) {
                                ForEach(0..<weekdays.count, id: \.self) { index in
                                    Text(weekdays[index])
                                        .tag(index + 1)
                                }
                            }
                            .accessibilityLabel("Select day of the week for reminder")
                        }
                        
                        if habit.frequency == "monthly" {
                            Picker("Day of Month", selection: $selectedDayOfMonth) {
                                ForEach(daysOfMonth, id: \.self) { day in
                                    Text("\(day)")
                                        .tag(day)
                                }
                            }
                            .accessibilityLabel("Select day of the month for reminder")
                        }
                    }
                } footer: {
                    switch habit.frequency {
                    case "daily":
                        Text("You will receive a notification every day at the specified time")
                    case "weekly":
                        Text("You will receive a notification every \(weekdays[selectedWeekday - 1]) at the specified time")
                    case "monthly":
                        Text("You will receive a notification on day \(selectedDayOfMonth) of each month at the specified time")
                    default:
                        Text("")
                    }
                }
            }
            .navigationTitle("Reminder Settings")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    saveReminder()
                }
            )
            .alert("Notifications Disabled", isPresented: $showingAuthAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Please enable notifications in Settings to use reminders")
            }
        }
    }
    
    private func saveReminder() {
        Task {
            do {
                let isAuthorized = try await NotificationManager.shared.requestAuthorization()
                if isAuthorized {
                    viewModel.updateHabitReminder(
                        habit,
                        isEnabled: isReminderEnabled,
                        reminderTime: isReminderEnabled ? reminderTime : nil,
                        selectedWeekday: habit.frequency == "weekly" ? selectedWeekday : nil,
                        selectedDayOfMonth: habit.frequency == "monthly" ? selectedDayOfMonth : nil
                    )
                    dismiss()
                } else {
                    showingAuthAlert = true
                }
            } catch {
                showingAuthAlert = true
            }
        }
    }
} 