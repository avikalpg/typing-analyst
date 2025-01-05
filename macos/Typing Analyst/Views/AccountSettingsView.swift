//
//  AccountSettingsView.swift
//  Typing Analyst
//
//  Created by Avikalp on 03/01/25.
//

import SwiftUI

struct AccountSettingsView: View {
    @Binding var isLoggedIn: Bool
    @State private var errorMessage: String? = nil

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
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            }
            .padding(.top)
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.bottom)
            }
        }
        .frame(width: 800)
        .padding(20)
    }
}
