---
id: T015
spec: specs/ui-overhaul-implementation.md
est_tokens: 9k
runner: orchestrator
parallel: true
area: align-ui
checkpoint: 11
---

# T015 — `align-ui` remodel: Nielsen checklist + native-over-custom flag + post-wiring check

> **State:** todo

## Description
Session 1's T007 already made `align-ui` treat `Foundation/Design-tokens/` as the visual leaf
source and flag un-tokenized literals. This task adds the three remaining Block B/C
responsibilities per `ui-overhaul-implementation.md` §3.1: the **10 Nielsen heuristics
checklist** (`swiftui-design-doctrine.md` §3), the **native-over-custom flag**
(`swiftui-design-doctrine.md` §2), and the **post-wiring check** absorbed from the retired
`visual-grounding` skill (does the real-data render still hold up against the mock-data-approved
`ui-variations` graduate — same-engine, no cross-engine diff).

## Files
- `skills/align-ui/SKILL.md`

## Definition of Done
- The 10-heuristic table (visibility of system status, match system & real world, user control
  & freedom, consistency & standards, error prevention, recognition over recall, flexibility &
  efficiency, aesthetic & minimalist, help users with errors, help & documentation) is present
  as a design-phase checklist, each with its concrete SwiftUI check.
- A native-over-custom flag step is documented: `align-ui` flags an un-justified custom control
  (hand-rolled toggle, `GeometryReader` progress bar where `Gauge` fits) during the explore round
  and again at the post-wiring check.
- A post-wiring check step is documented: after `execute`'s make-it-live wires the real
  ViewModel/data, confirm the real-data render still holds up against the mock-data-approved
  `ui-variations` graduate (same-engine, same-code — not a cross-engine diff).
- No reference to the retired `visual-grounding` skill remains as something to invoke — it is
  named only as the historical source the post-wiring check absorbed from.

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/swiftui-design-doctrine.md` §2 (native-over-custom budget), §3 (Nielsen
heuristics table). `specs/prototype-first-workflow.md` v2.0 §5 (post-wiring check, absorbed from
retired visual-grounding). Parallel with T016/T017/T018/T019/T020 — different files.
