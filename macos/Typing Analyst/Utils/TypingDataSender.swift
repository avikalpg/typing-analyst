//
//  TypingDataSender.swift
//  Typing Analyst
//
//  Created by Avikalp on 04/01/25.
//

import Foundation
import AppKit

class TypingDataSender: NSObject {
    private var lastActivity: Date?
    private var timer: Timer?
    private let inactivityInterval: TimeInterval = 10 // 10 seconds
    private var currentChunkKeystrokes: [Keystroke] = []

    override init() {
        super.init()
    }

    deinit {
        timer?.invalidate()
    }

    func addKeystrokesToChunk(keystroke: Keystroke) {
        guard UserDefaults.standard.bool(forKey: "isLoggedIn") else { return }
        currentChunkKeystrokes.append(keystroke)
        resetInactivityTimer()
    }

    private func resetInactivityTimer() {
        lastActivity = Date()
        timer?.invalidate() // Invalidate existing timer

        timer = Timer.scheduledTimer(withTimeInterval: inactivityInterval, repeats: false) { [weak self] _ in
            self?.sendTypingDataToServer()
        }
    }

    private func createTypingDataFromKeystrokes(keystrokes: [Keystroke]) -> TypingData {
        let startTime = keystrokes.first!.timestamp
        let endTime = keystrokes.last!.timestamp
        let chunkStats: ChunkStats = ChunkStats(
            totalKeystrokes: keystrokes.count,
            totalWords: keystrokes.filter { $0.characters == " " }.count,
            accuracy: TypingCalculations.calculateAccuracyDuring(keystrokes: keystrokes, from: startTime, to: endTime)
        )
        let perSecondData = groupKeystrokesBySecond(keystrokes: keystrokes)

        let dataToSend: TypingData = TypingData(
            start_timestamp: startTime,
            end_timestamp: endTime,
            application: "unknown",
            device_id: "unknown",
            keyboard_id: "unknown",
            locale: "en_US",
            per_second_data: perSecondData,
            chunk_stats: chunkStats
        )

        return dataToSend
    }

    private func sendTypingDataToServer() {
        guard !currentChunkKeystrokes.isEmpty else { return }

        let dataToSend = createTypingDataFromKeystrokes(keystrokes: currentChunkKeystrokes)

        AuthManager.shared.sendTypingData(data: dataToSend) { result in
            switch result {
            case .success():
                print("Typing data sent successfully")
                self.currentChunkKeystrokes = [] // Clear current data
            case .failure(let error):
                print("Error sending typing data: \(error)")
                // Handle the error appropriately (e.g., retry, log)
            }
        }
    }

    private func groupKeystrokesBySecond(keystrokes: [Keystroke]) -> [PerSecondDataPoint] {
        guard !keystrokes.isEmpty else { return [] }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Format to group by second
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        var perSecondDataPoints: [PerSecondDataPoint] = []
        var currentSecondKeystrokes: [Keystroke] = []
        var currentSecond: String?

        for keystroke in keystrokes.sorted(by: { $0.timestamp < $1.timestamp }) { // Sort keystrokes by time
            let keystrokeSecond = dateFormatter.string(from: keystroke.timestamp)

            if keystrokeSecond != currentSecond {
                if let currentSecond = currentSecond, !currentSecondKeystrokes.isEmpty {
                    let perSecondDataPoint = createPerSecondDataPoint(
                        timestamp: dateFormatter.date(from: currentSecond)!,
                        keystrokes: currentSecondKeystrokes
                    )
                    perSecondDataPoints.append(perSecondDataPoint)
                }
                currentSecond = keystrokeSecond
                currentSecondKeystrokes = [keystroke]
            } else {
                currentSecondKeystrokes.append(keystroke)
            }
        }

        // Add the last group
        if let currentSecond = currentSecond, !currentSecondKeystrokes.isEmpty {
            let perSecondDataPoint = createPerSecondDataPoint(
                timestamp: dateFormatter.date(from: currentSecond)!,
                keystrokes: currentSecondKeystrokes
            )
            perSecondDataPoints.append(perSecondDataPoint)
        }

        return perSecondDataPoints
    }

    private func createPerSecondDataPoint(timestamp: Date, keystrokes: [Keystroke]) -> PerSecondDataPoint {
        var keystrokeCount = 0
        var wordCount = 0
        var backspaceCount = 0
        var alphabetCount = 0
        var numberCount = 0
        var symbolCount = 0
        var modifierCount = 0

        for keystroke in keystrokes {
            keystrokeCount += 1

            if let characters = keystroke.characters {
                wordCount += characters.split(separator: " ").count
                for character in characters {
                    if character.isLetter {
                        alphabetCount += 1
                    } else if character.isNumber {
                        numberCount += 1
                    } else if character.isSymbol || character.isPunctuation {
                        symbolCount += 1
                    }
                }
            }

            if keystroke.keyCode == 51 { // Backspace key code
                backspaceCount += 1
            }

            modifierCount += keystroke.modifiers.split(separator: "+").count - (keystroke.modifiers == "" ? 0 : 1)
        }
        let accuracy = keystrokeCount == 0 ? 100.0 : Double(keystrokeCount - backspaceCount) / Double(keystrokeCount) * 100.0
        return PerSecondDataPoint(
            timestamp: timestamp,
            keystrokes: keystrokeCount,
            words: wordCount,
            backspaces: backspaceCount,
            accuracy: accuracy,
            keyStats: KeyStats(
                alphabets: alphabetCount,
                numbers: numberCount,
                symbols: symbolCount,
                backspaces: backspaceCount,
                modifiers: modifierCount
            )
        )
    }
}
