//
//  PreferencesView.swift
//  Typing Analyst
//
//  Created by Avikalp Kumar Gupta on 31/12/24.
//

import SwiftUI

struct PreferencesView: View {
    @Binding var preferences: AppPreferences
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    var body: some View {
        TabView {
            // General Settings tab
            GeneralSettingsView(preferences: $preferences)
                .tabItem { Label("General", systemImage: "gear") }
            
            if !isLoggedIn {
                LoginView(isLoggedIn: $isLoggedIn)
                    .tabItem { Label("Login", systemImage: "lock") }
            } else {
                AccountSettingsView(isLoggedIn: $isLoggedIn)
                    .tabItem { Label("Account", systemImage: "person.crop.circle") }
            }
        }
        .padding(20)
    }
}
