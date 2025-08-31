// HomeWorth/Navigation/AppTabView.swift
import SwiftUI

struct AppTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            // All users can see the main property listings
            HomeView()
                .tabItem {
                    // Removed the foregroundColor modifier to let SwiftUI's tint handle the color
                    Label("Browse", systemImage: "house.fill")
                }
            
            // The "Sell" and "My Listings" tabs are now exclusive to sellers.
            if authViewModel.currentUser?.userType == "seller" {
                AddPropertyView()
                    .tabItem {
                        Label("Sell", systemImage: "plus.circle.fill")
                    }
                
                MyPropertiesView()
                    .tabItem {
                        Label("My Listings", systemImage: "list.bullet.rectangle")
                    }
            }
            
            // Only admins see the "Admin" tab
            if authViewModel.currentUser?.userType == "admin" {
                AdminDashboardView()
                    .tabItem {
                        Label("Admin", systemImage: "shield.righthalf.filled")
                    }
            }
            
            // All users can access the Profile View
            ProfileView(authViewModel: authViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(.black) // <-- The fix: Set the tint of the TabView to black
    }
}
