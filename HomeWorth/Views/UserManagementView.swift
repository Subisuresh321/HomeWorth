// HomeWorth/Views/UserManagementView.swift
import SwiftUI

struct UserManagementView: View {
    @StateObject private var viewModel = UserManagementViewModel()
    
    var body: some View {
        ZStack {
            // Background gradient - exactly like HomeView
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
                    Text("USER MANAGEMENT")
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(.deepBlack)
                        .shadow(color: .white.opacity(0.6), radius: 2, x: 1, y: 1)
                    
                    Spacer()
                    
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.deepBlack)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Content area with proper spacing
                Group {
                    if viewModel.isLoading {
                        FuturisticUserLoadingView()
                    } else if let errorMessage = viewModel.errorMessage {
                        FuturisticUserErrorView(message: errorMessage)
                    } else if viewModel.users.isEmpty {
                        FuturisticEmptyUsersView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.users, id: \.id) { user in
                                    FuturisticUserCard(
                                        user: user,
                                        onDelete: { viewModel.deleteUser(user: user) }
                                    )
                                    .padding(.horizontal, 20)
                                }
                            }
                            .padding(.vertical, 10)
                        }
                        .background(Color.clear)
                    }
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchAllUsers()
        }
        .refreshable {
            viewModel.fetchAllUsers()
        }
    }
}



// MARK: - Futuristic User Components

struct FuturisticUserLoadingView: View {
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        VStack(spacing: 24) {
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.deepBlack, lineWidth: 4)
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(rotationAngle))
                .onAppear {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                }
            
            Text("SCANNING USER DATABASE...")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FuturisticUserErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("DATABASE ERROR")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.deepBlack.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FuturisticEmptyUsersView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 70))
                .foregroundColor(.deepBlack.opacity(0.6))
            
            VStack(spacing: 12) {
                Text("NO USERS FOUND")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(.deepBlack)
                
                Text("Database appears to be empty or connection failed.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.deepBlack.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FuturisticUserCard: View {
    let user: User
    let onDelete: () -> Void
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // User info section
            HStack(spacing: 16) {
                // User type indicator
                Circle()
                    .fill(userTypeColor(for: user.userType))
                    .frame(width: 16, height: 16)
                    .shadow(color: userTypeColor(for: user.userType).opacity(0.6), radius: 4)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(user.email)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.deepBlack)
                    
                    Text("TYPE: \(user.userType.uppercased())")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.deepBlack.opacity(0.7))
                }
                
                Spacer()
                
                // Delete button
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.red)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.9))
                                .overlay(
                                    Circle()
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .shadow(color: .red.opacity(0.3), radius: 6, x: 0, y: 3)
                }
            }
            
            // User details if available
            if let name = user.name, !name.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.deepBlack.opacity(0.6))
                    Text(name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.deepBlack.opacity(0.8))
                }
            }
            
            if let phoneNumber = user.phoneNumber, !phoneNumber.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.deepBlack.opacity(0.6))
                    Text(phoneNumber)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.deepBlack.opacity(0.8))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
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
        .alert("Delete User", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this user? This action cannot be undone.")
        }
    }
    
    private func userTypeColor(for userType: String) -> Color {
        switch userType.lowercased() {
        case "admin":
            return .red
        case "seller":
            return .orange
        case "buyer":
            return .green
        default:
            return .gray
        }
    }
}
