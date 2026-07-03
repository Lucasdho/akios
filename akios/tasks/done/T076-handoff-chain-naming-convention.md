---
id: T076
spec: akios/specs/subagent-context-chaining.md
est_tokens: 2k
runner: orchestrator
parallel: true
area: skills/handoff/SKILL.md
checkpoint: 1
---

# T076 — Register the chain-handoff naming convention in handoff/SKILL.md

> **State:** todo

## Description
`subagent-context-chaining.md` §4/§7 reuses `skills/handoff/SKILL.md`'s handoff format as-is,
but names a specific file for chain-internal handoffs:
`akios/tasks/handoffs/subagent-<spec-slug>-<link-number>.md` (e.g.
`subagent-alva-adoption-2.md`), written whenever a chain link crosses the 120k lineage budget.
Register this naming/location convention in `skills/handoff/SKILL.md`'s "Output format" section,
alongside the existing `<topic>.md` / `<topic>-return.md` patterns, and note that writing one at
the budget line is mandatory for a chained batch (not situational, unlike the general-purpose
handoff).

## Files
- `skills/handoff/SKILL.md`

## Definition of Done
- "Output format" documents the `subagent-<spec-slug>-<link-number>.md` filename pattern next to
  the existing `<topic>` / `<topic>-return.md` patterns, with the example from the spec
  (`subagent-alva-adoption-2.md`).
- States that this handoff is mandatory at the 120k lineage budget for a chained batch, per
  `subagent-context-chaining.md` §4.
- No existing content in "What to include" / "What NOT to include" / the two format templates
  was altered — this task only adds the naming convention.
- `grep -n "subagent-context-chaining\|subagent-<spec-slug>" skills/handoff/SKILL.md` returns a
  match.

## UI states
N/A — plugin-docs repo, no Swift/UI here (see `akios/Context.md` gotchas).

## Notes
No swift-dev routing applies (plugin-docs task). DoD verification = inspection + grep, not a
test suite, per `akios/Context.md`.
