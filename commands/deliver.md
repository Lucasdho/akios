---
description: Implement and ship from a task backlog (pipeline Phase 6, subagent-driven dev + verify + code-review).
disable-model-invocation: true
---

# /akios:deliver — Execute (pipeline Phase 6)

**Guard.** Confirm this repo is initialized (`AGENTS.md` + `.claude/.agentic-kit-version`
present). If not, STOP and point the user at `/akios:init` first.

**Run.** Load the `ios-feature-pipeline` skill (single source of truth — do not
re-document the phases) and execute **Phase 6 — Execute**:

- Drive `superpowers:subagent-driven-development` from `tasks.md`. Every subagent context
  block MUST name the correct Axiom domain skill (see the skill's routing table) plus
  `ponytail` if installed — subagents start cold.
- Then verify (`superpowers:verification-before-completion`) and run `/code-review` before
  claiming done.

Task backlog (pass as `$ARGUMENTS`): `$ARGUMENTS`  (defaults to `tasks.md`)
