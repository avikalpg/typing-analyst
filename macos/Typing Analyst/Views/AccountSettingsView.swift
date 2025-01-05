//
//  AccountSettingsView.swift
//  Typing Analyst
//
//  Created by Avikalp on 03/01/25.
//

import SwiftUI

struct AccountSettingsView: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        VStack {
            Text("You are logged in!")
            Button("Logout") {
                AuthManager.shared.logout { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success():
                            isLoggedIn = false // Correct: Directly assign to isLoggedIn
                        case .failure(let error):
                            print("Logout failed:", error)
                            // Handle logout error
                        }
                    }
                }
            }
        }
        .frame(width: 800)
        .padding(20)
    }
}
