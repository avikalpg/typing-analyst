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

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: eventMask) { (event) -> NSEvent? in
            handle(event: event, source: "local")
            return event
        }

        print("TEST print statement for global monitor")
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask) { (event) in
            handle(event: event, source: "global")
        }
    }

    func stopGlobalKeyCapture() {
        if let localMonitor = localMonitor {
            NSEvent.removeMonitor(localMonitor)
            self.localMonitor = nil // Now this works
        }
        if let globalMonitor = globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
            self.globalMonitor = nil // Now this works
        }
    }

    func handle(event: NSEvent, source: String) {
        guard let characters = event.charactersIgnoringModifiers else { return }
        print("\(source) Key pressed: \(characters)")
    }
}
