---
description: Explore, remix, and graduate a screen's SwiftUI variations (pipeline Phase 3, ui-variations + align-ui).
disable-model-invocation: true
---

# /akios:design — Design (workflow.yml: design)

**Guard (soft).** Confirm the repo is initialized and the `design` phase's `prereqs` from
`workflow.yml` exist (`tasks/todo/*.md`). If the backlog is missing, **don't hard-block** — say
so and **offer** to run `/akios:plan` first. `design` only applies to UI-scoped tasks (View,
Screen, SwiftUI, layout) — a non-UI task (domain/data/contract) skips this phase entirely and
goes straight to `/akios:execute`.

**Run.** Load the `ui-variations` skill (single source of truth for the loop — don't
re-document it) and run it against the UI-scoped task at hand:

- **Explore round** — 3–5 named `#Preview`s (user-specified count wins), built from existing
  `Foundation/Design-tokens/` tokens and components, each paired with sample data covering
  empty / unbounded / long-text edge cases.
- **Remix round** — 3 named hybrids combining the liked elements (skip if nothing was liked;
  regenerate explore instead).
- **Graduate** the approved variation directly into
  `Features/<Feature>/presentation/<View>/<View>View.swift` + `components/`; archive the rest,
  compiling and previewable, to `scratchs/<Component-or-View>.swift`.

Then load `align-ui` to resolve what a static preview can't express: states / interactions /
navigation, the JIT DTO shape, the 10 Nielsen heuristics checklist, and the native-over-custom
flag. Write `tasks/ui-alignment/<ScreenName>.md`.

**Just-vibes posture:** auto-select-and-graduate from the explore round (no remix round), every
auto-decision marked `[auto]` with rationale recorded.

**Posture override (optional).** A `--learning` or `--delivery` flag in `$ARGUMENTS` overrides
`Roadmap.md`'s `posture` for this session only (doesn't rewrite the Roadmap value); absent, use
the Roadmap default. See `align-ui`'s "Posture (learning vs. delivery)".

Task or spec (pass as `$ARGUMENTS`): `$ARGUMENTS`

Stop when the screen is graduated and the alignment doc exists. Tell the user `/akios:execute`
wires it up next.
