---
id: T011
spec: specs/alva-adoption.md
est_tokens: 3k
runner: orchestrator
parallel: false
area: release-checkpoint
checkpoint: 7
---

# T011 — ALVA-adoption release checkpoint (audit only — version bump deferred)

> **State:** todo

## Description
alva-adoption.md §7.11 calls this a "Release" step (install-skills.sh + VERSION/CHANGELOG/
plugin.json bump). **Adapted for the v0.8.0 multi-spec arc**: this build ships bundled with
the rest of the backlog (per the approved 3-session plan), not standalone — so the actual
version bump happens once, at the end of session 3, not here. This task is the audit-only
checkpoint: confirm nothing from this spec needs a new top-level skill directory registered,
and that the spec's own DoD list is fully green before moving to the next spec.

## Files
- `scripts/install-skills.sh` (check only — no new top-level skill dir was added by T001–T010,
  only a new guide *inside* the existing `swift-dev` skill, so no entry should be needed)

## Definition of Done
- Confirm `scripts/install-skills.sh`'s `SKILLS=(...)` array needs no new entry (T002/T010
  added a guide inside `swift-dev`, not a new skill directory).
- Every task T001–T010's DoD re-verified green.
- `Roadmap.md` row for `alva-adoption.md` and `alva-architecture-doctrine.md` flipped to `done`.
- Note in the commit message that the version bump is deferred to the v0.8.0 closeout.

## UI states
N/A (docs-only repo)

## Notes
[major] checkpoint — this is the vertical-slice completion point for the whole alva-adoption
spec; audit every task before committing.
