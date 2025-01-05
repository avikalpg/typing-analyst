//
//  Typing_AnalystApp.swift
//  Typing Analyst
//
//  Created by Avikalp Kumar Gupta on 30/12/24.
//

import SwiftUI

@main
struct Typing_AnalystApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
    @State private var preferences: AppPreferences = .load()
    @StateObject var viewModel: ViewModel
    let typingDataSender = TypingDataSender()

    init() {
        let preferences = AppPreferences.load()
        let viewModel = ViewModel(preferences: preferences, typingDataSender: typingDataSender)
        _viewModel = StateObject(wrappedValue: viewModel)
        appDelegate.viewModel = viewModel
    }
    var body: some Scene {
        Settings {
            PreferencesView(preferences: $preferences).onDisappear{
                self.preferences.save()
                self.appDelegate.viewModel.preferences = self.preferences
                self.appDelegate.viewModel.updatePreferences()
            }
        }
    }
}
