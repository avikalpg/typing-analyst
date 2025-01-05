//
//  TypingData.swift
//  Typing Analyst
//
//  Created by Avikalp on 04/01/25.
//

import Foundation

struct TypingData: Encodable { // Make it Encodable for JSON serialization
    let start_timestamp: Date
    let end_timestamp: Date?
    let application: String
    let device_id: String?
    let keyboard_id: String?
    let locale: String
    let per_second_data: [PerSecondDataPoint]
    let chunk_stats: ChunkStats
}

struct PerSecondDataPoint: Encodable {
    let timestamp: Date
    let keystrokes: Int
    let words: Int
    let backspaces: Int
    let accuracy: Double
    let keyStats: KeyStats
}

struct KeyStats: Encodable {
    let alphabets: Int
    let numbers: Int
    let symbols: Int
    let backspaces: Int
    let modifiers: Int
}

struct ChunkStats: Encodable {
    let totalKeystrokes: Int
    let totalWords: Int
    let accuracy: Double
//    let peakSpeed: Int?
//    let longestStreak: Int?
}

extension TypingData {
    func toKeyValueData() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              var dictionary = jsonObject as? [String: Any] else {
            return nil
        }
        // Convert Date objects to milliseconds since epoch
        for (key, value) in dictionary {
            if let date = value as? Date {
                dictionary[key] = Int64(date.timeIntervalSince1970 * 1000)
            } else if let array = value as? [Any] { // Handle arrays of PerSecondDataPoint
                var newArray: [[String: Any]] = []
                for item in array {
                    if var itemDict = item as? [String: Any] {
                        for (itemKey, itemValue) in itemDict {
                            if let itemDate = itemValue as? Date {
                                itemDict[itemKey] = Int64(itemDate.timeIntervalSince1970 * 1000)
                            }
                        }
                        newArray.append(itemDict)
                    }
                }
                dictionary[key] = newArray
            }
        }
        return dictionary
    }
}
