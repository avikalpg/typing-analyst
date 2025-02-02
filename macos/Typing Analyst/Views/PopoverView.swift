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
                ForEach(timeWindowOptions, id: \.self) { option in
                    if option <= maxWindow {
                        Text(formatTimeInterval(option)).tag(option)
                    }
                }
            }
            .pickerStyle(.segmented)
            if viewModel.preferences.showWPMChart {
                chart(data: viewModel.wpmData, label: "WPM", yRange: 0...150, showPointerTimestamp: true)
            }
            if viewModel.preferences.showCPMChart {
                chart(data: viewModel.cpmData, label: "CPM", yRange: 0...500, showPointerTimestamp: false)
            }
            if viewModel.preferences.showAccuracyChart {
                chart(data: viewModel.accuracyData, label: "Accuracy", yRange: 0...100, ySuffix: "%", showPointerTimestamp: false)
            }
        }
        .padding()
    }

    func chart(data: [(x: Date, y: Double)], label: String, yRange: ClosedRange<Double>, ySuffix: String = "", showPointerTimestamp: Bool = true) -> some View {
        let now = Date()
        let startTime = now.addingTimeInterval(-chartTimeWindow)
        let filteredData = data.filter { $0.x >= startTime }
        let yMidpoint = (yRange.lowerBound + yRange.upperBound) / 2

        return Chart {
            ForEach(filteredData, id: \.x) { item in
                LineMark(x: .value("Time", item.x), y: .value(label, item.y))
            }
            if let pointerTimestamp {
                if let point = filteredData.first(where: { abs($0.x.timeIntervalSince(pointerTimestamp)) < 1}) {
                    PointMark(x: .value("Time", pointerTimestamp), y: .value(label, point.y))
                        .foregroundStyle(.red)
                        .annotation(position: point.y <= yMidpoint ? .top : .bottom) {
                            Text("\(point.y, format: .number.precision(.fractionLength(0)))\(ySuffix)")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                }
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
            if showPointerTimestamp {
                AxisMarks(position: .top, values: [pointerTimestamp ?? Date()]) { value in
                    if value.as(Date.self) != nil {
                        AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .wide)).minute(.defaultDigits).second(.defaultDigits))
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .chartYScale(domain: yRange)
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    let formattedValue = value.as(Double.self).map {
                        Decimal($0).formatted(.number.rounded(rule: .toNearestOrEven))
                    } ?? ""
                    Text(formattedValue + ySuffix)
                }
            }
        }
        .frame(height: 150)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .onContinuousHover { phase in
                        switch phase {
                        case .active(let location):
                            let plotAreaFrame = geometry[proxy.plotAreaFrame]
                            let adjustedLocation = CGPoint(
                                x: location.x - plotAreaFrame.origin.x,
                                y: location.y - plotAreaFrame.origin.y
                            )
                            pointerTimestamp = proxy.value(atX: adjustedLocation.x, as: Date.self)
                        case .ended:
                            pointerTimestamp = nil
                        }
                    }
            }
        }
    }

    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        formatter.numberFormatter.maximumFractionDigits = 1
        let measurement = Measurement(value: interval, unit: UnitDuration.seconds)
        return formatter.string(from: measurement)
    }
}
