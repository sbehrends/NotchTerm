---
name: swiftterm
description: SwiftTerm VT100/Xterm terminal emulator library for Swift. Covers Terminal engine, LocalProcessTerminalView (macOS), TerminalView (iOS), LocalProcess PTY management, HeadlessTerminal, buffer/selection access, Metal rendering, mouse modes, and color/cursor configuration. Use when embedding terminal emulation in Swift apps.
allowed-tools: [Read, Glob, Grep]
---

# SwiftTerm Terminal Emulator Library

SwiftTerm is a VT100/Xterm terminal emulator library written in Swift for macOS and iOS. It separates the terminal engine (`Terminal` class) from the rendering layer, supporting AppKit, UIKit, or custom renderers. Features include Unicode, Sixel graphics, Kitty image protocol, hyperlinks, Metal GPU rendering, bracketed paste, mouse tracking, alternate screen buffers, and the Kitty keyboard protocol.

## When This Skill Activates

- User wants to embed a terminal emulator in a macOS or iOS Swift app
- User needs to spawn a local shell process connected to a terminal view
- User asks about PTY management or `LocalProcess` usage
- User is working with `TerminalView` or `LocalProcessTerminalView`
- User needs to parse or feed escape sequences to a terminal buffer
- User asks about terminal buffer access, text extraction, or selection
- User wants Metal GPU-accelerated terminal rendering
- User needs to configure terminal colors, cursor styles, or mouse modes
- User asks about `HeadlessTerminal` for scripting or automation
- User needs to handle `TerminalDelegate` or `TerminalViewDelegate` callbacks

## Decision Tree

```
What do you need?
|
+-- Embed a terminal with a local shell (macOS)
|   +-- LocalProcessTerminalView (all-in-one view + process)
|       --> see platform-views.md
|
+-- Embed a terminal connected to SSH/network (iOS or macOS)
|   +-- TerminalView + custom data feed
|       --> see platform-views.md
|
+-- Manage a shell process separately from the view
|   +-- LocalProcess + Terminal engine
|       --> see platform-views.md
|
+-- Automate or script without UI
|   +-- HeadlessTerminal
|       --> see terminal-basics.md
|
+-- Configure terminal (options, resize, feed data)
|   +-- Terminal class, TerminalOptions, feed/resize
|       --> see terminal-basics.md
|
+-- Read buffer contents, manage selections
|   +-- Buffer access, SelectionService
|       --> see advanced-features.md
|
+-- Customize appearance (colors, cursor, Metal)
|   +-- Color palette, CursorStyle, Metal renderer
|       --> see advanced-features.md
|
+-- Handle mouse events in terminal
    +-- Mouse modes, allowMouseReporting
        --> see advanced-features.md
```

## Architecture Overview

| Component | Class | Role |
|-----------|-------|------|
| Engine | `Terminal` | Escape sequence parsing, buffer management, state |
| macOS view | `LocalProcessTerminalView` | NSView + built-in local shell process |
| iOS view | `TerminalView` | UIView for network-connected terminals |
| Process | `LocalProcess` | PTY-based child process management |
| Headless | `HeadlessTerminal` | Terminal engine without rendering |
| Selection | `SelectionService` | Text selection (char, word, line modes) |
| Options | `TerminalOptions` | Dimensions, scrollback, cursor, features |

## API Availability

| API | Platform | Import |
|-----|----------|--------|
| `Terminal` | macOS / iOS / Linux | `SwiftTerm` |
| `TerminalView` | macOS (NSView) / iOS (UIView) | `SwiftTerm` |
| `LocalProcessTerminalView` | macOS only | `SwiftTerm` |
| `LocalProcess` | macOS / Linux | `SwiftTerm` |
| `HeadlessTerminal` | macOS / Linux | `SwiftTerm` |
| Metal rendering | macOS / iOS (Metal-capable) | `SwiftTerm` + `MetalKit` |

## Sub-documents

- `terminal-basics.md` — Terminal initialization, TerminalOptions, feed methods, resize, HeadlessTerminal, environment variables
- `platform-views.md` — LocalProcessTerminalView (macOS), TerminalView (iOS), LocalProcess PTY management
- `advanced-features.md` — Buffer access, SelectionService, color palette, cursor styles, Metal rendering, mouse modes

