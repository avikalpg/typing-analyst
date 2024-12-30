//
//  AppDelegate.swift
//  Typing Analyst
//
//  Created by Avikalp Kumar Gupta on 30/12/24.
//

import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var viewModel: ViewModel! // Store a reference to the ViewModel

    @State private var globalMonitor: Any?

    // Implement time window and refresh rate
    @State private var wpm: Double = 0
    @State private var cpm: Double = 0
    @State private var accuracy: Double = 0
    let timeWindow: TimeInterval = 10 // Time window in seconds
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        viewModel = ViewModel()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            updateStatusBar(button: button) // Initial update
        }

        startGlobalKeyCapture()

        // Observe changes in the ViewModel to update the status bar
        viewModel.$wpm.sink { [weak self] _ in self?.updateStatusBar() }.store(in: &viewModel.cancellables)
        viewModel.$cpm.sink { [weak self] _ in self?.updateStatusBar() }.store(in: &viewModel.cancellables)
        viewModel.$accuracy.sink { [weak self] _ in self?.updateStatusBar() }.store(in: &viewModel.cancellables)
    }

    func applicationWillTerminate(_ notification: Notification) {
        stopGlobalKeyCapture()
    }

    private func updateStatusBar(button: NSStatusBarButton? = nil) {
        let buttonToUpdate = button ?? statusItem.button
        guard let button = buttonToUpdate else { return }

        let wpmString = String(format: "%.0f WPM", viewModel.wpm)
        let cpmString = String(format: "%.0f CPM", viewModel.cpm)
        let accuracyString = String(format: "%.0f%%", viewModel.accuracy)

        button.title = "\(wpmString) | \(cpmString) | \(accuracyString)"
    }

    func startGlobalKeyCapture() {
        let eventMask = NSEvent.EventTypeMask.keyDown

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask) { [weak self] event in
            guard let self = self else { return }
            self.handle(event: event)
        }
    }

    func stopGlobalKeyCapture() {
        if let globalMonitor = globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
            self.globalMonitor = nil
        }
    }

    func handle(event: NSEvent) {
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
        viewModel.addKeystroke(keystroke: keystroke)
    }
}
