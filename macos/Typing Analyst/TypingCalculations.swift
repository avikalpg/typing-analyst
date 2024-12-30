//
//  TypingCalculations.swift
//  Typing Analyst
//
//  Created by Avikalp Kumar Gupta on 30/12/24.
//

import Foundation

struct TypingCalculations {
    static func calculateWPM(from keystrokes: [Keystroke], in timeWindow: TimeInterval) -> Double {
        guard !keystrokes.isEmpty else { return 0 }

        let now = Date()
        let relevantKeystrokes = keystrokes.filter { now.timeIntervalSince($0.timestamp) <= timeWindow }

        guard !relevantKeystrokes.isEmpty else { return 0 }
        
        let words = relevantKeystrokes.reduce(0) { (count, keystroke) -> Int in
            if keystroke.characters == " " {
                return count + 1
            }
            return count
        }

        let wpm = Double(words) / (timeWindow / 60.0) // Words per minute
        return wpm
    }

    static func calculateCPM(from keystrokes: [Keystroke], in timeWindow: TimeInterval) -> Double {
        guard !keystrokes.isEmpty else { return 0 }

        let now = Date()
        let relevantKeystrokes = keystrokes.filter { now.timeIntervalSince($0.timestamp) <= timeWindow }
        
        guard !relevantKeystrokes.isEmpty else { return 0 }

        let characters = relevantKeystrokes.reduce(0) { (count, keystroke) -> Int in
            if let charCount = keystroke.characters?.count {
                return count + charCount
            }
            return count
        }

        let cpm = Double(characters) / (timeWindow / 60.0) // Characters per minute
        return cpm
    }

    static func calculateAccuracy(from keystrokes: [Keystroke]) -> Double {
        guard keystrokes.count > 0 else { return 0 }

        var errors = 0
        var corrections = 0

        for (index, keystroke) in keystrokes.enumerated() {
            if keystroke.keyCode == 51 {
                errors += 1
                if index > 0 {
                    corrections += 1
                }
            }
        }

        let accuracy = Double(keystrokes.count - errors + corrections) / Double(keystrokes.count) * 100
        return accuracy
    }
}
