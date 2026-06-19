# Changelog

## 0.4.0 (2026-06-19)

### Changed — speckit dropped; lean 3-phase spine
- **New spine:** `idea-to-spec → spec-to-tasks → task-execution → verify + /code-review`.
  The four speckit phases (clarify/specify/plan/tasks) + the constitution bootstrap are gone —
  they re-did rigor the kit already has (design happens decision-by-decision in `idea-to-spec`;
  quality is gated by `AGENTS.md` house rules + axiom + ponytail + `/code-review`). A real run
  showed speckit producing ~9 files for a `tasks.md` that one pass now produces as 1.
- **`/akios:plan`** now runs `spec-to-tasks` (one pass, one confirm); **`/akios:deliver`** now
  runs `task-execution`. No `.specify/`, no web/backend folder trees.

### Added
- **`spec-to-tasks` skill** — one pass from an approved spec to `tasks.md`: atomic tasks with
  `[P]` parallel markers, checkpoint barriers, definitions of done, and a mandatory designer's-eye
  pass that puts happy / empty / loading / error coverage in every UI task's DoD.
- **`task-execution` skill** — runs `tasks.md` on a per-spec branch, commits at each checkpoint,
  runs the unit + integration battery at `[major]` checkpoints, compresses context only between
  specs, and stops at a hard human gate before any push or merge. Subagents are opt-in (never a
  hard dependency — this environment can deny them `xcodebuild`).
- **Two house rules** in `templates/AGENTS.md`: native types over wrappers (Swift `id`/`UUID`/
  `Hashable`/`Codable` before any wrapper), and protocol-first repositories (protocol + default
  impls; DoD = `Hashable` + JSON↔object round-trip).
- **`skill-trace` PostToolUse hook** (`scripts/hook/skill-trace.sh`, optional) — appends skill
  loads + skill-reference reads + a `git diff --shortstat` snapshot to `.akios/trace.jsonl`;
  `task-execution` adds the test pass/fail count at `[major]` checkpoints for a before/after delta.
  No test runs in the hook itself.

### Migration
- Repos with an existing `.specify/` keep working — those files just go unused; `/akios:plan`
  stops invoking speckit. Re-run `/akios:init` (or `install.sh`) to pick up the new hook + house
  rules and gitignore `.akios/`.

## 0.3.0 (2026-06-18)

### Added — plugin distribution + workflow commands
- **The kit now ships as a Claude Code plugin, `akios`.** New
  `.claude-plugin/plugin.json` (auto-discovers `commands/` + `skills/`) and
  `.claude-plugin/marketplace.json` (same-repo marketplace, `source: "./"`). Install in
  two lines: `/plugin marketplace add Lucasdho/iOS-agentic-kit` → `/plugin install akios`.
- **Four typed slash commands** (`commands/*.md`, all `disable-model-invocation: true` so
  they never auto-fire):
  - `/akios:init` — onboards a repo: interview → scan → fill the `{{...}}` placeholders →
    materialize the context files → wire the gate hook → check dependencies. The
    intelligent layer over `install.sh`.
  - `/akios:define` — pipeline Phase 1 (`idea-to-spec`).
  - `/akios:plan` — pipeline Phases 2-5 (speckit clarify→specify→plan→tasks; degraded path
    if no `.specify/`).
  - `/akios:deliver` — pipeline Phase 6 (`superpowers:subagent-driven-development` + verify
    + `/code-review`).
  The three wrappers invoke `ios-feature-pipeline` at the named phase and do not duplicate
  the spine (kit SSoT rule); they guard for an initialized repo and point to `/akios:init`.

### Changed
- `install.sh` reframed as the **cross-agent bootstrap** (Codex/Gemini and non-plugin
  setups) — a plugin command can't write into a user repo. Claude Code users are pointed at
  `/akios:init`. The gate hook stays a per-repo artifact (no plugin-level hook → no
  pollution of non-iOS repos).
- `test-kit.sh` now validates the plugin manifests parse, the plugin is named `akios`, and
  all four command files exist with a `description:` frontmatter line.

## 0.2.3 (2026-06-18)

### Fixes
- **axiom-xcode → axiom-build rename** — corrected the Axiom sub-skill name in 6 files
  (`AGENTS.md`, `skills/ios-agentic-kit/SKILL.md`, and related templates/rules). Any
  installed repo that has `axiom-xcode` in `AGENTS.md` or `.claude/rules/swift.md`
  should run `install.sh` again to pick up the corrected templates.
- Hook gate notation standardized to match `AGENTS.md` style (`swift-dev`→`sub-skill`).
- `idea-to-spec` and `ios-feature-pipeline` spec filename conventions aligned
  (`specs/<feature>.md` preferred form documented in `spec-format.md`).
- `test-kit.sh` now covers `templates/workflows/ios-feature-pipeline.yml`, so a
  missing workflow artifact is caught by CI.
- `install.sh` self-check now emits a visible warning (exit 1) when the SessionStart
  hook is not wired, instead of silently passing.

### Docs
- `skills/ios-agentic-kit/references/hooks.md` slimmed: clarifies that the kit
  installs exactly one SessionStart hook; opt-in examples (lint/format-on-save, file
  protection) moved to a clearly marked section.
- Removed three large, low-signal reference files (`prd-workflow.md`,
  `project-structure.md`, `xcodebuildmcp.md`) that duplicated content maintained
  elsewhere.
- Noted that `version:` frontmatter inside each skill file is an independent track
  from the kit's `VERSION`; added axiom pin verification date to `CREDITS.md`.
- Added comment explaining the SessionStart hook gate list is intentionally compressed
  vs `AGENTS.md` (not a drift).

## 0.2.2 (2026-06-17)

- `START-HERE.md` added — novice-friendly on-ramp; consolidates the agent-install
  block so `README.md` and `START-HERE.md` don't drift.
- Centralized workflow spine in a single orchestration document.

## 0.2.0 — 0.2.1

Initial public release of the 0.2.x line: `install.sh` idempotency, `check-update.sh`,
`install-skills.sh`, versioned `VERSION` stamp.
