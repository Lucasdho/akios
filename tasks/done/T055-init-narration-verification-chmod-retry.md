---
id: T055
spec: specs/init-reliability-and-ux.md
est_tokens: 16k
runner: orchestrator
parallel: false
area: init-narration-reliability
checkpoint: 34
---

# T055 — `/akios:init` narration, per-action verification, per-file chmod, bounded retry

> **State:** done

## Description
Harden `commands/init.md`'s Materialize step (§3) and skeleton-copy step (§1a) per
`init-reliability-and-ux.md` §1-§4: step-header narration everywhere, per-item narration in these
two long steps specifically, verify-after-every-action instead of trusting a clean tool-call
return, always-per-file `chmod +x` (never batched), and a bounded retry-then-stop-and-report path
on a confirmed miss.

## Files
- `commands/init.md` (§1a Skeleton selection; §3 Materialize; §5 Self-check)

## Definition of Done
- `commands/init.md` documents a one-line header narration for every top-level step (§0-§6).
- §3 (Materialize) and §1a (skeleton copy) document per-item narration as each file/action
  completes (e.g. "✓ `<file>` written", "✓ `<file>` copied + executable").
- §3 documents that every copy/write action is followed immediately by a verification check
  (re-read/stat the destination — exists, non-empty, or content-matches-source) **before**
  proceeding to the next item — not deferred to §5's end-of-run self-check.
- §3 documents that every `chmod +x` (the four hook scripts + `alva-usage-ledger.sh`) is issued
  as **one call per file**, always, never batched, and is followed by a re-stat confirming the
  executable bit is actually set.
- §3 documents the bounded-retry path: on a confirmed miss, retry the single action exactly once;
  if the retry also fails, **stop §3 immediately** (do not proceed to §4/§5) and report an
  itemized manifest — confirmed-landed / confirmed-missing / never-attempted — rather than
  continuing or guessing.
- §5 (Self-check) references this manifest concept: if §3 stopped early, self-check reports the
  manifest instead of claiming the repo is fully onboarded.
- `grep -n "verify\|re-stat\|retry\|manifest" commands/init.md` hits inside §3/§1a/§5's prose
  (spot-check by reading, not just a bare grep count).

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/init-reliability-and-ux.md` §1 (D1), §2 (D2), §3 (D3), §4 (D4). Footprint
consolidation (§5, §6, D5/D6) is a separate task, T056, since it touches a different part of the
same file (the materialize table's destination paths) plus cross-file references — kept separate
to bound each task's diff and DoD.
