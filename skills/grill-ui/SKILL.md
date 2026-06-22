---
name: grill-ui
description: Pre-implementation UI alignment gate. Grills the user branch-by-branch on every visual and interaction decision for a screen before any SwiftUI code is written. Produces a ui-alignment doc that task-execution loads as implementation ground truth.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "1.0.0"
---

# Grill UI — Pre-implementation UI Alignment

Runs before any SwiftUI View task is implemented. The spec defines *what* the screen does;
this skill aligns *how* it looks and behaves — resolving every UI decision with the user before
a single line of SwiftUI is written.

**Invocation:** automatic gate inside `task-execution` when a task is UI-scoped. Never manual.
**Skipped:** under `/akios:just-vibes` (unattended — the agent decides and records rationale).

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
