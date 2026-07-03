---
id: T074
spec: akios/specs/subagent-context-chaining.md
est_tokens: 6k
runner: orchestrator
parallel: true
area: skills/task-execution/SKILL.md
checkpoint: 1
---

# T074 — Point "Runner routing + model tier" at the chaining protocol

> **State:** todo

## Description
`skills/task-execution/SKILL.md`'s "Runner routing + model tier" / "Cold-subagent discipline"
bullets (~lines 98–114) answer whether/how to dispatch one subagent for one task, but say
nothing about what happens when a subagent is handed a **batch** of queued tasks in a row.
Add a short bullet, placed right after "Cold-subagent discipline," pointing to
`subagent-context-chaining.md` §§1–6: once a batch clears the existing eligibility bar, that
spec's chain-don't-spawn-per-task-don't-run-unbounded protocol (one subagent works the batch in
sequence, compacting between tasks, handing off in writing at a 120k-token lineage budget) is
the default execution shape for it. Keep it condensed — this is a pointer, not a restatement of
the spec's decisions.

## Files
- `skills/task-execution/SKILL.md`

## Definition of Done
- A new bullet exists after the existing "Cold-subagent discipline" bullet, referencing
  `subagent-context-chaining.md` by name.
- The bullet states the trigger (a subagent-eligible **batch**, not a single task) and the two
  load-bearing facts: chain in place between tasks, hand off in writing at the 120k lineage
  budget rather than running unbounded.
- No existing line in the section was overwritten or reworded — `git diff` shows only an
  addition.
- `grep -n "subagent-context-chaining" skills/task-execution/SKILL.md` returns a match.

## UI states
N/A — plugin-docs repo, no Swift/UI here (see `akios/Context.md` gotchas).

## Notes
No swift-dev routing applies (plugin-docs task). DoD verification = inspection + grep, not a
test suite, per `akios/Context.md`.
