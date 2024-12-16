//
//  ProfileView.swift
//  C3Americano
//
//  Created by Ahmet Haydar ISIK on 10/12/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel : AuthViewModel
    @State private var showDeleteConfirmation = false
    @State private var errorMessage: String?
    
    
    var body: some View {
        if let user = viewModel.currentUser
        {
            List {
                Section {
                    HStack {
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(minWidth: 72, minHeight: 72)
                            .background(Color(.gray))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4){
                            Text(user.fullname)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            
                            Text(user.email)
                                .font(.footnote)
                                .foregroundStyle(.gray)
                        }
                    }
                    
                }
                
                Section ("Gereral"){
                    HStack {
                        SettingsRowView(imageName: "gear", title: "version", tintColor: Color(.systemGray))
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    
                }
                
                Section ("Account"){
                    
                    Button{
                        print("sign out")
                        viewModel.signOut()
                    } label: {
                        SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                    }
                    
                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
                    }
                    .alert("Delete Account", isPresented: $showDeleteConfirmation) {
                        Button("Delete", role: .destructive) {
                            Task {
                                await handleDeleteAccount()
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Are you sure you want to delete your account? This action cannot be undone.")
                    }
                }
            }
        } else {
            Text("Loading...")
        }
    }
    
    // Asynchronous function to handle account deletion
    private func handleDeleteAccount() async {
        do {
            try await viewModel.deleteAccount()
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert()
        }
    }
    
    // Error alert
    private func showErrorAlert() {
        guard let errorMessage else { return }
        
        DispatchQueue.main.async {
            // Present the error message
            print("Error: \(errorMessage)") //
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
