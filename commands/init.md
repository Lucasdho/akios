---
description: Onboard this repo to the akios kit — interview, scan, fill the context files, create the folder tree, seed preferences, and wire the gate hook.
disable-model-invocation: true
---

# /akios:init — Onboard a repo to the kit

You are setting up the akios agentic-kit in the user's repo. A plugin cannot shell-write
into their repo, so you do this with your own file tools. Work at the **git repo root**
(`git rev-parse --show-toplevel`); fall back to the cwd if not a git repo.

Templates live in the installed plugin at `${CLAUDE_PLUGIN_ROOT}/templates/` and
`${CLAUDE_PLUGIN_ROOT}/scripts/`. Read them from there; do not invent their contents.
`init` is **bootstrap, not a phase** (see `workflow.yml` `bootstrap`).

## 0. Detect state (idempotency gate — do this first)
Don't re-onboard a repo that's already set up; re-running `/akios:init` should be cheap.
Read the installed version (`${CLAUDE_PLUGIN_ROOT}/VERSION`) and the repo's recorded version
(`<root>/.claude/.agentic-kit-version`, may be absent), then branch:

- **No version file (or no `AGENTS.md`)** → fresh repo. Run the **full** flow (steps 1–6).
- **Recorded == installed** → already initialized. **Skip the interview and copies.** Run only the
  **self-check (step 6)**, repair any single missing artifact, and stop with "Already initialized
  at v<X> — nothing to do." Re-run the full flow only if the user asks to repair/reset.
- **Recorded < installed** → **migrate, don't re-interview.** Skip step 1. Refresh only the
  **always-copy** artifacts (the two hooks, `workflow.yml`, the version file); leave the
  *skip-if-exists* files (`AGENTS.md`, `Context.md`, `Roadmap.md`, `.claude/rules/swift.md`)
  untouched. Re-verify wiring (steps 4–5). Write the new version, then **report the diff** from
  `${CLAUDE_PLUGIN_ROOT}/CHANGELOG.md` in two or three lines, flagging anything needing a manual touch.
  Detect the **mode** here too: if the user has feature work in mind, ask `new`/`one-shot`/`feature`.

## 1. Interview (short — map answers to the placeholders)
Ask in one batched pass (skip what the scan in step 2 answers confidently; confirm rather than re-ask):
- **Mode** — `new` (greenfield repo) / `one-shot` (single deliverable) / `feature` (adding to an
  existing app). Written to `Roadmap.md`; `brainstorm` reads it instead of re-asking.
- **Collaboration** — `solo` (you're the only one running akios here) / `team` (multiple devs each
  run akios against this repo). Written to `Roadmap.md`. Drives delivery: **solo** → just-vibes merges
  + pushes the default branch; **team** → just-vibes pushes `feature/<spec>` + opens a PR, and the
  multi-instance claim/signature etiquette is in force.
- **Stack** — language / framework / runtime / DB (`{{LANGUAGE / FRAMEWORK / RUNTIME / DB}}`)
- **Commands** — install / run-dev / test / lint / build (`{{install}}` `{{dev}}` `{{test}}` `{{lint}}` `{{build}}`)
- **Architecture** — one paragraph: entry points, key dirs, data flow
- **Conventions** — naming, error handling, commit/branch style
- **Gotchas** — the thing that bites a newcomer or the agent
- **Project-specific gate** (AGENTS.md) — e.g. "always /security-review when touching auth"
- **House rule** (AGENTS.md `{{PROJECT_RULE}}`) — a project-specific must/never
- **Claude note** (CLAUDE.md) — any Claude-specific instruction, or drop the section

## 2. Scan (facts win over interview; surface contradictions)
Inspect the repo to fill/verify command + stack + architecture: `.xcodeproj`/`.xcworkspace`
+ scheme, `Package.swift` (SPM deps), the `xcodebuild` test/build invocation (quote any
space-containing project/scheme), deployment target, top-level source dirs. If a scan fact
contradicts an interview answer, tell the user and ask which is right before writing.

**Target membership (fills `Context.md` `## Xcode targets`).** Read the `.pbxproj` and check for
`PBXFileSystemSynchronizedRootGroup` (or `objectVersion` ≥ 77 = Xcode 16+). If present, the project
uses **synchronized groups** — record which on-disk folder maps to which target (files dropped there
auto-include, no `.pbxproj` edit). If absent, record that target membership is **manual**. Note
where test fixtures live. This is what stops the agent re-deriving "will this file be in the bundle?"
on every new file.

## 3. Materialize the context files + folder tree (never clobber existing files)
Copy each template into the repo, replacing every `{{...}}` token with the resolved value.
Placeholders to fill live in `Context.md`, `AGENTS.md`, `CLAUDE.md`, and `Roadmap.md` (mode).

| File | Source | Rule |
|---|---|---|
| `AGENTS.md` | `templates/AGENTS.md` | skip if it already exists |
| `Context.md` | `templates/Context.md` | skip if it already exists |
| `Roadmap.md` | `templates/Roadmap.md` | skip if it exists; fill the `mode:` + `collaboration:` lines |
| `Vision.md` | `templates/Vision.md` | skip if it exists; fill the north-star + first wishlist items (just-vibes fuel) |
| `workflow.yml` | `${CLAUDE_PLUGIN_ROOT}/workflow.yml` | always copy (the phase contract) |
| `CLAUDE.md` | `templates/CLAUDE.md` | if missing, create; if present, prepend whichever of `@AGENTS.md` / `@Context.md` imports is missing (Context first so AGENTS ends on top) |
| `.claude/rules/swift.md` | `templates/rules/swift.md` | skip if it already exists |
| `.claude/hooks/agentic-kit-inject.sh` | `scripts/hook/agentic-kit-inject.sh` | always copy; make executable |
| `.claude/hooks/skill-trace.sh` | `scripts/hook/skill-trace.sh` | always copy; make executable (optional telemetry) |
| `.claude/hooks/akios-instance.sh` | `scripts/akios-instance.sh` | always copy; make executable (instance signature for just-vibes + claims) |
| `.claude/.agentic-kit-version` | contents of `${CLAUDE_PLUGIN_ROOT}/VERSION` | always write |
| `scripts/alva-usage-ledger.sh` | `${CLAUDE_PLUGIN_ROOT}/scripts/alva-usage-ledger.sh` | always copy; make executable |
| `.git/hooks/pre-commit` | append a call to `scripts/alva-usage-ledger.sh` | if a pre-commit hook already exists, append a line calling the script rather than overwrite it; if none exists, create one that just calls it (make executable) |

**Create the folder tree** (empty, with a `.gitkeep` if your tooling needs it):
`specs/ tasks/todo/ tasks/in-progress/ tasks/review/ tasks/done/ archive/ code-references/`.
(`.akios/` is created at runtime for the local journal/trace and stays gitignored — multi-instance
claims live in **committed** files: task frontmatter `owner:` and the `Roadmap.md` spec line.)

**Scaffold the ALVA composition root** (skip any piece that already exists):
`Router/ Container/ Foundation/Design-tokens/ Foundation/Code-tokens/ scratchs/`, plus a starter
`Foundation/usage-ledger.json` (`{"generated": null, "candidates_promote": [], "candidates_demote":
[]}`) so `scripts/alva-usage-ledger.sh` has a file to overwrite on the first commit. **Do not**
create `Features/` empty up front — a feature only gets a slice when `spec-to-tasks` decomposes
its spec; an empty `Features/` folder is dead scaffolding no one asked for yet. `scratchs/` holds
rejected `ui-variations` rounds and is excluded from the Xcode target (`Context.md` gets a line
noting this, so a fresh session doesn't have to re-derive it).

Also copy the two design-token stubs into `Foundation/Design-tokens/` (skip if either already
exists): `templates/foundation/DesignSystem.swift` and `templates/foundation/RoleModifiers.swift`
— a minimal `DesignSystem` token enum + `.textStyle`/`.imageStyle` role-modifier placeholder, so
the folder isn't empty on day one. Both point back at `swift-dev`'s `swiftui-design-system` guide
for the full shape (ui-overhaul-implementation.md Phase 1.4 / Phase 4.1).

**Seed user preferences (user-global, once):** if `~/.claude/akios/preferences.md` does **not**
exist, create `~/.claude/akios/` and copy `templates/preferences.seed.md` there as
`preferences.md`. If it already exists, leave it untouched (it survives plugin updates).

Append `.akios/` to the repo's `.gitignore` (the skill trace is runtime data, not source).

## 4. Wire the hooks (idempotent)
In `<root>/.claude/settings.json` (create as `{}` if absent; use `jq` if available):
- **SessionStart gate hook** — if `agentic-kit-inject` is present, leave it. Else append to
  `.hooks.SessionStart`:
  `{ "hooks": [ { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/agentic-kit-inject.sh\"" } ] }`
- **PostToolUse skill-trace hook** (optional) — if `skill-trace` is present, leave it. Else append to
  `.hooks.PostToolUse`:
  `{ "hooks": [ { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/skill-trace.sh\"" } ] }`

## 5. Self-check (fail loudly)
Confirm: the context files (incl. `Vision.md`) + `workflow.yml` + the folder tree exist;
`CLAUDE.md` imports both `@AGENTS.md` and `@Context.md`; both hooks +
`.claude/hooks/akios-instance.sh` are present; `Roadmap.md` has a `mode:` **and** a `collaboration:`
value; `~/.claude/akios/preferences.md` exists; **no `{{...}}` placeholder remains** in
`Context.md` / `AGENTS.md` / `CLAUDE.md` / `Roadmap.md` / `Vision.md`; and the ALVA scaffold
(`Router/ Container/ Foundation/{Design-tokens,Code-tokens}/ scratchs/` + a valid
`Foundation/usage-ledger.json` + the pre-commit hook calling `scripts/alva-usage-ledger.sh`) is in
place. Report any miss.

## 6. Dependencies
The kit has **no required external plugins** — everything the spine routes to (`swift-dev`,
`idea-to-spec`, `spec-to-tasks`, `task-execution`, `oss-first`, `ios-feature-pipeline`,
`just-vibes`) ships with akios. **Optional:** `ponytail` (efficiency overlay) —
`/plugin marketplace add DietrichGebert/ponytail` → `/plugin install ponytail`. The kit works
without it. No speckit needed.

Finish with: the repo is onboarded; next step is `/akios:brainstorm "<your feature idea>"`.
