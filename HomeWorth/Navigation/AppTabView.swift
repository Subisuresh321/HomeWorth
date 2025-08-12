//
//  AppTabView.swift
//  HomeWorth
//
//  Created by Subi Suresh on 09/08/2025.
//

// HomeWorth/Navigation/AppTabView.swift
import SwiftUI

struct AppTabView: View {
    var body: some View {
        TabView {
            // Buyer's Home View
            HomeView()
                .tabItem {
                    Label("Browse", systemImage: "house.fill")
                }
            
            // Seller's Add Property View
            AddPropertyView()
                .tabItem {
                    Label("Sell", systemImage: "plus.circle.fill")
                }
            
            // Placeholder for Profile/Settings View
            Text("Profile View")
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}
