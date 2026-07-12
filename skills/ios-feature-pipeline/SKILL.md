---
name: ios-feature-pipeline
description: >-
  Workflow orchestrator for taking a raw iOS feature idea all the way to working, reviewed code.
  Use whenever a user has a new feature idea for an iOS app and needs a structured path from
  concept to implementation. Triggers include: "I want to add X to the app", "let's build this
  feature", "new feature: ...", or any request to implement something non-trivial in a
  Swift/SwiftUI codebase. This skill does NOT write code itself — it reads akios/workflow.yml and
  routes you through the phases in order.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "3.0.0"
---

> **Scope: akios-exclusive.** This skill is the akios workflow orchestrator — it reads
> `akios/workflow.yml` and routes through akios phases. It is not intended to operate standalone.
> The anti-drift rules (§ "Staying in flow") are generic and may be extracted separately in the future.

# iOS Feature Pipeline — Idea to Working Code

The entry point for "I want to build X." It does **not** define the phases — **`akios/workflow.yml`
is the single source of truth** (the machine-readable contract: each phase's command, skill,
prereqs, outputs). This skill is the *conduct*: it reads `akios/workflow.yml`, figures out where you
are, and walks you through the phases in order, handing off the right artifact between them.

> For *what the kit installs, how routing/priority works, and how to set it up*, see
> `ios-agentic-kit` (the kit's self-knowledge). This skill is only the runtime conduct.

**Spine (from `akios/workflow.yml`):** `brainstorm → plan → design → deliver`

Each phase's command, skill, prereqs, and outputs live in **`akios/workflow.yml`** — this skill
reads them at runtime.
`design` runs between `plan` and `deliver` and fires only for UI-scoped work; non-UI tasks
skip it and go straight from `plan` to `deliver` — the mechanics are the `design` phase's comment in
`akios/workflow.yml`.

> Bootstrap first: if the repo isn't initialized (`AGENTS.md` + `akios/workflow.yml` + the folder
> tree), run `/akios:setup` — it is **not** a phase (see `akios/workflow.yml` `bootstrap`).

## How to route
1. **Read `akios/workflow.yml`.** It defines the phases and their prereqs/outputs.
2. **Detect the current phase per spec** — the highest phase whose `outputs` already exist for
   the relevant spec — and read the **mode** + per-spec status from `akios/Roadmap.md`.
3. **Soft gate:** if a phase's `prereqs` are missing, don't hard-block — say what's missing and
   **offer** to run the prerequisite phase. Never auto-fire the interactive `brainstorm` phase.
4. **Hand off** the named output of one phase as the input of the next (spec → tasks → code).

## Non-negotiable rules
1. **Phase 1 (brainstorm) is always interactive.** Never automate or skip it — the user must be present.
2. **Hand-offs follow `akios/workflow.yml` outputs:** spec path → `spec-to-tasks`; `akios/tasks/todo/` → `task-execution`.
3. **Subagents start cold and are opt-in.** When `task-execution` dispatches one, its prompt must
   include the task's `swift-dev` domain sub-skill plus `ponytail` if installed. Execution must
   never *depend* on subagents — this environment can deny them `xcodebuild`.
4. **No push/merge without the human gate** at the end of deliver.
5. **Stay in the current phase.** A phase ends only at its hand-off artifact (spec → tasks → reviewed
   code). Don't run the next phase's work early — no app code or data files during brainstorm or plan.

## Staying in flow (anti-drift)
The pipeline's most common failure is the agent **jumping out of the current phase or spec** when a
concrete build instruction surfaces mid-design — e.g. during brainstorm the user says "just create the
seed data / 5 teams / that model" and the agent starts hand-writing files, skipping plan and deliver,
often folding a *different* domain into the spec in flight.

Two rules close that gap:

- **WHAT is not HOW.** A mid-phase instruction to build something ("create X", "add Y") names a
  *what*; it does **not** authorize skipping to execution. Stay in the phase you're in.
- **When a build need surfaces mid-phase, STOP and route it — don't execute it inline.** Reflex:
  1. **Name** it: "that's an implementation/data task, not part of this design phase."
  2. **Classify scope:** does it belong to the *current* spec, or is it a *distinct domain*?
     A different domain (its own data, its own DoD) is its **own spec** — register it in
     `akios/Roadmap.md`, don't silently absorb it into the spec in flight.
  3. **Route:** if it's a true blocker, finish the current spec's design, then run that need
     through its own `brainstorm → plan → deliver`. If not a blocker, note it and stay on task.
  4. Only *then*, when you're legitimately in deliver for the right spec, write code or data.

If you catch yourself already mid-drift (writing files in a design phase), name the error, stop,
and re-route. Recovering is cheap; shipping the wrong thing in the wrong spec is not.

## What belongs in a subagent prompt (when one is dispatched)
- [ ] The task's `swift-dev` domain sub-skill (tagged on the task in `akios/tasks/todo/`)
- [ ] `ponytail`, if installed (optional)
- [ ] The specific task id + its DoD
- [ ] The relevant spec file(s)
- [ ] Any `akios/Context.md` gotcha matching this task type
