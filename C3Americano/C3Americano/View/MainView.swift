//
//  MainView.swift
//  C3Americano
//
//  Created by Ahmet Haydar ISIK on 14/12/24.
//


import SwiftUI

struct MainView: View {
    @StateObject var habitViewModel = HabitViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingAddHabit = false
    @State private var selectedFrequency = "daily"
    
    let frequencies = ["daily", "weekly", "monthly"]
    
    var filteredHabits: [Habit] {
        habitViewModel.habits.filter { $0.frequency == selectedFrequency }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Frequency Picker
                Picker("Frequency", selection: $selectedFrequency) {
                    ForEach(frequencies, id: \.self) { frequency in
                        Text(frequency.capitalized)
                            .tag(frequency)
                            .accessibilityLabel("\(frequency) habits")
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .accessibilityLabel("Filter habits by frequency")
                
                // Habits List
                List {
                    ForEach(filteredHabits) { habit in
                        HabitRowView(habit: habit, viewModel: habitViewModel)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            habitViewModel.deleteHabit(filteredHabits[index])
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("My Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let user = authViewModel.currentUser {
                        NavigationLink(destination: ProfileView()) {
                            Text(user.initials)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color(.systemGray3))
                                .clipShape(Circle())
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddHabit = true }) {
                        Image(systemName: "plus")
                            .accessibilityLabel("Add new habit")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView(viewModel: habitViewModel)
            }
        }
        .onAppear {
            habitViewModel.fetchUserHabits()
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AuthViewModel())
}
