

// HomeWorth/Views/ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: ProfileViewModel
    
    init(authViewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(authViewModel: authViewModel))
    }
    
    var body: some View {
        NavigationView {
            Form {
                if let user = viewModel.currentUser {
                    Section(header: Text("Profile Information")) {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email)
                                .foregroundColor(.secondary)
                        }
                        
                        TextField("Name", text: $viewModel.newName)
                        TextField("Phone Number", text: $viewModel.newPhoneNumber)
                    }
                    
                    Section {
                        Button("Save Changes") {
                            viewModel.saveProfileChanges()
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.isLoading)
                    }
                    
                    if let message = viewModel.message {
                        Text(message)
                            .foregroundColor(message.contains("successfully") ? .green : .red)
                    }
                }
                
                Section {
                    Button("Sign Out", role: .destructive) {
                        viewModel.signOut()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.bordered)
                }
            }
            .navigationTitle("My Profile")
        }
    }
}
