---
name: task-execution
description: Drive a tasks.md backlog to implemented, committed, reviewed Swift/iOS code — replaces superpowers:subagent-driven-development as the kit's execution phase. Use after spec-to-tasks has produced tasks.md, or when a user runs /akios:deliver. Works on a per-spec branch, commits at each checkpoint, runs the test battery at major checkpoints, compresses context only between specs, and stops at a hard human gate before any push or merge.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "1.0.0"
---

# Task Execution — tasks.md → shipped, reviewed code

Runs the backlog `spec-to-tasks` produced. Replaces `superpowers:subagent-driven-development`
as the kit's Phase 3. Subagents are a **tool here, not the spine** — execution never *depends*
on them, because this environment can deny them `xcodebuild` (it happened in the domain-model
run; the build subagent couldn't function and the work had to drop back in-session).

**Input:** `tasks.md`. **Output:** the feature implemented and committed on a branch — **not
pushed, not merged.**

## Setup (once, before any task)
1. **Branch per spec.** Create `feature/<feature>` (from `tasks.md` frontmatter). Never work on
   `main`/`master`.
2. **Keep specs + tasks on the working branch.** Work in-place on that branch. *If* you use a
   git worktree, commit `specs/` + `tasks.md` onto the branch first — otherwise the executor
   can't edit specs and the `tasks.md` checkboxes never update (both happened in the real run).
3. **Detect the build path.** Try a no-op `xcodebuild`/builder dispatch once. If subagents are
   denied it (common in background sessions), set a flag: run all builds/tests **in this
   session** or via the `apple-platform-build-tools:builder` agent. Never let a dead subagent
   stall execution.

## The execution loop (per checkpoint, in order)
1. **Run the checkpoint's tasks** respecting dependencies. Run `[P]`-tagged tasks in parallel
   **only** when subagents are available and cheap; otherwise run them sequentially in-session —
   same result, no dependency on the subagent layer.
2. **Cold-subagent discipline (only when you dispatch one).** A subagent starts cold. Its prompt
   MUST carry: the task + its DoD, the task's named **axiom domain skill**, `ponytail` (if
   installed), and any `Context.md` gotcha matching the task type. Restate gates — the subagent
   doesn't inherit them.
3. **TDD per task.** Follow `superpowers:test-driven-development` for any non-trivial logic —
   red → green → refactor. The task's DoD is the acceptance bar; UI tasks must satisfy their
   happy / empty / loading / error states.
4. **Barrier = audit + commit.** At the `↳ barrier` line: verify **every** task's DoD is met
   (not "code exists" — DoD met). Then `git commit -m "checkpoint: <name>"`. A failing DoD blocks
   the commit; fix or split, don't paper over it.
5. **Major checkpoint = test battery.** At a `[major]` checkpoint, run the unit + integration
   battery before advancing. Red battery blocks the next checkpoint. Record the pass/fail count
   into `.akios/trace.jsonl` (see Telemetry) — this is the honest before/after test signal.

## Context management
Monitor the window. Compress **only between specs** — after one spec fully ships and before the
next begins. Never compress mid-spec; that drops live execution context (which file does what,
what the last barrier proved) and you re-derive it at cost.

## Finish — the hard human gate
When the last checkpoint is green:
- Commits exist on `feature/<feature>`. **Nothing is pushed. Nothing is merged.**
- Run `superpowers:verification-before-completion` and `/code-review`; report failures honestly
  with output — don't claim done on a red.
- **Then ask the user two things and wait:** (a) push this branch? (b) merge — and *where*
  (`dev` / `main` / other)? Never assume the target. Act only on their answer.

## Telemetry hand-off (optional track)
If the repo has the `skill-trace` PostToolUse hook wired (see `/akios:init`), it already logs
skill loads + skill-reference reads + a `git diff --shortstat` snapshot to `.akios/trace.jsonl`.
This skill's only added duty: at each `[major]` battery, append the test pass/fail count keyed to
the checkpoint, so the trace carries a real before/after impact delta — **without ever running
tests just to measure** (the battery was going to run anyway).

## Anti-patterns
- Pushing or merging without the explicit human gate. Never.
- Making execution depend on subagents (they can be denied `xcodebuild`).
- Committing a checkpoint whose DoDs aren't actually met.
- Compressing context mid-spec.
- Working on `main`/`master`, or in a worktree without committing specs+tasks to the branch first.
