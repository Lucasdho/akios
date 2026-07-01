---
id: T002
spec: specs/alva-adoption.md
est_tokens: 14k
runner: orchestrator
parallel: false
area: swift-dev-guide
checkpoint: 2
---

# T002 — New `swift-dev` architecture guide (ALVA slice shape)

> **State:** done

## Description
Add a new bundled guide to `swift-dev` encoding the reconciled ALVA slice shape (alva-adoption
§1), the UI-family carry-over laws (§2), the contract/bounded-context rule (doctrine §5), and
"consult only `Foundation/` before writing a helper" (doctrine P6). Register it in the
`swift-dev` router table. Implements alva-adoption.md §7.2.

## Files
- `skills/swift-dev/skills/alva-architecture/GUIDE.md` (new)
- `skills/swift-dev/SKILL.md` (router table + selection rules + common combos)

## Definition of Done
- Guide exists at `skills/swift-dev/skills/alva-architecture/GUIDE.md`.
- `swift-dev/SKILL.md`'s Phase 2 routing table points to it for new-feature / new-slice work.
- Guide shows: the slice tree, the contract rule (import contract/, never internals), the
  Foundation-first rule (consult before creating a helper), and the dumb-component /
  build-order carry-over laws re-homed under `presentation/<View>/`.

## UI states
N/A (docs-only repo)

## Notes
Source content: `specs/alva-adoption.md` §1 (tree), §2 (carry-over table), §8 (worked example).
`specs/alva-architecture-doctrine.md` §3–§6 (principles + Foundation mechanics).
