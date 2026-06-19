---
description: Onboard this repo to the akios kit — interview, scan, fill the context files, wire the gate hook, and check dependencies.
disable-model-invocation: true
---

# /akios:init — Onboard a repo to the kit

You are setting up the akios agentic-kit in the user's repo. A plugin cannot shell-write
into their repo, so you do this with your own file tools. Work at the **git repo root**
(`git rev-parse --show-toplevel`); fall back to the cwd if not a git repo.

Templates live in the installed plugin at `${CLAUDE_PLUGIN_ROOT}/templates/` and
`${CLAUDE_PLUGIN_ROOT}/scripts/`. Read them from there; do not invent their contents.

## 0. Detect state (idempotency gate — do this first)
Don't re-onboard a repo that's already set up; re-running `/akios:init` should be cheap.
Read the installed version (`${CLAUDE_PLUGIN_ROOT}/VERSION`) and the repo's recorded version
(`<root>/.claude/.agentic-kit-version`, may be absent), then branch:

- **No version file (or no `AGENTS.md`)** → fresh repo. Run the **full** flow (steps 1–6).
- **Recorded == installed** → already initialized at this version. **Skip the interview and
  copies.** Run only the **self-check (step 5)** to confirm nothing rotted, repair any single
  missing artifact (a deleted hook, a dropped import), and stop with: "Already initialized at
  v<X> — nothing to do." Only re-run the full flow if the user explicitly asks to repair/reset.
- **Recorded < installed** → **migrate, don't re-interview.** The context files already exist and
  hold the user's answers, so skip step 1. Run steps 3–5 in *migration mode*: only the
  **always-copy** artifacts get refreshed (the two hooks + the version file); the
  *skip-if-exists* files (`AGENTS.md`, `Context.md`, `.claude/rules/swift.md`) are left untouched.
  Re-verify the hooks are wired (step 4) and the `CLAUDE.md` imports are present (step 5). Write
  the new version. Then **report the diff**: read `${CLAUDE_PLUGIN_ROOT}/CHANGELOG.md` and tell the user,
  in two or three lines, what changed between their recorded version and the installed one — and
  flag anything that needs a manual touch (e.g. a new template section their existing `AGENTS.md`
  predates).

## 1. Interview (short — map answers to the placeholders)
Ask the user, in one batched pass (skip anything the scan in step 2 already answers
confidently, and confirm rather than re-ask):
- **Stack** — language / framework / runtime / DB (`{{LANGUAGE / FRAMEWORK / RUNTIME / DB}}`)
- **Commands** — install / run-dev / test / lint / build (`{{install}}` `{{dev}}` `{{test}}` `{{lint}}` `{{build}}`)
- **Architecture** — one paragraph: entry points, key dirs, data flow
- **Conventions** — naming, error handling, commit/branch style
- **Gotchas** — the thing that bites a newcomer or the agent
- **Project-specific gate** (AGENTS.md) — e.g. "always /security-review when touching auth"
- **House rule** (AGENTS.md `{{PROJECT_RULE}}`) — a project-specific must/never
- **Claude note** (CLAUDE.md) — any Claude-specific instruction, or drop the section

## 2. Scan (facts win over interview; surface contradictions)
Inspect the repo to fill/verify the command + stack + architecture answers:
`.xcodeproj`/`.xcworkspace` + scheme name, `Package.swift` (SPM deps), the test/build
`xcodebuild` invocation (quote any space-containing project/scheme), deployment target,
top-level source dirs. If a scan fact contradicts an interview answer, tell the user and
ask which is right before writing.

## 3. Materialize the context files (never clobber existing ones)
Copy each template into the repo, replacing every `{{...}}` token with the resolved value.
The placeholders to fill live only in `Context.md`, `AGENTS.md`, and `CLAUDE.md`.

| File | Source | Rule |
|---|---|---|
| `AGENTS.md` | `${CLAUDE_PLUGIN_ROOT}/templates/AGENTS.md` | skip if it already exists |
| `Context.md` | `${CLAUDE_PLUGIN_ROOT}/templates/Context.md` | skip if it already exists |
| `CLAUDE.md` | `${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md` | if missing, create; if present, prepend whichever of `@AGENTS.md` / `@Context.md` imports is missing (Context first so AGENTS ends on top) |
| `.claude/rules/swift.md` | `${CLAUDE_PLUGIN_ROOT}/templates/rules/swift.md` | skip if it already exists |
| `.claude/hooks/agentic-kit-inject.sh` | `${CLAUDE_PLUGIN_ROOT}/scripts/hook/agentic-kit-inject.sh` | always copy; make executable |
| `.claude/hooks/skill-trace.sh` | `${CLAUDE_PLUGIN_ROOT}/scripts/hook/skill-trace.sh` | always copy; make executable (optional skill-use telemetry) |
| `.claude/.agentic-kit-version` | contents of `${CLAUDE_PLUGIN_ROOT}/VERSION` | always write |

Also append `.akios/` to the repo's `.gitignore` (the skill trace is runtime data, not source).

## 4. Wire the hooks (idempotent)
In `<root>/.claude/settings.json` (create as `{}` if absent), use `jq` if available, else edit
the JSON directly:
- **SessionStart gate hook** — if `agentic-kit-inject` is already present, leave it. Otherwise
  append to `.hooks.SessionStart`:
  ```
  { "hooks": [ { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/agentic-kit-inject.sh\"" } ] }
  ```
- **PostToolUse skill-trace hook** (optional telemetry) — if `skill-trace` is already present,
  leave it. Otherwise append to `.hooks.PostToolUse`:
  ```
  { "hooks": [ { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/skill-trace.sh\"" } ] }
  ```

## 5. Self-check (fail loudly)
Confirm the artifacts exist, `CLAUDE.md` imports both `@AGENTS.md` and `@Context.md`, both
hooks are wired (SessionStart + PostToolUse), and **no `{{...}}` placeholder remains** in
`Context.md` / `AGENTS.md` / `CLAUDE.md`. Report any miss.

## 6. Dependency check (the kit can't auto-install other plugins)
Check whether these are installed; for any missing one, print the exact install lines:
- **Required:** superpowers — `/plugin marketplace add obra/superpowers` → `/plugin install superpowers`
- **Required:** axiom — `/plugin marketplace add CharlesWiltgen/Axiom` → `/plugin install axiom`
- **Optional:** ponytail — `/plugin marketplace add DietrichGebert/ponytail` → `/plugin install ponytail`

No speckit is needed — `/akios:plan` runs the kit's own `spec-to-tasks` pass (one file, no
`.specify/`).

Finish with: the repo is onboarded; next step is `/akios:define "<your feature idea>"`.
