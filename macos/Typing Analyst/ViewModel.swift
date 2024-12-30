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
    @Published var wpm: Double = 0
    @Published var cpm: Double = 0
    @Published var accuracy: Double = 0
    private var keystrokes: [Keystroke] = []
    let timeWindow: TimeInterval = 10
    var cancellables = Set<AnyCancellable>() // Store cancellables

    init() {
        startTimer()
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    func startTimer() {
        Timer.publish(every: 0.5, on: .main, in: .common)
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
        wpm = TypingCalculations.calculateWPM(from: keystrokes, in: timeWindow)
        cpm = TypingCalculations.calculateCPM(from: keystrokes, in: timeWindow)
        accuracy = TypingCalculations.calculateAccuracy(from: keystrokes, in: timeWindow)
    }
}
