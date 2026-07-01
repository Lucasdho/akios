---
id: T008
spec: specs/alva-adoption.md
est_tokens: 6k
runner: orchestrator
parallel: true
area: deep-brainstorm
checkpoint: 5
---

# T008 — `deep-brainstorm` maps features as ALVA slices

> **State:** done

## Description
Whole-app mapping (Phase 2 Cartograph / Phase 4 Spec-burst) emits each identified domain as a
future ALVA slice, marks contract boundaries between domains that will need to talk to each
other, and seeds candidate `Foundation/` items (shared design tokens, obviously-repeated
concerns spotted across domains at map time). Implements alva-adoption.md §7.8.

## Files
- `skills/deep-brainstorm/SKILL.md`

## Definition of Done
- Phase 2 (Cartograph) or Phase 4 (Spec-burst) notes that each domain maps to a future
  `Features/<Domain>/` slice.
- Cross-domain dependencies identified during cartography are recorded as contract-boundary
  notes (which domain owns the intention, which consumes by contract — doctrine §5.4).
- Obvious cross-cutting concerns (Theming/Design System, shared utilities) are flagged as
  `Foundation/` seed candidates in the app map output.

## UI states
N/A (docs-only repo)

## Notes
Parallel with T006/T007 — different files.
