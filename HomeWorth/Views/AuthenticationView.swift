//
//  AuthenticationView.swift
//  HomeWorth
//
//  Created by Subi Suresh on 11/08/2025.
//


// HomeWorth/Views/Authentication/AuthenticationView.swift
import SwiftUI
import Supabase

struct AuthenticationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var message = ""
    @State private var isSigningUp = false
    @EnvironmentObject var authViewModel: AuthViewModel // Will be created in the next response

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

            Button(isSigningUp ? "Sign Up" : "Sign In") {
                if isSigningUp {
                    authViewModel.signUp(email: email, password: password)
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