#!/bin/bash
cd "$(dirname "$0")/NotchTerm/Resources"

echo '{"session_id":"test-123","cwd":"/tmp","permission_mode":"ask","hook_event_name":"UserPromptSubmit","tool_name":"execute_command"}' | python3 notchterm-hook.py

sleep 2

echo '{"session_id":"test-123","cwd":"/tmp","permission_mode":"ask","hook_event_name":"PermissionRequest","tool_name":"execute_command"}' | python3 notchterm-hook.py

sleep 2

echo '{"session_id":"test-123","cwd":"/tmp","permission_mode":"ask","hook_event_name":"Stop","tool_name":"execute_command"}' | python3 notchterm-hook.py
