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
    private var popover: NSPopover!
    var viewModel: ViewModel! // Store a reference to the ViewModel
    @State private var globalMonitor: Any?
    var preferences: AppPreferences = .load()

    // Implement time window and refresh rate
    @State private var wpm: Double = 0
    @State private var cpm: Double = 0
    @State private var accuracy: Double = 0

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "Typing Analyst")
            button.action = #selector(togglePopover(_:)) // Set the action
            updateStatusBar(button: button) // Initial update
        }
        
        popover = NSPopover()
        popover.contentViewController = NSHostingController(rootView: PopoverView(viewModel: self.viewModel))
        popover.behavior = .transient

        startGlobalKeyCapture()

        // Observe changes in the ViewModel to update the status bar
        self.viewModel.$wpm.sink { [weak self] _ in self?.updateStatusBar() }.store(in: &self.viewModel.cancellables)
        self.viewModel.$cpm.sink { [weak self] _ in self?.updateStatusBar() }.store(in: &self.viewModel.cancellables)
        self.viewModel.$accuracy.sink { [weak self] _ in self?.updateStatusBar() }.store(in: &self.viewModel.cancellables)
    }

    func applicationWillTerminate(_ notification: Notification) {
        stopGlobalKeyCapture()
    }
    
    @objc func togglePopover(_ sender: Any?) {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController = NSHostingController(rootView: PopoverView(viewModel: self.viewModel)) // Ensure view model is passed
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func updateStatusBar(button: NSStatusBarButton? = nil) {
        let buttonToUpdate = button ?? statusItem.button
        guard let button = buttonToUpdate else { return }

        let wpmString = String(format: "%.0f WPM", self.viewModel.wpm)
        let cpmString = String(format: "%.0f CPM", self.viewModel.cpm)
        let accuracyString = String(format: "%.0f%%", self.viewModel.accuracy)

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
        self.viewModel.addKeystroke(keystroke: keystroke)
    } 
}
