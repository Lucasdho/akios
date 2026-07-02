---
id: T023
spec: specs/ui-overhaul-implementation.md
est_tokens: 4k
runner: orchestrator
parallel: true
area: swiftui-ui-patterns
checkpoint: 12
---

# T023 — `swiftui-ui-patterns`: screens-vs-components ViewModel note + role-modifier cross-link

> **State:** todo

## Description
Record the narrow "screens get ViewModels, components don't; screens are few" override next to
the guide's existing "avoid unnecessary view models" line, framing it as the screen-vs-component
split (not a contradiction). Cross-link the `.textStyle`/`.imageStyle` role-modifier convention
from the guide's custom-view-modifier guidance.

## Files
- `skills/swift-dev/skills/swiftui-ui-patterns/GUIDE.md`

## Definition of Done
- The "General rules to follow" section's "avoid unnecessary view models" line is followed (or
  annotated) with the screen-vs-component split: screens get a ViewModel (few screens, VM-per-
  screen per ALVA carry-over), dumb components never do.
- A cross-link to `skills/swift-dev/skills/swiftui-design-system/GUIDE.md`'s role-modifier
  convention is added (this guide has no dedicated custom-view-modifier section today — added
  as a short new bullet under "General rules to follow" or "Cross-cutting references").
- Doesn't contradict the existing line — reads as a refinement.

## UI states
N/A (docs-only repo)

## Notes
Parallel with T021/T022 — different files. [major] checkpoint — closes Phase 4 (Block B
materialization); audit T021–T023 before the checkpoint commit. Source:
`specs/swiftui-design-doctrine.md` §8 open item 3.
