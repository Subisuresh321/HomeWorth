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
        ZStack {
            // Futuristic background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.homeWorthGradientStart,
                    Color.homeWorthGradientEnd,
                    Color.homeWorthYellow.opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 32) {
                    // App Logo and Title Section
                    AuthHeaderSection(isSigningUp: isSigningUp)
                    
                    // Profile Photo Section (Sign Up Only)
                    if isSigningUp {
                        AuthProfilePhotoSection(
                            profileImage: $profileImage,
                            showingImagePicker: $showingImagePicker
                        )
                    }
                    
                    // Authentication Form
                    AuthFormSection(
                        email: $email,
                        password: $password,
                        name: $name,
                        phoneNumber: $phoneNumber,
                        selectedUserType: $selectedUserType,
                        isSigningUp: isSigningUp,
                        userTypes: userTypes
                    )
                    
                    // Action Buttons
                    AuthActionButtonsSection(
                        isSigningUp: isSigningUp,
                        email: email,
                        password: password,
                        name: name,
                        phoneNumber: phoneNumber,
                        selectedUserType: selectedUserType,
                        profileImage: profileImage,
                        authViewModel: authViewModel,
                        onToggleMode: { toggleAuthMode() }
                    )
                    
                    // Status Message
                    if !authViewModel.message.isEmpty {
                        AuthStatusMessage(message: authViewModel.message)
                    }
                    
                    // Bottom spacing
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            SingleImagePicker(selectedImage: $profileImage)
        }
    }
    
    private func toggleAuthMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isSigningUp.toggle()
            // Clear form data when switching modes
            email = ""
            password = ""
            name = ""
            phoneNumber = ""
            profileImage = nil
            selectedUserType = "buyer"
            authViewModel.message = ""
        }
    }
}

// MARK: - Authentication Components

struct AuthHeaderSection: View {
    let isSigningUp: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // App logo/icon
            ZStack {
                Circle()
                    .fill(Color.homeWorthYellow)
                    .frame(width: 80, height: 80)
                    .shadow(color: .homeWorthYellow.opacity(0.4), radius: 12, x: 0, y: 6)
                
                Image(systemName: "house.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.deepBlack)
            }
            
            VStack(spacing: 8) {
                Text("HOMEWORTH")
                    .font(.system(size: 32, weight: .black, design: .monospaced))
                    .foregroundColor(.deepBlack)
                    .shadow(color: .white.opacity(0.6), radius: 2, x: 1, y: 1)
                
                Text(isSigningUp ? "CREATE NEW ACCOUNT" : "WELCOME BACK")
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    .foregroundColor(.deepBlack.opacity(0.8))
            }
        }
    }
}

struct AuthProfilePhotoSection: View {
    @Binding var profileImage: UIImage?
    @Binding var showingImagePicker: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("PROFILE PHOTO")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack.opacity(0.7))
            
            Button(action: { showingImagePicker = true }) {
                ZStack {
                    if let image = profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.homeWorthLightGray)
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.homeWorthDarkGray.opacity(0.6))
                            )
                    }
                    
                    // Edit overlay
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Circle()
                                .fill(Color.homeWorthYellow)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.deepBlack)
                                )
                                .shadow(color: .deepBlack.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                    }
                }
                .frame(width: 120, height: 120)
            }
            
            Text("Tap to select photo")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.deepBlack.opacity(0.6))
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
        )
        .shadow(color: .deepBlack.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct AuthFormSection: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var name: String
    @Binding var phoneNumber: String
    @Binding var selectedUserType: String
    let isSigningUp: Bool
    let userTypes: [String]
    
    var body: some View {
        VStack(spacing: 20) {
            // Email Field
            AuthInputField(
                title: "EMAIL ADDRESS",
                text: $email,
                placeholder: "Enter your email",
                keyboardType: .emailAddress,
                isSecure: false
            )
            
            // Password Field
            AuthInputField(
                title: "PASSWORD",
                text: $password,
                placeholder: "Enter your password",
                keyboardType: .default,
                isSecure: true
            )
            
            // Sign Up Additional Fields
            if isSigningUp {
                AuthInputField(
                    title: "FULL NAME",
                    text: $name,
                    placeholder: "Enter your full name",
                    keyboardType: .default,
                    isSecure: false
                )
                
                AuthInputField(
                    title: "PHONE NUMBER",
                    text: $phoneNumber,
                    placeholder: "Enter your phone number",
                    keyboardType: .phonePad,
                    isSecure: false
                )
                
                // User Type Picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("I AM A")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.deepBlack.opacity(0.7))
                    
                    Picker("User Type", selection: $selectedUserType) {
                        ForEach(userTypes, id: \.self) { type in
                            Text(type.uppercased())
                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .background(Color.homeWorthYellow.opacity(0.3))
                    .cornerRadius(12)
                }
                .padding(.vertical, 8)
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
        )
        .shadow(color: .deepBlack.opacity(0.1), radius: 12, x: 0, y: 6)
    }
}

struct AuthActionButtonsSection: View {
    let isSigningUp: Bool
    let email: String
    let password: String
    let name: String
    let phoneNumber: String
    let selectedUserType: String
    let profileImage: UIImage?
    let authViewModel: AuthViewModel
    let onToggleMode: () -> Void
    
    // ADD LOCAL LOADING STATE
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Primary Action Button
            Button(action: {
                // SET LOADING TRUE BEFORE AUTH CALLS
                isLoading = true
                
                if isSigningUp {
                    authViewModel.signUp(
                        email: email,
                        password: password,
                        name: name,
                        phoneNumber: phoneNumber,
                        userType: selectedUserType,
                        profileImage: profileImage
                    )
                } else {
                    authViewModel.signIn(email: email, password: password)
                }
                
                // SIMULATE LOADING COMPLETION (or use proper callbacks)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    isLoading = false
                }
            }) {
                HStack(spacing: 12) {
                    // USE LOCAL isLoading INSTEAD OF authViewModel.isLoading
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.deepBlack)
                    } else {
                        Image(systemName: isSigningUp ? "person.badge.plus" : "person.fill")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    
                    // USE LOCAL isLoading INSTEAD OF authViewModel.isLoading
                    Text(isLoading ? "PROCESSING..." : (isSigningUp ? "CREATE ACCOUNT" : "SIGN IN"))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                }
                .foregroundColor(.deepBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.homeWorthYellow)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.deepBlack, lineWidth: 2)
                        )
                )
                .shadow(color: .homeWorthYellow.opacity(0.4), radius: 12, x: 0, y: 6)
            }
            // USE LOCAL isLoading INSTEAD OF authViewModel.isLoading
            .disabled(isLoading || !isFormValid())
            
            // Toggle Mode Button
            Button(action: onToggleMode) {
                Text(isSigningUp ? "ALREADY HAVE ACCOUNT?" : "NEED AN ACCOUNT?")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.deepBlack.opacity(0.7))
                    .underline()
            }
        }
    }
    
    private func isFormValid() -> Bool {
        if isSigningUp {
            return !email.isEmpty && !password.isEmpty && !name.isEmpty && !phoneNumber.isEmpty
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
}


struct AuthStatusMessage: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(message.contains("successfully") ? .green : .red)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(message.contains("successfully") ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                message.contains("successfully") ? Color.green.opacity(0.3) : Color.red.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: .deepBlack.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct AuthInputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let isSecure: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.deepBlack.opacity(0.7))
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
                }
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.deepBlack)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.deepBlack.opacity(0.2), lineWidth: 1)
                    )
            )
            .tint(.homeWorthYellow)
        }
    }
}
