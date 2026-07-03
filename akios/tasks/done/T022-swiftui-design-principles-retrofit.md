---
id: T022
spec: specs/ui-overhaul-implementation.md
est_tokens: 8k
runner: orchestrator
parallel: true
area: swiftui-design-principles
checkpoint: 12
---

# T022 — `swiftui-design-principles` retrofit: token/role call sites, values unchanged

> **State:** done

## Description
Keep the vendored guide's (arjitj2, MIT v1.1.1) spacing-grid / "5 sizes" / semantic-color rules
as the **source** of the token table — update its examples to show `.textStyle(.hero)` +
`DesignSystem.*` token refs instead of inline `.font(.system(size:…))` / `Color(.x)` literals.
Values preserved, call sites re-homed only.

## Files
- `skills/swift-dev/skills/swiftui-design-principles/GUIDE.md`

## Definition of Done
- At least the guide's most prominent typography/spacing example shows the token/role form
  (`.textStyle(.hero)`, `DesignSystem.Spacing.md`) alongside or replacing the raw literal, with
  a cross-link to `skills/swift-dev/skills/swiftui-design-system/GUIDE.md` (T021).
- No numeric rule value (spacing grid numbers, allowed sizes, color semantics) changed — only
  call-site presentation.
- A short note near the top of the guide states the token/role convention is now the preferred
  call-site form, this guide remains the rule *source*.

## UI states
N/A (docs-only repo)

## Notes
Vendored file — edit surgically, don't rewrite wholesale. Parallel with T021/T023 — different
files. Source: `specs/swiftui-design-doctrine.md` §8 open item 2.
