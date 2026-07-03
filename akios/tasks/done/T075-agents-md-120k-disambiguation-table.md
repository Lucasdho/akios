---
id: T075
spec: akios/specs/subagent-context-chaining.md
est_tokens: 5k
runner: orchestrator
parallel: true
area: templates/AGENTS.md
checkpoint: 1
---

# T075 — Add the 120k disambiguation table to AGENTS.md

> **State:** todo

## Description
`templates/AGENTS.md`'s "Sizing the work & subagent economy" section already states one 120k
threshold (the orchestrator's own context, the subagent-dispatch judgment call) right next to a
textually similar but distinct 110k/135k pair from `task-execution/SKILL.md`'s "Context
management." `subagent-context-chaining.md` §2 adds a **third** 120k (a subagent's own
accumulated context across a chained batch) and, because this exact area already has a
documented history of the two existing numbers being confused with each other (backlog B36's
self-audit), includes an explicit three-row disambiguation table so the new number is never
read as the same measurement as the existing one. Insert that table into `templates/AGENTS.md`,
directly after the existing "driving session is at **≥120k tokens**..." bullet in "Sizing the
work & subagent economy," with a one-line pointer to `subagent-context-chaining.md` §2 for the
full reasoning.

## Files
- `templates/AGENTS.md`

## Definition of Done
- The three-row table from `subagent-context-chaining.md` §2 (Inter-spec compact line /
  Subagent-dispatch judgment / Subagent lineage budget) is present in `templates/AGENTS.md`,
  placed after the existing dispatch-judgment bullet in "Sizing the work & subagent economy."
- A one-line pointer to `subagent-context-chaining.md` §2 accompanies the table.
- No existing threshold value (110k, 120k, 135k) in the file was changed — this task only adds
  the table, per the spec's §10 "Deliberate exclusions."
- `grep -n "subagent-context-chaining" templates/AGENTS.md` returns a match.

## UI states
N/A — plugin-docs repo, no Swift/UI here (see `akios/Context.md` gotchas).

## Notes
No swift-dev routing applies (plugin-docs task). DoD verification = inspection + grep, not a
test suite, per `akios/Context.md`.
