# Changelog

## 0.7.3 (2026-06-22)

### Added
- **`deep-brainstorm` Phase 5 — R-W-W Validation Audit.** After the spec-burst, scores each
  spec against Real / Win / Worth-It criteria (rubric adapted from FounderLens MVA). Writes
  `specs/rww-audit.md` in the target project with per-spec scores and band (Green / Yellow /
  Red). Red specs get Roadmap status `needs-revision`; Yellow specs get `[audit: shaky]` note.
- **`just-vibes` `needs-revision` fuel filter.** Specs at status `needs-revision` are skipped
  during fuel detection by default. Pass `--force` to include them. PARK logic updated: a
  `needs-revision` spec is never delivered even after a green quality gate.
- **`specs/deep-brainstorm-rww-audit.md`** — the design spec for this feature.

## 0.7.2 (2026-06-22)

### Added
- **`deep-brainstorm` skill + command.** Whole-app mapping session — runs FounderLens Double
  Diamond on the entire product, cartographs every major surface (screens, data, infrastructure,
  cross-cutting, business logic, integrations), scopes each area (core/enhance/future), and
  bursts out a complete family of versioned specs in one session. Registered in `workflow.yml`
  as a `run_style`. Invoked via `/akios:deep-brainstorm`.
- **`founderlens-behavior` skill.** Chat-native FounderLens co-founder persona — walks an idea
  through the Double Diamond first diamond (Discover → Define) and Midpoint Validation Audit,
  one ingredient at a time. Used as the Discover phase in `deep-brainstorm`.

### Changed
- **`grill-ui` → `align-ui`.** Renamed for clarity. All references in `task-execution` and
  `CHANGELOG.md` updated.

## 0.7.1 (2026-06-22)

### Added
- **`align-ui` skill** (formerly `grill-ui`). Pre-implementation UI alignment gate that walks
  the user decision-by-decision (structure → layout → components → interactions → states →
  animation) before any SwiftUI View task is written. Fires automatically inside `task-execution`
  for UI-scoped tasks; auto-skipped in just-vibes (writes `tasks/ui-alignment/<Screen>.md`
  unattended with `[auto]` markers).
- **`handoff` skill + command.** Cross-session context transfer via `tasks/handoffs/`. Supports
  the bidirectional pattern: Session 1 writes `<topic>.md`, Session 2 returns
  `<topic>-return.md`. References existing artifacts by path rather than duplicating content.
  Invoked via `/akios:handoff [topic]`.

### Changed
- **Mandatory compact between specs.** `task-execution` compact rule upgraded from advisory to
  hard rule: warn at 110k, compact at 135k, `/compact` required after every spec before the
  next one starts — no exceptions.

## 0.7.0 (2026-06-22)

### Added — just-vibes (autonomous run)
- **`/akios:just-vibes` run-style.** akios drives the whole pipeline unattended: picks the next fuel
  (a submitted idea → `tasks/todo/` → designed specs → `Vision.md`/`Roadmap.md`), builds it, gates on
  quality, and delivers. **Default** runs one unit then stops at the spec boundary; **`--force`** loops
  until fuel is exhausted or interrupted. It is the explicit **opt-out of the human push/merge gate**
  (invoking it is the authorization) — but the **quality gate stays**: verify + code-review + a bounded
  fix loop, and a still-red spec is **parked** (branch + logs), never delivered. New `commands/just-vibes.md`
  + `skills/just-vibes/SKILL.md`; documented in `workflow.yml` (`run_styles`), `AGENTS.md`, `specs/pipeline.md`.
- **Vision.md as top-tier fuel.** New `templates/Vision.md` (north star + prioritized wishlist) seeded by
  `/akios:init`; just-vibes mines it when no idea/spec work is queued.
- **Unattended deepthink brainstorm.** `idea-to-spec` gains an "Unattended (just-vibes) brainstorm"
  posture: deepthink per decision, competitor/solution research, reuse of previously delivered specs
  (`archive/Archive.md`, `MEMORY.md`), and a decision record for every choice (post-hoc review). Skill → 1.2.0.

### Added — multi-instance (teammate-aware, safety-first, no server)
- **Instance signature.** New `scripts/akios-instance.sh` mints a stable `Akios-Instance: user@host/id`
  (cached in `~/.claude/akios/instance.id`), carried on commit trailers and claims so a teammate's akios
  recognizes others' work. Copied into `.claude/hooks/` by install + init.
- **Claim-before-work + git-arbitrated locking.** In `collaboration: team`, claim a unit in a committed
  file (task frontmatter `owner:` / the `Roadmap.md` line) and push; **push-rejection is the lock**; yield
  if a teammate's signature already holds it. `Roadmap.md` stays single-source with a **monotonic-status
  merge** (higher status wins; edit only your line, never reorder) so unattended runs resolve conflicts
  without a human. Protocol in `task-execution` (→ 2.2.0); etiquette in a new AGENTS.md
  "Working alongside teammates" section.

### Changed — init + config
- **`/akios:init` asks solo vs team** and writes a new **`collaboration: solo|team`** flag to `Roadmap.md`
  (alongside `mode:`); drives just-vibes delivery (solo → merge+push default branch · team → feature branch
  + PR). `workflow.yml` gains `collaboration:` + a `run_styles:` block. (`commands/init.md`,
  `templates/Roadmap.md`, `scripts/install.sh`)

## 0.6.2 (2026-06-22)

### Added — size the work, spend the cheapest tier
- **Sizing the work.** New AGENTS.md section + hook line teaching the agent to tell a *quick task*
  (one file, mechanical, low-risk → do it inline, no pipeline) from a *real spec* (multi-file, new
  behavior, new domain → route through brainstorm → plan → execute). Mis-sizing costs both ways; when
  genuinely unsure, ask one sizing question. (`templates/AGENTS.md`, `scripts/hook/agentic-kit-inject.sh`)
- **Subagent model tiers + budget orchestration.** Dispatch the **cheapest model that fits**: simple,
  well-scoped subtask (mechanical edit, focused search, one test file) → **haiku**; implementing a
  spec's tasks end-to-end (judgment + TDD across files) → **sonnet**; never a model more capable than
  the subtask needs. The driving session itself runs on **opus or sonnet** — sonnet is the budget
  default; opus is optional, not required. Wired into `task-execution`'s runner routing.
  (`templates/AGENTS.md`, `skills/task-execution/SKILL.md`, hook)
- **Never clone context into a subagent.** A subagent starts cold and is billed for every token handed
  to it — passing the whole window is the most expensive mistake. Send only the slice (task + DoD, the
  one `swift-dev` domain sub-skill, the matching `Context.md` gotcha, the precedent path). Stated in
  AGENTS.md, `task-execution` cold-subagent discipline + anti-patterns, and the hook. Skill version → 2.1.0.

- **Subagents gated on context pressure.** Subagents are now discouraged by default: dispatch one only
  when the driving session is at **≥120k tokens (~60% of a 200k window)** *and* the task is heavy and
  isolatable. A cold subagent is re-fed context and billed on top of the session, so below that bar
  inline is cheaper. (`templates/AGENTS.md`, `skills/task-execution/SKILL.md`, hook)

### Changed — spec state single source of truth
- **Roadmap.md is the only spec registry.** Made the existing convention explicit so executions stop
  asking whether to duplicate it: never mirror the `## Specs` table into `CLAUDE.md` (or anywhere).
  One file updates, nothing drifts. (`templates/AGENTS.md`, `templates/CLAUDE.md`, `templates/Roadmap.md`,
  `skills/task-execution/SKILL.md` anti-patterns, hook)
- **Match permission mode to phase.** New guidance to run `brainstorm`/`plan` in **plan mode** (review
  before any edit) and `execute` in **accept-edits / auto mode** (don't approve every edit during the
  implementation loop); `Shift+Tab` cycles. Framed as workflow economy and added to the always-on path,
  complementing the existing sandbox/security note in `ios-agentic-kit`'s `references/sandbox.md`.
  (`templates/AGENTS.md`, hook)

## 0.6.1 (2026-06-22)

### Changed — usage fixes
- **Claude-only.** Dropped the multi-agent (Codex/Gemini/"cross-agent") framing — akios targets the
  Claude agent. The no-plugin script route stays (it serves plain Claude Code without the plugin);
  the `AGENTS.md` file is unchanged. (`templates/AGENTS.md`, `START-HERE.md`, `README.md`,
  `scripts/install.sh`)
- **Apple/Swift scope warning.** New House rule: akios is tuned for the Apple ecosystem; it may
  still help with non-Apple code (web/JS, Android, non-Swift backend) but **warns once** that it's
  outside its specialization first, then proceeds — warn, don't block. Mirrored in the SessionStart
  hook. (`templates/AGENTS.md`, `scripts/hook/agentic-kit-inject.sh`)

### Added — Xcode target-membership knowledge
- **Baseline in `swift-dev`.** New "Adding files to an Xcode target" section: check the `.pbxproj`
  for `PBXFileSystemSynchronizedRootGroup` / `objectVersion` ≥ 77 — if present (Xcode 16+
  synchronized groups), files dropped in the target's on-disk folder auto-include with no
  `.pbxproj` surgery; if absent, target membership is explicit. Stops the agent re-deriving "will
  this file be in the bundle?" each time. Skill version → 1.1.0.
- **Per-project answer + auto-detect.** `Context.md` gains an `## Xcode targets` field (membership
  mechanism + test-fixture location); `/akios:init`'s scan detects and fills it from the `.pbxproj`.
  (`skills/swift-dev/SKILL.md`, `templates/Context.md`, `commands/init.md`)

## 0.6.0 (2026-06-22)

### Added — deepthink mode + open-field decisions
- **Deepthink mode (user-triggered).** When the user flags a decision as high-stakes and wants
  the full tradeoffs ("deepthink this", "vai fundo nessa"), the rigor turns up on *that one
  decision*: grounded research with citations when external facts would change the answer,
  second-order consequences per option (what it forecloses, reversible vs one-way, who it
  helps/hurts), and a decision record written into the spec (the *why* + rejected alternatives,
  not just the chosen option). Depth goes up; the rules — one decision at a time, ≤3 positions,
  the user decides — do not. Opt-in, so zero standing overhead. Full protocol in
  `skills/idea-to-spec/SKILL.md` ("Deepthink mode") + `references/session-patterns.md`
  ("Deepthink turns"); a short global trigger lives in `templates/AGENTS.md` so it applies to any
  consequential decision, not just spec design.

### Changed — decision presentation
- **Up to 3 positions (was 2–4), open field first-class.** `idea-to-spec` now caps proposed
  positions at 3 (never pads to a fourth) and presents the free-text open path as a peer of the
  options on every decision turn — never a buried footnote. Picking and writing your own are
  equally available. (golden rules #2/#3, the decision loop, and `session-patterns.md`)
- `idea-to-spec` skill version → `1.1.0`.

## 0.5.1 (2026-06-22)

### Changed — proportional gating (less overhead)
- **Gates are a map, not a toll booth.** Reframed the skill gates from an opt-out default
  ("treat as the workflow; skip only with reason") to a proportionality principle: load a guide
  only when it injects knowledge you lack or enforces discipline on risky/novel work. Mechanical
  pattern-copy from an existing repo file (mirror a screen/VM, rename, obvious one-liner) skips
  the gate — recognizing the precedent *is* the routing. (`templates/AGENTS.md`)
- **`swift-dev`: fast-path + reversed anti-pattern.** Added a fast-path selection rule, and
  replaced the "skipping the router for trivial changes is a mistake" anti-pattern (which forced
  the baseline guide onto every `.swift` touch) with an "over-gating mechanical work" anti-pattern.
  Judge by whether the guide would change what you ship. (`skills/swift-dev/SKILL.md`)
- **SessionStart hook** now leads the gate reminder with the proportionality rule.
  (`scripts/hook/agentic-kit-inject.sh`)
- **Isolation guardrail.** Skipping the gate is not skipping isolation: standalone work that
  bypasses the pipeline still lands on a branch/worktree (never the working copy mid-build), reads
  first, and deletes dead code so the diff shrinks. Pairs the speed-up with its safety rails so
  de-gating can't be read as "edit in place recklessly." (`templates/AGENTS.md`)

## 0.5.0 (2026-06-20)

### Changed — no external plugin dependencies
- **axiom → `swift-dev`.** The Swift/iOS domain master router (restored, bundled with its
  sub-skills) replaces the external `axiom` plugin. `.claude/rules/swift.md` now loads the
  `swift-dev` gate. Debugging routes to `swift-dev`'s `ios-debugger-agent`.
- **superpowers → `task-execution`.** The execution phase absorbs the TDD + verification
  discipline the kit used to borrow from `superpowers` (brainstorming was already covered by
  `idea-to-spec`). No required external plugins remain; `ponytail` stays optional.

### Added
- **`workflow.yml`** — a machine-readable phase contract (single source of truth). Commands are
  thin wrappers that read it; phase detection = "which outputs exist", gating = "which prereqs
  exist" (soft gate + offer).
- **Folder-state task lifecycle.** `spec-to-tasks` now emits one file per task under `tasks/todo/`
  (with `est_tokens` + `runner`); `task-execution` moves each file `todo → in-progress → review →
  done`. Decomposition is by size + similarity (80k soft ceiling); `[P]` is by area.
- **Priority chain** — `project (MEMORY.md+code) → code-references/ → ~/.claude/akios/preferences.md
  → swift-dev`, applied as a cascade. New `code-references/` (indexed, load-on-demand) and a
  user-global `preferences.md` (observe→confirm→append).
- **`Roadmap.md`** — mode flag (`new`/`one-shot`/`feature`, written by `init`) + per-spec state.
- **Archive mechanism** — `archive/Archive.md` index + moved full specs on completion.

### Renamed
- Commands: `define → brainstorm`, `deliver → execute` (no aliases). `/akios:init` now also
  creates the folder tree and seeds `~/.claude/akios/preferences.md`.

## 0.4.1 (2026-06-19)

### Added
- **`/akios:init` is now idempotent + version-aware.** A new Step 0 reads the repo's recorded
  `.claude/.agentic-kit-version` and compares it to the installed plugin: same version
  short-circuits to a self-check ("already initialized — nothing to do"); an older version
  **migrates** (refreshes only the always-copy hooks + version file, leaves the user's
  `AGENTS.md`/`Context.md` untouched, re-verifies wiring) and reports the changelog diff; absent
  runs the full onboard. No more re-onboarding an already-set-up repo.
- **Anti-drift flow guards (keep the user in flow).** `ios-feature-pipeline` gains rule 6 ("stay
  in the current phase") and a *Staying in flow (anti-drift)* reflex: when a build/data instruction
  surfaces mid-design, name it → classify scope (this spec vs. its own) → route it through the
  pipeline / register a new spec → only write files in Phase 3. `/akios:define` carries a Phase-1
  guard pointing at it.
- **Multi-spec intake.** `idea-to-spec` gains an *Intake* triage: when one prompt is really several
  specs, split them, ask the user one/some/all, then design **sequentially** — one spec's questions
  at a time, each labeled and registered in `## Specs`, never merged. `/akios:define` points at it.

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
  two lines: `/plugin marketplace add Lucasdho/akios` → `/plugin install akios`.
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
