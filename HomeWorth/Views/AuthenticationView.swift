// HomeWorth/Views/Authentication/AuthenticationView.swift
import SwiftUI
import Supabase
import PhotosUI

struct AuthenticationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var profileImage: UIImage? = nil
    @State private var isSigningUp = false
    @State private var selectedUserType: String = "buyer"
    @State private var showingImagePicker = false
    
    private let userTypes = ["buyer", "seller"]
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text(isSigningUp ? "Create a New Account" : "Welcome Back")
                .font(.title)
                .fontWeight(.bold)
            
            if isSigningUp {
                if let image = profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }
                
                Button("Select Profile Photo") {
                    showingImagePicker = true
                }
                .padding(.vertical, 8)
            }
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if isSigningUp {
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.words)
                
                TextField("Phone Number", text: $phoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
                
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
                    authViewModel.signUp(email: email, password: password, name: name, phoneNumber: phoneNumber, userType: selectedUserType, profileImage: profileImage)
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
                email = ""
                password = ""
                name = ""
                phoneNumber = ""
                profileImage = nil
                selectedUserType = "buyer"
                authViewModel.message = ""
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
        .sheet(isPresented: $showingImagePicker) {
            SingleImagePicker(selectedImage: $profileImage)
        }
    }
}
