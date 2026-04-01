#!/usr/bin/env python3
"""
NotchTerminal Hook
- Sends Claude Code session state to NotchTerminal.app via Unix socket
- Fire-and-forget (no permission handling)
"""
import json
import os
import socket
import sys

SOCKET_PATH = "/tmp/notch-terminal.sock"


def send_event(state):
    try:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.settimeout(2)
        sock.connect(SOCKET_PATH)
        sock.sendall(json.dumps(state).encode())
        sock.close()
    except (socket.error, OSError):
        pass


def main():
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    session_id = data.get("session_id", "unknown")
    event = data.get("hook_event_name", "")
    cwd = data.get("cwd", "")

    state = {
        "session_id": session_id,
        "cwd": cwd,
        "event": event,
        "pid": os.getppid(),
    }

    if event == "UserPromptSubmit":
        state["status"] = "processing"

    elif event == "PreToolUse":
        state["status"] = "running_tool"
        state["tool"] = data.get("tool_name")

    elif event == "PostToolUse":
        state["status"] = "processing"
        state["tool"] = data.get("tool_name")

    elif event == "Notification":
        notification_type = data.get("notification_type")
        if notification_type == "idle_prompt":
            state["status"] = "waiting_for_input"
        else:
            state["status"] = "notification"
        state["notification_type"] = notification_type

    elif event in ("Stop", "SubagentStop", "SessionStart"):
        state["status"] = "waiting_for_input"

    elif event == "SessionEnd":
        state["status"] = "ended"

    elif event == "PreCompact":
        state["status"] = "compacting"

    elif event == "PermissionRequest":
        # Let Claude Code handle permissions natively; just notify
        state["status"] = "waiting_for_approval"
        state["tool"] = data.get("tool_name")
        sys.exit(0)

    else:
        state["status"] = "unknown"

    send_event(state)


if __name__ == "__main__":
    main()
