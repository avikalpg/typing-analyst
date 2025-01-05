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
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        guard let data = try? encoder.encode(self),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let dictionary = jsonObject as? [String: Any] else {
            return nil
        }
        print("[TypingData/toKeyValueData] \(dictionary) ")
        return dictionary
    }
}
