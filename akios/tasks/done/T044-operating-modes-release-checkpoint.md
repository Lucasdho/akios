---
id: T044
spec: specs/operating-modes.md
est_tokens: 2k
runner: orchestrator
parallel: false
area: release-checkpoint
checkpoint: 27
---

# T044 — `operating-modes.md` release checkpoint

> **State:** done

## Description
Closes out `operating-modes.md` (backlog B3, G4): verifies T042+T043's DoDs and flips the spec's
`Roadmap.md` row from `designed` to `done`.

## Files
- `Roadmap.md` (spec row status flip)

## Definition of Done
- T042 and T043 DoDs re-verified by inspection/grep (both green, see checkpoint 26 commit).
- `Roadmap.md`'s `operating-modes.md` row status is `done`, noting T042-T043 and deferring the
  version bump to the v0.8.0 closeout, matching the style of every prior release-checkpoint row.
- No content population beyond mechanism — no repo has actually run `/akios:init` with the new
  posture question yet; that's expected (mechanism-only ship, per session precedent).

## UI states
N/A (docs-only repo)

## Notes
Third of this session's three release checkpoints. Next: `verification-and-learning-loop.md`
(T045+).
