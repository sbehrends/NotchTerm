# Terminal Basics

Core terminal engine initialization, configuration, data feeding, resizing, environment variables, and headless operation.

## Terminal Initialization

The `Terminal` class is the core terminal emulator engine that processes escape sequences and manages terminal state. It requires a delegate that implements `TerminalDelegate` protocol to handle UI updates and user input.

```swift
import SwiftTerm

class MyTerminalDelegate: TerminalDelegate {
    func send(source: Terminal, data: ArraySlice<UInt8>) {
        // Send data to the connected process/network
        print("Sending \(data.count) bytes to process")
    }

    func setTerminalTitle(source: Terminal, title: String) {
        print("Terminal title changed to: \(title)")
    }

    func showCursor(source: Terminal) { }
    func hideCursor(source: Terminal) { }
    func setTerminalIconTitle(source: Terminal, title: String) { }
    func windowCommand(source: Terminal, command: Terminal.WindowManipulationCommand) -> [UInt8]? { nil }
    func sizeChanged(source: Terminal) { }
    func scrolled(source: Terminal, yDisp: Int) { }
    func linefeed(source: Terminal) { }
    func bufferActivated(source: Terminal) { }
    func synchronizedOutputChanged(source: Terminal, active: Bool) { }
    func bell(source: Terminal) { }
    func selectionChanged(source: Terminal) { }
    func isProcessTrusted(source: Terminal) -> Bool { true }
    func cellSizeInPixels(source: Terminal) -> (width: Int, height: Int)? { nil }
    func mouseModeChanged(source: Terminal) { }
    func cursorStyleChanged(source: Terminal, newStyle: CursorStyle) { }
    func hostCurrentDirectoryUpdated(source: Terminal) { }
    func hostCurrentDocumentUpdated(source: Terminal) { }
    func colorChanged(source: Terminal, idx: Int?) { }
    func setForegroundColor(source: Terminal, color: Color) { }
    func setBackgroundColor(source: Terminal, color: Color) { }
    func setCursorColor(source: Terminal, color: Color?) { }
    func getColors(source: Terminal) -> (foreground: Color, background: Color) {
        (Color.defaultForeground, Color.defaultBackground)
    }
    func iTermContent(source: Terminal, content: ArraySlice<UInt8>) { }
    func clipboardCopy(source: Terminal, content: Data) { }
    func notify(source: Terminal, title: String, body: String) { }
    func progressReport(source: Terminal, report: Terminal.ProgressReport) { }
    func createImageFromBitmap(source: Terminal, bytes: inout [UInt8], width: Int, height: Int) { }
    func createImage(source: Terminal, data: Data, width: ImageSizeRequest, height: ImageSizeRequest, preserveAspectRatio: Bool) { }
}

// Create terminal with custom options
let options = TerminalOptions(
    cols: 120,
    rows: 40,
    scrollback: 1000,
    cursorStyle: .blinkBlock,
    tabStopWidth: 8
)
let delegate = MyTerminalDelegate()
let terminal = Terminal(delegate: delegate, options: options)

// Feed data to terminal
terminal.feed(text: "Hello, Terminal!\r\n")
terminal.feed(text: "\u{1b}[32mGreen text\u{1b}[0m\r\n")

// Query terminal state
print("Terminal size: \(terminal.cols)x\(terminal.rows)")
print("Cursor position: (\(terminal.buffer.x), \(terminal.buffer.y))")
```

## TerminalOptions Configuration

`TerminalOptions` provides configuration settings for terminal initialization including dimensions, scrollback buffer size, cursor style, and advanced features like Sixel graphics support.

```swift
import SwiftTerm

// Default options (80x25, 500 line scrollback)
let defaultOptions = TerminalOptions.default

// Custom options for a larger terminal
let customOptions = TerminalOptions(
    cols: 132,                              // Column count (default: 80)
    rows: 50,                               // Row count (default: 25)
    convertEol: false,                      // LF also acts as CR (default: false)
    termName: "xterm-256color",             // TERM value (default: "xterm-256color")
    cursorStyle: .steadyBar,                // Cursor style (default: .blinkBlock)
    screenReaderMode: false,                // Accessibility mode (default: false)
    scrollback: 10000,                      // Scrollback lines (default: 500)
    tabStopWidth: 4,                        // Tab width (default: 8)
    enableSixelReported: true,              // Report Sixel support (default: true)
    kittyImageCacheLimitBytes: 512 * 1024 * 1024  // Kitty image cache (default: 320MB)
)

// Create terminal with custom options
let terminal = Terminal(delegate: myDelegate, options: customOptions)

// Update options at runtime
terminal.options.scrollback = 5000
terminal.setup(isReset: false)  // Apply changes without full reset
```

## Terminal Feed Methods

The `feed` methods inject data into the terminal for processing. Data is parsed as escape sequences and characters are added to the terminal buffer.

```swift
import SwiftTerm

let terminal = Terminal(delegate: myDelegate, options: .default)

// Feed a String directly
terminal.feed(text: "Hello, World!\r\n")

// Feed a byte array
let bytes: [UInt8] = [0x1b, 0x5b, 0x32, 0x4a]  // ESC[2J (clear screen)
terminal.feed(byteArray: bytes)

// Feed an ArraySlice (efficient for network data)
let buffer: [UInt8] = Array("Incoming data\r\n".utf8)
terminal.feed(buffer: buffer[0...])

// Common escape sequences
terminal.feed(text: "\u{1b}[2J")           // Clear screen
terminal.feed(text: "\u{1b}[H")            // Move cursor home
terminal.feed(text: "\u{1b}[31m")          // Red foreground
terminal.feed(text: "\u{1b}[42m")          // Green background
terminal.feed(text: "\u{1b}[1m")           // Bold
terminal.feed(text: "\u{1b}[0m")           // Reset attributes
terminal.feed(text: "\u{1b}[?1049h")       // Switch to alternate screen
terminal.feed(text: "\u{1b}[?1049l")       // Switch back to normal screen

// For TerminalView, use the view's feed methods which handle display updates
terminalView.feed(text: "With automatic display refresh\r\n")
terminalView.feed(byteArray: networkData[...])
```

## Terminal Resize

Resize the terminal dimensions. This affects the buffer size and may trigger content reflow.

```swift
import SwiftTerm

// Resize the Terminal
let terminal = Terminal(delegate: myDelegate, options: .default)
terminal.resize(cols: 120, rows: 40)

// Get current dimensions
let (cols, rows) = terminal.getDims()
print("Terminal is \(cols) columns by \(rows) rows")

// For TerminalView, resize updates both terminal and view
terminalView.resize(cols: 132, rows: 50)

// Resize triggers delegate callback
func sizeChanged(source: Terminal) {
    print("Terminal resized to \(source.cols)x\(source.rows)")
}

// For LocalProcess, update PTY window size after resize
func updateProcessWindowSize(process: LocalProcess, terminal: Terminal) {
    var size = winsize(
        ws_row: UInt16(terminal.rows),
        ws_col: UInt16(terminal.cols),
        ws_xpixel: 0,
        ws_ypixel: 0
    )
    PseudoTerminalHelpers.setWinSize(
        masterPtyDescriptor: process.childfd,
        windowSize: &size
    )
}
```

## Environment Variables

`Terminal.getEnvironmentVariables` generates appropriate environment variables for shell processes, ensuring proper terminal identification and Unicode support.

```swift
import SwiftTerm

// Get default environment variables
let env = Terminal.getEnvironmentVariables()
// Returns: ["TERM=xterm-256color", "COLORTERM=truecolor", "LANG=en_US.UTF-8", ...]

// Customize terminal name
let customEnv = Terminal.getEnvironmentVariables(
    termName: "xterm-direct",
    trueColor: true
)

// Use with LocalProcess
process.startProcess(
    executable: "/bin/bash",
    environment: Terminal.getEnvironmentVariables(termName: "xterm-256color")
)

// Use with SSH connections
let sshEnv = Terminal.getEnvironmentVariables(termName: "xterm-256color", trueColor: true)
for envVar in sshEnv {
    let parts = envVar.split(separator: "=", maxSplits: 1)
    if parts.count == 2 {
        sshChannel.setEnvironmentVariable(
            name: String(parts[0]),
            value: String(parts[1])
        )
    }
}
```

## HeadlessTerminal for Scripting

`HeadlessTerminal` provides a terminal emulator without UI rendering, useful for scripting, screen scraping, and automated testing.

```swift
import SwiftTerm

// Run a command and capture output
func runCommand(_ command: String) async -> String {
    return await withCheckedContinuation { continuation in
        let headless = HeadlessTerminal(
            queue: DispatchQueue.global(),
            options: TerminalOptions(cols: 80, rows: 24, scrollback: 1000)
        ) { exitCode in
            print("Command exited with code: \(exitCode ?? -1)")
        }

        // Start bash and run command
        headless.process.startProcess(executable: "/bin/bash", args: ["-c", command])

        // Wait for process to complete
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            // Extract text from terminal buffer
            var output = ""
            for row in 0..<headless.terminal.rows {
                if let line = headless.terminal.getLine(row: row) {
                    output += line.translateToString(trimRight: true) + "\n"
                }
            }
            continuation.resume(returning: output.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
}

// Screen scraping example
func scrapeTerminalScreen(terminal: Terminal) -> [[Character]] {
    var screen: [[Character]] = []

    for row in 0..<terminal.rows {
        var rowChars: [Character] = []
        for col in 0..<terminal.cols {
            if let char = terminal.getCharacter(col: col, row: row) {
                rowChars.append(char)
            } else {
                rowChars.append(" ")
            }
        }
        screen.append(rowChars)
    }
    return screen
}

// Send input to headless terminal
func interactWithHeadless(_ headless: HeadlessTerminal) {
    // Send text input
    headless.send("ls -la\n")

    // Send escape sequences
    headless.send("\u{1b}[A")  // Up arrow
    headless.send("\u{1b}[B")  // Down arrow

    // Change scrollback size at runtime
    headless.changeScrollback(5000)
}
```
