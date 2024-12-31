//
//  AppPreferences.swift
//  Typing Analyst
//
//  Created by Avikalp Kumar Gupta on 31/12/24.
//

import Foundation

struct AppPreferences: Codable {
    var updateFrequency: TimeInterval = 0.5
    var dataTimeWindow: TimeInterval = 10 // 1 minute default
    var chartTimeWindow: TimeInterval = 60 * 60 * 24 // 24 hours
    var showWPMChart: Bool = true
    var showCPMChart: Bool = true
    var showAccuracyChart: Bool = true
}

extension AppPreferences {
    private static let preferencesKey = "appPreferences"

    static func load() -> AppPreferences {
        if let data = UserDefaults.standard.data(forKey: preferencesKey),
           let preferences = try? JSONDecoder().decode(AppPreferences.self, from: data) {
            return preferences
        }
        return AppPreferences() // Return default preferences if none are saved
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: AppPreferences.preferencesKey)
        }
    }
}
