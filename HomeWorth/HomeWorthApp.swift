//
//  HomeWorthApp.swift
//  HomeWorth
//
//  Created by Subi Suresh on 08/08/2025.
//

import SwiftUI



@main
struct HomeWorthApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithDefaultBackground()
                
                // Set title colors
                appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
                
                // Apply to all navigation bars
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().compactAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
                
                // Set tint color for back buttons and other controls
                UINavigationBar.appearance().tintColor = UIColor.black
           UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .systemBlue
       }

    var body: some Scene {
        WindowGroup {
            ContentView()
                
        }
    }
}
