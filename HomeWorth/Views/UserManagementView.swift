//
//  UserManagementView.swift
//  HomeWorth
//
//  Created by Subi Suresh on 14/08/2025.
//


// HomeWorth/Views/UserManagementView.swift
import SwiftUI

struct UserManagementView: View {
    @StateObject private var viewModel = UserManagementViewModel()

    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView("Loading users...")
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else if viewModel.users.isEmpty {
                Text("No users found.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.users) { user in
                    VStack(alignment: .leading) {
                        Text(user.email)
                            .font(.headline)
                        Text("Type: \(user.userType)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("User Management")
        .refreshable {
            viewModel.fetchAllUsers()
        }
    }
}