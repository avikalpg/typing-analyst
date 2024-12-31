//
//  PreferencesView.swift
//  Typing Analyst
//
//  Created by Avikalp Kumar Gupta on 31/12/24.
//

import SwiftUI

struct PreferencesView: View {
    @Binding var preferences: AppPreferences

    var body: some View {
        Form {
            LabeledContent("Update Frequency (seconds):") {
                TextField("Update Frequency", value: $preferences.updateFrequency, format: .number)
                    .frame(width: 50) // Set a fixed width for the TextField
            }
            LabeledContent("Data Time Window (seconds):") {
                TextField("Data Time Window", value: $preferences.dataTimeWindow, format: .number)
                    .frame(width: 75)
            }
            LabeledContent("Chart Time Window (seconds):") {
                TextField("Chart Time Window", value: $preferences.chartTimeWindow, format: .number)
                    .frame(width: 75)
            }

            Toggle("Show WPM Chart", isOn: $preferences.showWPMChart)
            Toggle("Show CPM Chart", isOn: $preferences.showCPMChart)
            Toggle("Show Accuracy Chart", isOn: $preferences.showAccuracyChart)
        }
        .padding()
        .frame(width: 300) // Keep a fixed width for the entire Form
    }
}
