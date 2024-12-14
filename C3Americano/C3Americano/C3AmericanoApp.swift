//
//  C3AmericanoApp.swift
//  C3Americano
//
//  Created by Ahmet Haydar ISIK on 9/12/24.
//

import SwiftUI
import Firebase

@main
struct C3AmericanoApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
