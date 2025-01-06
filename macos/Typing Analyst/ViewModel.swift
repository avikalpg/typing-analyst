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
    var preferences: AppPreferences
    lazy var chartDataCapacity: Int = Int(preferences.chartTimeWindow / preferences.updateFrequency)
    private var lastUpdate: Date?
    
    @Published var wpm: Double = 0
    @Published var cpm: Double = 0
    @Published var accuracy: Double = 0
    private(set) var keystrokes: [Keystroke] = []

    // for adding graph over time
    @Published var wpmData: [(x: Date, y: Double)] = []
    @Published var cpmData: [(x: Date, y: Double)] = []
    @Published var accuracyData: [(x: Date, y: Double)] = []
    
    private let typingDataSender: TypingDataSender

    init(preferences: AppPreferences, typingDataSender: TypingDataSender) {
        self.preferences = preferences
        self.typingDataSender = typingDataSender
        DispatchQueue.main.async {
            self.startTimer()
        }
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    func updatePreferences() {
        chartDataCapacity = Int(preferences.chartTimeWindow / preferences.updateFrequency)
        startTimer()
    }
    
    func startTimer() {
        guard let appDelegate = NSApp.delegate as? AppDelegate else {
            // TODO: Handle the case where the app delegate is nil (e.g., during testing)
            print("AppDelegate is nil. Timer will not start.")
            return
        }
        
        Timer.publish(every: preferences.updateFrequency, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.update()
            }
            .store(in: &appDelegate.cancellables) // Store the cancellable here
    }

    func addKeystroke(keystroke: Keystroke) {
        keystrokes.append(keystroke) // Just append, no need to remove
        update()
        typingDataSender.addKeystrokesToChunk(keystroke: keystroke)
    }
    
    func update() {
        guard lastUpdate == nil || Date().timeIntervalSince(lastUpdate!) >= preferences.updateFrequency else { return }
        lastUpdate = Date()
        
        wpm = TypingCalculations.calculateWPM(from: keystrokes, in: preferences.dataTimeWindow)
        cpm = TypingCalculations.calculateCPM(from: keystrokes, in: preferences.dataTimeWindow)
        accuracy = TypingCalculations.calculateAccuracy(from: keystrokes, in: preferences.dataTimeWindow)
        
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
