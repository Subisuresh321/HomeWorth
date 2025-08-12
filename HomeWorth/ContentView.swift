// HomeWorth/App/ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                AppTabView()
            } else {
                AuthenticationView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
