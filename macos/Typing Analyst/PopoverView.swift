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

    var body: some View {
        VStack {
            Chart {
                ForEach(viewModel.wpmData, id: \.x) { item in
                    LineMark(x: .value("Time", item.x, unit: .second), y: .value("WPM", item.y))
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom, values: .stride(by: .second)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.second(.defaultDigits))
                }
            }
            .frame(height: 100)
            Chart {
                ForEach(viewModel.cpmData, id: \.x) { item in
                    LineMark(x: .value("Time", item.x, unit: .second), y: .value("CPM", item.y))
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom, values: .stride(by: .second)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.second(.defaultDigits))
                }
            }
            .frame(height: 100)
            Chart {
                ForEach(viewModel.accuracyData, id: \.x) { item in
                    LineMark(x: .value("Time", item.x, unit: .second), y: .value("Accuracy", item.y))
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom, values: .stride(by: .second)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.second(.defaultDigits))
                }
            }
            .frame(height: 100)
        }
        .padding()
    }
}
