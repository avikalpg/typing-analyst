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

    var body: some View {
        Text("Keystroke Monitor Running")
            .padding()
            .onAppear {
                startGlobalKeyCapture()
            }
            .onDisappear {
                stopGlobalKeyCapture()
            }
    }

    func startGlobalKeyCapture() {
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
        print("keystrokes: \(keystrokes)")
    }
}
