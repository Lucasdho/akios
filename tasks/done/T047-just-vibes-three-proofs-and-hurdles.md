---
id: T047
spec: specs/verification-and-learning-loop.md
est_tokens: 5k
runner: orchestrator
parallel: false
area: just-vibes-gate-naming
checkpoint: 28
---

# T047 — `just-vibes`: name the three proofs at GATE; Lessons digest names the hurdles ledger

> **State:** done

## Description
Closes the last two seams from `verification-and-learning-loop.md` §5 ("Where it fires"): the
`just-vibes` quality gate *is* the three proofs (§2), and the learning-posture journal Lessons
subsection (shipped in T043 for `operating-modes.md`) explicitly names the hurdles ledger as one
of the things it captures — so G4's journal mechanism and G5's ledger mechanism visibly connect
instead of just coincidentally both existing.

## Files
- `skills/just-vibes/SKILL.md`:
  - "The contract" — quality-gate bullet now names the three proofs
  - step 4 (GATE) in "The loop" — same naming
  - "Posture under just-vibes" — Lessons bullet now names `code-references/hurdles.md` and
    `task-execution`'s "Hurdles ledger" section explicitly, instead of a generic "hurdle/preference"

## Definition of Done
- `grep -n "three proofs" skills/just-vibes/SKILL.md` hits at least twice (contract + loop step 4).
- `grep -n "hurdles.md" skills/just-vibes/SKILL.md` hits at least once, inside the Lessons bullet.
- No change to the actual GATE mechanics (`/verify` + `/code-review` still run exactly as before)
  — this task is naming/cross-referencing only, no new gate behavior.

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/verification-and-learning-loop.md` §5 ("just-vibes" row) and §8 fourth
CONSEQUENCE. Completes checkpoint 28 (build) for this spec; T048 is the release checkpoint.
