# CLAUDE.md — NotchTerminal

## Project

macOS notch terminal emulator. A borderless `NSPanel` lives at the top of the screen; the notch area acts as a pill that expands into a multi-tab shell panel. Deep Claude Code hook integration animates the pill when Claude is processing.

**Working directory:** `/Users/sergiobehrends/Documents/Others/Claudeland/NotchTerminal/`
**Language:** Swift 6.0 · SwiftUI + AppKit · macOS 15.0+
**Build tool:** xcodegen → `xcodegen generate` then `xcodebuild`

---

## Build & Run

```bash
xcodegen generate                    # regenerate .xcodeproj from project.yml
xcodebuild -project NotchTerminal.xcodeproj \
           -scheme NotchTerminal \
           -destination 'platform=macOS' build
```

Always run `xcodegen generate` after adding, removing, or moving source files. The `.xcodeproj` is derived from `project.yml`.

---

## Architecture — What Lives Where

| Layer | Files | Responsibility |
|---|---|---|
| App bootstrap | `App/` | `@main`, `AppDelegate`, `WindowManager`, `ScreenObserver` |
| State | `Core/NotchViewModel.swift` | open/close state machine, hover detection, mouse event routing |
| Geometry | `Core/NotchGeometry.swift`, `Core/Ext+NSScreen.swift` | pure rect math, notch size helpers |
| Events | `Events/` | global `NSEvent` monitors via Combine |
| Terminal | `Terminal/` | `TerminalSession` (owns PTY), `TerminalSessionManager` (tab list) |
| Hooks | `Services/Hooks/` | Unix socket server, event model, settings.json installer |
| Activity | `Services/ClaudeHookMonitor.swift` | publishes `isActive` from hook events |
| UI — window | `UI/Window/` | `NSPanel`, `NSWindowController`, `PassThroughHostingView` |
| UI — views | `UI/Views/` | `NotchContainerView`, `TerminalTabsView`, `TerminalEmulatorView` |
| UI — components | `UI/Components/` | `NotchShape`, `ClaudeCrabIcon`, `ProcessingSpinner` |
| Resources | `Resources/` | `notch-terminal-hook.py` (bundled, copied to `~/.claude/hooks/` on launch) |

---

## Core Concepts

### NotchShape

`Components/NotchShape.swift` — custom `Shape` implementing `Animatable`. Draws a quadratic-curve notch path. Corner radii are the animatable parameters:

- **Closed idle:** `top: 6, bottom: 14`
- **Closed hover:** `top: 6, bottom: 17`
- **Closed active:** `top: 6, bottom: 18`
- **Opened:** `top: 19, bottom: 24`

All transitions use a single `.animation(..., value: viewModel.status)` on the container, so width, height, and corner radii animate together.

### Single-shape expansion

`NotchContainerView` uses one `VStack` clipped by `NotchShape`. The pill header row is always at the top; `TerminalTabsView` appears below it only when opened. There is no separate pill + gap + panel — it's all one unified shape. This is what gives the Dynamic Island–style animation.

### Terminal content width

The `NotchShape` with `openedTopRadius = 19` has straight sides at `x = 19` from each edge. `TerminalTabsView` is sized to `openedSize.width - 2 * openedTopRadius` (722pt) and offset with `.padding(.horizontal, openedTopRadius)`. This ensures the terminal emulator reports the correct column width and no content is clipped.

### Click-through

`PassThroughHostingView` overrides `hitTest` to return `nil` for points outside the current notch rect (closed: hardware notch dimensions, opened: full panel area). Everything outside that rect passes through to the window below.

### PTY persistence across tab switches

`TerminalSession` holds a strong reference to `LocalProcessTerminalView`. When switching tabs, `TerminalEmulatorView.makeNSView` returns the existing view instead of creating a new one. The PTY process never stops.

### Hook system

On launch `HookInstaller.installIfNeeded()` copies the bundled Python script and patches `~/.claude/settings.json`. The script sends JSON to `/tmp/notch-terminal.sock`. `HookSocketServer` listens on a GCD queue; `ClaudeHookMonitor` maps `status` → `isActive: Bool` on `@MainActor`.

---

## Key Values & Constraints

- **App Sandbox: NO** — required for `Process`/PTY. Do not re-enable.
- **Swift 6 strict concurrency** — all UI must be on `@MainActor`. Socket server runs on its own `DispatchQueue`. Use `nonisolated(unsafe)` only for types that manage their own locking.
- **No Dock icon, no menu bar** — `setActivationPolicy(.accessory)` in `AppDelegate`. Do not add a menu bar extra.
- **`NSPanel` must not steal focus** — `nonactivatingPanel` styleMask. Never call `makeKeyAndOrderFront` in a way that pulls focus from other apps.
- **Don't change `openedSize`** without also updating `openedAreaScreenRect` in `NotchViewModel` and the `hitTestRect` in `NotchViewController`.

---

## Common Tasks

### Add a new hook event status

1. Add the mapping in `Resources/notch-terminal-hook.py`
2. Add the mapping in `Services/Hooks/HookEvent.swift` → `isProcessing`
3. Re-run `xcodegen generate` (Python resource doesn't require this, but Swift changes do)

### Change panel dimensions

`NotchViewModel.swift`:
```swift
let openedSize = CGSize(width: 760, height: 460)
let closedPillHeight: CGFloat = 44
```
Also update `openedAreaScreenRect` if height changes, and the `hitTestRect` opened case in `NotchViewController`.

### Add a keyboard shortcut

In `NotchWindowController.setupKeyboardShortcuts()` — all shortcuts gate on `viewModel.status == .opened` except ESC.

### Change animation parameters

- **Open/close spring:** `openAnimation` / `closeAnimation` in `NotchViewModel`
- **Hover expansion:** `.animation(.easeOut(duration: 0.18), value: viewModel.isHovering)` in `NotchContainerView`
- **Activity expansion:** `.animation(.spring(response: 0.38, dampingFraction: 0.72), value: activityMonitor.isActive)` in `NotchContainerView`

---

## What Not To Do

- Do not add `@unchecked Sendable` to new types unless they genuinely manage their own thread safety
- Do not use `NotchShape` as a content clip for the terminal panel — it clips the side edges by `topCornerRadius`. Use the `panelWidth = openedSize.width - 2 * openedTopRadius` pattern instead
- Do not remove the `pillPanelGap` property from `NotchViewModel` (it's retained for reference) but do not use it in `openedAreaScreenRect` (gap was removed when switching to the single-shape design)
- Do not poll `pgrep` for Claude activity — `ClaudeHookMonitor` replaces that. `ClaudeActivityMonitor.swift` is a legacy fallback kept for reference
