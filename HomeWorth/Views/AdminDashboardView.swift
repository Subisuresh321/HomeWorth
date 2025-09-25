// HomeWorth/Views/AdminDashboardView.swift

import SwiftUI

struct AdminDashboardView: View {
    @StateObject private var propertyViewModel = AdminDashboardViewModel()
    
    var body: some View {
        TabView {
            // Properties Management Tab
            ZStack {
                // Background gradient for Properties tab
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
                
                AdminPropertyManagementView(viewModel: propertyViewModel)
            }
            .tabItem {
                Label("Properties", systemImage: "list.bullet.rectangle.fill")
            }
            
            // User Management Tab
            ZStack {
                // Background gradient for Users tab
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
                
                UserManagementView()
            }
            .tabItem {
                Label("Users", systemImage: "person.3.fill")
            }
        }
        .accentColor(.homeWorthYellow)
        .navigationBarHidden(true)
        .onAppear {
            propertyViewModel.fetchProperties()
        }
    }
}


// Grid component matching other views
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


// MARK: - User Management Content for Admin Dashboard
struct UserManagementContentView: View {
    @StateObject private var viewModel = UserManagementViewModel()
    
    var body: some View {
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
        .background(Color.clear)
        .onAppear {
            viewModel.fetchAllUsers()
        }
        .refreshable {
            viewModel.fetchAllUsers()
        }
    }
}

struct AdminPropertyManagementView: View {
    @ObservedObject var viewModel: AdminDashboardViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Fixed header with stable height
            HStack {
                Text("PROPERTIES MANAGEMENT")
                    .font(.system(size: 24, weight: .black, design: .monospaced))
                    .foregroundColor(.deepBlack)
                    .shadow(color: .white.opacity(0.6), radius: 2, x: 1, y: 1)
                
                Spacer()
                
                Image(systemName: "list.bullet.rectangle.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.deepBlack)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 30)
            
            // Filter section
            AdminFilterCard(
                selectedFilter: $viewModel.selectedFilter,
                onFilterChange: { viewModel.applyFilter() }
            )
            
            // Content area
            Group {
                if viewModel.isLoading {
                    AdminLoadingView()
                } else if let errorMessage = viewModel.errorMessage {
                    AdminErrorView(message: errorMessage)
                } else if viewModel.pendingProperties.isEmpty {
                    AdminEmptyView(filterType: viewModel.selectedFilter)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.pendingProperties, id: \.id) { property in
                                AdminPropertyCardView(
                                    property: property,
                                    onApprove: { propertyId in
                                        viewModel.approveProperty(propertyId: propertyId)
                                    },
                                    onReject: { propertyId in
                                        viewModel.rejectProperty(propertyId: propertyId)
                                    }
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    .background(Color.clear)
                }
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .background(Color.clear)
        .refreshable {
            viewModel.fetchProperties()
        }
    }
}

// MARK: - Admin Components

struct AdminFilterCard: View {
    @Binding var selectedFilter: String
    let onFilterChange: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("FILTER PROPERTIES")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
            
            Picker("Filter", selection: $selectedFilter) {
                Text("PENDING").tag("pending")
                Text("APPROVED").tag("approved")
                Text("REJECTED").tag("rejected")
                Text("ALL").tag("all")
            }
            .pickerStyle(.segmented)
            .background(Color.homeWorthYellow.opacity(0.3))
            .cornerRadius(8)
            .onChange(of: selectedFilter) {
                onFilterChange()
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
        .padding(.horizontal, 20)
    }
}

struct AdminLoadingView: View {
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
            
            Text("LOADING PROPERTIES...")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}

struct AdminErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("ADMIN ERROR")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.deepBlack)
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.deepBlack.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}

struct AdminEmptyView: View {
    let filterType: String
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: emptyIcon(for: filterType))
                .font(.system(size: 70))
                .foregroundColor(.deepBlack.opacity(0.6))
            
            VStack(spacing: 12) {
                Text("NO \(filterType.uppercased()) PROPERTIES")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(.deepBlack)
                
                Text(emptyMessage(for: filterType))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.deepBlack.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
    
    private func emptyIcon(for filter: String) -> String {
        switch filter.lowercased() {
        case "pending": return "clock.badge.questionmark"
        case "approved": return "checkmark.circle"
        case "rejected": return "xmark.circle"
        default: return "house.badge.questionmark"
        }
    }
    
    private func emptyMessage(for filter: String) -> String {
        switch filter.lowercased() {
        case "pending": return "No properties awaiting admin approval."
        case "approved": return "No approved properties found."
        case "rejected": return "No rejected properties found."
        default: return "No properties found in the system."
        }
    }
}

