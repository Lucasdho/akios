---
id: T050
spec: specs/code-review-doctrine.md
est_tokens: 10k
runner: orchestrator
parallel: false
area: review-doctrine-wiring
checkpoint: 30
---

# T050 — Wire `review-doctrine` into the gates + optional `/akios:review` wrapper

> **State:** done

## Description
Realizes `code-review-doctrine.md` §4 (D4, "how it plugs in"): `task-execution`'s finish step and
`just-vibes`' GATE step load the doctrine before `/code-review`; ships the optional thin
`/akios:review` wrapper for an on-demand principled pass (§1).

## Files
- `skills/task-execution/SKILL.md` — new "Code-review doctrine (loaded at the gate)" section
  (placed right before "Finish"); the lifecycle's `/code-review` line and "Finish" step both
  reference it.
- `skills/just-vibes/SKILL.md` — step 4 (GATE) now names loading `review-doctrine` before
  `/code-review`, same as `task-execution`'s own gate.
- `commands/review.md` (new) — the `/akios:review` wrapper: doctrine-preload + `/code-review` +
  graduated severity + priority-chain deference + DRY-via-ledger, non-ALVA/plugin-repo degrade.

## Definition of Done
- `task-execution/SKILL.md` has a "Code-review doctrine" section stating: loaded before
  `/code-review` at both the per-task review step and `Finish`; graduated block/warn severity;
  repeated findings route to the hurdles ledger; doesn't replace the built-in command.
- `just-vibes/SKILL.md`'s GATE step (loop step 4) names loading `review-doctrine` explicitly.
- `commands/review.md` exists with the house command frontmatter (`description`,
  `disable-model-invocation: true`), states it's a thin wrapper (not a fork of `/code-review`),
  and documents the priority-chain-deference + DRY-ledger + plugin-repo-degrade rules.
- `grep -rln "review-doctrine" skills/task-execution/SKILL.md skills/just-vibes/SKILL.md commands/review.md` returns all three files.

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/code-review-doctrine.md` §4 (D4), §1 (optional wrapper). Depends on T049's
`review-doctrine/GUIDE.md` existing (same checkpoint, sequenced after). The DRY check's dependency
on `Foundation/usage-ledger.json` (§8 third CONSEQUENCE) needed no new wiring — `alva-adoption.md`
already ships the ledger script; T049's guide documents reading it, which is the entire
"wiring" this reconciliation required.
