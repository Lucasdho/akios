---
name: align-ui
description: Pre-implementation UI alignment gate. Walks the user decision-by-decision through every visual and interaction choice for a screen before any SwiftUI code is written. Produces a ui-alignment doc that task-execution loads as implementation ground truth.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "1.0.0"
---

# Align UI — Pre-implementation UI Alignment

Runs before any SwiftUI View task is implemented. The spec defines *what* the screen does;
this skill aligns *how* it looks and behaves — resolving every UI decision with the user before
a single line of SwiftUI is written.

**Invocation:** automatic gate inside `task-execution` when a task is UI-scoped. Never manual.
**Auto-decide under `/akios:just-vibes`:** the gate itself never skips — only the interactive
grilling does. Unattended, the agent decides every question itself and records rationale (see
"Just-vibes posture" below).

## Input

- The spec file for the feature being built
- The task file for the UI task about to start

Read both before opening the first question. Seed the decision tree from the spec's screen
description, data shape, and any existing UI patterns found in the codebase.

## The decision tree (resolve in this order)

Dependencies flow top-down. Never ask about components before layout is settled.

```
1. Structure & navigation
   └── 2. Layout & visual hierarchy
         └── 3. Key components
               └── 4. Interactions & gestures
                     └── 5. States (empty / loading / error / success)
                           └── 6. Animation & feedback
```

Branches within a level may be independent — resolve them in parallel only when there is
genuinely no dependency between them. When in doubt, go sequentially.

## Conduct

- **`Foundation/Design-tokens/` is the visual leaf source.** Before proposing a color, spacing
  value, type style, or reusable component, check what already exists there — recommend from it
  rather than inventing a new literal. A recommendation that introduces a hardcoded literal where
  a Design-tokens equivalent exists (or should be promoted, per the usage ledger) gets flagged in
  the alignment doc rather than silently implemented — either reuse the token or note it as a new
  candidate the component will seed.
- **One question at a time.** Never ask two things in one turn.
- **Lead with your recommendation.** For every question, state what you'd implement and why
  (one sentence, grounded in HIG or existing app patterns). Then ask the user to confirm,
  adjust, or override.
- **Don't accept vague answers.** If the user says "keep it simple" or "the usual way",
  rephrase into a concrete choice and ask again: "By 'simple' — do you mean a plain List
  with swipe actions, or a flat scroll with no row separators?"
- **Walk down each branch fully** before moving to the next. If layout opens a sub-question
  about components, answer it before returning to the next layout question.
- **Resolve dependencies first.** If question B depends on the answer to A, A goes first —
  even if B feels more urgent.
- **Flag HIG conflicts.** If the user's direction diverges from platform convention, name
  it: "This deviates from HIG's expected pattern for X — worth noting for App Review."
  Then implement their direction anyway.

## Nielsen heuristics checklist (design-phase backbone)

Fired for every screen this gate touches — a static `ui-variations` preview can't express
interaction/flow completeness, so `align-ui` is where these get resolved:

| Heuristic | Concrete check |
|---|---|
| Visibility of system status | loading / progress / refresh states exist (not a frozen screen) |
| Match system & real world | domain language in copy; SF Symbols that mean what they show |
| User control & freedom | back / cancel / undo paths; non-trapping flows; `.sheet` dismissal |
| Consistency & standards | native components + `DesignSystem` tokens (no bespoke one-offs) |
| Error prevention | destructive actions confirmed; `.sheet(item:)` from payload state (not `Bool`+data) |
| Recognition over recall | no hidden gestures without an affordance; visible options |
| Flexibility & efficiency | sensible defaults; shortcuts (swipe actions, `Menu`) where they help |
| Aesthetic & minimalist | the restraint rule — cross-refs `swiftui-design-principles` Core Philosophy |
| Help users with errors | plain-language error states with a recovery action |
| Help & documentation | empty-state guidance where a screen needs orientation |

Walk this table after the decision tree's "States" branch — it's the acceptance bar for that
branch, not a separate pass.

## Native-over-custom flag

Before or alongside recommending a component, check: **did this try the native control first?**
A hand-rolled toggle, a `GeometryReader` progress bar where `Gauge` fits, a custom divider where
`Divider()` works — these get flagged, not silently accepted. A justified exception carries a
one-line comment at the component (`// custom: native <X> can't do <Y>`); an unjustified one is a
finding in the alignment doc, fired **twice**: once during the `ui-variations` explore round
review, and again at the post-wiring check below (the two moments a custom control tends to
sneak past review).

## Post-wiring check (absorbed from the retired `visual-grounding` skill)

After `execute`'s make-it-live stage wires the real ViewModel and pulls real data, `align-ui`
runs one more check: does the **real-data render** still hold up against the **mock-data-
approved** `ui-variations` graduate? (E.g. the mock tested a 100-player roster — does the real
150-player roster still look right? Does real long-text still truncate the way the sample data
suggested it would?)

This is a **same-engine, same-code check** — the graduated screen and the wired screen are the
same SwiftUI, just with real data behind it — not the cross-engine diff `visual-grounding` used
to run against an HTML/Figma reference (that skill is retired; the *problem* it solved doesn't
exist anymore since there's no second medium to diff against). A divergence here is a normal
`execute`-phase fix, not a re-triggered design-phase approval cycle.

## Completion criterion

The grilling ends when every branch of the tree has a concrete, unambiguous answer —
not when a checklist is ticked. If an answer is still fuzzy after two follow-ups, mark it
as a **risk** in the alignment doc and continue; don't block on it.

## Output

Write `tasks/ui-alignment/<ScreenName>.md` before task-execution begins the implementation.

```markdown
# UI Alignment — <ScreenName>

> Spec: specs/<spec-name>.md
> Task: tasks/in-progress/<task-name>.md
> Date: YYYY-MM-DD

## Structure & Navigation
- [decision and rationale]

## Layout & Visual Hierarchy
- [decision and rationale]

## Key Components
- [decision and rationale]

## Interactions & Gestures
- [decision and rationale]

## States
- Empty: [description]
- Loading: [description]
- Error: [description]
- Success / normal: [description]

## Animation & Feedback
- [decision and rationale]

## Open Risks
- [anything still fuzzy, marked explicitly]

## HIG Deviations
- [any user-directed departures from platform convention]
```

Task-execution loads this file as the highest-priority reference for the UI task —
it overrides any pattern from `swift-dev` or `code-references/` for visual decisions.

## Just-vibes posture (gate skipped)

When running unattended, skip the grilling loop entirely. Instead:

1. Read the spec and codebase for existing UI patterns.
2. Apply HIG defaults for every decision not specified in the spec.
3. Write the same `tasks/ui-alignment/<ScreenName>.md` — marking every auto-decided item
   as `[auto]` so the user can review and override post-run.
4. Record any genuine ambiguity as an open risk, not a silent choice.
