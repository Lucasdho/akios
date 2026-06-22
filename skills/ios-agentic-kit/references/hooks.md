# Hooks for Swift Development

The kit installs **one** hook: `agentic-kit-inject.sh` on `SessionStart`, which re-states the
gates each session. This page is the mechanism if you want to add your own — none of the
scripts below ship with the kit; they're opt-in examples (SwiftLint/format on save,
secret-file protection).

## Hook Events

| Event | Trigger | Use |
|-------|---------|-----|
| `PreToolUse` | Before tool (can block with exit 2) | Protect files, validate commands |
| `PostToolUse` | After tool completes | Lint, format |
| `SessionStart` | Session start/resume | Env setup — the kit's own hook uses this |
| `Stop` | Claude finishes responding | Summary, cleanup |
| `SubagentStop` | Subagent task completes | Post-processing |
| `PermissionRequest` | Permission dialog | Auto-approve/deny |

## settings.json Hook Config

The kit's `SessionStart` entry is already wired by `install.sh`. To add your own, append to
the relevant event array — e.g. lint Swift on save and block writes to secret files:

```json
{
  "hooks": {
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

## Example Scripts (opt-in)

### `.claude/hooks/post-swift-edit.sh` (PostToolUse) — lint/format on save
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

### `.claude/hooks/file-protection.sh` (PreToolUse) — block writes to sensitive files
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

Make them executable after adding:
```bash
chmod +x .claude/hooks/*.sh
```
