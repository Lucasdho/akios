---
id: T034
spec: specs/snippet-library.md
est_tokens: 7k
runner: orchestrator
parallel: false
area: task-execution-snippet-consumption
checkpoint: 20
---

# T034 — `task-execution` gains the copy-and-adapt-and-prune step for `kind: snippet`

> **State:** done

## Description
Give `task-execution` the consumption-side half of `snippet-library.md`: when a task's pack
lookup resolves to a `kind: snippet` entry (as opposed to `kind: reference`), the executor copies
the snippet's file(s) verbatim, adapts placeholder names per its `usage.md`, and prunes anything
the task doesn't need — as a **required** DoD step, not optional (§3). Also documents how the
declared `target:` (§5 of the spec) decides `Foundation/Design-tokens` vs. feature-local
placement.

## Files
- `skills/task-execution/SKILL.md`

## Definition of Done
- The task lifecycle section gains a documented step: when a task's pack tag resolves to a
  `kind: snippet` entry, `task-execution` (1) copies the file(s) to the target location, (2)
  adapts placeholder names (e.g. `EntityName` → the task's real entity) per the snippet's
  `usage.md`, (3) prunes unused parts of the copy — listed as a mandatory DoD line for that task,
  not an optional cleanup.
- Target resolution documented: a snippet declaring `target: Foundation/Design-tokens` is copied
  once and reused directly on subsequent tasks that need it (no re-copy if already present); a
  snippet declaring `target: Features/<F>/data` or `.../domain` is copied fresh into each
  consuming feature, with entity names adapted per feature — matching `snippet-library.md` §5's
  distinction and its worked example (§8).
- A new anti-pattern line: accepting a copied snippet as-is without a prune pass.
- No change to the priority-chain section or the Foundation ledger's promotion/demotion rules —
  explicitly noted that a snippet's declared `target:` is a human decision at registration time
  (`knowledge-ingest`'s confirm gate, T033), not a ledger mutation, per the spec's own "noted
  tension (resolved, not reopened)" in §5.
- Graceful fallthrough documented: if a task could use a snippet but none matches, the agent
  writes fresh code as it would today — no error, no forced match (§9).

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/snippet-library.md` §3 (D3), §5 (D5), §8 (worked example), §9 (edge states).
Companion to T033 (the ingestion side); this task is the consumption side. Both land in
checkpoint 20 — sequential edits (different files, no functional dependency between them beyond
both realizing the same spec).
