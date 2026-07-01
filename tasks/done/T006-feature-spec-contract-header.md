---
id: T006
spec: specs/alva-adoption.md
est_tokens: 6k
runner: orchestrator
parallel: true
area: idea-to-spec
checkpoint: 5
---

# T006 — Feature-spec contract/Foundation declaration header

> **State:** done

## Description
A feature spec declares its `contract/` surface and the Foundation symbols it consumes
(doctrine §4 note, §6.4 alternative D — declaration as a cheap cross-check against the
ledger's counted evidence). Implements alva-adoption.md §7.6.

## Files
- `templates/spec.md` (or a feature-spec-specific template if `idea-to-spec` uses one)
- `skills/idea-to-spec/SKILL.md` (mention the header where feature specs are authored)

## Definition of Done
- The feature-spec template has a declaration header for: exported `contract/` surface, and
  Foundation symbols (Design-tokens / Code-tokens) the feature consumes.
- `spec-to-tasks` (already updated in T004) is noted as the reader of this header.

## UI states
N/A (docs-only repo)

## Notes
Parallel with T007/T008 — different files.
