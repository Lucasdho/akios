---
id: T001
spec: specs/alva-adoption.md
est_tokens: 6k
runner: orchestrator
parallel: false
area: doctrine-import
checkpoint: 1
---

# T001 — Import the ALVA doctrine as ground-truth

> **State:** todo

## Description
Register `specs/alva-architecture-doctrine.md` in `Roadmap.md` and have the installed
`AGENTS.md`/`Context.md` templates import it as ground-truth (ALVA §11 row 1: "doctrine as
ground-truth versionned, imported by AGENTS.md/Context.md"). Implements alva-adoption.md §7.1.

## Files
- `Roadmap.md` (this repo's own — add a row for `alva-architecture-doctrine.md`)
- `templates/AGENTS.md` (reference the doctrine + the reconciled slice shape)

## Definition of Done
- Roadmap row exists for `alva-architecture-doctrine.md`.
- `templates/AGENTS.md` references the doctrine and states the ALVA slice shape supersedes
  any prior layer-first assumption.
- `grep -ri "layer-first" templates/ skills/` finds no unqualified contradiction left.

## UI states
N/A (docs-only repo)

## Notes
Doctrine content: `specs/alva-architecture-doctrine.md` §3 (7 principles), §4 (folder shape),
§5 (contract boundary). Reconciliation deltas: `specs/alva-adoption.md` §1–§2.
