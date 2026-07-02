---
id: T018
spec: specs/ui-overhaul-implementation.md
est_tokens: 2k
runner: orchestrator
parallel: true
area: figma-audit
checkpoint: 11
---

# T018 — `figma-to-swiftui` — audit only, confirm parked (no change)

> **State:** done

## Description
Per `ui-overhaul-implementation.md` §3.4, `figma-to-swiftui` stays exactly as shipped and is
**not** added to any routing table — parked per `prototype-first-workflow.md` v2.0 §1/§4/§9,
revived only if a future session wires Figma/Stitch back in as an optional feeder. This task
is audit-only: confirm it is absent from `spec-to-tasks`' and `task-execution`'s routing
tables. Nothing to build.

## Files
None — audit only.

## Definition of Done
- `grep -n "figma-to-swiftui" skills/spec-to-tasks/SKILL.md skills/task-execution/SKILL.md`
  finds no hit outside `swift-dev`'s own domain-routing table (which still lists it as a
  Figma-URL-triggered `swift-dev` sub-skill — unrelated to the design-phase routing this audit
  checks).
- Confirmed: no file changed by this task.

## UI states
N/A (docs-only repo)

## Notes
Parallel with T015/T016/T017/T019/T020 — audit only, touches no files.
