// HomeWorth/Navigation/AppTabView.swift
import SwiftUI

struct AppTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            // All users can see the main property listings
            HomeView()
                .tabItem {
                    Label("Browse", systemImage: "house.fill")
                }
            
            // The "Sell" tab (AddPropertyView) is for a user who wants to become a seller
            // We'll show this to buyers to allow them to list their first property.
            // A dedicated "My Listings" tab is for existing sellers.
            if authViewModel.currentUser?.userType == "seller" {
                MyPropertiesView()
                    .tabItem {
                        Label("My Listings", systemImage: "list.bullet.rectangle")
                    }
            } else if authViewModel.currentUser?.userType == "buyer" {
                AddPropertyView()
                    .tabItem {
                        Label("Sell", systemImage: "plus.circle.fill")
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
    }
}
