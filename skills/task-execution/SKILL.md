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
  < done`); on a merge conflict, **higher status wins** (a finished spec is never demoted by a stale
  edit). This rule lets an unattended run resolve the merge without a human.

## The task lifecycle (state = folder)
Each task file lives in a folder that **is** its state. Process tasks checkpoint by checkpoint,
in order; within a checkpoint respect `[P]`/area (different-area `[P]` tasks may run in parallel
when subagents are available and cheap; otherwise sequentially in-session — same result).

```
for each task (by checkpoint, respecting [P]/area):
  move  tasks/todo/<T>.md → tasks/in-progress/
  consult the PRIORITY CHAIN (below) before choosing any pattern
  load the task's swift-dev domain sub-skill by scope
  TDD  → failing test → implement → green        (see TDD posture)
  move  → tasks/review/
  /verify (when runnable) + /code-review
  move  → tasks/done/        (only when the DoD is actually met; failure loops to in-progress)
↳ at each checkpoint barrier: audit EVERY task's DoD, then commit "checkpoint: <name>"
```

- **Runner routing + model tier.** Read the task's `runner`: `≤20k → orchestrator` (run inline in this
  session); `>20k → subagent` (dispatch). When you dispatch, pick the **cheapest model that fits**: a
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

## The priority chain (consult before any code decision)
First tier with a relevant answer wins; lower tiers only fill silence:

```
1. Project decision (MEMORY.md + existing code / Context.md)
2. Code References (code-references/ — load the file whose INDEX tag matches the task domain)
3. User preferences (~/.claude/akios/preferences.md)
4. swift-dev (baseline)
```

Concrete shown code outranks a stated preference. A repo's established architecture is not
rewritten because of a general preference.

## TDD posture (tests-first where meaningful)
- **Logic / data / concurrency** → write the failing test first (Swift Testing /
  `swift-dev:swift-testing-pro`), then implement to green, then refactor.
- **Pure SwiftUI views** → no useful unit test of layout exists; the bar is a working **Preview**
  + the **happy / empty / loading / error** states the task's DoD lists + a snapshot test **if** the
  project has the harness. Don't force brittle view tests.

## Barrier = audit + commit
At each `↳ barrier`: verify **every** task's DoD is met (not "code exists" — DoD met). Then
`git commit -m "checkpoint: <name>"`. A failing DoD blocks the commit; fix or split, don't paper over
it. At a `[major]` checkpoint, run the unit + integration battery first — a red battery blocks the
next checkpoint.

## Feedback logging (preferences)
While executing, watch for preference signals — an explicit statement ("prefiro X") or a repeated
correction (the 2nd time the user undoes the same kind of change). At a natural pause, **propose**
appending it to `~/.claude/akios/preferences.md` (dedup, append-only). Never write silently.

## Context management
Monitor the window: **warn at 120k**, **urgent `/compact` at 180k**. Compress **only between specs**
— after one spec fully ships and before the next begins. Never compress mid-spec; that drops live
execution context and you re-derive it at cost.

## Archive on spec completion
When a spec's last checkpoint is green and all its tasks are `done`:
1. Append a **summary block** to `archive/Archive.md` — decisions, files touched, outcome.
2. Move the full spec to `archive/<spec>.md`.
3. Clear that spec's `tasks/done/` files (captured in the summary + git).
4. Record the **durable decisions** into native `MEMORY.md` (the spec-level what/where stays in
   `Archive.md`; recall-worthy decisions go to `MEMORY.md` — no duplication).

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
- Pushing or merging without the explicit human gate — **except** under `/akios:just-vibes`, which is
  itself the authorization. Outside just-vibes, never.
- Delivering a red spec under just-vibes because the fix loop "gave up" — park it (branch + logs), never ship it.
- Working a task whose `owner:` is **another** instance's signature (team mode) — yield and pick another.
- Reordering or demoting the `Roadmap.md` `## Specs` table — edit only your line; status only moves up.
- Making execution depend on subagents (they can be denied `xcodebuild`) — always degrade to inline.
- Committing a checkpoint whose DoDs aren't actually met.
- Compressing context mid-spec.
- Writing to `preferences.md` silently, or recording project-specific facts there (those go to `MEMORY.md`).
- Mirroring spec state outside `Roadmap.md` (e.g. duplicating the `## Specs` table into `CLAUDE.md`) — one source, no duplicates.
- Cloning your full context into a subagent, or dispatching a model more capable than the subtask needs.
- Working on `main`/`master`.
