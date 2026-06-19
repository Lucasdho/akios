---
name: ios-feature-pipeline
description: Workflow orchestrator for taking a raw iOS feature idea all the way to working, reviewed code. Use whenever a user has a new feature idea for an iOS app and needs a structured path from concept to implementation. Triggers include: "I want to add X to the app", "let's build this feature", "new feature: ...", or any request to implement something non-trivial in a Swift/SwiftUI codebase. This skill does NOT write code itself — it routes you through the right tools in the right order.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "1.0.0"
---

# iOS Feature Pipeline — Idea to Working Code

A 6-phase orchestrator for turning a raw iOS feature idea into implemented, tested, reviewed code. Each phase uses a specific tool. This skill tells you which tool, in what order, and what to hand off between phases.

> **This skill is the canonical definition of the kit's idea→ship workflow spine.** Other surfaces (the `ios-agentic-kit` skill, the project `AGENTS.md`) summarize it and point here — edit the spine here, not there.

**Spine at a glance:** `idea-to-spec → speckit (clarify→specify→plan→tasks) → subagent-driven-development → verify + /code-review`

## Non-negotiable rules

1. **Phase 1 is always interactive.** Never automate or skip it. The user must be present.
2. **Hand-off 1→2:** the spec text or file path produced by `idea-to-spec` becomes `$ARGUMENTS` for `speckit-clarify`.
3. **Hand-off 5→6:** `tasks.md` from `speckit-tasks` is the plan input for `subagent-driven-development`.
4. **Subagents start cold.** Every dispatch must include the correct Axiom domain skill (see table below) — no exceptions — plus `ponytail` if it's installed (optional, recommended).
5. **Speckit prerequisite:** phases 2–5 require `.specify/` to exist. If absent, use the degraded path (see below).
6. **Constitution check:** if `.specify/memory/constitution.md` does not exist before phase 4, run `/speckit-constitution` first — Axiom gates are baked in at the plan phase.

## The 6-phase pipeline

| # | Phase | Tool | Mode | What it produces |
|---|---|---|---|---|
| 1 | Design | `/idea-to-spec` | **Interactive — user must be present** | `specs/<feature>.md` |
| 2 | Clarify | `/speckit-clarify <spec>` | Automated | Resolved ambiguities appended to spec |
| 3 | Specify | `/speckit-specify` | Automated | Structured speckit artefacts; triggers `agent-context-update` |
| 4 | Plan | `/speckit-plan` | Automated | Ranked plan with Axiom gates enforced via constitution |
| 5 | Tasks | `/speckit-tasks` | Automated | `tasks.md` — the execution backlog |
| 6 | Execute | `superpowers:subagent-driven-development` | Automated, fresh subagents | Implemented, tested feature |

### Phase-by-phase instructions

**Phase 1 — Design (`/idea-to-spec`)**
Run this interactively with the user. Do not proceed until they have approved a spec and it is written to `specs/<feature>.md`. The spec file path (or its text content) is what you pass to phase 2.

**Phase 2 — Clarify (`/speckit-clarify <spec>`)**
Pass the spec path or text as `$ARGUMENTS`. This surfaces open questions and resolves ambiguity before the spec is formalized. Output stays in the spec.

**Phase 3 — Specify (`/speckit-specify`)**
Formalizes the spec into `.specify/` artefacts. The extension hook auto-triggers `speckit-agent-context-update` after this phase — let it run.

**Phase 4 — Plan (`/speckit-plan`)**
Produces the ranked implementation plan. The project constitution enforces Axiom gates here. If `.specify/memory/constitution.md` is absent, run `/speckit-constitution` first, then re-run this phase.

**Phase 5 — Tasks (`/speckit-tasks`)**
Breaks the plan into discrete tasks and writes `tasks.md`. This file is the sole input for phase 6.

**Phase 6 — Execute (`superpowers:subagent-driven-development`)**
Drive execution from `tasks.md`. Each subagent dispatch must include the Axiom domain skill for that task type (see routing table below), plus `ponytail` if installed. The subagent's context block must state the Axiom skill explicitly.

## Axiom domain skill routing (subagent context blocks)

Every subagent gets exactly the domain skill it needs — no full library, no context waste.

| Task type | Axiom skill to include |
|---|---|
| Views, SwiftUI layouts, previews | `axiom-swiftui` |
| async/await, actors, Sendable, concurrency | `axiom-concurrency` |
| Unit tests, Swift Testing, XCTest | `axiom-testing` |
| Swift language patterns, types, protocols | `axiom-swift` |
| SwiftData, CoreData, persistence, migrations | `axiom-data` |
| Build system, Xcode config, schemes, debug | `axiom-build` |

Example subagent context block:

```
Skills active for this subagent: axiom-swiftui (+ ponytail if installed)
Task: implement ProductCardView per tasks.md §3
Inputs: specs/catalog-feature.md, tasks.md
```

## Degraded path (no speckit / no `.specify/`)

If `.specify/` does not exist and you cannot run `npx speckit init`:

1. Complete phase 1 normally (`/idea-to-spec` → spec file).
2. Replace phases 2–5 with:
   - `superpowers:brainstorming` to surface open questions and design options.
   - `superpowers:writing-plans` to produce a task breakdown (save as `tasks.md`).
3. Proceed to phase 6 normally with `superpowers:subagent-driven-development` + Axiom routing.

State clearly in any handoff notes that the speckit phases were skipped and the plan is less formally gated.

## What belongs in a subagent prompt (checklist)

- [ ] Correct Axiom domain skill listed (pick from routing table above)
- [ ] `ponytail` listed too, if installed (optional, recommended)
- [ ] Reference to `tasks.md` section or specific task ID
- [ ] Reference to relevant spec file(s)
- [ ] Any project-specific gotchas from `Context.md` that apply to this task type
