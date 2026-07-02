---
id: T009
spec: specs/alva-adoption.md
est_tokens: 12k
runner: orchestrator
parallel: true
area: init-scaffold
checkpoint: 6
---

# T009 — `/akios:init` + templates scaffold the reconciled ALVA tree

> **State:** done

## Description
Scaffold the reconciled tree (alva-adoption §1) on init: `Router/`, `Container/`,
`Foundation/{Design-tokens,Code-tokens,usage-ledger.json}`, and the per-feature slice shape
`Features/<F>/{domain,data,presentation/{<View>/components/, Models/},contract,tests,
Feature-spec.md}`, plus top-level `scratchs/` (out-of-target rejected UI variations, per
prototype-first-workflow v2.0). Include DesignSystem + role-modifier stubs. `Context.md`
notes `scratchs/` stays out of the Xcode target. Implements alva-adoption.md §7.9.

## Files
- `commands/init.md`
- `templates/` (new stub files/folders for the scaffold — Foundation stubs, a starter
  `usage-ledger.json`, the git-hook install step referencing T003's script)

## Definition of Done
- `commands/init.md` step 3 (materialize) lists the new scaffold rows: `Router/`,
  `Container/`, `Foundation/` (with Design-tokens/Code-tokens stubs + ledger stub),
  top-level `scratchs/`, and documents `Features/` as created per-feature (not empty
  up front — a feature only gets a slice when `spec-to-tasks` decomposes it).
- The ledger stub + git-hook install step (from T003) is referenced in init's step 3/4.
- `templates/Context.md` gets a line noting `scratchs/` is excluded from the Xcode target.

## UI states
N/A (docs-only repo)

## Notes
Parallel with T010 — different files (commands/init.md + templates/ vs swift-dev).
