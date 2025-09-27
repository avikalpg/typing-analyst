//
//  PopoverView.swift
//  Typing Analyst
//
//  Created by Avikalp Kumar Gupta on 30/12/24.
//

import SwiftUI
import Charts

struct SelectedRangeStats {
    let startTime: Date
    let endTime: Date
    let averageWPM: Double
    let averageCPM: Double
    let averageAccuracy: Double
    let dataPointCount: Int
}

struct PopoverView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var chartTimeWindow: TimeInterval = 60 * 5
    @State private var pointerTimestamp: Date? = nil
    @State private var dragStart: Date? = nil
    @State private var dragEnd: Date? = nil
    @State private var isDragging = false
    @State private var selectedRangeStats: SelectedRangeStats? = nil

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

        VStack(spacing: 0) {
            Picker("Time Window", selection: $chartTimeWindow) {
                ForEach(timeWindowOptions, id: \.self) { option in
                    if option <= maxWindow {
                        Text(formatTimeInterval(option)).tag(option)
                    }
                }
            }
            .pickerStyle(.segmented)
            .frame(height: 32)

            ScrollView {
                VStack {
                    if viewModel.preferences.showWPMChart {
                        chart(data: viewModel.wpmData, label: "WPM", yRange: 0...150, showPointerTimestamp: true)
                    }
                    if viewModel.preferences.showCPMChart {
                        chart(data: viewModel.cpmData, label: "CPM", yRange: 0...500, showPointerTimestamp: false)
                    }
                    if viewModel.preferences.showAccuracyChart {
                        chart(data: viewModel.accuracyData, label: "Accuracy", yRange: 0...100, ySuffix: "%", showPointerTimestamp: false)
                    }

                    if let stats = selectedRangeStats {
                        selectedRangeView(stats: stats)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .frame(maxHeight: calculateMaxHeight())
        }
        .padding()
        .fixedSize(horizontal: false, vertical: true)
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

            // Selection overlay
            if let dragStart, let dragEnd {
                let selectionStart = min(dragStart, dragEnd)
                let selectionEnd = max(dragStart, dragEnd)
                RectangleMark(
                    xStart: .value("Start", selectionStart),
                    xEnd: .value("End", selectionEnd),
                    yStart: .value("Y Start", yRange.lowerBound),
                    yEnd: .value("Y End", yRange.upperBound)
                )
                .foregroundStyle(.blue.opacity(0.2))
                .clipShape(Rectangle())
            }

            if let pointerTimestamp, !isDragging {
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
                    .gesture(
                        DragGesture(minimumDistance: 5)
                            .onChanged { value in
                                let plotAreaFrame = geometry[proxy.plotFrame!]
                                let startLocation = CGPoint(
                                    x: value.startLocation.x - plotAreaFrame.origin.x,
                                    y: value.startLocation.y - plotAreaFrame.origin.y
                                )
                                let currentLocation = CGPoint(
                                    x: value.location.x - plotAreaFrame.origin.x,
                                    y: value.location.y - plotAreaFrame.origin.y
                                )

                                if !isDragging {
                                    isDragging = true
                                    pointerTimestamp = nil
                                }

                                dragStart = proxy.value(atX: startLocation.x, as: Date.self)
                                dragEnd = proxy.value(atX: currentLocation.x, as: Date.self)
                            }
                            .onEnded { _ in
                                isDragging = false
                                if let start = dragStart, let end = dragEnd {
                                    calculateSelectedRangeStats(startTime: min(start, end), endTime: max(start, end))
                                }
                            }
                    )
                    .onContinuousHover { phase in
                        if !isDragging {
                            switch phase {
                            case .active(let location):
                                let plotAreaFrame = geometry[proxy.plotFrame!]
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
                    .onTapGesture {
                        // Clear selection on tap
                        dragStart = nil
                        dragEnd = nil
                        selectedRangeStats = nil
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

    private func calculateMaxHeight() -> CGFloat {
        var enabledCharts = 0
        if viewModel.preferences.showWPMChart { enabledCharts += 1 }
        if viewModel.preferences.showCPMChart { enabledCharts += 1 }
        if viewModel.preferences.showAccuracyChart { enabledCharts += 1 }

        let baseHeight: CGFloat = 150 // Height per chart
        let selectedStatsHeight: CGFloat = selectedRangeStats != nil ? 80 : 0 // Reduced since we always show consistent stats
        let padding: CGFloat = 40

        return CGFloat(enabledCharts) * baseHeight + selectedStatsHeight + padding
    }

    private func calculateSelectedRangeStats(startTime: Date, endTime: Date) {
        // Filter data within the selected range
        let wpmInRange = viewModel.wpmData.filter { $0.x >= startTime && $0.x <= endTime }
        let cpmInRange = viewModel.cpmData.filter { $0.x >= startTime && $0.x <= endTime }
        let accuracyInRange = viewModel.accuracyData.filter { $0.x >= startTime && $0.x <= endTime }

        guard !wpmInRange.isEmpty, !cpmInRange.isEmpty, !accuracyInRange.isEmpty else {
            selectedRangeStats = nil
            return
        }

        // Calculate averages
        let avgWPM = wpmInRange.map { $0.y }.reduce(0, +) / Double(wpmInRange.count)
        let avgCPM = cpmInRange.map { $0.y }.reduce(0, +) / Double(cpmInRange.count)
        let avgAccuracy = accuracyInRange.map { $0.y }.reduce(0, +) / Double(accuracyInRange.count)

        selectedRangeStats = SelectedRangeStats(
            startTime: startTime,
            endTime: endTime,
            averageWPM: avgWPM,
            averageCPM: avgCPM,
            averageAccuracy: avgAccuracy,
            dataPointCount: min(wpmInRange.count, min(cpmInRange.count, accuracyInRange.count))
        )
    }

    private func selectedRangeView(stats: SelectedRangeStats) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Selected Range Statistics")
                .font(.headline)
                .foregroundColor(.primary)

            HStack {
                Text("Time Range:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(stats.startTime, formatter: timeFormatter) - \(stats.endTime, formatter: timeFormatter) (\(formatTimeInterval(stats.endTime.timeIntervalSince(stats.startTime))))")
                    .font(.caption)
                    .foregroundColor(.primary)
            }


            HStack {
                Text("Average WPM:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(stats.averageWPM, format: .number.precision(.fractionLength(1)))")
                    .font(.caption)
                    .foregroundColor(.primary)
            }

            HStack {
                Text("Average CPM:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(stats.averageCPM, format: .number.precision(.fractionLength(1)))")
                    .font(.caption)
                    .foregroundColor(.primary)
            }

            HStack {
                Text("Average Accuracy:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(stats.averageAccuracy, format: .number.precision(.fractionLength(1)))%")
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter
    }
}
