---
description: Turn an approved spec into a task backlog (pipeline Phases 2-5, speckit clarify-specify-plan-tasks).
disable-model-invocation: true
---

# /akios:plan — Spec-to-tasks (pipeline Phases 2-5)

**Guard.** Confirm this repo is initialized (`AGENTS.md` + `.claude/.agentic-kit-version`
present). If not, STOP and point the user at `/akios:init` first.

**Run.** Load the `ios-feature-pipeline` skill (single source of truth — do not
re-document the phases) and execute **Phases 2-5** against the spec:

- Phase 2 — Clarify (`/speckit-clarify`), Phase 3 — Specify (`/speckit-specify`),
  Phase 4 — Plan (`/speckit-plan`), Phase 5 — Tasks (`/speckit-tasks`).
- **Speckit precheck:** if `.specify/` is absent, follow the skill's **degraded path**
  (`superpowers:brainstorming` + `superpowers:writing-plans` → `tasks.md`) instead.
- **Constitution precheck:** if `.specify/memory/constitution.md` is missing before
  Phase 4, run `/speckit-constitution` first.

Spec path or text (pass as `$ARGUMENTS` to Phase 2): `$ARGUMENTS`

Stop when `tasks.md` exists. Tell the user it's ready and that `/akios:deliver <tasks.md>`
ships it.
