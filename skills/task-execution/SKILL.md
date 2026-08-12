---
name: task-execution
description: Drive a akios/tasks/todo/ backlog to implemented, verified, reviewed code — the kit's execution phase. Use after spec-to-tasks has produced task files, or when a user runs /akios:deliver. Stack-agnostic: it reads the project's own build/test commands from akios/Context.md. Moves task files through folder states, writes tests first, verifies at each checkpoint, manages the context window, and archives finished specs. Never writes to git — the finished work is left in the working tree for the user to review and commit.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "3.0.0"
---

# Task Execution — akios/tasks/todo/ → implemented, reviewed code

Runs the backlog `spec-to-tasks` produced. This is the kit's execution phase — it owns the loop
end to end with **no external skill dependency**. Subagents are a **tool, not the spine** —
execution never *depends* on them, because an environment can deny them the build tool.

**Language-agnostic.** Nothing here names a language, framework, or build system. Every build,
test, and lint invocation comes from `akios/Context.md` `## Commands`, which `/akios:setup`
recorded for this project. If a command isn't recorded there, ask once and record it — never
guess an invocation, and never hardcode one into a task.

**Input:** the task files in `akios/tasks/todo/`. **Output:** the feature implemented and verified,
as changed files in the working tree.

## akios never writes to git
**Never run a git command that changes anything.** No commits, no branches, no `git add`, no
pushes, no merges, no tags. Not at a checkpoint, not at the end of a task, not "so the work isn't
lost", and not because the user approved the *work* — approving a change is not approving a commit,
and those are different questions. This holds in every mode, `/akios:just-vibes` included: an
unattended run removes the *questions*, not the human's ownership of their history.

Every run — attended or not — ends the same way: changed files in the working tree, and a report
of what changed. The user reviews the diff and commits it however they like. If they directly tell
you to commit, that's an instruction and you follow it; you never propose it.

Reading git is fine and often useful (`git status`, `git diff`, `git log`) — the prohibition is on
writes.

## Setup (once, before any task)
1. **Work in place.** No branch, no worktree — `akios/specs/` and `akios/tasks/` must stay
   editable so task states actually update, and there is nothing to isolate when nothing is being
   committed. Before the first edit, check `git status` (when the repo is under version control):
   if the tree is already dirty, say so, so your changes and theirs don't get tangled.
2. **Resolve the build path.** Read `akios/Context.md` `## Commands` for this project's test/build
   invocation and confirm it runs once. If subagents are denied it (common in background sessions),
   set a flag: run all builds/tests **in this session**. Never let a dead subagent stall execution —
   degrade to inline. In a repo with no build tool at all (a docs/plugin repo), the DoD audit
   replaces the battery — see "The two proofs".

## The task lifecycle (state = folder)
Each task file lives in a folder that **is** its state. Process tasks checkpoint by checkpoint,
in order; within a checkpoint respect `[P]`/area (different-area `[P]` tasks may run in parallel
when subagents are available and cheap; otherwise sequentially in-session — same result).

```
for each task (by checkpoint, respecting [P]/area):
  move  akios/tasks/todo/<T>.md → akios/tasks/in-progress/
  consult the PRIORITY CHAIN (below) before choosing any pattern
  recall known hurdles for this domain from auto-memory (below) before repeating a solved mistake
  TDD  → failing test → implement → green        (see TDD)
  move  → akios/tasks/review/
  run the TWO PROOFS (below): build/test proof + /code-review (see "Code-review doctrine")
  [Divergence audit] compare planned (Description + DoD + Files) vs. done (actual diff/decisions)
  move  → akios/tasks/done/        (only when the TWO PROOFS (below) are green; failure loops to in-progress)
↳ at each checkpoint barrier: audit EVERY task's DoD
```

- **Runner routing + model tier.** Read the task's `runner`: `≤20k → orchestrator` (always run inline);
  `>20k → subagent-eligible` — **eligibility, not a mandate**: dispatch only when `AGENTS.md`'s
  subagent-economy rule also says yes (driving session **≥120k tokens** *and* the task is heavy and
  isolatable). Below that bar, run a `subagent`-tagged task inline too — the field sizes the task, it
  doesn't override the session-pressure judgment call. When you do dispatch, pick the **cheapest model
  that fits**: a simple, well-scoped task (mechanical edit, a focused search, one test file, a refactor
  with a clear precedent) → **haiku**; a task that implements real behavior end-to-end (judgment + TDD
  across files) → **sonnet**. Never dispatch a model more capable than the subtask needs. (The driving
  session itself runs on **opus or sonnet** — sonnet is the budget default; choose per budget.) If the
  subagent layer is unavailable, **degrade to inline** — never fail.
- **Cold-subagent discipline (only when you dispatch one).** A subagent starts cold. Its prompt MUST
  carry — and *only* — the slice it needs: the task + its DoD, any known hurdle for its domain,
  and any `akios/Context.md` gotcha matching the task type. Restate gates — it inherits nothing. **Never clone
  your context window into it:** a subagent is billed for every token you hand it, so pasting the whole
  conversation is the most expensive mistake here — send the slice, not the session.
- **Batch chaining (a subagent-eligible *batch*, not a single task).** The two bullets above cover
  one dispatch for one task. When a batch of ≥2 subagent-eligible tasks shares a domain and is meant
  to run in order, the default execution shape is: one subagent works the batch in sequence inside one
  session, compacting itself between tasks, instead of a fresh cold subagent per task or one subagent
  running the whole batch unbounded. At a **120k-token subagent lineage budget** (its own accumulated
  context, not the driving session's), it finishes its current task, writes a handoff, and terminates;
  the orchestrator spawns a fresh cold subagent to continue.

## Hurdles (recorded to auto-memory)
A solved recurring problem is durable project knowledge, so it goes where durable project knowledge
already lives: **native auto-memory** (`MEMORY.md`). There is no separate ledger file to load,
index, or keep in sync — auto-memory is loaded for you every session, which is exactly the property
a hurdle needs.

- **Entry shape** — one memory per hurdle: the symptom, when it's hit, the root cause, and the fix
  that worked. Name the file for the symptom so recall matches on it.
- **How it grows (observe → confirm → record).** A hurdle is captured when (a) the divergence audit
  below taught something reusable, or (b) the **same failure is hit a 2nd time** — the same
  2nd-occurrence rule that governs `preferences.md`. Attended → **propose** it at a pause.
  `just-vibes` → record it and journal the rationale. Check for an existing memory covering the
  same symptom and update it rather than writing a second one.
- **Nothing recorded yet** is the normal state of a fresh repo, and never an error.

## The priority chain (consult before any code decision)
First tier with a relevant answer wins; lower tiers only fill silence:

```
1. Project decision (MEMORY.md + existing code / akios/Context.md)
2. User preferences (~/.claude/akios/preferences.md)
3. Your own general knowledge of the language/framework in play — the floor, used only when the
   two tiers above are silent
```

The repo outranks a stated preference: an established architecture is not rewritten because of a
general taste, and a preference is not applied over a decision this project already made.

## TDD (tests-first where meaningful)
- **Logic / data / concurrency** → write the failing test first with the project's own test runner
  (`akios/Context.md` `## Commands`), then implement to green, then refactor.
- **Presentation code with no meaningful unit test** → don't force a brittle test. The bar is the
  code running plus the **happy / empty / loading / error** states the task's DoD lists, verified
  however this project verifies them (a preview, a story, a local run, a snapshot test **if** the
  project already has the harness).

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

## The two proofs (the `done` bar)
"Did it implement it right?" decomposes into two checkable proofs. A task/spec is *proven* only
when every proof that applies is green — **a red proof parks, never ships**, consistent with the
bounded fix loop and just-vibes' "park red, never deliver broken."

| Proof | What it checks | Mechanism | Applies to |
|---|---|---|---|
| Build/test proof | it builds and tests pass | run `akios/Context.md`'s recorded `Test:` (and `Build:`) command. In a repo with no build tool at all (docs/plugin), this degrades to the **DoD audit**: the file exists, its content matches the spec, config parses, and a grep finds no orphaned references | every code task |
| Spec-conformance proof | it did what the task said + followed the loaded doctrine | the divergence audit above + `/code-review` | every task |

## Barrier = audit
At each `↳ barrier`: verify **every** task's DoD is met (not "code exists" — DoD met), **and** run
whatever boundary/lint check `akios/Context.md` records for this project. A failing DoD or lint
blocks the barrier; fix or split, don't paper over it. Report the barrier as passed and move on —
a barrier is an audit, not a commit. At a `[major]` checkpoint, run the project's full test battery first
(`akios/Context.md` `## Commands`), or the DoD audit in a repo with no build tool. A red battery
blocks the next checkpoint.

## Feedback logging (preferences)
While executing, watch for preference signals — an explicit statement ("prefiro X") or a repeated
correction (the 2nd time the user undoes the same kind of change). At a natural pause, **propose**
appending it to `~/.claude/akios/preferences.md` (dedup, append-only). Never write silently.

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
1. Append a **summary block** to `akios/archive/Archive.md` — decisions, files touched, outcome.
2. Move the full spec to `akios/archive/<spec>.md`.
3. Clear that spec's `akios/tasks/done/` files (captured in the summary).
4. Record the **durable decisions** into native `MEMORY.md` (the spec-level what/where stays in
   `Archive.md`; recall-worthy decisions go to `MEMORY.md` — no duplication).
5. **Hurdles digest.** Any hurdle captured during this spec (see "Hurdles" above) is already in
   auto-memory — confirm it's recorded rather than writing it a second time.

Future sessions read `akios/archive/Archive.md` first and open a full archived file only on demand.

## Code-review doctrine (applied at the gate)
Before running `/code-review` — at a task's review step and again at `Finish` below — apply this
checklist against the diff, on top of whatever the built-in review finds:

- **Single responsibility drift** — does a file/function now do a second job? Does a new symbol sit
  in a folder that contradicts `akios/Context.md`'s stated architecture?
- **Duplication with evidence** — the same logic in a third place is a real signal; the same shape
  twice usually isn't. Don't abstract on a coincidence.
- **Boundary conformance** — does a module reach into another module's internals instead of its
  published surface, as `akios/Context.md` defines those boundaries for this project?
- **Spec conformance** — does the diff implement the task's DoD, no more (scope creep) and no less?
- **Data integrity where it applies** — for anything touching persistence or shared mutable state:
  are partial writes, concurrent access, and failure paths handled?

Findings are **graduated**: block on correctness + boundary violations, warn on style/structure. A
**repeated** finding is a 2nd-occurrence signal — record it as a hurdle (above).

## Finish — hand back
When the last checkpoint is green:
- Run **both proofs** one last time over the whole spec: the build/test proof (`akios/Context.md`'s
  recorded `Test:` / `Build:` command, or the DoD audit where there's no runner) and `/code-review`
  with the doctrine above applied. Report failures honestly with output — don't claim done on a red.
- **Stop.** The work sits in the working tree. Report what landed, which tasks are done, and what
  the proofs said. **Do not commit, push, merge, or offer to** — the user reviews the diff and
  takes it from there. If they explicitly ask you to commit, that's a direct instruction and you
  follow it; you never propose it as the next step.

**Under `/akios:just-vibes`,** the same thing happens without the report-and-wait: the quality gate
runs, a green unit's spec is marked `done` in `akios/Roadmap.md`, and a red one gets a bounded fix
loop (diagnose + fix, re-verify; stop after two consecutive cycles make no progress) and is then
**parked** — left in place with its logs and marked `blocked`, never marked done. The run still
commits nothing.

## Anti-patterns
- Starting a new spec without running `/compact` first — no exceptions.
- Hardcoding a build/test invocation instead of reading `akios/Context.md` `## Commands` — the kit is stack-agnostic; the project's commands are the contract.
- **Writing to git.** Committing a checkpoint, branching, committing "so the work isn't lost", or offering to — in any mode, just-vibes included.
- Treating a user's approval of the *work* as approval to *commit* it. They are different questions, and only one of them was asked.
- Marking a red spec `done` under just-vibes because the fix loop "gave up" — park it, never sign off on it.
- Reordering or demoting the `akios/Roadmap.md` `## Specs` table — edit only your line; status only moves up.
- Making execution depend on subagents (they can be denied the build tool) — always degrade to inline.
- Passing a checkpoint barrier whose DoDs aren't actually met.
- Compressing context mid-spec.
- Treating every material divergence as an automatic failure, or ignoring one instead of classifying it — both defeat the point of the divergence audit.
- Moving `review → done` on a red proof (build/test or spec-conformance) — park it.
- Writing to `preferences.md` silently, or recording project-specific facts there (those go to `MEMORY.md`).
- Mirroring spec state outside `akios/Roadmap.md` (e.g. duplicating the `## Specs` table into `CLAUDE.md`) — one source, no duplicates.
- Cloning your full context into a subagent, or dispatching a model more capable than the subtask needs.
