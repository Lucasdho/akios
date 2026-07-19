# Changelog

## 0.9.1 (2026-07-19)

### Added — data-modeling-canvas: complex/nested types + optional fields
- **`reference` attribute type.** An attribute can now be typed as another entity (e.g.
  `Clube.financas: Financas`) instead of only the flat primitives. Setting `refEntityId` draws
  and keeps in sync a composition line from the attribute to the target entity on the canvas —
  no manual `addRelation` call needed. Renaming/removing the attribute, changing its type away
  from `reference`, or deleting the target entity all clean the line up automatically; deleting
  a referenced entity falls any attribute pointing at it back to `string` rather than leaving a
  dangling reference.
- **`isOptional` flag** on any attribute (e.g. `Jogador.clube` — a player may not belong to a
  club). Renders as a dashed composition line for `reference` attributes, a toggle otherwise.
- Both fields are exposed through `window.agentTools` (`addEntity`/`addAttribute`/
  `updateAttribute`) and documented with a worked example in
  `skills/data-modeling-canvas/references/agent-tools-api.md`.

### Fixed — data-modeling-canvas
- **Entity-level relations silently failed to render.** `addRelation()` and spec re-import
  defaulted whole-entity connections to a `sourceHandle`/`targetHandle` (`'entity-source'`/
  `'entity-target'`) that didn't match any Handle actually rendered on the node (the real ones
  are suffixed `-top`/`-bottom`) — React Flow drops an edge whose handle doesn't resolve, with
  only a console warning and no visible error, so the line just never appeared. Both defaults
  now point at real handles.
- **Entity cards blew out from ~280px to 500px+ wide** whenever an attribute used the new
  `reference` type. Root cause: `.attribute-row`'s flex direction (row) let the new reference
  picker sit *beside* the name/type row instead of stacking under it; a native `<select>`'s
  intrinsic width in Chromium is also driven by its widest `<option>` (not just the selected
  value), inflating things further. Fixed in `EntityNode.css`.
- `SKILL.md`'s verification step now calls out that `getSpec()` proves the data model is right
  but not that a relation actually rendered — check the DOM (or a screenshot) too.
- **Row columns jumped left/right depending on whether an attribute was the primary key.** The
  key icon was only rendered for `isPrimary` attributes, so the name/type/`?`/reference columns
  didn't line up between rows within the same card. It's now rendered into a fixed-width slot on
  every row (empty when not primary) so all rows align.

## 0.9.0 (2026-07-13)

### Added — data-modeling-canvas skill + artifacts/ (new kit concept)
- **`artifacts/` — a new top-level directory** for the one exception to "skills are
  markdown+docs only": full npm/web apps that a skill drives live in the browser. The first
  occupant, `artifacts/data-modeling-canvas/` (React/Vite/Zustand/`@xyflow/react`), ships its own
  `package.json`/build tooling. `scripts/install-artifacts.sh` (new, mirrors
  `install-skills.sh`) installs it once to `~/.akios/artifacts/data-modeling-canvas/` — a single
  user-level location shared across every project on the machine, not tied to one project
  folder. Source is refreshed on every install run; `node_modules/` is preserved across runs and
  only `npm install`ed the first time. `akios/Context.md` documents the scope of this exception.
- **`data-modeling-canvas` skill.** Drives that app live in the browser via `claude-in-chrome`
  MCP tools (starting the dev server itself if it isn't already running, then calling the app's
  `window.agentTools` API) instead of asking the user to paste snippets into DevTools. API
  surface documented in `skills/data-modeling-canvas/references/agent-tools-api.md`.
- **`/akios:data-modeling-canvas` command wrapper** added; skill registered in
  `install-skills.sh`; artifact registered in `install-artifacts.sh`.

## 0.8.3 (2026-07-12)

### Changed — handmade audit: ALVA made opt-in across the kit
- **ALVA is now opt-in, not the kit's universal default.** The Agent-Legible Vertical
  Architecture doctrine is gated on an `architecture: alva` signal in `akios/Context.md` rather
  than being imposed on every repo. Skill docs (`deep-brainstorm`, `idea-to-spec`, `spec-to-tasks`,
  `task-execution`, `ui-variations`, `swift-dev`, `knowledge-ingest`, `ios-agentic-kit`) now
  reference ALVA through per-skill `references/alva-integration.md` files instead of restating the
  doctrine, keeping `alva-architecture-doctrine.md` the single source of truth.
- **UI-alignment gate docs.** `align-ui` and the pipeline docs clarify the pre-implementation
  UI-alignment contract and how it is invoked from the UI; pack metadata updated to match.
- **Doc consolidation.** Unattended-mode docs folded into the `just-vibes` skill; `idea-to-spec`
  refined (v1.5.0) and `spec-to-tasks` updated; phase-contract wording clarified in the iOS
  skill docs; the ALVA usage-ledger wording clarified.

### Added — Codex plugin manifest
- **Codex-ready plugin support.** Added `.codex-plugin/plugin.json` so Codex can install Akios
  and load the shared `skills/` family while Claude Code remains the full command/setup host.
- **Smoke-test coverage for Codex.** `scripts/test-kit.sh` now validates the Codex manifest,
  `skills` path, semver, and version sync with `VERSION`.
- **Docs for partial parity.** README and architecture docs now distinguish full Claude Code
  support from the first Codex layer; `/akios:*` commands and setup/hooks stay Claude-first
  until the `.codex/` migration is designed.

## 0.8.2 (2026-07-03)

### Added — subagent context chaining
- **`subagent-context-chaining.md` (B38/G14)** — one subagent now chains through a sequential
  task batch, compacting itself between tasks instead of being killed and re-spawned per task;
  at a **120k-token subagent lineage budget** it writes a handoff and terminates, and the
  orchestrator spawns a fresh cold subagent to continue from that handoff. Answers the
  `feedback_subagent_dispatch` memory's ~300k-token subagent incident with a repeatable
  threshold instead of an ad hoc judgment call.
- **`skills/task-execution/SKILL.md`** — "Runner routing + model tier" gains a "Batch chaining"
  bullet pointing subagent-eligible batches at the new protocol.
- **`templates/AGENTS.md`** — "Sizing the work & subagent economy" gains a three-row table
  disambiguating the kit's three similarly-valued thresholds (the 110k/135k inter-spec compact
  line, the orchestrator-side 120k dispatch-judgment line, and the new subagent-side 120k
  lineage budget) — this exact area had a documented history of the first two being confused
  (B36's self-audit).
- **`skills/handoff/SKILL.md`** — registers the `subagent-<spec-slug>-<link-number>.md` naming
  convention for chain-internal handoffs, mandatory (not situational) at the budget line.

## 0.8.1 (2026-07-03)

### Added — `akios/` folder consolidation
- **`akios-footprint-consolidation.md` (G13)** implemented — reopens B35, supersedes
  `init-reliability-and-ux.md` §5. A fresh `/akios:setup` now produces 9 top-level root entries
  instead of 15: `CLAUDE.md`, `AGENTS.md`, `.claude/` (external-tool contracts, unchanged), the
  ALVA scaffold (unchanged, it's the user's own app source), one `akios/` folder holding every
  bit of akios's own generated housekeeping (`Context.md`, `Roadmap.md`, `Vision.md`,
  `workflow.yml`, `specs/`, `tasks/`, `archive/`, `code-references/`), and whatever the user's
  project already had.
- **Runtime journal renamed and re-homed**: gitignored `.akios/` is now `akios/.local/` — nested
  inside the visible, committed folder instead of a same-named, dot-prefixed sibling.
- **`commands/setup.md`** gains a rewritten materialize table + folder-tree diagram, an opt-in
  migrate-path sequence for already-onboarded repos (detect, ask, move with verify-after-action,
  repoint `CLAUDE.md`'s import last), and a name-collision check for a pre-existing unrelated
  `akios/` folder.
- **Every kit-internal path reference updated**: `workflow.yml`, all templates/commands/skills,
  install/register/test scripts, both hooks, and the root docs.
- **This repo's own root self-migrated** into `akios/` via `git mv` (history preserved),
  dogfooding the same convention it ships.
- **Deliberately excluded**: `tasks/done/**` and archived `specs/*.md` prose — historical, left
  as-is, same treatment as this changelog's own past entries.

## 0.8.0 (2026-07-02)

### Added — Architecture
- **ALVA (Agent-Legible Vertical Architecture)** adopted as the kit's default architectural
  doctrine (`alva-architecture-doctrine.md`, `alva-adoption.md`). Vertical slices
  (`Features/<F>/{domain,data,presentation,contract,tests}`), a graduated
  `Foundation/{Design-tokens,Code-tokens}` promoted by an evidence ledger
  (`usage-ledger.json`), `Router/`/`Container/` composition root. Imported into `AGENTS.md`,
  `swift-dev`'s `alva-architecture` guide, `spec-to-tasks`, `task-execution`, `idea-to-spec`,
  `align-ui`, `deep-brainstorm`, and `/akios:init`'s scaffold. Resolves the ALVA-vs-layer-first
  architectural fork in ALVA's favor; `ui-first-architecture.md`'s folder shape is superseded
  (its behavioral laws survive, re-homed into `presentation/<View>/`).

### Added — UI overhaul
- **`design` phase** added to the pipeline (`brainstorm → plan → design → execute`), between
  `plan` and `execute`.
- **`ui-variations` skill** — the design phase's explore/remix/graduate/scratch-archive loop
  for multi-variant SwiftUI `#Preview` generation (`prototype-first-workflow.md`).
- **`swiftui-design-system` guide** + retrofit of `swiftui-design-principles`/
  `swiftui-ui-patterns` — unified `DesignSystem` token struct, native-over-custom budget,
  Nielsen heuristics, text/image role modifiers, `containerRelativeFrame` adaptivity
  (`swiftui-design-doctrine.md`).
- Reshaped `align-ui`, `spec-to-tasks`, `task-execution` for design-phase consumption; new
  `commands/design.md`.

### Added — Knowledge architecture
- **Knowledge packs** (`knowledge-architecture.md`): meta-prompt/knowledge split;
  `pack.yml`/`INDEX.md` format; `swift-dev` re-manifested as the `ios` baseline pack;
  `code-references/` reframed as the project's code pack; priority-chain tiers 2/4 widened from
  "swift-dev" to "packs" generally.
- **`knowledge-ingest` skill + `/akios:learn`** — ingest code/PDF/image/book/doc sources into a
  pack.
- **`kind: snippet`** (`snippet-library.md`) — copy-and-adapt Swift code bundles in a
  user-global pack (`ios-factory`), consumed via a copy-adapt-prune step in `task-execution`.
- **Skeleton library** (`skeleton-library.md`) — architecture-keyed whole-project starters for
  `/akios:init`'s greenfield path; folds into the existing Architecture interview question.
- **`skill-author` skill + `/akios:new-skill`** (`skill-authoring.md`) — scaffolds a behavior
  skill or knowledge-pack skeleton and self-registers (`scripts/register-skill.sh`),
  eliminating the install-skills.sh gotcha.

### Added — Operating discipline
- **`posture: learning | delivery`** — 3rd Roadmap flag (`operating-modes.md`); learning mode
  narrates the *why* behind each significant decision inline and gives an end-of-unit digest;
  delivery mode stays quiet. Threaded through `idea-to-spec`, `spec-to-tasks`, `task-execution`,
  `align-ui`; `just-vibes` gains a written "Lessons" journal section under learning.
- **Divergence audit + three proofs + hurdles ledger** (`verification-and-learning-loop.md`):
  `task-execution`'s `review → done` seam now compares planned vs. actual and classifies
  material divergence; the three proofs (build/test, spec-conformance, visual) are the `done`
  bar; `code-references/hurdles.md` (tier 2) captures recurring failures. New
  `scripts/hook/post-checkpoint-verify.sh` — the post-execute auto build/test hook (realizes
  Vision wishlist #3), degrades gracefully when no build tool is present.
- **`review-doctrine` guide** (`code-review-doctrine.md`) — SOLID applied honestly, DRY
  deferred to the usage ledger (never eager), ACID scoped to persistence, a 7-check ALVA/UI
  conformance table. Loaded by `task-execution`'s review step and `just-vibes`' GATE; optional
  `/akios:review` wrapper.
- **`autonomy: manual | auto`** — 4th Roadmap flag (`collaboration-autonomy.md`), splitting
  "who else works on this repo" (`collaboration`) from "is unattended push/merge authorized"
  (`autonomy`, default `manual`). `just-vibes`' DELIVER step and `task-execution`'s hard human
  gate both read it; a new "Built (undelivered)" report bucket distinguishes policy-withheld
  work from parked/red work.
- **`/akios:init` reliability** (`init-reliability-and-ux.md`): per-step and per-item narration
  during long steps; every materialization action is verified rather than trusted from a clean
  tool-call return; `chmod +x` always issued per-file (never batched); bounded retry-then-stop-
  with-manifest on a confirmed miss; the consumer-repo `alva-usage-ledger.sh` copy relocates to
  `.claude/scripts/`.

### Fixed
- **Contract-consistency reconciliation** (backlog B36): fixed the ~17 drift points a
  self-review found against `workflow.yml`/`AGENTS.md` — 3 outright contradictions (align-ui
  skip-vs-run under just-vibes, `runner: subagent` routing vs. the subagent-economy rule, the
  110k/120k context-warn mismatch), enum/number drift (`objectVersion`, the R-W-W rubric, skill
  counts, the `needs-revision`/`blocked` status states), and dangling references
  (`specs/pipeline.md`, `founderlens-sim`, `/ios-feature-pipeline`).

### Not included
- **`parallel-execution-scheduling.md`** (backlog B37) ships `designed`, not built — it's
  self-referential (the tool this backlog itself would use to compute build order) and
  non-blocking; rolls to a future release whenever a multi-spec batch would benefit from it.

## 0.7.4 (2026-06-24)

### Housekeeping
- No skill or workflow-behavior changes. Repo cleanup only:
  - Removed `specs/pipeline.md`, `specs/plugin-architecture.md`, `specs/preferences-and-priority.md`
    — content already shipped into `workflow.yml`/`AGENTS.md` in the v0.7.0 refactor (Roadmap still
    tracks them as `done`); left `workflow.yml` with a stale reference to the deleted
    `specs/pipeline.md`, fixed in 0.8.0's contract-consistency pass.
  - Removed a stray committed `.akios/just-vibes-journal.md` — that path is runtime-local and
    gitignored; it should never have been committed.
  - Removed the legacy root `tasks.md` and its already-completed `tasks/todo/*.md` entries.

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

### Changed — lean 3-phase spine
- **New spine:** `idea-to-spec → spec-to-tasks → task-execution → verify + /code-review`.
  The old multi-phase planning ceremony + constitution bootstrap are gone —
  they re-did rigor the kit already has (design happens decision-by-decision in `idea-to-spec`;
  quality is gated by `AGENTS.md` house rules + axiom + ponytail + `/code-review`). A real run
  showed that path producing ~9 files for a `tasks.md` that one pass now produces as 1.
- **`/akios:plan`** now runs `spec-to-tasks` (one pass, one confirm); **`/akios:deliver`** now
  runs `task-execution`. No scaffold directory, no web/backend folder trees.

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
- Repos with an existing scaffold directory keep working — those files just go unused; `/akios:plan`
  no longer invokes the old planning framework. Re-run `/akios:init` (or `install.sh`) to pick up
  the new hook + house rules and gitignore `.akios/`.

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
  - `/akios:plan` — pipeline Phases 2-5 (multi-phase clarify→specify→plan→tasks; degraded path
    if no scaffold directory).
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
