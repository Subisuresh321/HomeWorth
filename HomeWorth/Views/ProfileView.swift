// HomeWorth/Views/ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: ProfileViewModel
    @State private var showingImagePicker = false
    
    init(authViewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(authViewModel: authViewModel))
    }
    
    var body: some View {
        ZStack {
            // Match HomeView background structure exactly
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
            
            // Grid overlay
            SimpleGrid()
                .opacity(0.05)
            
            VStack(spacing: 0) {
                // Fixed header with proper spacing
                HStack {
                    Text("MY PROFILE")
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(.deepBlack)
                        .shadow(color: .white.opacity(0.6), radius: 2, x: 1, y: 1)
                    
                    Spacer()
                    
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.deepBlack)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Content area
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Profile Header
                        ProfileHeaderCard(
                            user: viewModel.currentUser,
                            onImageTap: { showingImagePicker = true }
                        )
                        
                        // Profile Information Card
                        if let user = viewModel.currentUser {
                            ProfileInformationCard(
                                user: user,
                                newName: $viewModel.newName,
                                newPhoneNumber: $viewModel.newPhoneNumber,
                                isLoading: viewModel.isLoading,
                                message: viewModel.message,
                                onSave: { viewModel.saveProfileChanges() }
                            )
                        }
                        
                        // Account Actions Card
                        AccountActionsCard(
                            onSignOut: { viewModel.signOut() }
                        )
                        
                        // Bottom spacing
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                .background(Color.clear)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingImagePicker) {
            SingleImagePicker(selectedImage: $viewModel.selectedImage)
        }
    }
}

// Grid component matching HomeView
struct SimpleGrid: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 60
            let lineWidth: CGFloat = 0.5
            
            for x in stride(from: 0, through: size.width + spacing, by: spacing) {
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    },
                    with: .color(.deepBlack.opacity(0.2)),
                    lineWidth: lineWidth
                )
            }
            
            for y in stride(from: 0, through: size.height + spacing, by: spacing) {
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    },
                    with: .color(.deepBlack.opacity(0.2)),
                    lineWidth: lineWidth
                )
            }
        }
    }
}

// MARK: - Profile Components

struct ProfileHeaderCard: View {
    let user: User?
    let onImageTap: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Profile Image Section
            Button(action: onImageTap) {
                ZStack {
                    if let user = user,
                       let profilePhotoUrl = user.profilePhotoUrl,
                       let url = URL(string: profilePhotoUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } placeholder: {
                            ZStack {
                                Circle()
                                    .fill(Color.homeWorthLightGray)
                                    .frame(width: 120, height: 120)
                                
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .tint(.homeWorthYellow)
                            }
                        }
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
            
            Text("Tap to change photo")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.deepBlack.opacity(0.6))
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.7),
                                    Color.homeWorthYellow.opacity(0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .shadow(color: .deepBlack.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

struct ProfileInformationCard: View {
    let user: User
    @Binding var newName: String
    @Binding var newPhoneNumber: String
    let isLoading: Bool
    let message: String?
    let onSave: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("PERSONAL INFORMATION")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
            
            VStack(alignment: .leading, spacing: 16) {
                // Email (read-only)
                VStack(alignment: .leading, spacing: 8) {
                    Text("EMAIL ADDRESS")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.deepBlack.opacity(0.7))
                    
                    HStack {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.deepBlack.opacity(0.6))
                        
                        Text(user.email)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.deepBlack.opacity(0.8))
                        
                        Spacer()
                        
                        Text("VERIFIED")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.green.opacity(0.1))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.deepBlack.opacity(0.1), lineWidth: 1)
                            )
                    )
                }
                
                // Name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("FULL NAME")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.deepBlack.opacity(0.7))
                    
                    HStack {
                        Image(systemName: "person.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.deepBlack.opacity(0.6))
                        
                        TextField("Enter your full name", text: $newName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.deepBlack)
                            .textInputAutocapitalization(.words)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.deepBlack.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                
                // Phone field
                VStack(alignment: .leading, spacing: 8) {
                    Text("PHONE NUMBER")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.deepBlack.opacity(0.7))
                    
                    HStack {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.deepBlack.opacity(0.6))
                        
                        TextField("Enter your phone number", text: $newPhoneNumber)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.deepBlack)
                            .keyboardType(.phonePad)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.deepBlack.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                
                // Save button
                Button(action: onSave) {
                    HStack(spacing: 12) {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.deepBlack)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        
                        Text(isLoading ? "SAVING..." : "SAVE CHANGES")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.deepBlack)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.homeWorthYellow)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.deepBlack, lineWidth: isLoading ? 1 : 2)
                            )
                    )
                    .shadow(color: .homeWorthYellow.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .disabled(isLoading)
                
                // Status message
                if let message = message, !message.isEmpty {
                    Text(message)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(message.contains("successfully") ? .green : .red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(message.contains("successfully") ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(message.contains("successfully") ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.7),
                                    Color.homeWorthYellow.opacity(0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .shadow(color: .deepBlack.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

struct AccountActionsCard: View {
    let onSignOut: () -> Void
    @State private var showSignOutAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("ACCOUNT ACTIONS")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
            
            Button(action: { showSignOutAlert = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("SIGN OUT")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                    
                    Spacer()
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                )
                .shadow(color: .red.opacity(0.2), radius: 6, x: 0, y: 3)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.7),
                                    Color.homeWorthYellow.opacity(0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .shadow(color: .deepBlack.opacity(0.08), radius: 12, x: 0, y: 6)
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                onSignOut()
            }
        } message: {
            Text("Are you sure you want to sign out of your account?")
        }
    }
}
