//
//  TypingCalculations.swift
//  Typing Analyst
//
//  Created by Avikalp Kumar Gupta on 30/12/24.
//

import Foundation

struct TypingCalculations { // Putting the functions inside a struct is also a good practice
    static func calculateWPM(from keystrokes: [Keystroke]) -> Double {
        guard keystrokes.count > 0 else { return 0 }

        let startTime = keystrokes.first!.timestamp
        let endTime = keystrokes.last!.timestamp
        let timeInterval = endTime.timeIntervalSince(startTime)

        guard timeInterval > 0 else { return 0 }

        let words = keystrokes.reduce(0) { (count, keystroke) -> Int in
            if keystroke.characters == " " {
                return count + 1
            }
            return count
        }

        let wpm = Double(words) / (timeInterval / 60.0)
        return wpm
    }

    static func calculateCPM(from keystrokes: [Keystroke]) -> Double {
        guard keystrokes.count > 0 else { return 0 }

        let startTime = keystrokes.first!.timestamp
        let endTime = keystrokes.last!.timestamp
        let timeInterval = endTime.timeIntervalSince(startTime)

        guard timeInterval > 0 else { return 0 }

        let characters = keystrokes.reduce(0) { (count, keystroke) -> Int in
            if let charCount = keystroke.characters?.count {
                return count + charCount
            }
            return count
        }

        let cpm = Double(characters) / (timeInterval / 60.0)
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
