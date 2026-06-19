---
description: Turn an approved spec into a lean task backlog (pipeline Phase 2, spec-to-tasks).
disable-model-invocation: true
---

# /akios:plan — Spec-to-tasks (pipeline Phase 2)

**Guard.** Confirm this repo is initialized (`AGENTS.md` + `.claude/.agentic-kit-version`
present). If not, STOP and point the user at `/akios:init` first.

**Run.** Load the `spec-to-tasks` skill (single source of truth — do not re-document the
pass) and run it against the spec: one pass, one human confirm, producing `tasks.md` with
parallel `[P]` markers, checkpoint barriers, definitions of done, and per-task UI-state
coverage. No `.specify/`, no constitution, no speckit.

Spec path or text (pass as `$ARGUMENTS`): `$ARGUMENTS`

Stop when `tasks.md` exists. Tell the user it's ready and that `/akios:deliver <tasks.md>`
ships it.
