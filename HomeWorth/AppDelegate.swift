// HomeWorth/AppDelegate.swift
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // No need to initialize Supabase here.
        // The SupabaseClient is initialized in SupabaseService.swift.
        return true
    }
}
