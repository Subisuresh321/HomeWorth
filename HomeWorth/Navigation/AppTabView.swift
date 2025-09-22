// HomeWorth/Navigation/AppTabView.swift
import SwiftUI

struct AppTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Simple static background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.homeWorthGradientStart.opacity(0.2),
                    Color.homeWorthGradientEnd.opacity(0.1),
                    Color.homeWorthYellow.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                // Browse Tab - Available to all users
                HomeView()
                    .tabItem {
                        SimpleTabItemView(
                            icon: "house.fill",
                            title: "Browse",
                            isSelected: selectedTab == 0
                        )
                    }
                    .tag(0)
                
                // Seller-only tabs
                if authViewModel.currentUser?.userType == "seller" {
                    AddPropertyView()
                        .tabItem {
                            SimpleTabItemView(
                                icon: "plus.circle.fill",
                                title: "Sell",
                                isSelected: selectedTab == 1
                            )
                        }
                        .tag(1)
                    
                    MyPropertiesView()
                        .tabItem {
                            SimpleTabItemView(
                                icon: "list.bullet.rectangle",
                                title: "My Listings",
                                isSelected: selectedTab == 2
                            )
                        }
                        .tag(2)
                }
                
                // Admin-only tab
                if authViewModel.currentUser?.userType == "admin" {
                    AdminDashboardView()
                        .tabItem {
                            SimpleTabItemView(
                                icon: "shield.righthalf.filled",
                                title: "Admin",
                                isSelected: selectedTab == 3
                            )
                        }
                        .tag(3)
                }
                
                // Profile - Available to all users
                ProfileView(authViewModel: authViewModel)
                    .tabItem {
                        SimpleTabItemView(
                            icon: "person.fill",
                            title: "Profile",
                            isSelected: selectedTab == getProfileTabIndex()
                        )
                    }
                    .tag(getProfileTabIndex())
            }
            .accentColor(.homeWorthYellow)
            .onAppear {
                setupTabBarAppearance()
            }
        }
    }
    
    private func getProfileTabIndex() -> Int {
        if authViewModel.currentUser?.userType == "seller" {
            return 4
        } else if authViewModel.currentUser?.userType == "admin" {
            return 4
        } else {
            return 1 // Regular user
        }
    }
    
    private func setupTabBarAppearance() {
        // Optimized tab bar styling
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        // Tab bar background with simple blur effect
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        
        // Selected tab item styling
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.deepBlack)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.deepBlack),
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold)
        ]
        
        // Unselected tab item styling
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.homeWorthDarkGray.opacity(0.6))
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.homeWorthDarkGray.opacity(0.6)),
            .font: UIFont.systemFont(ofSize: 12, weight: .medium)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Simple Tab Item Component (No Deprecated onChange)

struct SimpleTabItemView: View {
    let icon: String
    let title: String
    let isSelected: Bool
    @State private var iconScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .deepBlack : .homeWorthDarkGray.opacity(0.6))
                .scaleEffect(iconScale)
                .shadow(
                    color: isSelected ? .homeWorthYellow.opacity(0.3) : .clear,
                    radius: isSelected ? 3 : 0
                )
            
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .deepBlack : .homeWorthDarkGray.opacity(0.6))
        }
        // NEW: Using non-deprecated onChange syntax (zero parameters)
        .onChange(of: isSelected) {
            if isSelected {
                // Simple scale animation when tab becomes selected
                withAnimation(.easeInOut(duration: 0.2)) {
                    iconScale = 1.1
                }
                // Return to normal
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        iconScale = 1.0
                    }
                }
            }
        }
    }
}
