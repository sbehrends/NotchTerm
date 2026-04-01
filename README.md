# NotchTerminal

A macOS terminal emulator that lives in the MacBook Pro notch. Click or hover to expand a full multi-tab shell directly from the top of your screen — no Dock icon, no menu bar clutter.

## Features

- **Notch-native UI** — the pill sits flush with the hardware notch; the expanded panel drops below it using the same `NotchShape` corner curves
- **Multi-tab terminal** — open as many shell sessions as you need; each tab owns its own PTY so background tabs keep running
- **Hover-to-expand** — hovering over the notch widens the pill and shows a terminal hint icon; holding for 1 s auto-opens the panel
- **Click-through when closed** — the window is transparent to mouse events everywhere except the notch pill, so menu bar clicks and other apps work normally
- **Claude Code integration** — registers hooks with Claude Code so the notch animates a crab icon and spinner while Claude is processing; the pill expands laterally to accommodate the icons
- **Login shell** — each tab launches your `$SHELL` as a login shell, starting in your home directory with your full profile loaded
- **Keyboard shortcuts** — `⌘T` new tab, `⌘W` close tab, `⌘1-9` switch tabs, `⎋` collapse panel

## Requirements

- macOS 15.0+
- MacBook with physical notch (works on non-notch Macs too, positioned at top-center)
- Xcode 16+ to build
- [xcodegen](https://github.com/yonaskolb/XcodeGen) to regenerate the `.xcodeproj`

## Building

```bash
# Install xcodegen if needed
brew install xcodegen

# Generate the Xcode project
xcodegen generate

# Open and build in Xcode, or via CLI
xcodebuild -project NotchTerminal.xcodeproj \
           -scheme NotchTerminal \
           -destination 'platform=macOS' \
           build
```

> App Sandbox is disabled (`ENABLE_APP_SANDBOX = NO`) — required for PTY/shell process spawning.

## Project Structure

```
NotchTerminal/
├── App/
│   ├── NotchTerminalApp.swift       @main entry, Settings scene
│   ├── AppDelegate.swift            activation policy, window setup, hook install
│   ├── WindowManager.swift          creates/recreates the notch window per screen
│   └── ScreenObserver.swift         rebuilds window on display configuration change
├── Core/
│   ├── NotchViewModel.swift         open/close state, hover detection, mouse events
│   ├── NotchGeometry.swift          pure geometry helpers
│   └── Ext+NSScreen.swift           notch rect & hasPhysicalNotch helpers
├── Events/
│   ├── EventMonitor.swift           NSEvent monitor wrapper
│   └── EventMonitors.swift          shared global mouse publisher
├── Terminal/
│   ├── TerminalSession.swift        one tab — owns the PTY reference
│   └── TerminalSessionManager.swift tab list, active tab, add/remove/switch
├── Services/
│   ├── ClaudeHookMonitor.swift      publishes isActive from hook socket events
│   ├── ClaudeActivityMonitor.swift  legacy pgrep-based fallback
│   └── Hooks/
│       ├── HookEvent.swift          Codable model for socket events
│       ├── HookSocketServer.swift   GCD Unix socket server (/tmp/notch-terminal.sock)
│       └── HookInstaller.swift      copies script → ~/.claude/hooks/, patches settings.json
├── UI/
│   ├── Window/
│   │   ├── NotchWindow.swift        NSPanel subclass (borderless, nonactivating)
│   │   ├── NotchWindowController.swift  window lifecycle, keyboard shortcuts
│   │   └── NotchViewController.swift   PassThroughHostingView with hit-test rect
│   ├── Views/
│   │   ├── NotchContainerView.swift single expanding NotchShape container
│   │   ├── TerminalTabsView.swift   tab bar + terminal area
│   │   └── TerminalView.swift       NSViewRepresentable wrapping SwiftTerm
│   └── Components/
│       ├── ClaudeCrabIcon.swift     pixel-art crab + ProcessingSpinner
│       └── NotchShape.swift         animatable quad-curve notch path
└── Resources/
    └── notch-terminal-hook.py       Claude Code hook script (bundled resource)
```

## Claude Code Integration

On first launch the app installs a Python hook script to `~/.claude/hooks/notch-terminal-hook.py` and registers it in `~/.claude/settings.json` for the following events:

| Hook | Status reported |
|---|---|
| `UserPromptSubmit` | `processing` |
| `PreToolUse` | `running_tool` |
| `PostToolUse` | `processing` |
| `Stop` / `SubagentStop` / `SessionStart` | `waiting_for_input` |
| `SessionEnd` | `ended` |
| `PreCompact` | `compacting` |

When status is `processing`, `running_tool`, or `compacting` the notch pill expands sideways and shows the animated crab + spinner. The app listens on `/tmp/notch-terminal.sock`.

## Design Details

- **Closed pill**: hardware notch dimensions, `NotchShape(top:6, bottom:14)`
- **Hover**: +24pt wider, bottom radius nudges to 17
- **Active (Claude working)**: +40pt wider, bottom radius 18, spring animation
- **Opened panel**: 760×504pt total, `NotchShape(top:19, bottom:24)`
- Terminal content is inset by `openedTopRadius (19pt)` on each side to stay within the shape's straight section
- All corner-radius transitions animate via `NotchShape.animatableData`
