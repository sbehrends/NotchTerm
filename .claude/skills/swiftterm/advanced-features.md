# Advanced Features

Buffer access, text extraction, selection, color palette, cursor styles, Metal GPU rendering, and mouse modes.

## Buffer Access and Text Extraction

Access the terminal buffer contents for reading characters, lines, or extracting text from selections.

```swift
import SwiftTerm

let terminal = Terminal(delegate: myDelegate, options: .default)
terminal.feed(text: "Line 1\r\nLine 2\r\nLine 3\r\n")

// Get a single character at position
if let char = terminal.getCharacter(col: 0, row: 0) {
    print("Character at (0,0): \(char)")  // 'L'
}

// Get character data (includes attributes)
if let charData = terminal.getCharData(col: 0, row: 0) {
    let char = terminal.getCharacter(for: charData)
    let attr = charData.attribute
    print("Character: \(char), Bold: \(attr.bold), FG: \(attr.fg)")
}

// Get a full line
if let line = terminal.getLine(row: 0) {
    let text = line.translateToString(trimRight: true)
    print("Line 0: \(text)")  // "Line 1"
}

// Get scroll-invariant line (accounts for scrollback)
if let scrollLine = terminal.getScrollInvariantLine(row: 0) {
    let text = scrollLine.translateToString()
    print("Scroll line 0: \(text)")
}

// Extract text from a range
let start = Position(col: 0, row: 0)
let end = Position(col: 5, row: 0)
let extractedText = terminal.getText(start: start, end: end)
print("Extracted: \(extractedText)")  // "Line 1"

// Access current buffer
let buffer = terminal.buffer
print("Cursor position: (\(buffer.x), \(buffer.y))")
print("Scroll region: \(buffer.scrollTop) to \(buffer.scrollBottom)")
print("Y display offset: \(buffer.yDisp)")
print("Is alternate buffer: \(terminal.isCurrentBufferAlternate)")
```

## Selection Service

The `SelectionService` manages text selection in the terminal, supporting character, word, and line selection modes.

```swift
import SwiftTerm

// Selection is accessed through TerminalView
let terminalView = TerminalView(frame: bounds)

// Select all text
terminalView.selectAll()

// Clear selection
terminalView.selectNone()

// Access selection through terminal
let terminal = terminalView.getTerminal()
let selection = terminalView.selection

// Check if selection is active
if selection.active {
    // Get selected text
    let selectedText = selection.getSelectedText()
    print("Selected: \(selectedText)")

    // Get selection bounds
    print("Start: (\(selection.start.col), \(selection.start.row))")
    print("End: (\(selection.end.col), \(selection.end.row))")
}

// Programmatic selection (through SelectionService)
selection.select(row: 5)  // Select entire row 5
selection.selectAll()
selection.selectWordOrExpression(
    at: Position(col: 10, row: 5),
    in: terminal.buffer
)

// Copy selection to clipboard (macOS)
if let text = selection.getSelectedText().data(using: .utf8) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(selection.getSelectedText(), forType: .string)
}
```

## Metal GPU Rendering

Enable GPU-accelerated rendering using Metal for improved performance with large terminals or high update rates.

```swift
import SwiftTerm

// Enable Metal rendering (macOS/iOS)
let terminalView = TerminalView(frame: bounds)

do {
    try terminalView.setUseMetal(true)
    print("Metal rendering enabled")
} catch MetalError.deviceUnavailable {
    print("Metal not available, using CoreGraphics")
} catch {
    print("Metal initialization failed: \(error)")
}

// Check if Metal is active
#if canImport(MetalKit)
if terminalView.isUsingMetalRenderer {
    print("Using Metal GPU rendering")

    // Configure buffering mode for best performance
    terminalView.metalBufferingMode = .perRowPersistent  // Cache row data
    // or
    terminalView.metalBufferingMode = .perFrameAggregated  // Rebuild each frame
}
#endif

// Disable Metal and return to CoreGraphics
do {
    try terminalView.setUseMetal(false)
} catch {
    print("Failed to disable Metal: \(error)")
}

// Environment variable to control live resize throttling
// Set SWIFTTERM_METAL_LIVE_RESIZE_THROTTLE=0 to disable
```

## Mouse Mode and Events

The terminal supports various mouse tracking modes. The `mouseMode` property indicates what mouse events should be sent to the terminal.

```swift
import SwiftTerm

let terminal = terminalView.getTerminal()

// Check current mouse mode
switch terminal.mouseMode {
case .off:
    print("Mouse tracking disabled")
case .x10:
    print("X10 mode: button press only")
case .vt200:
    print("VT200 mode: press and release")
case .buttonEventTracking:
    print("Button tracking: press, release, and motion while pressed")
case .anyEvent:
    print("Any event: all mouse events including motion")
}

// Query what events to send
if terminal.mouseMode.sendButtonPress() {
    // Send button press events
}
if terminal.mouseMode.sendButtonRelease() {
    // Send button release events
}
if terminal.mouseMode.sendMotionEvent() {
    // Send motion events even without button pressed
}

// TerminalView handles mouse automatically via allowMouseReporting
terminalView.allowMouseReporting = true  // Let apps capture mouse
terminalView.allowMouseReporting = false // Always enable selection

// Delegate is notified when mode changes
func mouseModeChanged(source: Terminal) {
    if source.mouseMode != .off {
        print("Application requested mouse tracking")
    }
}
```

## Color Palette Management

Customize the terminal's color palette including ANSI colors and true color support.

```swift
import SwiftTerm

let terminal = Terminal(delegate: myDelegate, options: .default)

// Set foreground and background colors
terminal.foregroundColor = Color(red: 255, green: 255, blue: 255)
terminal.backgroundColor = Color(red: 0, green: 0, blue: 0)

// Set cursor color
terminal.cursorColor = Color(red: 0, green: 255, blue: 255)

// Install custom ANSI color palette (16 colors)
let customPalette: [Color] = [
    Color(red: 0, green: 0, blue: 0),       // Black
    Color(red: 187, green: 0, blue: 0),     // Red
    Color(red: 0, green: 187, blue: 0),     // Green
    Color(red: 187, green: 187, blue: 0),   // Yellow
    Color(red: 0, green: 0, blue: 187),     // Blue
    Color(red: 187, green: 0, blue: 187),   // Magenta
    Color(red: 0, green: 187, blue: 187),   // Cyan
    Color(red: 187, green: 187, blue: 187), // White
    // Bright variants (8-15)
    Color(red: 85, green: 85, blue: 85),    // Bright Black
    Color(red: 255, green: 85, blue: 85),   // Bright Red
    Color(red: 85, green: 255, blue: 85),   // Bright Green
    Color(red: 255, green: 255, blue: 85),  // Bright Yellow
    Color(red: 85, green: 85, blue: 255),   // Bright Blue
    Color(red: 255, green: 85, blue: 255),  // Bright Magenta
    Color(red: 85, green: 255, blue: 255),  // Bright Cyan
    Color(red: 255, green: 255, blue: 255), // Bright White
]
terminal.installPalette(colors: customPalette)

// For TerminalView, use native colors
terminalView.nativeForegroundColor = .white
terminalView.nativeBackgroundColor = .black
terminalView.caretColor = .cyan
terminalView.caretTextColor = .black  // Block cursor text color
terminalView.selectedTextBackgroundColor = .systemBlue.withAlphaComponent(0.3)
```

## Cursor Styles

Configure the terminal cursor appearance, which can be changed programmatically or by escape sequences from the running application.

```swift
import SwiftTerm

// Available cursor styles
let styles: [CursorStyle] = [
    .blinkBlock,      // Blinking filled rectangle
    .steadyBlock,     // Solid filled rectangle
    .blinkUnderline,  // Blinking underscore
    .steadyUnderline, // Solid underscore
    .blinkBar,        // Blinking vertical line
    .steadyBar        // Solid vertical line
]

// Set via TerminalOptions at initialization
let options = TerminalOptions(cursorStyle: .blinkBar)
let terminal = Terminal(delegate: myDelegate, options: options)

// Cursor style changes trigger delegate callback
func cursorStyleChanged(source: Terminal, newStyle: CursorStyle) {
    print("Cursor style changed to: \(newStyle)")
}

// Parse cursor style from string (useful for preferences)
if let style = CursorStyle.from(string: "steadyBlock") {
    print("Parsed style: \(style)")
}

// For TerminalView, configure caret tracking
terminalView.caretViewTracksFocus = true  // Show different style when unfocused
```
