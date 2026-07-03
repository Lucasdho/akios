---
id: T067
spec: specs/akios-footprint-consolidation.md
est_tokens: 7k
runner: orchestrator
parallel: true
area: skills/design
checkpoint: 38
---

# T067 — Skills `align-ui` + `ui-variations`: `akios/` path rewrite

> **State:** todo

## Description
Both design-phase skills reference `specs/` (for the alignment doc / spec they implement
against) and possibly `tasks/` (per-task UI-state coverage). Rewrite to the `akios/`-prefixed
form.

## Files
- `skills/align-ui/SKILL.md`
- `skills/ui-variations/SKILL.md`

## Definition of Done
- Every `specs/`, `tasks/`, `Roadmap.md`, `Context.md` path literal in both files gains the
  `akios/` prefix.
- `grep -n "specs/\|tasks/\|Roadmap\.md\|Context\.md" skills/align-ui/SKILL.md skills/ui-variations/SKILL.md`
  shows only `akios/`-prefixed forms.

## UI states
N/A

## Notes
Source: `specs/akios-footprint-consolidation.md` §3, §13. Mechanical rewrite.
