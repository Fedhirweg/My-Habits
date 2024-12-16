import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        return try await UNUserNotificationCenter.current().requestAuthorization(options: options)
    }
    
    func scheduleHabitReminder(habit: Habit) {
        guard let reminderTime = habit.reminderTime,
              let habitId = habit.id,
              habit.isReminderEnabled else {
            print("Invalid reminder settings for habit: \(habit.title)")
            return
        }
        
        // Remove any existing notifications for this habit
        cancelHabitReminder(habitId: habitId)
        
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = "Time to complete your habit: \(habit.title)"
        content.sound = .default
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        // Add additional components based on frequency
        switch habit.frequency {
        case "weekly":
            // Get the current weekday and set it for the trigger
            let weekday = calendar.component(.weekday, from: reminderTime)
            components.weekday = weekday
        case "monthly":
            // Get the current day of month and set it for the trigger
            let dayOfMonth = calendar.component(.day, from: reminderTime)
            components.day = dayOfMonth
        default: // "daily"
            // Keep only hour and minute for daily reminders
            break
        }
        
        // Create trigger with appropriate components
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "habit-\(habitId)",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification with error handling
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification for habit '\(habit.title)': \(error.localizedDescription)")
            } else {
                print("Successfully scheduled \(habit.frequency) reminder for '\(habit.title)'")
            }
        }
    }
    
    func cancelHabitReminder(habitId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["habit-\(habitId)"]
        )
    }
} 