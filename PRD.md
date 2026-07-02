# Product Requirements Document — NotchTerm

## Overview

NotchTerm is a macOS utility that repurposes the MacBook Pro hardware notch as a persistent terminal launcher. It turns dead screen real estate into a zero-friction shell access point with deep Claude Code integration.

---

## Problem Statement

Power users who run Claude Code and terminal-heavy workflows context-switch constantly between their editor, terminal, and other apps. Existing terminal emulators require a dedicated window, a Dock slot, or a menu bar icon. The MacBook Pro notch is always visible but currently unused by third-party software.

---

## Goals

1. Provide instant terminal access from anywhere on screen with a single hover + click
2. Keep the notch area visually clean and unobtrusive when idle
3. Surface Claude Code activity state passively in the notch without requiring any user action
4. Never interfere with normal macOS interaction when the terminal is not in use

---

## Non-Goals

- Full-featured terminal emulator replacement (no tmux integration, no split panes in v1)
- Support for non-shell processes or SSH in the panel (can be done inside the shell itself)
- Menu bar icon or Dock presence
- System-wide keyboard shortcut to open the panel (uses hover/click on notch instead)

---

## User Stories

| # | As a… | I want to… | So that… |
|---|---|---|---|
| 1 | Developer | hover over the notch and see a reaction | I know the notch is interactive |
| 2 | Developer | click the notch to open a terminal panel | I can run a command without switching apps |
| 3 | Developer | have multiple tabs in the panel | I can run several concurrent commands |
| 4 | Developer | switch tabs without killing background processes | my long-running jobs keep running |
| 5 | Developer | press ESC or click outside to close | the panel gets out of my way instantly |
| 6 | Claude Code user | see the notch animate while Claude is working | I know Claude is still processing without looking at my editor |
| 7 | User | have the terminal start in my home directory | I don't have to cd every time I open a tab |
| 8 | User | have keyboard shortcuts for tab management | I can work without reaching for the mouse |

---

## Functional Requirements

### Notch Pill (Closed State)

- **FR-01** The pill shall match the hardware notch dimensions when idle
- **FR-02** The pill shall expand 24pt laterally on mouse hover (12pt each side) with an `easeOut(0.18s)` animation
- **FR-03** Hovering for ≥ 1 second shall auto-open the panel
- **FR-04** The pill shall show a `terminal.fill` SF Symbol at low opacity when hovered
- **FR-05** Mouse events shall pass through the window to apps behind it in all areas except the pill region

### Expanded Panel

- **FR-06** Clicking the pill shall expand the panel to 760×460pt below the notch with a spring animation
- **FR-07** Clicking outside the expanded panel shall close it and re-post the click to the target below
- **FR-08** ESC shall close the panel
- **FR-09** The panel shall use the same `NotchShape` as the pill, with animated corner-radius transitions

### Terminal Emulator

- **FR-10** Each tab shall launch `$SHELL` as a login shell starting in `$HOME`
- **FR-11** The shell process shall remain alive when switching to another tab
- **FR-12** The terminal content width shall equal the visible area inside the `NotchShape` (panel width − 2 × top corner radius)
- **FR-13** Closing the last tab shall be a no-op (minimum 1 tab at all times)

### Tab Management

- **FR-14** `⌘T` shall open a new tab
- **FR-15** `⌘W` shall close the active tab
- **FR-16** `⌘1–⌘9` shall activate the tab at that index
- **FR-17** The tab bar shall show each tab's title (updated from the shell's title escape sequence)
- **FR-18** Tab insertion and removal shall animate with a spring

### Claude Code Integration

- **FR-19** On first launch the app shall copy `notchterm-hook.py` to `~/.claude/hooks/` and register it in `~/.claude/settings.json`
- **FR-20** Hook events `processing` / `running_tool` / `compacting` shall set `isActive = true` in the monitor
- **FR-21** Hook events `waiting_for_input` / `ended` shall set `isActive = false`
- **FR-22** When `isActive = true` the pill shall expand 40pt laterally to show the crab + spinner
- **FR-23** The expansion shall use a spring with `response: 0.38s, dampingFraction: 0.72`
- **FR-24** The hook script shall communicate via Unix domain socket at `/tmp/notchterm.sock`
- **FR-25** The hook script shall be fire-and-forget (no permission handling)

### Display Handling

- **FR-26** The app shall detect display configuration changes and recreate the window on the correct screen
- **FR-27** On machines without a physical notch the pill shall still render at top-center

---

## Non-Functional Requirements

- **NFR-01** The window layer shall be `NSPanel` with `.nonactivatingPanel` so it never steals focus
- **NFR-02** The app shall run as an accessory app (no Dock icon, no menu bar icon)
- **NFR-03** App Sandbox shall be disabled to allow PTY/shell process spawning
- **NFR-04** Swift 6 strict concurrency — all UI on `@MainActor`, socket server on a private GCD queue
- **NFR-05** Target: macOS 15.0+, Swift 6.0, deployment target matches OS

---

## Architecture Overview

```
AppDelegate
  └── WindowManager
        └── NotchWindowController (NSWindowController)
              ├── NotchViewModel          ← state machine + event handling
              ├── TerminalSessionManager  ← tab lifecycle
              └── NotchViewController
                    └── PassThroughHostingView<NotchContainerView>
                          ├── NotchContainerView  ← single expanding NotchShape
                          │     ├── headerRow      ← crab/spinner or hover icon
                          │     └── TerminalTabsView
                          │           ├── TabChrome (tab bar)
                          │           └── TerminalEmulatorView (SwiftTerm)
                          └── ClaudeHookMonitor
                                └── HookSocketServer (/tmp/notchterm.sock)
```

---

## Key Design Decisions

| Decision | Rationale |
|---|---|
| Single `NotchShape` container (vs separate pill + panel) | Enables seamless corner-radius animation between states, matching the iOS Dynamic Island |
| `NSPanel` with `nonactivatingPanel` | Panel opens without stealing keyboard focus from the active app |
| `PassThroughHostingView` with custom `hitTest` | Only the visible notch area intercepts mouse events; everything else is transparent |
| SwiftTerm `LocalProcessTerminalView` stored on session | PTY survives tab switches because the view is held by the session object, not recreated |
| Unix socket for hook events (vs polling) | Near-zero CPU when idle; instant reaction to Claude events |
| Login shell (`execName: "-zsh"`) | Sources `~/.zprofile`/`~/.zshrc`, starts in `$HOME`, matches a real terminal's behavior |

---

## Future Considerations

- Split panes within the terminal panel
- Per-tab environment variables or working directory configuration
- Permission request UI (Claude Code `PermissionRequest` hook with approve/deny buttons in the notch)
- Global hotkey option as an alternative to hover-to-open
- Theming (the white tab bar could expose a color preference)
- Non-notch Mac support with a configurable anchor point
