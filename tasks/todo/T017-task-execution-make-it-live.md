---
id: T017
spec: specs/ui-overhaul-implementation.md
est_tokens: 6k
runner: orchestrator
parallel: true
area: task-execution
checkpoint: 11
---

# T017 — `task-execution`: "make-it-live" merges ViewModel wiring + JIT data in one pass

> **State:** todo

## Description
Session 1's T005 already made `task-execution` read the Foundation ledger and run the boundary
lint at checkpoint barriers. This task adds the remaining piece from
`ui-overhaul-implementation.md` §3.3: state explicitly that the "make-it-live" stage (the third
A3 stage, after a `ui-variations` graduate exists) merges ViewModel wiring and JIT data pull
into one pass — no separate translation/grounding step, since the graduated screen is already
the target SwiftUI code (`prototype-first-workflow.md` v2.0 §5/§6).

## Files
- `skills/task-execution/SKILL.md`

## Definition of Done
- The task lifecycle description (or TDD posture section) states that "make-it-live" attaches
  the real ViewModel via `init` and pulls real data just-in-time in a single pass, once a
  `ui-variations` graduate already exists at `presentation/<View>/<View>View.swift` — build-order
  dependency, not a parallel track.
- The `align-ui` post-wiring check (T015) is referenced as the check that runs after
  make-it-live, not a new skill.
- `grep -n "visual-grounding" skills/task-execution/SKILL.md` finds nothing as an active trigger.

## UI states
N/A (docs-only repo)

## Notes
Parallel with T015/T016/T018/T019/T020 — different files. Source:
`specs/prototype-first-workflow.md` v2.0 §6 (pipeline integration table).
