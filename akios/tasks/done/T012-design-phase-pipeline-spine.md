---
id: T012
spec: specs/ui-overhaul-implementation.md
est_tokens: 10k
runner: orchestrator
parallel: false
area: pipeline-spine
checkpoint: 8
---

# T012 — Add the `design` phase to the pipeline spine

> **State:** done

## Description
Insert a 4th phase, `design`, between `plan` and `execute` in `workflow.yml` (the phase
contract). Per `prototype-first-workflow.md` v2.0 §6, `design` runs `ui-variations`
(explore + remix + graduate) and the reshaped `align-ui`; there is no separate approval-gate
mechanism — a screen can't reach `make-it-live` until a variation has graduated, which is
`alva-adoption.md`'s A3 build-order already. Implements ui-overhaul-implementation.md §0.1.

**Reconciliation note:** the spec text says "`workflow.yml` + `pipeline.md`" but this repo has
no literal `pipeline.md` file — `skills/ios-feature-pipeline/SKILL.md` is the de facto pipeline
conduct doc (it reads `workflow.yml` and narrates the spine). Treated as the same target.

## Files
- `workflow.yml` (new `design` phase entry between `plan` and `execute`)
- `skills/ios-feature-pipeline/SKILL.md` (spine table + narrative: 3 phases → 4)
- `templates/AGENTS.md` ("Full feature workflow" spine line + permission-mode note)

## Definition of Done
- `workflow.yml` lists `design` between `plan` and `execute`: `command: /akios:design`,
  `skill: ui-variations`, `prereqs: [tasks/todo/*.md]`, `outputs` = a graduated
  `presentation/<View>/` screen + `tasks/ui-alignment/<Screen>.md`, `roadmap: in-progress`.
- `ios-feature-pipeline/SKILL.md`'s spine table and prose show 4 phases
  (`brainstorm → plan → design → execute`), with `design`'s skill/command/mode/output row.
- `templates/AGENTS.md`'s "Full feature workflow" section and permission-mode guidance mention
  `design` in the spine.
- `grep -rn "3-phase\|3 phase" skills/ commands/ templates/ workflow.yml` finds nothing live
  (only historical spec/CHANGELOG text, untouched, since those record past decisions).

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/prototype-first-workflow.md` v2.0 §6 (pipeline integration), §9 open item
("workflow.yml / pipeline.md: design phase description changes... phase count stays at 4").
`ui-overhaul-implementation.md`'s own Phase 0.1 is the direct source.
