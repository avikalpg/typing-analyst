//
//  AuthManager.swift
//  Typing Analyst
//
//  Created by Avikalp on 03/01/25.
//

import AuthenticationServices
import Foundation

class AuthManager: NSObject { // NSObject is needed for ASWebAuthenticationSessionDelegate

    static let shared = AuthManager() // Singleton instance
    private override init() {} // Prevent direct instantiation
    let serverURL = "http://localhost:3000"

    func loginWithEmailAndPassword(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("login URL: \(self.serverURL)/api/auth/login")
        guard let url = URL(string: "\(self.serverURL)/api/auth/login") else { return } // Replace with your API URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid response from server"])))
                return
            }

            // Extract cookies
            if let allHeaderFields = httpResponse.allHeaderFields as? [String: String] {
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHeaderFields, for: httpResponse.url!)

                // Store cookies in HTTPCookieStorage
                let cookieStorage = HTTPCookieStorage.shared
                for cookie in cookies {
                    cookieStorage.setCookie(cookie)
                }
            }
            
            completion(.success(())) // Login successful
        }.resume()
    }

    func sendTypingData(data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        makeApiRequest(url: URL(string: self.serverURL + "/api/typing-stats")!, data: data, completion: completion)
    }

    private func makeApiRequest(url: URL, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let cookies = HTTPCookieStorage.shared.cookies(for: request.url!) {
            let cookieHeader = HTTPCookie.requestHeaderFields(with: cookies)
            request.allHTTPHeaderFields = cookieHeader
        }
        let body = try? JSONSerialization.data(withJSONObject: data)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { dataTask, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid response from server"])))
                return
            }
            if (200...299).contains(httpResponse.statusCode) {
                completion(.success(()))
                return
            } else if httpResponse.statusCode == 401 {
                self.refreshTokens { refreshResult in
                    switch refreshResult {
                    case .success():
                        self.makeApiRequest(url: url, data: data, completion: completion)
                    case .failure(let refreshError):
                        completion(.failure(refreshError))
                    }
                }
            } else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid response from server"])))
            }
        }.resume()
    }

    private func refreshTokens(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: self.serverURL + "/api/auth/refresh") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        if let cookies = HTTPCookieStorage.shared.cookies(for: request.url!) {
            let cookieHeader = HTTPCookie.requestHeaderFields(with: cookies)
            request.allHTTPHeaderFields = cookieHeader
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid response from server"])))
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                if let allHeaderFields = httpResponse.allHeaderFields as? [String: String] {
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHeaderFields, for: httpResponse.url!)

                    let cookieStorage = HTTPCookieStorage.shared
                    for cookie in cookies {
                        cookieStorage.setCookie(cookie)
                    }
                }
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not refresh token"])))
            }
        }.resume()
    }
    
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(self.serverURL)/api/auth/logout") else { return } // Replace with your API URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid response from server"])))
                return
            }

            // Extract cookies
            if let allHeaderFields = httpResponse.allHeaderFields as? [String: String] {
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: allHeaderFields, for: httpResponse.url!)

                // Store cookies in HTTPCookieStorage
                let cookieStorage = HTTPCookieStorage.shared
                for cookie in cookies {
                    cookieStorage.setCookie(cookie)
                }
            }
            
            completion(.success(())) // Logout successful
        }.resume()
    }
}
