---
id: T021
spec: specs/ui-overhaul-implementation.md
est_tokens: 12k
runner: orchestrator
parallel: true
area: swiftui-design-system
checkpoint: 12
---

# T021 — New `swiftui-design-system` reference guide + fill the Phase-1 stubs

> **State:** done

## Description
New bundled `swift-dev` guide (beside `swiftui-design-principles`) encoding the `DesignSystem`
static-token-struct convention (`swiftui-design-doctrine.md` §1/B1) and the
`.textStyle`/`.imageStyle` role-modifier convention (§4/B4), plus the static→instance upgrade
rule (promote to `@Environment` on 2nd theme). Home: `Foundation/Design-tokens/`. Also fills in
the minimal stub files T013 created with the real shape now that it's decided.

## Files
- `skills/swift-dev/skills/swiftui-design-system/GUIDE.md` (new)
- `skills/swift-dev/SKILL.md` (router table: new row pointing to the guide)
- `templates/foundation/DesignSystem.swift` (fill in the stub — Spacing/Radius/Typography/Color
  enum shape)
- `templates/foundation/RoleModifiers.swift` (fill in the stub — `.textStyle`/`.imageStyle`
  View extensions)

## Definition of Done
- Guide shows: the `enum DesignSystem` shape (Spacing/Radius/Typography/Color, semantic system
  colors + asset-catalog brand colors), the `.textStyle(.hero/.statValue/.body/.sectionLabel/
  .caption)` / `.imageStyle(.avatar/.thumbnail/.badge/.hero)` role-modifier pattern, the
  "promote to `@Environment(\.designSystem)` on 2nd theme" upgrade clause, and the correct
  `Foundation/Design-tokens/` home (not a `PresentationLayer/DesignSystem/`).
- `swift-dev/SKILL.md`'s Phase 2 routing table gets a row for "Design tokens, text/image role
  modifiers, DesignSystem struct" → the new guide.
- Both stub files now contain real (if minimal) Swift matching the guide's shape — no longer
  bare placeholders.

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/swiftui-design-doctrine.md` §1 (B1), §4 (B4), §8 open item 1. Parallel with
T022/T023 — different files.
