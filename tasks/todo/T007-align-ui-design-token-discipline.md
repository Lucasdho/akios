---
id: T007
spec: specs/alva-adoption.md
est_tokens: 5k
runner: orchestrator
parallel: true
area: align-ui
checkpoint: 5
---

# T007 — `align-ui` treats Design-tokens as the visual leaf source

> **State:** todo

## Description
`align-ui` (the pre-implementation UI alignment gate) treats `Foundation/Design-tokens/` as
the visual leaf source of truth and flags un-tokenized literals (colors, spacing, type styles
hardcoded instead of pulled from the DesignSystem). Composes with the UI-family carry-over
laws (alva-adoption §2, B1–B5). Implements alva-adoption.md §7.7.

## Files
- `skills/align-ui/SKILL.md`

## Definition of Done
- SKILL.md notes `Foundation/Design-tokens/` as the design-token source to check before
  proposing a visual decision.
- A literal-flag check is named: a hardcoded color/spacing/font literal in the alignment
  conversation is flagged and redirected to a Design-tokens lookup or promotion.

## UI states
N/A (docs-only repo)

## Notes
Parallel with T006/T008 — different files.
