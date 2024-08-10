//
//  ScopesApp.swift
//  Scopes
//
//  Created by Michael Eisemann on 7/30/24.
//

import SwiftUI
import SwiftData

@main
struct ScopesApp: App {
    
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
        
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Horoscope.self,
            User.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    
    
    var body: some Scene {
        WindowGroup {
            if isUserLoggedIn {
                ContentView()
            } else {
                LoginSignupView(isUserLoggedIn: $isUserLoggedIn)
            }
        }
        .modelContainer(sharedModelContainer)
        
    }
}
