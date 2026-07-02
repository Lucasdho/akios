---
id: T016
spec: specs/ui-overhaul-implementation.md
est_tokens: 6k
runner: orchestrator
parallel: true
area: spec-to-tasks
checkpoint: 11
---

# T016 — `spec-to-tasks`: name `ui-variations` in the UI build-order stage shape

> **State:** todo

## Description
Session 1's T004 already made `spec-to-tasks` emit ALVA slice-shaped tasks with the
Foundation-consult step. This task adds the remaining piece from `ui-overhaul-implementation.md`
§3.2: emit the A3 build-order stage shape explicitly naming `ui-variations` for the middle
stage — `components [P] → ui-variations dumb-screen → make-it-live` — nested *inside*
`presentation/<View>/`, and confirm `ui-variations` (not any retired skill) is the only design-
phase skill named anywhere spec-to-tasks routes to.

## Files
- `skills/spec-to-tasks/SKILL.md`

## Definition of Done
- A "UI build-order stage shape" note/table is present naming the three stages explicitly:
  components `[P]` (swiftui-pro) → `ui-variations` dumb-screen (design phase) → make-it-live
  (wiring), all nested inside `presentation/<View>/`.
- `grep -n "ui-variations" skills/spec-to-tasks/SKILL.md` finds at least one hit.
- `grep -n "html-to-swiftui\|visual-grounding\|figma-to-swiftui" skills/spec-to-tasks/SKILL.md`
  finds nothing (confirms no retired/parked skill is routed to).

## UI states
N/A (docs-only repo)

## Notes
Parallel with T015/T017/T018/T019/T020 — different files. Builds on T004's slice-shape
decomposition (`skills/spec-to-tasks/SKILL.md` step 2) without duplicating it.
