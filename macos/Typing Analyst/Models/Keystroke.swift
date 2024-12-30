//
//  Keystroke.swift
//  Typing Analyst
//
//  Created by Avikalp Kumar Gupta on 30/12/24.
//
import Foundation

struct Keystroke {
    let id = UUID()
    let timestamp: Date
    let characters: String? // nil for special keys
    let keyCode: UInt16
    let modifiers: String // e.g., "Shift+", "Control+Option+", "" (for no modifiers)
}
