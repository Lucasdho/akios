---
id: T010
spec: specs/alva-adoption.md
est_tokens: 5k
runner: orchestrator
parallel: true
area: coordinator-doc
checkpoint: 6
---

# T010 — Coordinator reference for multi-step custom flows

> **State:** todo

## Description
A short reference note on the `Router/`-owned coordinator pattern for multi-step custom flows
(onboarding, purchase wizards spanning several screens/slices) — closes backlog B14.
A coordinator is a composition-root citizen: it consumes slices only through their `contract/`.
Implements alva-adoption.md §7.10.

## Files
- `skills/swift-dev/skills/alva-architecture/GUIDE.md` (append the coordinator section — same
  guide T002 created, cross-linked rather than a separate file)

## Definition of Done
- The coordinator pattern is documented: when to reach for a named coordinator vs a plain
  `navigationDestination`, where it lives (`Router/`), and that it only imports other slices'
  `contract/`.
- Cross-links the DI/composition section from T002 (same guide).

## UI states
N/A (docs-only repo)

## Notes
Parallel with T009 — different files.
