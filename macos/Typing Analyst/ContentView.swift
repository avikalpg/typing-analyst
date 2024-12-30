//
//  ContentView.swift
//  Typing Analyst
//
//  Created by Avikalp Kumar Gupta on 30/12/24.
//

import SwiftUI

struct ContentView: View {
    @State private var localMonitor: Any?
    @State private var globalMonitor: Any?
    @State private var hasAppeared = false
    @State private var keystrokes: [Keystroke] = []

    // Implement time window and refresh rate
    @State private var wpm: Double = 0
    @State private var cpm: Double = 0
    @State private var accuracy: Double = 0
    let timeWindow: TimeInterval = 10 // Time window in seconds
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            Text("WPM: \(wpm, format: .number.precision(.fractionLength(2)))")
            Text("CPM: \(cpm, format: .number.precision(.fractionLength(2)))")
            Text("Accuracy: \(accuracy, format: .number.precision(.fractionLength(2)))%")
        }
            .padding()
            .onAppear {
                hasAppeared = true
                if globalMonitor == nil {
                    startGlobalKeyCapture()
                }
            }
            .onDisappear {
                stopGlobalKeyCapture()
            }
            .onReceive(timer) { _ in // Update speed on timer events
                updateSpeedAndAccuracy()
            }
    }

    func startGlobalKeyCapture() {
        guard hasAppeared else { return }

        let eventMask = NSEvent.EventTypeMask.keyDown

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: eventMask) { event in
            handle(event: event, source: "local")
            return event
        }

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask) { event in
            handle(event: event, source: "global")
        }
    }

    func stopGlobalKeyCapture() {
        if let localMonitor = localMonitor {
            NSEvent.removeMonitor(localMonitor)
            self.localMonitor = nil
        }
        if let globalMonitor = globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
            self.globalMonitor = nil
        }
    }

    func handle(event: NSEvent, source: String) {
        if event.isARepeat {
            print("Key is being repeated. Ignoring.")
            return
        }

        let modifierFlags = event.modifierFlags
        var modifiers = ""

        if modifierFlags.contains(.shift) { modifiers += "Shift+" }
        if modifierFlags.contains(.control) { modifiers += "Control+" }
        if modifierFlags.contains(.option) { modifiers += "Option+" }
        if modifierFlags.contains(.command) { modifiers += "Command+" }


        let keystroke = Keystroke(
            timestamp: Date(),
            characters: event.characters,
            keyCode: event.keyCode,
            modifiers: modifiers
        )
        keystrokes.append(keystroke)
        // print("keystrokes: \(keystrokes)")
    }

    func updateSpeedAndAccuracy() {
        wpm = TypingCalculations.calculateWPM(from: keystrokes, in: timeWindow)
        cpm = TypingCalculations.calculateCPM(from: keystrokes, in: timeWindow)
        accuracy = TypingCalculations.calculateAccuracy(from: keystrokes, in: timeWindow)
    }
}
