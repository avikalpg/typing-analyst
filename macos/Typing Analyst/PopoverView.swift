//
//  PopoverView.swift
//  Typing Analyst
//
//  Created by Avikalp Kumar Gupta on 30/12/24.
//

import SwiftUI
import Charts

struct PopoverView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var chartTimeWindow: TimeInterval = 60 * 5

    var body: some View {
        VStack {
            Picker("Time Window", selection: $chartTimeWindow) {
                Text("1 Minute").tag(TimeInterval(60))
                Text("5 Minutes").tag(TimeInterval(60 * 5))
                Text("15 Minutes").tag(TimeInterval(60 * 15))
                Text("30 Minutes").tag(TimeInterval(60 * 30))
                Text("1 Hour").tag(TimeInterval(60 * 60))
            }
            .pickerStyle(.segmented)
            chart(data: viewModel.wpmData, label: "WPM", yRange: 0...150)
//            chart(data: viewModel.cpmData, label: "CPM", yRange: 0...500)
            chart(data: viewModel.accuracyData, label: "Accuracy", yRange: 0...100)
        }
        .padding()
    }

    func chart(data: [(x: Date, y: Double)], label: String, yRange: ClosedRange<Double>) -> some View {
        let now = Date()
        let filteredData = data.filter { now.timeIntervalSince($0.x) <= chartTimeWindow }
        
        return Chart {
            ForEach(filteredData, id: \.x) { item in
                LineMark(x: .value("Time", item.x), y: .value(label, item.y))
            }
        }
        .chartXScale(domain: .automatic)
        .chartXAxis {
            AxisMarks(position: .bottom) { value in
                AxisGridLine()
                AxisTick()

                if let dateValue = value.as(Date.self) {
                    let timeInterval = Date().timeIntervalSince(dateValue)
                    var format: Date.FormatStyle {
                        if timeInterval < 60 {
                            return .dateTime.second(.defaultDigits)
                        } else if timeInterval < 60 * 60 {
                            return .dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute(.defaultDigits).second(.defaultDigits)
                        } else {
                            return .dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute(.defaultDigits)
                        }
                    }
                    AxisValueLabel(format: format)
                }
            }
            AxisMarks(position: .bottom, values: [filteredData.first?.x ?? Date()]) { value in
                if value.as(Date.self) != nil {
                    AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .wide)).minute(.defaultDigits).second(.defaultDigits))
                }
            }
        }
        .chartYScale(domain: yRange)
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: Decimal.FormatStyle.number.rounded(rule: .toNearestOrEven))
            }
        }
        .frame(height: 150)
    }
}
