// HomeWorth/Views/AdminDashboardView.swift
import SwiftUI

struct AdminDashboardView: View {
    @StateObject private var propertyViewModel = AdminDashboardViewModel()
    
    var body: some View {
        ZStack {
            // Futuristic background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.homeWorthGradientStart.opacity(0.3),
                    Color.homeWorthGradientEnd.opacity(0.2),
                    Color.homeWorthYellow.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            TabView {
                // Properties Management Tab
                AdminPropertyManagementView(viewModel: propertyViewModel)
                    .tabItem {
                        Label("Properties", systemImage: "list.bullet.rectangle.fill")
                    }
                
                // User Management Tab
                UserManagementView()
                    .tabItem {
                        Label("Users", systemImage: "person.3.fill")
                    }
            }
            .accentColor(.homeWorthYellow)
        }
        .navigationTitle("Admin Dashboard")
        .onAppear {
            propertyViewModel.fetchProperties()
        }
    }
}

struct AdminPropertyManagementView: View {
    @ObservedObject var viewModel: AdminDashboardViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Futuristic header
            HStack {
                Text("ADMIN DASHBOARD")
                    .font(.system(size: 28, weight: .black, design: .monospaced))
                    .foregroundColor(.deepBlack)
                    .shadow(color: .white.opacity(0.6), radius: 2, x: 1, y: 1)
                
                Spacer()
                
                Image(systemName: "shield.righthalf.filled")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.deepBlack)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Filter section
            AdminFilterCard(
                selectedFilter: $viewModel.selectedFilter,
                onFilterChange: { viewModel.applyFilter() }
            )
            
            // Content area - FIXED: Explicit ForEach with proper data source
            Group {
                if viewModel.isLoading {
                    AdminLoadingView()
                } else if let errorMessage = viewModel.errorMessage {
                    AdminErrorView(message: errorMessage)
                } else if viewModel.pendingProperties.isEmpty {
                    AdminEmptyView(filterType: viewModel.selectedFilter)
                } else {
                    // FIXED: Use explicit List with ForEach to avoid generic inference error
                    List {
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
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
            .padding(.top, 20)
        }
        .navigationBarHidden(true)
        .refreshable {
            viewModel.fetchProperties()
        }
    }
}

// MARK: - Admin Components (Same as before)

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
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
        )
        .shadow(color: .deepBlack.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
        .padding(.top, 20)
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


