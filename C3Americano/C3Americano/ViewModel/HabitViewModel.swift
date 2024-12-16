import Foundation
import Firebase
import FirebaseAuth

class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var errorMessage: String?
    
    var habitsByFrequency: [String: [Habit]] {
        Dictionary(grouping: habits) { $0.frequency }
    }
    
    func fetchUserHabits() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("habits")
            .whereField("userId", isEqualTo: uid)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                self.habits = snapshot?.documents.compactMap { document in
                    try? document.data(as: Habit.self)
                } ?? []
            }
    }
    
    func deleteHabit(_ habit: Habit) {
        guard let habitId = habit.id else { return }
        
        Firestore.firestore().collection("habits").document(habitId).delete { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func addHabit(title: String, description: String, frequency: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let habit = Habit(
            userId: uid,
            title: title,
            description: description,
            frequency: frequency,
            completedDates: [],
            createdAt: Date(),
            reminderTime: nil,
            isReminderEnabled: false
        )
        
        do {
            let _ = try Firestore.firestore().collection("habits").addDocument(from: habit)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func toggleHabitCompletion(habit: Habit) {
        guard let habitId = habit.id else { return }
        var updatedDates = habit.completedDates
        
        if habit.isCompletedToday {
            updatedDates.removeAll { Calendar.current.isDate($0, inSameDayAs: Date()) }
        } else {
            updatedDates.append(Date())
        }
        
        Firestore.firestore().collection("habits").document(habitId).updateData([
            "completedDates": updatedDates.map { Timestamp(date: $0) }
        ])
    }
    
    func updateHabit(_ habit: Habit, title: String, description: String, frequency: String) {
        guard let habitId = habit.id else { return }
        
        var updatedData: [String: Any] = [
            "title": title,
            "description": description,
            "frequency": frequency
        ]
        
        if frequency != habit.frequency {
            updatedData["selectedWeekday"] = FieldValue.delete()
            updatedData["selectedDayOfMonth"] = FieldValue.delete()
            
            if habit.isReminderEnabled {
                updatedData["isReminderEnabled"] = false
                NotificationManager.shared.cancelHabitReminder(habitId: habitId)
            }
        }
        
        Firestore.firestore().collection("habits").document(habitId).updateData(updatedData) { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            
            if frequency != habit.frequency && habit.isReminderEnabled {
                self?.errorMessage = "Please reconfigure your reminders for the updated frequency"
            }
        }
    }
    
    func updateHabitReminder(_ habit: Habit, isEnabled: Bool, reminderTime: Date?, selectedWeekday: Int? = nil, selectedDayOfMonth: Int? = nil) {
        guard let habitId = habit.id else { return }
        
        var updatedData: [String: Any] = [
            "isReminderEnabled": isEnabled
        ]
        
        var updatedHabit = habit
        updatedHabit.isReminderEnabled = isEnabled
        updatedHabit.reminderTime = reminderTime
        updatedHabit.selectedWeekday = selectedWeekday
        updatedHabit.selectedDayOfMonth = selectedDayOfMonth
        
        if let time = reminderTime {
            updatedData["reminderTime"] = Timestamp(date: time)
        } else {
            updatedData["reminderTime"] = FieldValue.delete()
        }
        
        updatedData["selectedWeekday"] = selectedWeekday
        updatedData["selectedDayOfMonth"] = selectedDayOfMonth
        
        Firestore.firestore().collection("habits").document(habitId).updateData(updatedData) { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            
            if isEnabled, let _ = reminderTime {
                Task {
                    do {
                        let isAuthorized = try await NotificationManager.shared.requestAuthorization()
                        if isAuthorized {
                            NotificationManager.shared.scheduleHabitReminder(habit: updatedHabit)
                        }
                    } catch {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            } else {
                NotificationManager.shared.cancelHabitReminder(habitId: habitId)
            }
        }
    }
} 
