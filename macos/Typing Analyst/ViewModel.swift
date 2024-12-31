//
//  ViewModel.swift
//  Typing Analyst
//
//  Created by Avikalp Kumar Gupta on 30/12/24.
//

import SwiftUI
import Foundation
import Combine

class ViewModel: ObservableObject {
    let updateFrequency: TimeInterval = 0.5 // Update every 0.5 seconds
    let timeWindow: TimeInterval = 10
    let chartTimeWindow: TimeInterval = 60 * 60 * 24 // Store data for 24 hours
    lazy var chartDataCapacity: Int = Int(chartTimeWindow / updateFrequency)
    private var lastUpdate: Date?
    
    @Published var wpm: Double = 0
    @Published var cpm: Double = 0
    @Published var accuracy: Double = 0
    private var keystrokes: [Keystroke] = []
    var cancellables = Set<AnyCancellable>() // Store cancellables

    // for adding graph over time
    @Published var wpmData: [(x: Date, y: Double)] = []
    @Published var cpmData: [(x: Date, y: Double)] = []
    @Published var accuracyData: [(x: Date, y: Double)] = []

    init() {
        startTimer()
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    func startTimer() {
        Timer.publish(every: updateFrequency, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.update()
            }.store(in: &cancellables) // Store the cancellable here
    }

    func addKeystroke(keystroke: Keystroke) {
        keystrokes.append(keystroke) // Just append, no need to remove
        update()
    }
    
    func update() {
        guard lastUpdate == nil || Date().timeIntervalSince(lastUpdate!) >= updateFrequency else { return }
        lastUpdate = Date()
        
        wpm = TypingCalculations.calculateWPM(from: keystrokes, in: timeWindow)
        cpm = TypingCalculations.calculateCPM(from: keystrokes, in: timeWindow)
        accuracy = TypingCalculations.calculateAccuracy(from: keystrokes, in: timeWindow)
        
        let now = Date()
        appendWithCapacity(&wpmData, (x: now, y: wpm))
        appendWithCapacity(&cpmData, (x: now, y: cpm))
        appendWithCapacity(&accuracyData, (x: now, y: accuracy))
    }
    
    private func appendWithCapacity(_ array: inout [(x: Date, y: Double)], _ element: (x: Date, y: Double)) {
        array.append(element)
        if array.count > chartDataCapacity {
            array.removeFirst()
        }
    }
}
