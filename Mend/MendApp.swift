//
//  MendApp.swift
//  Mend
//
//  Created by Shehani Hansika on 05.05.26.
//

import SwiftUI
import SwiftData

@main
struct MendApp: App {
    @AppStorage("isLoggedIn") var isLoggedIn = false
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                RootTabView()
            } else {
                WelcomeView()
            }
        }
        .modelContainer(for:
            [MoodEntry.self]
        )
        
    }
}
