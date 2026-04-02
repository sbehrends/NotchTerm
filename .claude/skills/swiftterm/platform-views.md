# Platform Views

macOS `LocalProcessTerminalView`, iOS `TerminalView`, and `LocalProcess` PTY management.

## macOS LocalProcessTerminalView

`LocalProcessTerminalView` is an AppKit NSView that combines terminal rendering with local process management, providing a complete terminal emulator UI connected to a local shell.

```swift
import SwiftTerm
import AppKit

class TerminalWindowController: NSWindowController, LocalProcessTerminalViewDelegate {
    var terminalView: LocalProcessTerminalView!

    override func windowDidLoad() {
        super.windowDidLoad()

        // Create terminal view
        terminalView = LocalProcessTerminalView(frame: window!.contentView!.bounds)
        terminalView.processDelegate = self
        terminalView.autoresizingMask = [.width, .height]

        // Customize appearance
        terminalView.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        terminalView.nativeForegroundColor = .white
        terminalView.nativeBackgroundColor = .black
        terminalView.caretColor = .cyan

        // Configure behavior
        terminalView.optionAsMetaKey = true     // Option sends ESC prefix
        terminalView.allowMouseReporting = true  // Enable mouse tracking

        window!.contentView!.addSubview(terminalView)

        // Start shell process
        terminalView.startProcess(
            executable: "/bin/zsh",
            args: ["-l"],  // Login shell
            environment: nil,  // Uses Terminal.getEnvironmentVariables()
            currentDirectory: NSHomeDirectory()
        )
    }

    // LocalProcessTerminalViewDelegate methods
    func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {
        window?.title = "Terminal (\(newCols)×\(newRows))"
    }

    func setTerminalTitle(source: LocalProcessTerminalView, title: String) {
        window?.title = title
    }

    func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {
        if let dir = directory {
            print("Working directory: \(dir)")
        }
    }

    func processTerminated(source: TerminalView, exitCode: Int32?) {
        print("Process exited with code: \(exitCode ?? -1)")
        window?.close()
    }
}
```

## iOS TerminalView

On iOS, `TerminalView` provides the terminal UI as a UIView. Since iOS doesn't support local processes, you connect it to a remote shell via SSH or another network protocol.

```swift
import SwiftTerm
import UIKit

class iOSTerminalViewController: UIViewController, TerminalViewDelegate {
    var terminalView: TerminalView!
    var sshConnection: SSHConnection?  // Your SSH implementation

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create terminal view
        terminalView = TerminalView(frame: view.bounds)
        terminalView.terminalDelegate = self
        terminalView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Customize appearance
        terminalView.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        terminalView.nativeForegroundColor = .white
        terminalView.nativeBackgroundColor = .black

        // iOS-specific settings
        terminalView.optionAsMetaKey = true
        terminalView.allowMouseReporting = false  // Better for touch

        view.addSubview(terminalView)

        // Connect to SSH server and feed data
        connectSSH()
    }

    func connectSSH() {
        // Feed initial data for testing
        terminalView.feed(text: "Connected to remote server\r\n")
        terminalView.feed(text: "$ ")
    }

    // TerminalViewDelegate methods
    func send(source: TerminalView, data: ArraySlice<UInt8>) {
        // Send user input to SSH connection
        sshConnection?.write(data: Data(data))
    }

    func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {
        // Notify SSH server of terminal size change
        sshConnection?.setTerminalSize(cols: newCols, rows: newRows)
    }

    func setTerminalTitle(source: TerminalView, title: String) {
        navigationItem.title = title
    }

    func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) { }
    func scrolled(source: TerminalView, position: Double) { }
    func requestOpenLink(source: TerminalView, link: String, params: [String: String]) {
        if let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }
    func bell(source: TerminalView) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    func clipboardCopy(source: TerminalView, content: Data) {
        if let text = String(data: content, encoding: .utf8) {
            UIPasteboard.general.string = text
        }
    }
    func iTermContent(source: TerminalView, content: ArraySlice<UInt8>) { }
    func rangeChanged(source: TerminalView, startY: Int, endY: Int) { }
}
```

## LocalProcess for Shell Management

`LocalProcess` manages a child process inside a pseudo-terminal (PTY). It handles process lifecycle, I/O routing, and terminal window size updates.

```swift
import SwiftTerm

class ShellManager: LocalProcessDelegate {
    var process: LocalProcess!
    var terminal: Terminal!

    init() {
        // Create terminal first
        terminal = Terminal(delegate: self, options: .default)

        // Create process manager
        process = LocalProcess(
            delegate: self,
            dispatchQueue: DispatchQueue.main
        )
    }

    func startShell() {
        // Get environment variables for the shell
        let env = Terminal.getEnvironmentVariables(
            termName: "xterm-256color",
            trueColor: true
        )

        // Start the process
        process.startProcess(
            executable: "/bin/bash",
            args: ["--login"],
            environment: env,
            execName: "-bash",  // Login shell (starts with -)
            currentDirectory: NSHomeDirectory()
        )

        print("Shell PID: \(process.shellPid)")
        print("Running: \(process.running)")
    }

    func sendCommand(_ command: String) {
        let data = Array(command.utf8)
        process.send(data: data[...])
    }

    func resize(cols: Int, rows: Int) {
        terminal.resize(cols: cols, rows: rows)
        var size = winsize(
            ws_row: UInt16(rows),
            ws_col: UInt16(cols),
            ws_xpixel: 0,
            ws_ypixel: 0
        )
        PseudoTerminalHelpers.setWinSize(
            masterPtyDescriptor: process.childfd,
            windowSize: &size
        )
    }

    // LocalProcessDelegate methods
    func processTerminated(_ source: LocalProcess, exitCode: Int32?) {
        print("Process terminated with exit code: \(exitCode ?? -1)")
    }

    func dataReceived(slice: ArraySlice<UInt8>) {
        // Feed data to terminal
        terminal.feed(buffer: slice)
    }

    func getWindowSize() -> winsize {
        winsize(
            ws_row: UInt16(terminal.rows),
            ws_col: UInt16(terminal.cols),
            ws_xpixel: 0,
            ws_ypixel: 0
        )
    }
}

// Also implement TerminalDelegate for the terminal
extension ShellManager: TerminalDelegate {
    func send(source: Terminal, data: ArraySlice<UInt8>) {
        process.send(data: data)
    }
    // ... other delegate methods
}
```
