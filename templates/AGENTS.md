# AGENTS.md — Agentic Operating Manual

Loaded every session via the project `CLAUDE.md`, which imports `@AGENTS.md` (Claude Code
auto-loads `CLAUDE.md`). akios targets the Claude agent. This is the single source of truth
for how to work here — the skill gates live below, not in a separate file.

## The loop (every code task)
1. **Orient** → `Context.md` — stack, commands, architecture, conventions
   (auto-loaded for you via the `@Context.md` import in `CLAUDE.md`).
2. **Recall** → your native auto-memory (`MEMORY.md`, loaded automatically) for
   decisions already made. Don't relitigate them.
3. **Route** → the gate table below — which skill fits this task type.
4. **Work** → the smallest change that is correct, honoring the priority chain.
5. **Record** → save durable decisions to auto-memory (Claude writes it itself;
   tell it "remember that …" for anything that should survive the session).

## Always on (Swift / iOS)
Two internal routers, no external plugin dependencies:
- **`swift-dev`** — Swift/iOS domain master router. Classifies the scope of a change
  and loads the right bundled guide before any code: `swiftui-pro` (views/layout) ·
  `swift-concurrency-pro` (async/await/actors/Sendable) · `swift-testing-pro` (Swift
  Testing) · `swiftdata-pro` (SwiftData) · `ios-accessibility` · `ios-debugger-agent`
  (run/debug) · `alva-architecture` (new feature / slice scaffolding, DI, coordinators) ·
  plus performance/refactor/figma guides on demand. Replaces the old axiom gate.
- **`task-execution`** — owns the execution loop (Phase 3): branch per spec, folder-state
  task lifecycle, checkpoint commits, TDD-first, human gate before push/merge. Absorbs the
  execution discipline the kit used to borrow from superpowers.

## Architecture (ALVA)
Every new feature is a **vertical slice**, not a shared app-wide layer. A feature lives
entirely under `Features/<Feature>/{domain,data,presentation,contract,tests,Feature-spec.md}`;
cross-feature composition happens only at the top (`Router/`, `Container/`), and shared leaf
code graduates into `Foundation/{Design-tokens,Code-tokens}` on evidence of reuse (a
deterministic usage ledger), never by upfront guess. This supersedes any shared
`DomainLayer/DataLayer/PresentationLayer` split — package-by-layer is not the folder law here.
Load `swift-dev`'s `alva-architecture` guide before scaffolding any new feature or slice; the
full portable doctrine (ALVA — Agent-Legible Vertical Architecture) is this kit's own
ground-truth reference, publishable standalone from the akios-specific realization.

**Optional (not required):** `ponytail` — efficiency overlay (no over-building, no rewriting
what works). The kit has no external dependency on it; install it for yourself if you like.

## The priority chain (whose answer wins)
For any code decision (pattern, naming, architecture), resolve **top-down — the first tier
with a relevant answer wins, lower tiers only fill silence**:

```
1. Project decision already made   (MEMORY.md + existing code / Context.md)
2. Sample code / Code References    (code-references/ — your uploaded patterns)
3. Global user preference           (~/.claude/akios/preferences.md)
4. swift-dev                        (best-practice baseline / floor)
```

A repo's established architecture isn't rewritten because of a general preference (project
on top). Concrete code you've shown outranks a stated preference (Code References above
preferences). `swift-dev` is the floor that always answers.

## How to execute (orchestration)
The feature spine's phases are defined in **`workflow.yml`** (the machine-readable contract —
commands and phase detection read it). `task-execution` owns the *execute* phase loop;
`spec-to-tasks` owns *plan*; `idea-to-spec` owns *brainstorm*. For a vague "build X" request,
**`ios-feature-pipeline`** is the entry point — it reads `workflow.yml` and walks you through
the phases.

Note: a spawned subagent starts cold — it does NOT inherit these gates. When you dispatch one
for gated work, restate the relevant gate (and the task's `swift-dev` domain) in its prompt.

## Sizing the work & subagent economy
Match the machinery — and the model — to the size of the job. Two questions before you start or dispatch:

**1. Quick task or real spec?**
- *Quick task* — one file, or a mechanical change across a few, low-risk, no new domain (a rename, a
  one-liner, mirroring an existing screen, a copy tweak). **Do it inline, now** — no spec, no pipeline
  (still on a branch/worktree per the isolation rule below; never edit a building working copy in place).
- *Real spec* — multi-file, new behavior, a new domain, or anything you'd want reviewed as a unit.
  Route it through the spine (brainstorm → plan → design → execute) and let `task-execution` own the loop.

Mis-sizing costs both ways: a full pipeline for a one-liner is overhead the user pays for nothing; a
quick patch for a real feature ships half-baked. When genuinely unsure, ask one sizing question rather
than guessing.

**2. Should you dispatch a subagent at all? Usually no.**
Work **inline by default** — a subagent is cold (re-fed context, fresh tooling) and billed on top of
your session, so it rarely pays for itself. Reach for one only when **both** hold:
- **Context pressure** — the driving session is at **≥120k tokens (~60% of a 200k window)**, i.e. inline
  work is starting to crowd the window (a distinct, earlier threshold from `task-execution`'s own
  **110k** context-warn line — that one triggers a mandatory `/compact` before the next spec; this one
  is the subagent-dispatch judgment call), **and**
- **The task is heavy and isolatable** — a large, self-contained chunk (a whole spec's tasks, a wide
  mechanical sweep) that genuinely benefits from running in its own window.

Below that bar, just do it inline — offloading a light task, or one while you have ample context, spends
money to save nothing. If subagents are unavailable, inline is the answer anyway.

**3. When you do dispatch: cheapest model that fits, and only the slice it needs.**
- *Orchestration tier.* The driving session runs on **opus or sonnet** — sonnet is the budget option
  and is a fine default; reach for opus when the planning/judgment genuinely warrants it. Pick per
  budget, not by reflex.
- *Subagent tier.* A **simple, well-scoped** subtask (mechanical edit, a focused search, one test file,
  a refactor with a clear precedent) → **haiku**. **Implementing a spec's tasks end-to-end** (judgment,
  multi-step, TDD across files) → **sonnet**. Never dispatch a *more capable* model than the subtask
  needs — that's spending the orchestrator's tier on work a cheaper one ships correctly.
- *Never clone your context into a subagent.* A subagent starts cold and is billed for **every token you
  hand it** — passing your whole window is the single most expensive mistake here. Send only the slice:
  the task + its DoD, the one `swift-dev` domain sub-skill, the matching `Context.md` gotcha, the
  precedent file path. If you're about to paste the conversation, stop — summarize the slice instead.

## Skill gates
The SessionStart hook re-states these every session, but it only reminds — it
does not enforce. They are a routing aid, **not a toll booth on every file**.

**Proportionality (read before routing).** A skill earns its overhead only when it
injects knowledge you don't already have or enforces discipline on risky work. Match the
ceremony to the task:

- **Just do it** (no gate) when the change is a *mechanical application of a pattern already
  established in this repo* and is low-risk — e.g. "make BoardView like SquadView", renames,
  obvious one-liners, moving code. Recognizing the existing pattern **is** the routing; loading
  a guide to copy a pattern you can already see adds latency, not correctness.
- **Load a guide** when there's genuine uncertainty it would resolve: a new domain, an
  unfamiliar or version-sensitive API, concurrency / SwiftData / accessibility nuance, a design
  with no in-repo precedent, or anything you'd hesitate to ship unreviewed.

When in doubt, the cost of skipping is a missed best-practice; the cost of over-gating is the
overhead the user is paying for nothing. Bias toward the smaller of the two. The gates below are
the *map of where knowledge lives* — consult it when you need the knowledge, not reflexively.

**Skipping the gate ≠ skipping isolation.** "Just do it" means do it directly, not do it
recklessly. Standalone work that bypasses the feature pipeline still lands on a branch (or a
worktree for anything that builds) — never edit the user's working copy in place mid-build. Read
the files first and diagnose before writing; delete dead code and duplicates so the diff gets
*smaller*, not bigger. Speed comes from reading first and reusing the existing pattern as a spec —
not from cutting the safety rails.

| Trigger | Skill | When |
|---|---|---|
| Building a new feature end-to-end | `ios-feature-pipeline` → brainstorm → plan → design → execute | before starting |
| Designing a system / turning an idea into a spec | `idea-to-spec` (`/akios:brainstorm`) → write specs to `specs/` | before building |
| Turning a spec into tasks | `spec-to-tasks` (`/akios:plan`) → `tasks/todo/` | after the spec |
| About to hand-write complex code, docs, types, or a format conversion | `oss-first` — is there a mature tool/lib first? | before generating |
| Implementing / running / debugging Swift | `swift-dev` (domain router) + `fewer-permission-prompts` | while coding |
| Creating / polishing SwiftUI Views | `swift-dev` → `swiftui-pro` (+ design-principles for polish) | before the view |
| Writing tests | `swift-dev` → `swift-testing-pro` | with the code |
| Bug, crash, flake, regression | `swift-dev` → `ios-debugger-agent` | before any fix |
| Executing the backlog | `task-execution` (`/akios:execute`) | to ship |
| Running unattended (drive the whole pipeline yourself) | `just-vibes` (`/akios:just-vibes` · `--force` to loop) | hands-off |
| Claiming "done" | `/verify` + `/code-review` | before finishing |

`swift-dev` uses progressive disclosure — the ~400-word router dispatches to one bundled
guide on demand, so only the relevant domain loads during long plan/execute sessions.

### Deepthink (user-triggered)
Proportionality runs the other way too: when the user flags a decision as high-stakes and wants
the full tradeoffs ("this one's really important", "deepthink this", "vai fundo nessa"), slow down
on **that one decision**: ground it with cited research if external facts would change the answer,
lay out each option's second-order consequences (what it forecloses, reversible vs one-way, who it
helps or hurts), recommend with a reason, and record the reasoning (in the spec if one exists —
not just the chosen option). Then return to normal pace. It's opt-in, so it adds no standing
overhead. Inside `idea-to-spec` the full protocol applies (see its "Deepthink mode").

## Where things live (artifact map)
One lookup for where every artifact is created and stored — so files land consistently and
the agent (or a newcomer) finds them fast. These are the kit's fixed conventions; your own
source dirs are described in `Context.md` `## Architecture`.

| Artifact | Location | Naming | Found / loaded via |
|---|---|---|---|
| Operating files | repo root | `CLAUDE.md`, `AGENTS.md`, `Context.md` | Claude Code auto-loads `CLAUDE.md`, which imports the other two |
| Phase contract | repo root (from plugin) | `workflow.yml` | commands + phase detection read it |
| Spec state | repo root | `Roadmap.md` | mode flag + `collaboration` flag + one line per spec |
| Product vision | repo root | `Vision.md` | north star + prioritized wishlist; top-tier `just-vibes` fuel |
| Specs | `specs/` | `<domain>.md`, one file per domain | `Roadmap.md` `## Specs` table |
| Tasks | `tasks/<state>/` | `T<NNN>-<slug>.md`; state = folder (`todo/ in-progress/ review/ done/`) | moved between folders = state change |
| Archived specs | `archive/` | `<spec>.md` + `Archive.md` (summary index) | read `Archive.md` first; open full file on demand |
| Code references | `code-references/` | user-uploaded `.swift` + `INDEX.md` (tags) | loaded on-demand by matching domain tag |
| User preferences | `~/.claude/akios/preferences.md` (not in repo) | — | priority chain tier 3 |
| Durable decisions | native auto-memory (not in repo) | `MEMORY.md` | written automatically; survives compaction |
| Path rules | `.claude/rules/` | `<topic>.md` (e.g. `swift.md`) | fires when a matching file is read |
| Hooks | `.claude/hooks/` | `<event>-<name>.sh` | wired in `.claude/settings.json` |
| Skill trace + run journal | `.akios/` | `trace.jsonl`, `just-vibes-journal.md` (append-only) | local runtime; **gitignored** — not shared |
| Instance claims | committed, not `.akios/` | task frontmatter `owner:` + the `Roadmap.md` spec line | teammates see them via `git pull` |
| App source | per `Context.md` `## Architecture` | project-specific | `Context.md` |

Adding a new artifact? Put it where the table says and name it the same way. If it's a spec,
add a row to the `Roadmap.md` `## Specs` table so the next session knows it exists.

## Specs & Roadmap (idea-to-spec)
- Store versioned specs in `specs/` — one file per domain.
- `Roadmap.md` is the orchestration doc: the **mode flag** (`new`/`one-shot`/`feature`, written
  by `/akios:init`) plus **one line per spec** (spec → domain → status
  `designed/planned/in-progress/done`). Phase detection is per-spec — different specs can be in
  different phases.
- **Single source of truth.** Spec state lives **only** in `Roadmap.md` — never mirror the `## Specs`
  table into `CLAUDE.md` or anywhere else. One file updates; nothing else can drift out of sync.
  `CLAUDE.md` imports the operating files; it does not track spec state.
- Before designing something new, read `Roadmap.md` first.

## Full feature workflow (the spine)
Defined in `workflow.yml`; entry point is **`ios-feature-pipeline`**. At a glance:

`brainstorm (idea-to-spec) → plan (spec-to-tasks) → design (ui-variations + align-ui) → execute (task-execution)`

Four phases: `brainstorm` (interactive design → `specs/<feature>.md`) → `plan` (one pass →
`tasks/todo/*.md` with `[P]` markers, est_tokens/runner, DoDs, UI states) → `design` (UI-scoped
tasks only: `ui-variations` explores + remixes + graduates a screen into
`presentation/<View>/`, `align-ui` resolves states/interactions/navigation + the Nielsen
heuristics checklist; non-UI tasks skip straight to `execute`) → `execute` (branch per spec,
folder-state lifecycle, TDD-first, commit at each checkpoint, `/verify` + `/code-review`,
human gate before push/merge). See `ios-feature-pipeline` for the conduct; `workflow.yml` for the
contract. No speckit, no `.specify/`, no constitution.

**Match the permission mode to the phase.** `brainstorm` + `plan` are design work — run them in
**plan mode** (read-only; review the spec/backlog before a single edit lands). `design` and
`execute` both write real files (graduated SwiftUI previews, then wired code) — switch to
**accept-edits / auto mode** for both so you're not approving every individual edit while the
agent works a known plan. `Shift+Tab` cycles modes mid-session. This is workflow economy, not just
safety: plan mode stops premature writes during design-of-the-spec; accept-edits stops
death-by-prompt once code (prototype or final) starts landing. (For the sandbox/security angle,
see `ios-agentic-kit`'s `references/sandbox.md`.)

### Autonomous run (just-vibes) — driving the spine yourself
`/akios:just-vibes` runs the whole spine **unattended**: it picks the next fuel (a submitted idea →
`tasks/todo/` → designed specs → `Vision.md`/`Roadmap.md`), builds it, gates on quality, and delivers.
**Default** does one unit then stops at the spec boundary; **`--force`** loops until fuel is exhausted
or you interrupt. It is the **explicit opt-out of the human push/merge gate** (invoking it *is* the
authorization) — but the **quality gate stays**: verify + code-review + a bounded fix loop, and a spec
that won't go green is **parked** (branch + logs), never delivered. Unattended brainstorm runs in a
**deepthink** posture (research + decision records) since no one's there to decide live. The loop,
fuel precedence, and reporting live in the `just-vibes` skill — don't re-document them here.

## Working alongside teammates (multi-instance)
When `Roadmap.md` says `collaboration: team`, several teammates each run akios against this repo.
Coordination is **git-based, safety-first, no central server** — the etiquette:

- **Recognize signatures.** Each instance has an identity (`.claude/hooks/akios-instance.sh` →
  `user@host/id`) carried on commit trailers (`Akios-Instance:`) and claims. Work tagged with a
  signature that isn't yours belongs to a teammate's akios — leave it alone.
- **Claim before you build.** `git pull`, check ownership, then claim the unit in a **committed** file
  (task frontmatter `owner:` or its `Roadmap.md` line) and push. **Push-rejection is the lock**: if your
  claim push is rejected, pull, re-check, and yield if a teammate took it. Full protocol in `task-execution`.
- **One branch per spec; never two instances on one branch.** Worktrees keep parallel builds isolated.
- **`Roadmap.md` is shared and single-source.** Edit only your unit's line; never reorder the table.
  Status is **monotonic** (`designed < planned < in-progress < done`, plus the `needs-revision`/
  `blocked` demotion side-states — see `Roadmap.md`'s status-enum note for the full order) — on a
  merge conflict, higher status wins, so an unattended run resolves it without a human.
- **Solo (`collaboration: solo`) skips all of this** — no claims, and delivery merges + pushes the
  default branch directly.

## Project-specific gates
{{e.g. "always /security-review when touching Keychain / auth / networking"}}

## House rules
- **Scope — Apple/Swift specialization.** akios is tuned for the Apple ecosystem (Swift,
  Objective-C, SwiftUI/UIKit, Xcode project files, `*.plist` / entitlements / `.xcconfig`, Swift
  Package Manager, Apple platform targets) — that's where the gates, skills, and best-practice
  baseline apply. You **may** still help with non-Apple code (web/JS, Android, a non-Swift
  backend, other tooling), but **warn once up front** that it's outside akios's specialization
  ("heads-up: this is outside akios's Apple/Swift focus — the Swift gates and best-practice floor
  don't cover it"), then proceed if the user wants. Warn, don't block.
- Shortest working diff. No speculative abstractions, no scaffolding "for later".
- One runnable check behind any non-trivial logic.
- Boring over clever. Deletion over addition.
- **Honor the priority chain** (above) before applying any default.
- **Native types over wrappers.** Use Swift's own `id` / `UUID` / `Hashable` / `Codable`
  before writing a wrapper type. A wrapper needs a one-line justification.
- **Protocol-first repositories / data access.** Define a `protocol` + default
  implementations; concrete types inherit. Smaller, reviewable PRs. A repository's done-bar
  is: protocol defined, defaults provided, `Hashable` + JSON↔object round-trip covered.
- {{PROJECT_RULE — e.g. "never touch /migrations without a backup plan"}}
