---
id: T024
spec: specs/ui-overhaul-implementation.md
est_tokens: 3k
runner: orchestrator
parallel: false
area: coordinator-audit
checkpoint: 13
---

# T024 — Coordinator reference — audit + cross-link to the new design-system guide

> **State:** todo

## Description
`ui-overhaul-implementation.md` §5.1's DoD is identical in substance to `alva-adoption.md`
§7.10, already shipped as Session 1's T010 (coordinator section inside
`skills/swift-dev/skills/alva-architecture/GUIDE.md`). The one genuine delta: §5.1 asks the
note to cross-link "the DI guide (1.2/4.1)" — 1.2 (the guide itself) is already true by
construction; 4.1 (T021's new `swiftui-design-system` guide) didn't exist when T010 was written
and needs a link now.

## Files
- `skills/swift-dev/skills/alva-architecture/GUIDE.md` (Composition: Router + Container section)

## Definition of Done
- The coordinator section (or the composition section it lives in) adds a one-line cross-link
  to `skills/swift-dev/skills/swiftui-design-system/GUIDE.md`, noting that views/components a
  coordinator draws through the Container's factories still consume `Foundation/Design-tokens/`
  statically (dumb-component law unaffected by DI/coordination).
- The existing coordinator pattern description (when to reach for one, `Router/` home,
  contract-only cross-slice consumption) is otherwise unchanged.

## UI states
N/A (docs-only repo)

## Notes
Depends on T021 existing (checkpoint 12 must land first). Source:
`specs/ui-overhaul-implementation.md` §5.1.
