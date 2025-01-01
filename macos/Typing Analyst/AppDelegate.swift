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
    var viewModel: ViewModel!
    @State private var globalMonitor: Any?
    var preferences: AppPreferences = .load()

    @State private var wpm: Double = 0
    @State private var cpm: Double = 0
    @State private var accuracy: Double = 0

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusItem()
        setupPopover()
        startGlobalKeyCapture()
        setupObservers()
        
        if !UserDefaults.standard.bool(forKey: "hasShownFirstRunAlert") {
            showFirstRunAlert()
            UserDefaults.standard.set(true, forKey: "hasShownFirstRunAlert")
        }
    }
    
    private func showFirstRunAlert() {
        let alert = NSAlert()
        alert.messageText = "App Not (yet) Notarized"
        alert.informativeText = "This app is currently not notarized by Apple. This means you might see a security warning when you first try to open it. This is because I'm an independent developer starting out and haven't yet enrolled in the Apple Developer Program.\n\nTo open the app:\n1. Right-click (or Control-click) on the app icon.\n2. Select 'Open' from the context menu.\n3. You'll see a dialog box. Click 'Open' again to confirm.\n\nI plan to notarize the app in the future if there's sufficient interest."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    func applicationWillTerminate(_ notification: Notification) {
        stopGlobalKeyCapture()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "Typing Analyst")
            button.action = #selector(togglePopover(_:))
            updateStatusBar(button: button)
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentViewController = NSHostingController(rootView: PopoverView(viewModel: viewModel))
        popover.behavior = .transient
    }

    private func setupObservers() {
        viewModel.$wpm.sink { [weak self] _ in self?.updateStatusBar() }
            .store(in: &viewModel.cancellables)
        viewModel.$cpm.sink { [weak self] _ in self?.updateStatusBar() }
            .store(in: &viewModel.cancellables)
        viewModel.$accuracy.sink { [weak self] _ in self?.updateStatusBar() }
            .store(in: &viewModel.cancellables)
    }

    @objc func togglePopover(_ sender: Any?) {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController = NSHostingController(rootView: PopoverView(viewModel: viewModel))
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func updateStatusBar(button: NSStatusBarButton? = nil) {
        let buttonToUpdate = button ?? statusItem.button
        guard let button = buttonToUpdate else { return }

        var statusComponents: [String] = []

        if viewModel.preferences.showWPMChart {
            statusComponents.append(String(format: "%.0f WPM", viewModel.wpm))
        }

        if viewModel.preferences.showCPMChart {
            statusComponents.append(String(format: "%.0f CPM", viewModel.cpm))
        }

        if viewModel.preferences.showAccuracyChart {
            statusComponents.append(String(format: "%.0f%%", viewModel.accuracy))
        }

        button.title = statusComponents.joined(separator: " | ")
    }

    func startGlobalKeyCapture() {
        let eventMask = NSEvent.EventTypeMask.keyDown
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask) { [weak self] event in
            self?.handle(event: event)
        }
    }

    func stopGlobalKeyCapture() {
        if let globalMonitor = globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
            self.globalMonitor = nil
        }
    }

    func handle(event: NSEvent) {
        guard !event.isARepeat else {
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
