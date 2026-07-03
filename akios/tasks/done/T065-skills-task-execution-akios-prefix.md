---
id: T065
spec: specs/akios-footprint-consolidation.md
est_tokens: 9k
runner: orchestrator
parallel: true
area: skills/task-execution
checkpoint: 38
---

# T065 — Skill `task-execution`: `akios/` path rewrite

> **State:** todo

## Description
`task-execution` owns the `deliver` phase loop — folder-state task lifecycle (`tasks/todo/ →
in-progress/ → review/ → done/`), checkpoint commits, and `Roadmap.md` status writes. Rewrite
every path literal to the `akios/`-prefixed form.

## Files
- `skills/task-execution/SKILL.md`

## Definition of Done
- Every `tasks/<state>/`, `specs/`, `Roadmap.md`, `Context.md` path literal gains the `akios/`
  prefix, including the folder-state lifecycle description (`akios/tasks/todo/ →
  akios/tasks/in-progress/ → akios/tasks/review/ → akios/tasks/done/`).
- The existing `scripts/alva-usage-ledger.sh` → `.claude/scripts/alva-usage-ledger.sh` reference
  (from T056) is unchanged — that path isn't part of this spec's scope.
- `grep -n "tasks/\|specs/\|Roadmap\.md\|Context\.md" skills/task-execution/SKILL.md` shows only
  `akios/`-prefixed forms (excluding the unrelated `.claude/scripts/` line).

## UI states
N/A

## Notes
Source: `specs/akios-footprint-consolidation.md` §3, §13. Mechanical rewrite; double-check the
folder-state lifecycle prose since it's referenced by name in multiple places in this file.
