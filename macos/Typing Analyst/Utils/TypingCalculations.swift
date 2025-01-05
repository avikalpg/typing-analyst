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

    static func calculateAccuracy(from keystrokes: [Keystroke], in timeWindow: TimeInterval) -> Double {
        let now = Date()
        let startTime = now.addingTimeInterval(-timeWindow)
        return calculateAccuracyDuring(keystrokes: keystrokes, from: startTime, to: now)
    }
        
    static func calculateAccuracyDuring(keystrokes: [Keystroke], from: Date, to: Date) -> Double {
        guard !keystrokes.isEmpty else { return 100.0 } // 100% if no input
        let relevantKeystrokes = keystrokes.filter { to.timeIntervalSince($0.timestamp) <= to.timeIntervalSince(from) }

        guard !relevantKeystrokes.isEmpty else { return 100.0 }

        var correctCharacters = 0
        var totalCharacters = 0

        var currentString = ""

        for keystroke in relevantKeystrokes {
            if let characters = keystroke.characters {
                if keystroke.keyCode == 51 {
                    if !currentString.isEmpty {
                        currentString.removeLast()
                    }
                } else {
                    currentString.append(characters)
                }
            }
        }
        
        totalCharacters = relevantKeystrokes.reduce(0) { (count, keystroke) -> Int in
            if let charCount = keystroke.characters?.count, keystroke.keyCode != 51 {
                return count + charCount
            }
            return count
        }
        
        correctCharacters = currentString.count
        
        if totalCharacters == 0 {
            return 100.0
        }

        let accuracy = Double(correctCharacters) / Double(totalCharacters) * 100
        return accuracy
    }
}
