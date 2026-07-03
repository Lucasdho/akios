---
id: T004
spec: specs/alva-adoption.md
est_tokens: 8k
runner: orchestrator
parallel: true
area: spec-to-tasks
checkpoint: 4
---

# T004 — `spec-to-tasks` emits ALVA slice-shaped tasks

> **State:** done

## Description
UI/feature task decomposition emits tasks scoped to the ALVA slice
(`domain/data/presentation/contract/tests`), and every feature task includes the step
"consult `Foundation/` before creating a helper." The existing build-order stage shape (A3:
components → dumb screen → make-it-live) nests *inside* `presentation/`, not replaced.
Implements alva-adoption.md §7.4.

## Files
- `skills/spec-to-tasks/SKILL.md`

## Definition of Done
- A worked example (or the existing decomposition steps) shows a feature spec decomposing
  into tasks tagged with `area:` values matching slice sub-folders
  (`Features/<F>/domain`, `.../data`, `.../presentation/<View>`, `.../contract`, `.../tests`).
- The Foundation-consult step is present as a named step in the decomposition pass.
- The task file format / routing table references the `alva-architecture` swift-dev guide
  (T002) for any task scoped to a new feature/slice.

## UI states
N/A (docs-only repo)

## Notes
Parallel with T005 — different files, no shared symbols this checkpoint.
