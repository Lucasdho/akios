---
id: T014
spec: specs/ui-overhaul-implementation.md
est_tokens: 22k
runner: subagent-eligible
parallel: false
area: ui-variations-skill
checkpoint: 10
---

# T014 — New `ui-variations` skill (the design phase's one skill)

> **State:** done

## Description
Author the whole design-phase loop as one new skill, per `prototype-first-workflow.md` v2.0
§2–§6 and `ui-overhaul-implementation.md` §2.1: explore round (3–5 named `#Preview`s by
default, user-specified count wins, warn-don't-block on extreme requests), remix round (3
named hybrids from liked elements), sample data with edge cases (empty / unbounded / long-text)
shipped alongside every round, approve-and-graduate (winner lands directly at
`presentation/<View>/<View>View.swift` + `components/`, no translation step), archive-to-scratch
(losers compile + preview at `scratchs/<Component-or-View>.swift`). Unattended (`just-vibes`):
auto-select-and-graduate from the explore round, `[auto]`-marked, rationale recorded.

## Files
- `skills/ui-variations/SKILL.md` (new)

## Definition of Done
- SKILL.md covers both rounds with their default/override counts (explore 3–5, remix 3; user
  count always wins).
- The edge-case warning (quantity far outside a reasonable range — 1 or 100 — warn, don't
  block) is documented.
- The sample-data requirement (empty / unbounded (100+) / long-text, shipped with every
  explore round, not a separate step) is documented.
- The graduation target path is exact: `Features/<Feature>/presentation/<View>/<View>View.swift`
  + `presentation/<View>/components/<Component>/` (ALVA-reconciled path, not the flat
  `Features/<Feature>/<View>/` path from the pre-ALVA v2.0 draft).
- The scratch-archive mechanism is documented: `scratchs/<Component-or-View>.swift`,
  compilable + previewable, out of the Xcode target, manual/agent-assisted cleanup only.
- Just-vibes posture documented: auto-select-and-graduate from the explore round (no remix
  round — no one to state taste preferences to), `[auto]`-marked, rationale recorded.
- The retired-skills note is present: `prototype`/`html-to-swiftui`/`visual-grounding` never
  shipped and are fully superseded; `figma-to-swiftui` stays parked, not routed through this loop.
- Skill frontmatter (name/description/license/metadata) matches the shape of sibling skills
  (e.g. `align-ui/SKILL.md`).

## UI states
happy (explore/remix rounds produce working previews) · empty (no components/snippets exist
yet for a novel screen — generates freeform, lower-confidence, may suggest ingestion first) ·
in-flight (n/a, single-pass generation) · error/offline (nothing liked from either round — ask
for fresh direction, regenerate explore, don't force a remix from unwanted parts)

## Notes
Source: `specs/prototype-first-workflow.md` v2.0 §2 (mechanics), §3 (approval/graduation), §4
(skill inventory), §5 (deliberate exclusion — no cross-engine grounding), §7 (worked example),
§8 (empty/edge states). Graduation path reconciled per `specs/alva-adoption.md` §1/§2 (per-view
component nesting inside `presentation/<View>/`, not a flat `Features/<Feature>/Components/`).
