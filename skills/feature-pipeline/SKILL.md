---
name: feature-pipeline
description: >-
  Workflow orchestrator for taking a raw feature idea all the way to working, reviewed code, in any
  language or stack. Use whenever a user has a new feature idea and needs a structured path from
  concept to implementation. Triggers include: "I want to add X", "let's build this feature",
  "new feature: ...", or any request to implement something non-trivial. This skill does NOT write
  code itself — it reads workflow.yml and routes you through the phases in order.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "5.0.0"
---

# Feature Pipeline — Idea to Working Code

The entry point for "I want to build X." It does **not** define the phases — **`workflow.yml`
is the single source of truth** (the machine-readable contract: each phase's command, skill,
prereqs, outputs). This skill is the *conduct*: it reads `workflow.yml`, figures out where you
are, and walks you through the phases in order, handing off the right artifact between them.

**Spine (from `workflow.yml`):** `brainstorm → plan → deliver`

> Bootstrap first: if the repo isn't initialized (`AGENTS.md` + `workflow.yml` + the folder
> tree), run `/akios:setup` — it is **not** a phase (see `workflow.yml` `bootstrap`).

## How to route
1. **Read `workflow.yml`.** It defines the phases and their prereqs/outputs.
2. **Detect the current phase per spec** — the highest phase whose `outputs` already exist for
   the relevant spec — and read the **mode** + per-spec status from `akios/Roadmap.md`.
3. **Soft gate:** if a phase's `prereqs` are missing, don't hard-block — say what's missing and
   **offer** to run the prerequisite phase. Never auto-fire the interactive `brainstorm` phase.
4. **Hand off** the named output of one phase as the input of the next (spec → tasks → code).

## Non-negotiable rules
1. **Phase 1 (brainstorm) is always interactive.** Never automate or skip it — the user must be present.
2. **Hand-offs follow `workflow.yml` outputs:** spec path → `spec-to-tasks`; `akios/tasks/todo/` → `task-execution`.
3. **Subagents start cold and are opt-in.** When `task-execution` dispatches one, its prompt must
   carry the slice it needs (task + DoD + the project's test command). Execution must never
   *depend* on subagents — an environment can deny them the project's build tool.
4. **Never write to git** — no commit, no branch, no push, in any phase. Deliver ends with changed
   files in the working tree and a report; the user owns their history.
5. **Stay in the current phase.** The anti-drift discipline — WHAT is not HOW, and route a
   mid-phase build need instead of executing it inline — lives in the installed `AGENTS.md`
   (**"Staying in flow"**). Read it there; it is not restated here.
6. **Never assume a stack.** Build, test, and lint invocations come from `akios/Context.md`
   `## Commands`; the pipeline itself is language-agnostic.

## What belongs in a subagent prompt (when one is dispatched)
- [ ] The specific task id + its DoD
- [ ] The relevant spec file(s)
- [ ] The project's build/test command from `akios/Context.md`
- [ ] Any `akios/Context.md` gotcha matching this task type
