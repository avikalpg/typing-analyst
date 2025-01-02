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
   @State private var pointerTimestamp: Date? = nil

    var body: some View {
        let baseTimeWindowOptions = [
            TimeInterval(60),
            TimeInterval(60 * 5),
            TimeInterval(60 * 15),
            TimeInterval(60 * 30),
            TimeInterval(60 * 60),
            TimeInterval(60 * 60 * 12),
            TimeInterval(60 * 60 * 24)
        ]

        let maxWindow = viewModel.preferences.chartTimeWindow
        let timeWindowOptions = baseTimeWindowOptions + (baseTimeWindowOptions.contains(maxWindow) ? [] : [maxWindow])

        VStack {
            Picker("Time Window", selection: $chartTimeWindow) {
                ForEach(timeWindowOptions.indices, id: \.self) { index in
                    if timeWindowOptions[index] <= maxWindow {
                        Text(formatTimeInterval(timeWindowOptions[index])).tag(timeWindowOptions[index])
                    }
                }
            }
            .pickerStyle(.segmented)
            if viewModel.preferences.showWPMChart {
                chart(data: viewModel.wpmData, label: "WPM", yRange: 0...150)
            }
            if viewModel.preferences.showCPMChart {
                chart(data: viewModel.cpmData, label: "CPM", yRange: 0...500)
            }
            if viewModel.preferences.showAccuracyChart {
                chart(data: viewModel.accuracyData, label: "Accuracy", yRange: 0...100)
            }
        }
        .padding()
    }

    func chart(data: [(x: Date, y: Double)], label: String, yRange: ClosedRange<Double>) -> some View {
        let now = Date()
        let startTime = now.addingTimeInterval(-chartTimeWindow)
        let filteredData = data.filter { $0.x >= startTime }

        return Chart {
            ForEach(filteredData, id: \.x) { item in
                LineMark(x: .value("Time", item.x), y: .value(label, item.y))
            }
            if let pointerTimestamp {
                PointMark(x: .value("Time", pointerTimestamp), y: .value(label, filteredData.first(where: { abs($0.x.timeIntervalSince(pointerTimestamp)) < 1})?.y ?? 0))
                    .foregroundStyle(.red)
            }
        }
        .chartXScale(domain: startTime...now)
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
       .chartOverlay { proxy in
           GeometryReader { geometry in
               Rectangle().fill(.clear).contentShape(Rectangle())
                   .onContinuousHover { phase in
                       switch phase {
                       case .active(let location):
                           pointerTimestamp = proxy.value(atX: location.x, as: Date.self)
                        case .ended:
                           pointerTimestamp = nil
                       }
                   }
           }
       }
        .frame(height: 150)
    }

    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        formatter.numberFormatter.maximumFractionDigits = 1
        let measurement = Measurement(value: interval, unit: UnitDuration.seconds)
        return formatter.string(from: measurement)
    }
}
