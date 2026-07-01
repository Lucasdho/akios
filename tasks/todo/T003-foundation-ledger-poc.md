---
id: T003
spec: specs/alva-adoption.md
est_tokens: 10k
runner: orchestrator
parallel: false
area: foundation-ledger
checkpoint: 3
---

# T003 — Foundation ledger PoC (ripgrep + git-hook)

> **State:** todo

## Description
Ship strategy A (ripgrep + pre-commit git-hook) from alva-adoption §3: a hook that counts
Foundation symbol occurrences across `Features/*/` and rewrites `Foundation/usage-ledger.json`
using the JSON schema from doctrine §6.4. Ships as a template script installed by `/akios:init`
into a consumer repo — this repo itself has no `Features/` tree to run it against, so the
artifact here is the reusable script + template wiring + docs, not a live run.
Implements alva-adoption.md §7.3.

## Files
- `scripts/alva-usage-ledger.sh` (new — the ripgrep-based counter)
- `templates/rules/alva.md` or `commands/init.md` (wiring the hook into a consumer repo)

## Definition of Done
- Script exists, is executable, and regenerates a `Foundation/usage-ledger.json` matching the
  doctrine §6.4 schema (`candidates_promote` / `candidates_demote` with symbol/kind/features/
  count/threshold).
- `/akios:init` wiring documented so the hook installs into a consumer repo's
  `.git/hooks/pre-commit` (or `.claude/hooks/`) the same way the existing hooks do.
- A worked/seeded example (3 fake features referencing one shared symbol) is shown in the
  script's own header comment or a short doc, demonstrating a `candidates_promote` entry.

## UI states
N/A (docs-only repo)

## Notes
`oss-first` check first per the spec: if a maintained dead-code/index tool already walks a
symbol-reference index, prefer wiring that over hand-rolling ripgrep counting. Record the
decision either way. Never let the agent count by hand — `task-execution` only *reads* the
ledger (see T005).
