> Adapted from [keskinonur/claude-code-ios-dev-guide](https://github.com/keskinonur/claude-code-ios-dev-guide) (MIT).

# Sandbox Permission Levels

## Level 1 — Read + Build Only

```json
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep",
      "mcp__xcodebuildmcp__build_*",
      "mcp__xcodebuildmcp__test_*",
      "mcp__xcodebuildmcp__list_*",
      "mcp__xcodebuildmcp__boot_simulator",
      "mcp__xcodebuildmcp__capture_logs"
    ],
    "deny": ["Write", "Edit"]
  }
}
```

✅ Read, build, test, simulators  ❌ No file creation or modification

---

## Level 2 — + Docs Writing

```json
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep",
      "Write(docs/*)", "Edit(docs/*)",
      "mcp__xcodebuildmcp__*"
    ],
    "deny": ["Write(*.swift)", "Edit(*.swift)", "Write(*.json)", "Write(*.plist)"]
  }
}
```

✅ All of Level 1 + write PRDs/specs/docs  ❌ No Swift/config changes

---

## Level 3 — + Test Files

```json
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep",
      "Write(docs/*)",
      "Write(*Tests/*.swift)", "Write(*Tests/**/*.swift)",
      "Edit(*Tests/*.swift)", "Edit(*Tests/**/*.swift)",
      "mcp__xcodebuildmcp__*"
    ],
    "deny": ["Write(*/App/*)", "Write(*/Features/*)", "Write(*/Core/*)"]
  }
}
```

✅ All of Level 2 + test files  ❌ No production code

---

## Level 4 — Full Development

```json
{
  "permissions": {
    "allow": ["Read", "Write", "Edit", "mcp__xcodebuildmcp__*", "Bash(git *)", "Bash(swift *)"],
    "deny": ["Write(.env*)", "Write(**/Secrets.swift)", "Bash(rm -rf *)"]
  }
}
```

✅ Full dev capabilities  ❌ No secrets, no destructive commands

---

## Full Project settings.json Template

```json
{
  "model": "claude-sonnet-4-6",
  "permissions": {
    "allow": [
      "mcp__xcodebuildmcp__*", "Read", "Write", "Edit",
      "Bash(git *)", "Bash(swift *)", "Bash(swiftlint *)",
      "Bash(swift-format *)", "Bash(xcodegen *)", "WebFetch"
    ],
    "deny": ["Read(.env*)", "Read(**/Secrets.swift)", "Write(.env*)", "Bash(rm -rf *)"]
  },
  "env": {
    "PROJECT_NAME": "MyApp",
    "DEFAULT_SIMULATOR": "iPhone 16",
    "SWIFT_VERSION": "6.0",
    "IOS_DEPLOYMENT_TARGET": "17.0"
  }
}
```

## Personal settings.local.json

```json
{
  "model": "claude-opus-4-8",
  "env": {
    "DEVELOPMENT_TEAM": "YOUR_TEAM_ID",
    "CODE_SIGN_IDENTITY": "Apple Development"
  }
}
```

## Sandbox Workflow

```bash
# 1. Plan (read-only)
claude --permission-mode plan

# 2. "Ultrathink about how to implement X. DO NOT write code."
# 3. Review plan

# 4. Implement (Normal mode — asks per change)
claude
# Shift+Tab to cycle modes during session
```

## Sandbox Slash Commands

### `.claude/commands/sandbox-review.md`
```markdown
---
allowed-tools: Read, Grep, Glob, mcp__xcodebuildmcp__build_*, mcp__xcodebuildmcp__test_*
---
Analyze codebase read-only: read, build, test, report. DO NOT modify files.
```

### `.claude/commands/sandbox-build.md`
```markdown
---
allowed-tools: mcp__xcodebuildmcp__*, Read
---
1. Clean: mcp__xcodebuildmcp__clean
2. Build: mcp__xcodebuildmcp__build_sim_name_proj
3. Test: mcp__xcodebuildmcp__test_sim_name_proj
4. Report results. No file modifications.
```
