---
name: ios-feature-pipeline
description: Workflow orchestrator for taking a raw iOS feature idea all the way to working, reviewed code. Use whenever a user has a new feature idea for an iOS app and needs a structured path from concept to implementation. Triggers include: "I want to add X to the app", "let's build this feature", "new feature: ...", or any request to implement something non-trivial in a Swift/SwiftUI codebase. This skill does NOT write code itself — it routes you through the right tools in the right order.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "2.0.0"
---

# iOS Feature Pipeline — Idea to Working Code

A 3-phase orchestrator for turning a raw iOS feature idea into implemented, tested, reviewed
code. Each phase uses one skill. This skill says which skill, in what order, and what to hand
off between phases.

> **This skill is the canonical definition of the kit's idea→ship workflow spine.** Other
> surfaces (the `ios-agentic-kit` skill, the project `AGENTS.md`) summarize it and point here —
> edit the spine here, not there.

**Spine at a glance:** `idea-to-spec → spec-to-tasks → task-execution → verify + /code-review`

> **v2 — speckit dropped.** Earlier versions ran speckit (clarify/specify/plan/tasks) +
> a constitution between design and execution. That re-did rigor the kit already has — design
> happens decision-by-decision in `idea-to-spec`; quality is enforced by the gates in
> `AGENTS.md` + axiom + ponytail + `/code-review`. The four speckit phases collapsed into one
> `spec-to-tasks` pass. No `.specify/`, no constitution.

## Non-negotiable rules
1. **Phase 1 is always interactive.** Never automate or skip it — the user must be present.
2. **Hand-off 1→2:** the spec file path from `idea-to-spec` is the input to `spec-to-tasks`.
3. **Hand-off 2→3:** the `tasks.md` from `spec-to-tasks` is the sole input to `task-execution`.
4. **Subagents start cold and are opt-in.** When `task-execution` dispatches one, its prompt must
   include the task's Axiom domain skill (tagged in `tasks.md`) plus `ponytail` if installed.
   Execution must never *depend* on subagents — this environment can deny them `xcodebuild`.
5. **No push/merge without the human gate** at the end of Phase 3.

## The 3-phase pipeline

| # | Phase | Tool | Mode | Produces |
|---|---|---|---|---|
| 1 | Design | `/idea-to-spec` (`/akios:define`) | **Interactive — user present** | `specs/<feature>.md` |
| 2 | Plan | `spec-to-tasks` (`/akios:plan`) | One pass, one confirm | `tasks.md` |
| 3 | Execute | `task-execution` (`/akios:deliver`) | Branch, checkpoints, verify+review | Implemented, reviewed feature |

### Phase-by-phase

**Phase 1 — Design (`idea-to-spec`).** Run interactively. Don't proceed until the user has
approved a spec written to `specs/<feature>.md`. That path feeds Phase 2.

**Phase 2 — Plan (`spec-to-tasks`).** One pass: spec + `Context.md` + `MEMORY.md` → atomic tasks
with `[P]` parallel markers, checkpoint barriers, definitions of done, and per-task UI-state
coverage (happy/empty/loading/error). One human confirm of the task graph, then write `tasks.md`.
See the `spec-to-tasks` skill for the full pass and the `tasks.md` format. No speckit artefacts.

**Phase 3 — Execute (`task-execution`).** Branch per spec; run checkpoint by checkpoint; commit at
each barrier; run the unit + integration battery at `[major]` checkpoints; compress context only
between specs; verify + `/code-review`; then stop at the hard human gate (push? merge where?). See
the `task-execution` skill for the full loop. Axiom routing for subagent dispatch lives in
`spec-to-tasks` (each task is pre-tagged with its domain skill).

## What belongs in a subagent prompt (when one is dispatched)
- [ ] The task's Axiom domain skill (already tagged on the task in `tasks.md`)
- [ ] `ponytail`, if installed (optional, recommended)
- [ ] The specific task id + its DoD
- [ ] The relevant spec file(s)
- [ ] Any `Context.md` gotcha matching this task type
