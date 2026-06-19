---
description: Implement and ship from a task backlog (pipeline Phase 3, task-execution + verify + code-review).
disable-model-invocation: true
---

# /akios:deliver — Execute (pipeline Phase 3)

**Guard.** Confirm this repo is initialized (`AGENTS.md` + `.claude/.agentic-kit-version`
present). If not, STOP and point the user at `/akios:init` first.

**Run.** Load the `task-execution` skill (single source of truth — do not re-document the
loop) and run it against the backlog:

- Branch per spec, execute checkpoint by checkpoint, commit at each barrier, run the test
  battery at `[major]` checkpoints. Subagents are opt-in — when dispatched, the context block
  MUST name the task's axiom domain skill plus `ponytail` if installed (subagents start cold).
- Verify (`superpowers:verification-before-completion`) and `/code-review` before claiming done.
- Stop at the hard human gate: ask whether to push and where to merge. Never push or merge
  on your own.

Task backlog (pass as `$ARGUMENTS`): `$ARGUMENTS`  (defaults to `tasks.md`)
