//
//  GeneralSettingsView.swift
//  Typing Analyst
//
//  Created by Avikalp on 03/01/25.
//

import SwiftUI

struct GeneralSettingsView: View {
    @Binding var preferences: AppPreferences
    private let formWidth: CGFloat = 800
    
    var body: some View {
        Form {
            VStack(spacing: 15) {
                HStack {
                    Text("Update Frequency")
                    Image(systemName: "info.circle")
                        .help("How often the charts and statistics are updated. Lower values provide more frequent updates but may use more system resources.")
                    TextField("", value: $preferences.updateFrequency, format: .number)
                        .multilineTextAlignment(.center)
                        .frame(width: 100)
                    Text("seconds")
                }
                
                HStack {
                    Text("Measurement Time Window")
                    Image(systemName: "info.circle")
                        .help("The rolling window of time within which your WPM, CPM and accuracy are measured, i.e. your typing performance of the last X seconds.")
                    TextField("", value: $preferences.dataTimeWindow, format: .number)
                        .multilineTextAlignment(.center)
                        .frame(width: 100)
                    Text("seconds")
                }
                
                HStack {
                    Text("Max Chart Time Window")
                    Image(systemName: "info.circle")
                        .help("The longest time period shown in the charts. Longer windows show more historical data.")
                    TextField("", value: $preferences.chartTimeWindow, format: .number)
                        .multilineTextAlignment(.center)
                        .frame(width: 100)
                    Text("seconds")
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Charts to show in popover")
                        .font(.headline)
                        .padding(.top)
                    
                    HStack {
                        Toggle("Show WPM Chart", isOn: $preferences.showWPMChart)
                        Image(systemName: "info.circle")
                            .help("Words Per Minute chart shows your typing speed over time")
                    }
                    HStack {
                        Toggle("Show CPM Chart", isOn: $preferences.showCPMChart)
                        Image(systemName: "info.circle")
                            .help("Characters Per Minute chart shows your raw typing rate")
                    }
                    HStack {
                        Toggle("Show Accuracy Chart", isOn: $preferences.showAccuracyChart)
                        Image(systemName: "info.circle")
                            .help("Accuracy chart shows the percentage of correctly typed characters")
                    }
                }
            }
            .frame(width: formWidth)
            .padding()
        }
    }
}
