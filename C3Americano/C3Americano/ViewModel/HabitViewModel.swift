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
            createdAt: Date()
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
} 
