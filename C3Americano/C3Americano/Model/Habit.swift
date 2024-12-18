import Firebase
import FirebaseFirestore

struct Habit: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let userId: String
    var title: String
    var description: String
    var frequency: String // daily, weekly, monthly
    var completedDates: [Date]
    var createdAt: Date
    var reminderTime: Date?
    var isReminderEnabled: Bool
    var selectedWeekday: Int?    // 1 (Sunday) through 7 (Saturday)
    var selectedDayOfMonth: Int? // 1 through 31
    
    static func == (lhs: Habit, rhs: Habit) -> Bool {
        lhs.id == rhs.id &&
        lhs.userId == rhs.userId &&
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.frequency == rhs.frequency &&
        lhs.completedDates == rhs.completedDates &&
        lhs.createdAt == rhs.createdAt &&
        lhs.reminderTime == rhs.reminderTime &&
        lhs.isReminderEnabled == rhs.isReminderEnabled &&
        lhs.selectedWeekday == rhs.selectedWeekday &&
        lhs.selectedDayOfMonth == rhs.selectedDayOfMonth
    }
    
    var isCompletedToday: Bool {
        guard let lastCompletion = completedDates.last else { return false }
        return Calendar.current.isDate(lastCompletion, inSameDayAs: Date())
    }
    
    var isCompletedThisWeek: Bool {
        let calendar = Calendar.current
        let currentWeek = calendar.component(.weekOfYear, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        return completedDates.contains { date in
            let completionWeek = calendar.component(.weekOfYear, from: date)
            let completionYear = calendar.component(.year, from: date)
            return completionWeek == currentWeek && completionYear == currentYear
        }
    }
    
    var isCompleted: Bool {
        switch frequency {
        case "daily":
            return isCompletedToday
        case "weekly":
            return isCompletedThisWeek
        case "monthly":
            let calendar = Calendar.current
            let currentMonth = calendar.component(.month, from: Date())
            let currentYear = calendar.component(.year, from: Date())
            
            return completedDates.contains { date in
                let completionMonth = calendar.component(.month, from: date)
                let completionYear = calendar.component(.year, from: date)
                return completionMonth == currentMonth && completionYear == currentYear
            }
        default:
            return false
        }
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
        
        func isWithinCurrentPeriod(_ date: Date) -> Bool {
            switch frequency {
            case "daily":
                let daysDiff = calendar.dateComponents([.day], from: date, to: today).day ?? 0
                return daysDiff <= 1
            case "weekly":
                let completionWeek = calendar.component(.weekOfYear, from: date)
                let currentWeek = calendar.component(.weekOfYear, from: today)
                let completionYear = calendar.component(.year, from: date)
                let currentYear = calendar.component(.year, from: today)
                
                if completionYear == currentYear {
                    return completionWeek == currentWeek
                } else if completionYear == currentYear - 1 {
                    let lastWeekOfYear = calendar.component(.weekOfYear, from: date)
                    return currentWeek == 1 && (lastWeekOfYear == 52 || lastWeekOfYear == 53)
                }
                return false
            case "monthly":
                let completionMonth = calendar.component(.month, from: date)
                let currentMonth = calendar.component(.month, from: today)
                let completionYear = calendar.component(.year, from: date)
                let currentYear = calendar.component(.year, from: today)
                
                if completionYear == currentYear {
                    return completionMonth == currentMonth
                } else if completionYear == currentYear - 1 {
                    return currentMonth == 1 && completionMonth == 12
                }
                return false
            default:
                return false
            }
        }
        
        func areDatesInConsecutivePeriods(_ date1: Date, _ date2: Date) -> Bool {
            switch frequency {
            case "daily":
                let days = calendar.dateComponents([.day], from: date2, to: date1).day ?? 0
                return days == 1
            case "weekly":
                let week1 = calendar.component(.weekOfYear, from: date1)
                let week2 = calendar.component(.weekOfYear, from: date2)
                let year1 = calendar.component(.year, from: date1)
                let year2 = calendar.component(.year, from: date2)
                
                if year1 == year2 {
                    return week1 - week2 == 1
                } else if year1 == year2 + 1 {
                    let lastWeekOfYear = calendar.component(.weekOfYear, from: date2)
                    return week1 == 1 && (lastWeekOfYear == 52 || lastWeekOfYear == 53)
                }
                return false
            case "monthly":
                let month1 = calendar.component(.month, from: date1)
                let month2 = calendar.component(.month, from: date2)
                let year1 = calendar.component(.year, from: date1)
                let year2 = calendar.component(.year, from: date2)
                
                if year1 == year2 {
                    return month1 - month2 == 1
                } else if year1 == year2 + 1 {
                    return month1 == 1 && month2 == 12
                }
                return false
            default:
                return false
            }
        }
        
        // If the last completion is not within current period, streak is broken
        guard isWithinCurrentPeriod(lastCompletionDate) else { return 0 }
        
        var currentDate = lastCompletionDate
        streak = 1
        
        for date in sortedDates.dropFirst() {
            if calendar.isDate(date, inSameDayAs: currentDate) { continue }
            
            if areDatesInConsecutivePeriods(currentDate, date) {
                streak += 1
                currentDate = date
            } else {
                break
            }
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
        
        func areDatesInConsecutivePeriods(_ date1: Date, _ date2: Date) -> Bool {
            switch frequency {
            case "daily":
                let days = calendar.dateComponents([.day], from: date1, to: date2).day ?? 0
                return days == 1
            case "weekly":
                let weeks = calendar.dateComponents([.weekOfYear], from: date1, to: date2).weekOfYear ?? 0
                return weeks == 1
            case "monthly":
                let months = calendar.dateComponents([.month], from: date1, to: date2).month ?? 0
                return months == 1
            default:
                return false
            }
        }
        
        var previousDate: Date?
        
        for date in sortedDates {
            if let previous = previousDate {
                if calendar.isDate(date, inSameDayAs: previous) {
                    continue
                }
                
                if areDatesInConsecutivePeriods(previous, date) {
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

extension Habit {
    static var example = Habit(
        id: "123",
        userId: "abc",
        title: "Example Habit",
        description: "This is an example habit.",
        frequency: "daily",
        completedDates: [],
        createdAt: Date(),
        reminderTime: nil,
        isReminderEnabled: false,
        selectedWeekday: nil,
        selectedDayOfMonth: nil)
}
