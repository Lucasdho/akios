# Permission Levels & `settings.json`

How much the agent is allowed to touch is a `permissions` block in `.claude/settings.json`.
The kit doesn't install one — pick a level that matches how much you trust the current task,
and let the built-in `fewer-permission-prompts` skill trim the per-action prompts once you've
settled on a set.

Four graduated levels, loosest task → tightest. Use a tighter one for exploration/planning,
a looser one once you're implementing.

## Level 1 — Read + Build Only

For exploration, planning, and "look but don't touch" sessions (pairs with plan mode).

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

> If you drive builds through `swift-dev` (`ios-debugger-agent`) or the `builder` agent instead
> of XcodeBuildMCP, swap the `mcp__xcodebuildmcp__*` entries for the tools those use (`Bash`
> scoped to `xcodebuild`, etc.).

---

## Level 2 — + Docs / Specs Writing

Lets the agent write specs and docs (e.g. during `idea-to-spec`) but not Swift or config.

```json
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep",
      "Write(specs/*)", "Edit(specs/*)", "Write(docs/*)", "Edit(docs/*)",
      "mcp__xcodebuildmcp__*"
    ],
    "deny": ["Write(*.swift)", "Edit(*.swift)", "Write(*.json)", "Write(*.plist)"]
  }
}
```

✅ Level 1 + write specs/docs  ❌ No Swift/config changes

---

## Level 3 — + Test Files

Adds test files — useful for a test-first pass before production code is unlocked.

```json
{
  "permissions": {
    "allow": [
      "Read", "Glob", "Grep",
      "Write(specs/*)",
      "Write(*Tests/*.swift)", "Write(*Tests/**/*.swift)",
      "Edit(*Tests/*.swift)", "Edit(*Tests/**/*.swift)",
      "mcp__xcodebuildmcp__*"
    ],
    "deny": ["Write(*/App/*)", "Write(*/Features/*)", "Write(*/Core/*)"]
  }
}
```

✅ Level 2 + test files  ❌ No production code

---

## Level 4 — Full Development

The implementing-code default. Everything except secrets and destructive commands.

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

## Full project `settings.json`

Committed to the repo — shared baseline for everyone (and every agent) on the project.

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

## Personal `settings.local.json` (gitignored)

Per-developer overrides — model preference, signing identity — not shared.

```json
{
  "model": "claude-opus-4-8",
  "env": {
    "DEVELOPMENT_TEAM": "YOUR_TEAM_ID",
    "CODE_SIGN_IDENTITY": "Apple Development"
  }
}
```

## A typical sandboxed session

1. **Plan read-only** — `claude --permission-mode plan` (or Level 1 above). Have the agent
   design the change without writing anything; review the plan.
2. **Implement** — switch to a looser level (Level 4) and let it work. Normal mode asks per
   change; `Shift+Tab` cycles permission modes mid-session.
3. Lean on `fewer-permission-prompts` to fold the repeated approvals into your `allow` list.
