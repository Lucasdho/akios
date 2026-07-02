---
name: ui-variations
description: The design phase's one skill — explores multiple SwiftUI #Preview variations directly (no HTML/Figma detour), remixes liked elements, and graduates an approved winner straight into presentation/<View>/. Use when a UI-scoped task from spec-to-tasks reaches the design phase, or when a screen/component needs visual exploration before implementation. Owns the whole prototype-first loop: explore -> remix -> approve-and-graduate -> archive-losers-to-scratch.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "1.0.0"
---

# UI Variations — explore, remix, graduate

Runs inside the `design` phase (`workflow.yml`), between `plan` and `deliver`. It is the **one
skill** that owns the whole prototype-first loop introduced by `prototype-first-workflow.md`
v2.0: everything happens **directly in SwiftUI**, as named `#Preview` blocks built from what
already exists in the project (`Foundation/Design-tokens/` tokens, promoted components, and
copy-and-adapt snippets) — there is no external medium (Figma/Stitch/HTML) to translate from.

**Invocation:** automatic inside `task-execution`'s A3 build-order (components → `ui-variations`
dumb-screen → make-it-live), for any task whose scope is a `presentation/<View>/` screen or
component. Also reachable directly via `/akios:design`.

## Why no external medium

Xcode's Preview tooling renders live without a full rebuild — the exact property that made
HTML/Tailwind attractive in the retired v1.0 workflow. Routing through a second medium and
translating back no longer buys anything; it only adds a translation step and a cross-engine
rendering mismatch that had to be worked around before. SwiftUI *is* the target medium, so there
is nothing left to converge later.

## The loop

### 1. Explore round

- **Default: 3–5 named `#Preview`s**, divergent styles from one prompt (the screen's features +
  any mood/style parameters given), each a runnable variation built from existing
  components/tokens/snippets in `Foundation/Design-tokens/` and the feature's own
  `presentation/<View>/components/`.
- **User-specified count always wins.** If the user states a quantity, use it — the default only
  fires when they don't.
- **Edge-case guard, warn-don't-block:** if the requested count is far outside a reasonable range
  (e.g. 1 or 100), say so plainly — "1 defeats the anti-anchoring point of exploring at all" /
  "100 spends heavily for marginal signal" — then proceed with what was actually asked for once
  the user confirms. Never silently clamp.
- **Sample data ships with every explore round, in its own file**, covering the edge cases a
  real screen will hit: an **empty** state, **unbounded/large** data (100+ items), and
  **long-text** truncation. This is not a separate step — every variation is judged against
  real-shaped data, not best-case mocks.

### 2. Remix round

- **Default: 3 named `#Preview`s** — hybrids combining the *specific elements* the user liked
  across the explore round ("the typography from A, the layout from B"). User-specified count
  wins here too.
- If **nothing** from the explore round is liked, don't force a remix out of unwanted parts —
  ask for fresh direction in the user's own words and regenerate the explore round instead.

### 3. Approve and graduate

- The approved variation **lands directly in its final file** — no translation step, because it
  is already the target code:
  ```
  Features/<Feature>/presentation/<View>/<View>View.swift        ← next to <View>Model.swift
  Features/<Feature>/presentation/<View>/components/<Component>/  ← view-local components
  ```
  (ALVA-reconciled path — components nest **per-view**, not in a flat
  `Features/<Feature>/Components/`.)
- This *is* `alva-adoption.md`'s A3 build-order (components → dumb screen → make-it-live)
  already enforcing the order — a screen cannot enter `deliver`'s make-it-live stage until a
  variation has graduated here. No separate approval-gate mechanism exists.

### 4. Archive losers to scratch

- Everything that didn't win — the rest of the explore round, the remix losers — is archived to
  a scratch file that **still compiles and still previews**:
  `scratchs/<Component-or-View>.swift` at the project root. Nothing is silently deleted at
  approval time.
- `scratchs/` is **excluded from the Xcode target** (compilable/previewable standalone, never
  added to target membership — `Context.md` records this).
- **Cleanup is manual or agent-assisted, never automatic.** No background job prunes `scratchs/`.

## Just-vibes posture (unattended)

When running under `/akios:just-vibes`, there is no one to state taste preferences to:

1. **Auto-select-and-graduate from the explore round** — skip the remix round entirely.
2. Mark the selection `[auto]` and record the rationale (why this variation, over the others) in
   the scratch-file archive, mirroring how `align-ui` behaves unattended.
3. The user can review and override post-run, same as any other `[auto]` decision.

## Retired / parked — do not revive without a new decision

- `prototype`, `html-to-swiftui`, `visual-grounding` **never shipped** and are fully superseded
  by this skill — their planned jobs (HTML generation, translation, cross-engine diff) don't
  exist as problems anymore, since the medium is already SwiftUI.
- `figma-to-swiftui` **did ship** and stays exactly as-is, but is **not** routed through this
  loop — parked as a future optional feeder (Figma/Stitch MCP token extraction) if a later
  session decides to wire it back in. Do not add it to any routing table here.

## Handoff to `align-ui`

`ui-variations` produces the graduated, mock-data-approved screen. `align-ui` (also part of the
`design` phase) then resolves what a static preview can't express: states/interactions/
navigation, the JIT DTO shape, the 10 Nielsen heuristics checklist, and the native-over-custom
flag. After `deliver`'s make-it-live wires real data, `align-ui`'s **post-wiring check** confirms
the real-data render still holds up against the mock-data-approved graduate — a same-engine,
same-code check, not a new grounding pass.

## UI states this skill must cover per round

Every explore-round sample-data file covers: **empty** (no items) · **unbounded** (100+ items) ·
**long-text** (truncation). This is the design-phase realization of the kit-wide
happy/empty/loading/error coverage rule — loading/error are resolved by `align-ui`, not here,
since a static preview has no async lifecycle.

## Empty / edge states (of the loop itself)

- **No components/snippets exist yet for a genuinely novel screen:** still generate freeform —
  lower-confidence with nothing established to draw from. Suggest running snippet/knowledge
  ingestion first if the user wants faster convergence (future work, not blocking).
- **Extreme quantity requested (1 or 100):** warn per the explore-round guard above, then honor
  the explicit request once confirmed.
- **Nothing liked from either round:** ask for fresh direction, regenerate explore — never force
  a remix from unwanted parts.
- **`scratchs/` grows stale over many runs:** no automatic pruning — an open hygiene question for
  a future `/akios:setup` pass, not solved here.
- **Approved variation breaks once real data is wired:** handled by `align-ui`'s post-wiring
  check as a normal `deliver`-phase fix, not a re-triggered design-phase approval cycle.

## Anti-patterns

- Generating an HTML or Figma prototype and translating it — the retired v1.0 loop. Don't.
- Skipping the sample-data file, or judging a variation against best-case mock data only.
- Silently clamping an extreme explore/remix count instead of warning and proceeding.
- Deleting a losing variation instead of archiving it to `scratchs/`.
- Graduating a variation into a flat `Features/<Feature>/Components/` — components nest
  per-view, inside `presentation/<View>/components/`.
- Running a remix round unattended (just-vibes) — auto-select from explore instead.
- Adding `figma-to-swiftui` or any retired skill to this loop without a new, explicit decision.
