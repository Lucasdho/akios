---
description: Implement and ship from the task backlog (pipeline Phase 3, task-execution + verify + code-review).
disable-model-invocation: true
---

# /akios:execute — Execute (workflow.yml: execute)

**Guard (soft).** Confirm the repo is initialized and the `execute` phase's `prereqs` from
`workflow.yml` exist (`tasks/todo/*.md`). If the backlog is missing, **don't hard-block** — say so
and **offer** to run `/akios:plan` first.

**Run.** Load the `task-execution` skill (single source of truth — don't re-document the loop) and
run it against the backlog in `tasks/todo/`:

- Branch per spec; move each task file `todo → in-progress → review → done`; consult the priority
  chain before any pattern; write tests first (light bar for pure UI); commit at each checkpoint
  barrier after the DoDs are met.
- **Runner routing** from each task: `≤20k → orchestrator` (inline), `>20k → subagent`. Subagents
  are opt-in and start cold — their prompt MUST name the task's `swift-dev` domain sub-skill (plus
  `ponytail` if installed). If the subagent layer is unavailable, degrade to inline.
- Manage context (warn 110k / urgent `/compact` 135k). **Mandatory `/compact` between every spec** — never start a new spec without compacting first.
- On spec completion, archive (`archive/Archive.md` + move spec) and record durable decisions to `MEMORY.md`.
- `/verify` and `/code-review` before claiming done.
- Stop at the **hard human gate**: ask whether to push and where to merge. Never push or merge on your own.

**Posture override (optional).** A `--learning` or `--delivery` flag in `$ARGUMENTS` overrides
`Roadmap.md`'s `posture` for this session only — it does not rewrite the Roadmap value. Absent a
flag, use the Roadmap default (`delivery` if unset). See `task-execution`'s "Operating posture".

Backlog (pass as `$ARGUMENTS`): `$ARGUMENTS`  (defaults to `tasks/todo/`)
