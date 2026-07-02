---
name: task-execution
description: Drive a tasks/todo/ backlog to implemented, committed, reviewed Swift/iOS code — the kit's execution phase (absorbs the execution discipline once borrowed from superpowers). Use after spec-to-tasks has produced task files, or when a user runs /akios:execute. Works on a per-spec branch, moves task files through folder states, writes tests first, commits at each checkpoint, manages the context window, archives finished specs, and stops at a hard human gate before any push or merge.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "2.2.0"
---

# Task Execution — tasks/todo/ → shipped, reviewed code

Runs the backlog `spec-to-tasks` produced. This is the kit's Phase 3 — it owns the execution loop
end to end with **no external skill dependency** (the TDD and verification discipline once borrowed
from `superpowers` is built in here). Subagents are a **tool, not the spine** — execution never
*depends* on them, because this environment can deny them `xcodebuild`.

**Input:** the task files in `tasks/todo/`. **Output:** the feature implemented and committed on a
branch — **not pushed, not merged.**

## Setup (once, before any task)
1. **Branch per spec.** Create `feature/<spec>`. Never work on `main`/`master`.
2. **Keep specs + tasks on the working branch.** Work in-place. If you use a worktree, commit
   `specs/` + `tasks/` onto the branch first — otherwise the executor can't edit them and the task
   states never update.
3. **Detect the build path.** Try a no-op `xcodebuild`/builder dispatch once. If subagents are
   denied it (common in background sessions), set a flag: run all builds/tests **in this session**.
   Never let a dead subagent stall execution — degrade to inline.

## Multi-instance: claim before you work (team mode)
When `Roadmap.md` has `collaboration: team`, several teammates' akios instances share this repo. Claim
a unit before touching it so two instances never build the same thing. **Solo mode skips all of this.**

- **Identity.** Each instance has a signature from `.claude/hooks/akios-instance.sh` (or the plugin's
  `scripts/akios-instance.sh`) — `user@host/id`, e.g. `lucas@mbp/3f2a9c`. It rides on commit trailers
  (`Akios-Instance:`) and claim records so a teammate's akios can recognize who did what.
- **Claim protocol (git is the lock, no server):**
  1. `git pull` (or fetch) first.
  2. Check the unit isn't already owned: a task's frontmatter `owner:`, or the owner annotation on its
     `Roadmap.md` spec line (for a spec/unit with no tasks yet). If owned by **another** signature →
     **yield**, pick the next unit. (Claims live in **committed** files, never in gitignored `.akios/`,
     so a `git pull` shows you what teammates hold.)
  3. Claim: set the task frontmatter `owner: <sig>` + `claimed_at` (or annotate the unit's `Roadmap.md`
     line `owner: <sig>` when no tasks exist yet), move `todo → in-progress`, commit
     `claim: <task> by <sig>`, **push immediately**.
  4. **Push rejected** = someone pushed first → pull, re-check ownership, yield if it was taken.
     The push race *is* the arbitration; don't add a lock server.
- **Stale claims.** A claim that's old with no commits behind it may be reclaimed — note the takeover
  in the commit so the original owner sees it.
- **Roadmap.md is shared.** It stays the single source of truth, but edit **only your unit's line** in
  the `## Specs` table — never reorder it. Status is **monotonic** (`designed < planned < in-progress
  < done`, plus the `needs-revision`/`blocked` demotion side-states — full order in `Roadmap.md`'s
  status-enum note); on a merge conflict, **higher status wins** (a finished spec is never demoted by
  a stale edit). This rule lets an unattended run resolve the merge without a human.

## The task lifecycle (state = folder)
Each task file lives in a folder that **is** its state. Process tasks checkpoint by checkpoint,
in order; within a checkpoint respect `[P]`/area (different-area `[P]` tasks may run in parallel
when subagents are available and cheap; otherwise sequentially in-session — same result).

```
for each task (by checkpoint, respecting [P]/area):
  move  tasks/todo/<T>.md → tasks/in-progress/
  consult the PRIORITY CHAIN (below) before choosing any pattern
  load the task's pack reference by scope, per its `pack:<domain>` tag (default `pack:ios` for a
    Swift repo — its realization is swift-dev's bundled domain sub-skill; a non-ios pack's
    realization is its own INDEX.md-selected reference)
  [Snippet gate] if the pack lookup resolves to a `kind: snippet` entry (not `kind: reference`)
    → copy-and-adapt-and-prune (below) instead of writing the pattern from scratch
  [Foundation gate] before writing any new helper/protocol/component → consult ONLY
    Foundation/ (never the whole repo); see "Foundation ledger" below
  [Hurdles gate] before starting a task in a domain that has one → load the matching-tag slice of
    code-references/hurdles.md (below) so a known hurdle is avoided by consulting the ledger
  [UI gate] if task is UI-scoped → run align-ui (auto-decide mode under just-vibes; grilling skipped, gate itself is not)
  TDD  → failing test → implement → green        (see TDD posture)
  move  → tasks/review/
  /verify (when runnable) + /code-review (loads `review-doctrine` — see "Code-review doctrine")
  [Divergence audit] compare planned (Description + DoD + Files) vs. done (actual diff/decisions)
  move  → tasks/done/        (only when the THREE PROOFS (below) are green; failure loops to in-progress)
↳ at each checkpoint barrier: audit EVERY task's DoD + the boundary lint, then commit "checkpoint: <name>"
```

- **UI alignment gate.** A task is UI-scoped when its title or scope mentions View, Screen,
  SwiftUI, layout, or UI. Before writing any implementation code, run the `align-ui` skill:
  it resolves every visual and interaction decision with the user and writes
  `tasks/ui-alignment/<ScreenName>.md`. Load that file as the highest-priority reference for
  the task — it overrides `swift-dev` and `code-references/` for visual decisions.
  Under just-vibes the **interactive grilling** is skipped — `align-ui` still runs, in auto-decide
  mode, and writes the alignment doc unattended (every auto-decision marked `[auto]`).

- **Make-it-live is one pass, not two.** The third A3 stage (after components and the
  `ui-variations`-graduated dumb screen already exist at `presentation/<View>/<View>View.swift`)
  attaches the real ViewModel via `init` **and** pulls real data just-in-time in the **same
  pass** — there is no separate translation/grounding step, because the graduated screen is
  already the target SwiftUI code. `align-ui`'s post-wiring check runs right after: does the
  real-data render still hold up against the mock-data-approved graduate (same-engine, same-code
  — not a cross-engine diff against a retired `visual-grounding` reference).

- **Runner routing + model tier.** Read the task's `runner`: `≤20k → orchestrator` (always run inline);
  `>20k → subagent-eligible` — **eligibility, not a mandate**: dispatch only when `AGENTS.md`'s
  subagent-economy rule also says yes (driving session **≥120k tokens** *and* the task is heavy and
  isolatable). Below that bar, run a `subagent`-tagged task inline too — the field sizes the task, it
  doesn't override the session-pressure judgment call. When you do dispatch, pick the **cheapest model
  that fits**: a
  simple, well-scoped task (mechanical edit, a focused search, one test file, a refactor with a clear
  precedent) → **haiku**; a task that implements real behavior end-to-end (judgment + TDD across files)
  → **sonnet**. Never dispatch a model more capable than the subtask needs. (The driving session itself
  runs on **opus or sonnet** — sonnet is the budget default; choose per budget.) If the subagent layer
  is unavailable, **degrade to inline** — never fail.
- **Cold-subagent discipline (only when you dispatch one).** A subagent starts cold. Its prompt MUST
  carry — and *only* — the slice it needs: the task + its DoD, the task's named **`swift-dev` domain
  sub-skill**, `ponytail` (if installed), and any `Context.md` gotcha matching the task type. Restate
  gates — it inherits nothing. **Never clone your context window into it:** a subagent is billed for
  every token you hand it, so pasting the whole conversation is the most expensive mistake here — send
  the slice, not the session.

## Snippet consumption — copy, adapt, prune (`kind: snippet`, `snippet-library.md`)
A pack lookup can resolve to a `kind: snippet` entry — literal, field-tested Swift code (a card
component, a repository template, a use case, a gateway protocol) — instead of a `kind:
reference` (prose). A snippet is **never** read as inspiration and rewritten from scratch; the
entire point of registering one is to skip re-deriving boilerplate that already exists:

1. **Copy** the snippet's file(s) into the target location (below decides where).
2. **Adapt** placeholder names (e.g. `EntityName` → the task's real entity) per the snippet's
   own `usage.md`.
3. **Prune** anything the task doesn't need (an unused CRUD method, an unused field) — this is a
   **required DoD step**, not optional cleanup. A copied snippet is never accepted as-is.

**Target resolution.** Read the snippet's declared `target:` (its `usage.md` or `INDEX.md` row):
- **`Foundation/Design-tokens`** — already shared by design. If it's already present there from
  an earlier task, don't recopy — just import and use it. If not yet present, copy it there
  directly.
- **`Features/<F>/data`** or **`.../domain`** — feature-local by design. Copy it **fresh** into
  the current feature's slice, with entity names adapted for that feature, even if the same
  snippet was already copied into a different feature earlier.

This target split is a **human decision made at snippet-registration time**
(`knowledge-ingest`'s confirm-before-live gate) — it does not bypass or shortcut the Foundation
ledger's own evidence-based promotion/demotion rules below, which still govern everything that
is **not** a registered snippet.

**No match, no problem.** If a task could plausibly use a snippet but none matches, write fresh
code as the pipeline does today — no error, no forced match; same graceful degradation as "no
user packs" (`knowledge-architecture.md` §7).

## Foundation ledger (ALVA — read, never count)
Before creating any new helper, protocol, or shared component, consult **only**
`Foundation/Design-tokens/` and `Foundation/Code-tokens/` — a small, bounded search — never the
whole repo (`swift-dev`'s `alva-architecture` guide, doctrine P6). If nothing there fits, the code
is born inside the current feature; it is not shared preemptively.

- **You read `Foundation/usage-ledger.json`; you never count.** The count is produced by a
  deterministic tool (`scripts/alva-usage-ledger.sh` or its consumer-repo git-hook installation) —
  investigating usage across features is not something you do by grepping the repo per-run.
- **Each ledger entry becomes a task, not a silent move.** Every `candidates_promote` /
  `candidates_demote` entry in the ledger gets written as a new `tasks/todo/T<NNN>-*.md` (promote:
  move the symbol to its `target` behind a contract if it's a Code-token; demote: return it to its
  sole remaining feature). Promotion is **suggested**, reviewed like any other task — never mutate
  `Foundation/` because the ledger said so without a task and a DoD.
- **Boundary lint runs at the checkpoint barrier.** A feature importing another feature's
  `domain/`/`data/` internals (instead of its `contract/`) fails the barrier audit — fix the import
  or extend the contract before the checkpoint commits. This is the lint realization of doctrine
  P3 (folder-first + lint by default; compiler-enforced local SPM modules only once the app has
  earned it — a recurring violation, or the user asks).

## Hurdles ledger (`code-references/hurdles.md` — tier 2 of the priority chain)
A solved recurring problem is curated project knowledge, so it lives in the project's **code
pack** at tier 2 — the same place `code-references/` already sits — not a loose file nobody
loads. `INDEX.md` carries a row for it with domain tags, same as any other reference.

- **Read, before a domain task.** Load the matching-tag slice of `hurdles.md` before starting a
  task in that domain (the `[Hurdles gate]` in the lifecycle above) — a known hurdle is avoided by
  consulting the ledger, exactly as a matching code reference is loaded today.
- **Entry format** (one per hurdle, deduplicated):
  ```markdown
  ### <short symptom>            [tags: swiftdata, concurrency]
  - **Hit when:** <the situation that triggers it>
  - **Root cause:** <why it happens>
  - **Fix:** <the resolution that worked>
  - **First seen:** <task/spec> · **Times hit:** <n>
  ```
- **How it grows (observe → confirm → append).** A hurdle is captured when (a) the divergence
  audit below taught something reusable, or (b) the **same failure is hit a 2nd time** — the same
  2nd-occurrence rule that governs `preferences.md`. Attended → **propose** the entry at a pause
  (delivery posture) or more eagerly with rationale (learning posture, see "Operating posture").
  `just-vibes` → auto-append with rationale + journal it. Dedup against existing entries; bump
  `Times hit` instead of duplicating.
- **Cross-session recall.** A recall-worthy, cross-session hurdle also gets a one-line pointer in
  native `MEMORY.md` — the full entry stays in `hurdles.md` only, no duplication.
- **Empty ledger:** absent/empty `hurdles.md` → tier 2 is simply silent for hurdles; behaves as
  today. First run of any repo starts here.

## The priority chain (consult before any code decision)
First tier with a relevant answer wins; lower tiers only fill silence:

```
1. Project decision (MEMORY.md + existing code / Context.md)
2. Knowledge packs, user-curated (code-references/ = the project's auto-built code pack — load
   the file whose INDEX tag matches the task domain; other ingested packs route the same way
   by pack:<domain>)
3. User preferences (~/.claude/akios/preferences.md)
4. Baseline packs, shipped floor (swift-dev = the ios pack)
```

Concrete shown code outranks a stated preference. A repo's established architecture is not
rewritten because of a general preference.

## Operating posture (learning vs. delivery)
Read `Roadmap.md`'s `posture` flag (default `delivery`; a session override — e.g.
`/akios:execute --learning` — wins for this session only and does not rewrite the Roadmap
value). It never changes what gets built, only what gets narrated:

- **Delivery (default):** proceed exactly as documented above — resolve the priority chain, apply
  the pattern, move on. No inline narration beyond what's already recorded on the task/spec.
- **Learning:** each time the priority chain resolves to a non-obvious tier (a project decision or
  a pack overriding the baseline) or a doctrine gets applied (ALVA boundary, dumb-component law,
  a snippet's `target:` split), add a one-line note: *what* was chosen, the *principle* behind it,
  and the tradeoff — citing the owning pack/spec (e.g. "dumb-component law — `alva-adoption` §2").
  At the **end of each unit** (checkpoint or spec), add a short **"what you learned"** digest: the
  3–5 principles this unit exercised. If nothing teachable happened (a routine mechanical task),
  say so plainly rather than manufacture a lesson.
- **Under `just-vibes`:** no one is present to narrate to — learning posture instead appends the
  same digest as a **"Lessons"** section to `.akios/just-vibes-journal.md` per unit (see
  `just-vibes`'s own posture note). Delivery journals outcomes only, as today.

Learning posture is also where a hurdle/preference capture gets **proposed more eagerly**, with
its rationale attached — see "Feedback logging" below. See `AGENTS.md` "Operating posture" /
`specs/operating-modes.md` §3–§4 for the full design.

## TDD posture (tests-first where meaningful)
- **Logic / data / concurrency** → write the failing test first (Swift Testing /
  `swift-dev:swift-testing-pro`), then implement to green, then refactor.
- **Pure SwiftUI views** → no useful unit test of layout exists; the bar is a working **Preview**
  + the **happy / empty / loading / error** states the task's DoD lists + a snapshot test **if** the
  project has the harness. Don't force brittle view tests.

## The divergence audit (`review → done`, the exact moment intent and reality are both in hand)
Before moving a task `review → done`, compare what it **planned** (`## Description` + `##
Definition of Done` + planned `## Files`) to what was **actually done** (the diff, files touched,
decisions taken).

- **Material divergence** = a different approach was taken, files outside the plan were touched,
  a DoD item was dropped/added, or an open decision got resolved. A rename or an obvious helper is
  cosmetic, not material — don't flag it.
- **On material divergence, classify — never auto-fail:**
  (a) **code is right, plan was stale** → note it on the task, proceed;
  (b) **code drifted from a correct plan** → loop back to `in-progress` and fix;
  (c) **genuinely open** → surface it (to the user if attended; as a journaled open risk under
  `just-vibes`, per its "flag, don't smooth" rule).
- If the *spec itself* is the source of the staleness (not just the task), flag it for spec
  revision rather than silently patching around it — specs are the memory.

## The three proofs (the `done` bar)
"Did it implement it right?" decomposes into three checkable proofs. A task/spec is *proven* only
when every proof that applies is green — **a red proof parks, never ships**, consistent with the
bounded fix loop and just-vibes' "park red, never deliver broken."

| Proof | What it checks | Mechanism | Applies to |
|---|---|---|---|
| Build/test proof | it compiles and tests pass | the auto-build/test hook `.claude/hooks/post-checkpoint-verify.sh` (installed by `/akios:init`) → runs Context.md's `Test:` command or auto-detects `xcodebuild`, writes `.akios/verify-result.json` for you to read; degrades to inline if the hook/tool is unavailable, and to the DoD audit (grep + YAML validation + install smoke-test) in a plugin/docs repo with no build tool | every code task |
| Spec-conformance proof | it did what the task said + followed the loaded doctrine | the divergence audit above + `/code-review` with `review-doctrine` loaded | every task |
| Visual proof | it looks like the approved design | `align-ui`'s post-wiring check: real data vs. the `ui-variations`-graduated screen | UI tasks only |

`/verify` + `/code-review` already realize most of this; naming the three proofs as a set makes
"did I ship it right" a checklist instead of a vague worry, and shows *which* axis is red when
something's off.

## Barrier = audit + commit
At each `↳ barrier`: verify **every** task's DoD is met (not "code exists" — DoD met), **and** run
the boundary lint (no slice importing another slice's internals instead of its `contract/`). Then
`git commit -m "checkpoint: <name>"`. A failing DoD or a boundary violation blocks the commit; fix
or split, don't paper over it. At a `[major]` checkpoint, run the unit + integration battery first —
call `.claude/hooks/post-checkpoint-verify.sh` (the build/test proof's hook) and read
`.akios/verify-result.json` for the outcome rather than parsing build output yourself; if it
reports `ran:false` (no build tool reachable), fall back to running the battery inline, or — in a
plugin/docs repo with no build tool at all — to the DoD audit. A red battery blocks the next checkpoint.

## Feedback logging (preferences)
While executing, watch for preference signals — an explicit statement ("prefiro X") or a repeated
correction (the 2nd time the user undoes the same kind of change). At a natural pause, **propose**
appending it to `~/.claude/akios/preferences.md` (dedup, append-only). Never write silently.
**Delivery** proposes at natural pauses per the 2nd-occurrence rule, as above. **Learning** posture
proposes more eagerly and explains *why the signal is worth remembering* — same dedup, append-only
discipline, just surfaced sooner and with the reasoning attached (`operating-modes.md` §5).

## Context management — MANDATORY compact between specs

**Hard rule: run `/compact` after every spec completes, before starting the next one.**
This is not advisory. A spec boundary is the only safe compression point — mid-spec compaction
drops live execution context (task state, DoD progress, checkpoint position) and forces costly
re-derivation.

```
spec N ships → archive → /compact ← MANDATORY → spec N+1 starts
```

Monitor the window and act before it forces you:
- **110k tokens:** warn the user, finish the current task cleanly before the next.
- **135k tokens:** urgent — complete the current checkpoint, then `/compact` immediately,
  even if mid-spec. A forced compaction mid-spec is the failure; reaching 135k without
  warning is the error to fix.

Never start a new spec without compacting first, regardless of token count.

## Archive on spec completion
When a spec's last checkpoint is green and all its tasks are `done`:
1. Append a **summary block** to `archive/Archive.md` — decisions, files touched, outcome.
2. Move the full spec to `archive/<spec>.md`.
3. Clear that spec's `tasks/done/` files (captured in the summary + git).
4. Record the **durable decisions** into native `MEMORY.md` (the spec-level what/where stays in
   `Archive.md`; recall-worthy decisions go to `MEMORY.md` — no duplication).
5. **Hurdles digest.** Any hurdle captured during this spec (see "Hurdles ledger" above) gets a
   one-line `MEMORY.md` pointer alongside the durable decisions — the full entry stays only in
   `code-references/hurdles.md`.

Future sessions read `archive/Archive.md` first and open a full archived file only on demand.

## Finish — the hard human gate
When the last checkpoint is green:
- Commits exist on `feature/<spec>`. **Nothing is pushed. Nothing is merged.**
- Run `/verify` and `/code-review`; report failures honestly with output — don't claim done on a red.
- **Then ask the user two things and wait:** (a) push this branch? (b) merge — and *where*
  (`dev` / `main` / other)? Never assume the target. Act only on their answer.

**Exception — running under `/akios:just-vibes`.** The human push/merge gate is **waived** there: the
just-vibes invocation *is* the authorization (see the `just-vibes` skill). The **quality gate is not
waived** — `/verify` + `/code-review` still run, with a bounded **fix loop** on red (diagnose + fix,
re-verify; stop after two consecutive cycles make no progress, then **park** the spec — keep the
branch + logs, mark it `blocked` in `Roadmap.md`, never deliver red). Delivery target follows
`Roadmap.md` `collaboration`: **solo** → merge `feature/<spec>` into the default branch + push it;
**team** → push `feature/<spec>` + open a PR (`gh`). Commits carry the `Akios-Instance:` trailer.

## Anti-patterns
- Starting a new spec without running `/compact` first — no exceptions.
- Implementing a UI task without running `align-ui` first — interactively, or in auto-decide mode
  under just-vibes; the gate itself never skips, only the grilling does.
- Pushing or merging without the explicit human gate — **except** under `/akios:just-vibes`, which is
  itself the authorization. Outside just-vibes, never.
- Delivering a red spec under just-vibes because the fix loop "gave up" — park it (branch + logs), never ship it.
- Working a task whose `owner:` is **another** instance's signature (team mode) — yield and pick another.
- Reordering or demoting the `Roadmap.md` `## Specs` table — edit only your line; status only moves up.
- Making execution depend on subagents (they can be denied `xcodebuild`) — always degrade to inline.
- Counting Foundation usage yourself (grepping the repo to judge "is this used elsewhere") instead
  of reading `Foundation/usage-ledger.json` — that's the exact per-run investigation cost the
  ledger exists to remove.
- Moving a symbol into `Foundation/` because the ledger flagged it, without writing a task first —
  promotion is suggested, not automatic.
- A slice importing another slice's `domain/`/`data/` instead of its `contract/` — boundary
  violation, blocks the checkpoint.
- Accepting a copied `kind: snippet` as-is without a prune pass, or re-deriving a registered
  snippet's pattern from scratch instead of copying and adapting it.
- Committing a checkpoint whose DoDs aren't actually met.
- Compressing context mid-spec.
- Treating every material divergence as an automatic failure, or ignoring one instead of
  classifying it — both defeat the point of the divergence audit.
- Moving `review → done` on a red proof (build/test, spec-conformance, or visual) — park it.
- Writing to `preferences.md` silently, or recording project-specific facts there (those go to `MEMORY.md`).
- Mirroring spec state outside `Roadmap.md` (e.g. duplicating the `## Specs` table into `CLAUDE.md`) — one source, no duplicates.
- Cloning your full context into a subagent, or dispatching a model more capable than the subtask needs.
- Working on `main`/`master`.
