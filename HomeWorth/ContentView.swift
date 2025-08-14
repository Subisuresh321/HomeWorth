// HomeWorth/App/ContentView.swift - After Fix
import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                AppTabView()
                    .environmentObject(authViewModel) // <- Added the missing modifier
            } else {
                AuthenticationView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
