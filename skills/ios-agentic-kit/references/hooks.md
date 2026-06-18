> Adapted from [keskinonur/claude-code-ios-dev-guide](https://github.com/keskinonur/claude-code-ios-dev-guide) (MIT).

# Hooks for Swift Development

## Hook Events

| Event | Trigger | Use |
|-------|---------|-----|
| `PreToolUse` | Before tool (can block with exit 2) | Protect files, validate commands |
| `PostToolUse` | After tool completes | Lint, format |
| `SessionStart` | Session start/resume | Env setup |
| `Stop` | Claude finishes responding | Summary, cleanup |
| `SubagentStop` | Subagent task completes | Post-processing |
| `PermissionRequest` | Permission dialog | Auto-approve/deny |

## settings.json Hook Config

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/session-start.sh" }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "jq -r '.tool_input.file_path' | { read f; [[ \"$f\" == *.swift ]] && swiftlint lint --path \"$f\" --quiet; }" }]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": "python3 -c \"import json,sys; d=json.load(sys.stdin); p=d.get('tool_input',{}).get('file_path',''); sys.exit(2 if '.env' in p or 'Secrets.swift' in p else 0)\"" }]
      }
    ]
  }
}
```

## Hook Return Codes

- **PreToolUse**: exit `0` → continue, exit `2` → block + feedback to Claude
- **PermissionRequest**: output JSON `{"decision":"approve","reason":"...","suppressOutput":true}`

## Hook Scripts

### `.claude/hooks/session-start.sh`
```bash
#!/bin/bash
PROJECT_NAME=$(basename "$(pwd)")
SWIFT_VERSION=$(swift --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
XCODE_VERSION=$(xcodebuild -version 2>/dev/null | head -1)

echo "Starting $PROJECT_NAME — Swift $SWIFT_VERSION | $XCODE_VERSION" >&2

if ! command -v swiftlint &>/dev/null; then echo "⚠️ SwiftLint not installed" >&2; fi
if ! xcrun simctl list devices booted | grep -q "Booted"; then
    echo "💡 No simulator running." >&2
fi
```

### `.claude/hooks/post-swift-edit.sh`
```bash
#!/bin/bash
FILE=$(jq -r '.tool_input.file_path // empty')
[[ "$FILE" != *.swift ]] && exit 0

if command -v swiftlint &>/dev/null && [ -f ".swiftlint.yml" ]; then
    swiftlint lint --path "$FILE" --quiet 2>&1 | head -5 >&2
fi
if command -v swift-format &>/dev/null; then
    swift-format lint "$FILE" 2>&1 | head -3 >&2
fi
```

### `.claude/hooks/file-protection.sh` (PreToolUse)
```bash
#!/bin/bash
FILE=$(jq -r '.tool_input.file_path // empty' < /dev/stdin)
PROTECTED=(".env" "Secrets.swift" "GoogleService-Info.plist" ".git/" "Podfile.lock")

for pattern in "${PROTECTED[@]}"; do
    if [[ "$FILE" == *"$pattern"* ]]; then
        echo "🛡️ Protected: $FILE" >&2
        exit 2
    fi
done
exit 0
```

```bash
chmod +x .claude/hooks/*.sh
```
