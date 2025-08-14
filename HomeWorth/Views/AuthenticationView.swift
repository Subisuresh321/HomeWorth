// HomeWorth/Views/Authentication/AuthenticationView.swift
import SwiftUI
import Supabase

struct AuthenticationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSigningUp = false
    @State private var selectedUserType: String = "buyer" // Default user type
    
    // Admin user types are not available for new sign-ups.
    private let userTypes = ["buyer", "seller"]
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text(isSigningUp ? "Create a New Account" : "Welcome Back")
                .font(.title)
                .fontWeight(.bold)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // Show the user type picker only during sign-up
            if isSigningUp {
                Picker("I am a", selection: $selectedUserType) {
                    ForEach(userTypes, id: \.self) { type in
                        Text(type.capitalized)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
            }

            Button(isSigningUp ? "Sign Up" : "Sign In") {
                if isSigningUp {
                    // Pass the selected user type to the sign-up function
                    authViewModel.signUp(email: email, password: password, userType: selectedUserType)
                } else {
                    authViewModel.signIn(email: email, password: password)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button(isSigningUp ? "Already have an account?" : "Need an account?") {
                isSigningUp.toggle()
                // Reset the selected user type when switching forms
                selectedUserType = "buyer"
            }
            .foregroundColor(.secondary)
            .padding(.top, 10)

            if !authViewModel.message.isEmpty {
                Text(authViewModel.message)
                    .foregroundColor(authViewModel.message.contains("successfully") ? .green : .red)
                    .padding(.top)
            }
        }
        .padding()
    }
}
