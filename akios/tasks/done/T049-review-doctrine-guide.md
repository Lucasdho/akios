---
id: T049
spec: specs/code-review-doctrine.md
est_tokens: 14k
runner: orchestrator
parallel: false
area: review-doctrine-reference
checkpoint: 30
---

# T049 — `review-doctrine`: the doctrine reference itself

> **State:** done

## Description
Ships `code-review-doctrine.md` §1 (D1, "a doctrine reference the gate loads"), §2 (D2, SOLID/DRY/
ACID applied honestly), and §3 (D3, ALVA + UI conformance checks) as a knowledge reference under
the `ios` pack, in the same shape as every other `swift-dev` guide.

## Files
- `skills/swift-dev/skills/review-doctrine/GUIDE.md` (new) — the checklist tables (SOLID's 4 rows,
  the DRY-via-ledger reconciliation, the ACID-scoped-to-persistence reconciliation, the 7-row
  ALVA/UI conformance table, priority-chain deference, hurdles-ledger feed, empty/edge states, the
  worked Squad example).
- `skills/swift-dev/SKILL.md` — one-line pointer noting the doctrine is loaded at the review gate,
  not selected by Phase 2's classify-and-load routing table.

## Definition of Done
- `skills/swift-dev/skills/review-doctrine/GUIDE.md` exists with frontmatter (`name`,
  `description`, `license`, `metadata`) matching the shape of `alva-architecture/GUIDE.md`.
- Contains all four SOLID rows, the DRY section stating "read the ledger, never eyeball" with the
  ledger-absent-degrades-silent rule, the ACID section stating persistence-only scope + the
  never-cargo-cult-onto-views rule, and the 7-row ALVA/UI conformance table with boundary +
  multi-responsibility marked `block`.
- States the priority-chain deference rule (project/pack override downgrades a block to a
  visibility note) and that a repeated finding feeds the hurdles ledger.
- `swift-dev/SKILL.md` has a one-line callout that this guide is gate-loaded, not Phase-2-routed.
- `grep -n "review-doctrine" skills/swift-dev/SKILL.md` hits.

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/code-review-doctrine.md` §1–§3, §5 (worked example), §6 (deliberate exclusions),
§7 (empty/edge states). Wiring the guide into the actual gates (`task-execution` finish step,
`just-vibes` GATE, the optional `/akios:review` wrapper) is **T050**.
