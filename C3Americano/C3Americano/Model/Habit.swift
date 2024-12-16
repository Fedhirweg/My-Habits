import Firebase
import FirebaseFirestore

struct Habit: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    var title: String
    var description: String
    var frequency: String // daily, weekly, monthly
    var completedDates: [Date]
    var createdAt: Date
    
    var isCompletedToday: Bool {
        guard let lastCompletion = completedDates.last else { return false }
        return Calendar.current.isDate(lastCompletion, inSameDayAs: Date())
    }
    
    var currentStreak: Int {
        var streak = 0
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Sort dates in descending order
        let sortedDates = completedDates
            .map { calendar.startOfDay(for: $0) }
            .sorted(by: >)
        
        guard let lastCompletionDate = sortedDates.first else { return 0 }
        
        // If the last completion is not today or yesterday, streak is broken
        let daysSinceLastCompletion = calendar.dateComponents([.day], from: lastCompletionDate, to: today).day ?? 0
        guard daysSinceLastCompletion <= 1 else { return 0 }
        
        var currentDate = lastCompletionDate
        
        for date in sortedDates {
            if calendar.isDate(date, inSameDayAs: currentDate) {
                if streak == 0 { streak = 1 }
            } else {
                let days = calendar.dateComponents([.day], from: date, to: currentDate).day ?? 0
                if days != 1 { break }
                streak += 1
            }
            currentDate = date
        }
        
        return streak
    }
    
    var longestStreak: Int {
        var longest = 0
        var current = 0
        let calendar = Calendar.current
        
        let sortedDates = completedDates
            .map { calendar.startOfDay(for: $0) }
            .sorted()
        
        var previousDate: Date?
        
        for date in sortedDates {
            if let previous = previousDate {
                let days = calendar.dateComponents([.day], from: previous, to: date).day ?? 0
                if days == 1 {
                    current += 1
                } else {
                    longest = max(longest, current)
                    current = 1
                }
            } else {
                current = 1
            }
            previousDate = date
        }
        
        return max(longest, current)
    }
} 
