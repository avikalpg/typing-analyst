//
//  LoginView.swift
//  Typing Analyst
//
//  Created by Avikalp on 03/01/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @Binding var isLoggedIn: Bool

    var body: some View {
        VStack {
            Text("Login")
                .font(.title)
                .padding(.bottom)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.bottom)
            }

            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .textCase(.lowercase)
                .padding()
                .border(Color.gray)

            SecureField("Password", text: $password)
                .padding()
                .border(Color.gray)

            Button(action: {
                isLoading = true
                errorMessage = nil

                AuthManager.shared.loginWithEmailAndPassword(email: email, password: password) { result in
                    DispatchQueue.main.async {
                        isLoading = false
                        switch result {
                        case .success(let user):
                            print("Login successful: \(user)")
                            isLoggedIn = true
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                            print("Login failed: \(error)")
                        }
                    }
                }
            }) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Login")
                }
            }
            .padding(.top)
        }
        .padding()
    }
}
