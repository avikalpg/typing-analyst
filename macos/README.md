# Typing Analyst

[![GitHub Stars](https://img.shields.io/github/stars/avikalpg/typing-analyst)](https://github.com/avikalpg/typing-analyst/stargazers)
![Contributor activity](https://img.shields.io/github/commit-activity/y/avikalpg/typing-analyst)
![App version](https://img.shields.io/github/v/release/avikalpg/typing-analyst)
![App contributors](https://img.shields.io/github/contributors/avikalpg/typing-analyst)
[![License](https://img.shields.io/badge/license-AGPLv3-purple)](https://github.com/avikalpg/typing-analyst/blob/main/LICENSE)

A MacOS application for analyzing your typing speed, accuracy, and other key metrics.

## About

Typing Analyst helps you track your typing performance by providing real-time statistics and visualizations. It captures your keystrokes for this analysis independent of where you are typing.

Usually, people only measure their typing speed by using standalone applications that give an example text to write. Because this does not emulate how people type in real-life, the output number is often misguiding and not actionable. Typing Analyst measures your typing speed when you naturally type:

- Writing prompts on AI chat interfaces
- Making edits in documents or code
- Sending messages on IM, WhatsApp, Emails etc.

It's designed as a productivity tool for anyone who wants to improve their interaction with computers. Typing Analyst is especially useful for typing enthusiasts, freelance writers, coders, and typing trainers/educators.

### Features

*   Real-time WPM (Words Per Minute), CPM (Characters Per Minute), and Accuracy tracking.
*   Visual graphs of your typing performance over time.
*   Status bar display of key metrics.
*   Preferences to customize data collection and display.

<p align="center">
  <img src="https://github.com/user-attachments/assets/ae13c4f6-311a-4496-b354-e8bdb691034e" alt="TypingAnalyst Screenshot" width="600">
</p>

## Getting Started

### System Requirements
- Minimum macOS version required to run the application: MacOS Ventura (13.0)

### Installation (Important - Read Before Opening)

This app is currently *not notarized* by Apple. Notarization is a process by which Apple checks your app for malicious content and other issues. This means you will likely see a security warning (Gatekeeper) when you first try to open it.

This is because I'm an independent developer starting out and haven't yet enrolled in the Apple Developer Program (which is required for notarization, and is quite costly).

To open the app:

1.  Right-click (or Control-click) on the app icon.
2.  Select "Open" from the context menu.
3.  You'll see a dialog box. Click "Open" again to confirm.

I plan to notarize the app in the future if there's sufficient interest.

###  Permissions (Important)

MacOS Ventura (13.0) and later requires explicit user permission for applications to monitor keyboard and mouse events.  You will need to manually add this application to the "Input Monitoring" section in the Privacy & Security settings.

Here's how to do it:

1. Open "System Settings" (or "System Preferences" on older macOS versions).
1. Go to "Privacy & Security".
1. Select "Input Monitoring".
1. Click the "+" button.
1. Locate and select the application named "Typing Analyst" by searching it in the finder.<br>*(If you are building the application yourself, it might be located in a directory similar to `~/Library/Developer/Xcode/DerivedData/[YourProjectName]/Build/Products/Debug/`.)*
1. Click "Open" to grant the permission.

##  Usage

1.  **Launch the App:** After bypassing Gatekeeper (as described in the Installation section), launch Typing Analyst.
2.  **Status Bar Icon:** An icon will appear in your macOS status bar. This icon displays your current WPM, CPM, and Accuracy.
3.  **Popover Window:** Click the status bar icon to open a popover window. This window contains the graphs visualizing your typing performance.
4.  **Preferences:** Access the app's preferences by clicking on "Typing Analyst" in the menu bar and selecting "Settings..." (or "Preferences..."). In the preferences window, you can:
    *   Adjust the time window for the graphs.
    *   Change the update frequency of the statistics.
    *   Select which metrics to show.
5.  **Tracking:** Typing Analyst automatically tracks your keystrokes in the background while the app is running. You don't need to do anything special to start or stop tracking.
6. **Stopping the timer:** The timer is stopped automatically after a period of inactivity.

##  Contributing

Contributions are welcome! If you find a bug, have a feature request, or want to contribute code, please open an issue or submit a pull request on GitHub.

##  License

This project is licensed under the GNU General Public License v3.0.

A full copy of the license can be found in the `LICENSE` file included with this distribution or at [https://www.gnu.org/licenses/gpl-3.0.en.html](https://www.gnu.org/licenses/gpl-3.0.en.html).

In summary, the GPLv3:

*   **Requires that derivative works are also licensed under the GPLv3.** This is the strong copyleft aspect. If someone modifies your code and distributes it, they must also release their modifications under the GPLv3.
*   **Requires that source code is made available.** If you distribute binaries (compiled versions of your app), you must also provide access to the corresponding source code.
*   **Protects users' freedom to use, study, share, and modify the software.**

This license is chosen to ensure that any improvements or modifications to Typing Analyst remain open and accessible to the community.

## Commercial Use and Monetization

While Typing Analyst is open source under the GPLv3, I, Avikalp Gupta, retain the right to commercially distribute and license the application under different terms. This means:

*   You are free to use, modify, and distribute the application under the terms of the GPLv3.
*   If you wish to distribute Typing Analyst under different terms (e.g., in a closed-source application or as part of a commercial product), you must obtain a separate commercial license from me.

Please contact me at `avikalpgupta [at] gmail [dot] com` for inquiries regarding commercial licensing.

## Contributors

<a href="https://github.com/avikalpg/typing-analyst/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=avikalpg/typing-analyst" />
</a>
