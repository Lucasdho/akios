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
**Important:** the only placeholders to fill are the ones in `Context.md`, `AGENTS.md`, and
`CLAUDE.md`. Do NOT touch any `{{ inputs.* }}` tokens elsewhere — those are speckit's own
workflow syntax.

| File | Source | Rule |
|---|---|---|
| `AGENTS.md` | `${CLAUDE_PLUGIN_ROOT}/templates/AGENTS.md` | skip if it already exists |
| `Context.md` | `${CLAUDE_PLUGIN_ROOT}/templates/Context.md` | skip if it already exists |
| `CLAUDE.md` | `${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md` | if missing, create; if present, prepend whichever of `@AGENTS.md` / `@Context.md` imports is missing (Context first so AGENTS ends on top) |
| `.claude/rules/swift.md` | `${CLAUDE_PLUGIN_ROOT}/templates/rules/swift.md` | skip if it already exists |
| `.claude/hooks/agentic-kit-inject.sh` | `${CLAUDE_PLUGIN_ROOT}/scripts/hook/agentic-kit-inject.sh` | always copy; make executable |
| `.claude/.agentic-kit-version` | contents of `${CLAUDE_PLUGIN_ROOT}/VERSION` | always write |

## 4. Wire the SessionStart gate hook (idempotent)
In `<root>/.claude/settings.json` (create as `{}` if absent): if the text
`agentic-kit-inject` is already present, leave it ("hook already wired"). Otherwise append
to `.hooks.SessionStart` this entry (use `jq` if available, else edit the JSON directly):
```
{ "hooks": [ { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/agentic-kit-inject.sh\"" } ] }
```

## 5. Self-check (fail loudly)
Confirm all six artifacts exist, `CLAUDE.md` imports both `@AGENTS.md` and `@Context.md`,
the hook is wired, and **no `{{...}}` placeholder remains** in `Context.md` / `AGENTS.md` /
`CLAUDE.md`. Report any miss.

## 6. Dependency check (the kit can't auto-install other plugins)
Check whether these are installed; for any missing one, print the exact install lines:
- **Required:** superpowers — `/plugin marketplace add obra/superpowers` → `/plugin install superpowers`
- **Required:** axiom — `/plugin marketplace add CharlesWiltgen/Axiom` → `/plugin install axiom`
- **Optional:** ponytail — `/plugin marketplace add DietrichGebert/ponytail` → `/plugin install ponytail`
- **Speckit** (for `/akios:plan`): note if `.specify/` is absent — `/akios:plan` will use the
  degraded path until `npx speckit init` is run.

Finish with: the repo is onboarded; next step is `/akios:define "<your feature idea>"`.
