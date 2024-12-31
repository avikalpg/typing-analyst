//
//  PreferencesView.swift
//  Typing Analyst
//
//  Created by Avikalp Kumar Gupta on 31/12/24.
//

import SwiftUI

struct PreferencesView: View {
    @Binding var preferences: AppPreferences
    private let formWidth: CGFloat = 800

    var body: some View {
        Form {
            VStack(spacing: 15) {
                HStack {
                    Text("Update Frequency (seconds)")
                    TextField("", value: $preferences.updateFrequency, format: .number)
                        .multilineTextAlignment(.center)
                        .frame(width: 100)
                }

                HStack {
                    Text("Data Time Window (seconds)")
                    TextField("", value: $preferences.dataTimeWindow, format: .number)
                        .multilineTextAlignment(.center)
                        .frame(width: 100)
                }

                HStack {
                    Text("Chart Time Window (seconds)")
                    TextField("", value: $preferences.chartTimeWindow, format: .number)
                        .multilineTextAlignment(.center)
                        .frame(width: 100)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Charts to show in popover")
                        .font(.headline)
                        .padding(.top)

                    Toggle("Show WPM Chart", isOn: $preferences.showWPMChart)
                    Toggle("Show CPM Chart", isOn: $preferences.showCPMChart)
                    Toggle("Show Accuracy Chart", isOn: $preferences.showAccuracyChart)
                }
            }
            .frame(width: formWidth)
            .padding()
        }
    }
}
