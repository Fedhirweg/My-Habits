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
                
                List {
                    if filteredHabits.isEmpty {
                        Text("No \(selectedFrequency) habits yet")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(filteredHabits) { habit in
                            HabitRowView(habit: habit, viewModel: habitViewModel)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                habitViewModel.deleteHabit(filteredHabits[index])
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("My Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let user = authViewModel.currentUser {
                        NavigationLink {
                            ProfileView()
                        } label: {
                            Text(user.initials)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color(.systemGray3))
                                .clipShape(Circle())
                                .accessibilityLabel("View profile")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddHabit = true
                    } label: {
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
