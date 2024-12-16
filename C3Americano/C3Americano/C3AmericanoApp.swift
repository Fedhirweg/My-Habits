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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Request notification authorization at app launch
        Task {
            do {
                let authorized = try await NotificationManager.shared.requestAuthorization()
                print("Notification authorization status: \(authorized)")
            } catch {
                print("Error requesting notification authorization: \(error.localizedDescription)")
            }
        }
        
        return true
    }
}
