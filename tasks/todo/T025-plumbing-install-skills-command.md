---
id: T025
spec: specs/ui-overhaul-implementation.md
est_tokens: 5k
runner: orchestrator
parallel: false
area: plumbing
checkpoint: 14
---

# T025 — Plumbing: `install-skills.sh` + `commands/design.md` wrapper

> **State:** todo

## Description
Register the new `ui-variations` skill in the installer array (not the three retired skills —
they were never built), and add a command wrapper for the `design` phase, matching the pattern
of `commands/plan.md` / `commands/execute.md`.

## Files
- `scripts/install-skills.sh`
- `commands/design.md` (new)

## Definition of Done
- `scripts/install-skills.sh`'s `SKILLS=(...)` array includes `ui-variations` (and `align-ui` is
  already present from before — confirm, don't duplicate).
- `commands/design.md` exists, mirrors `commands/plan.md`/`commands/execute.md`'s shape: soft
  guard on `design`'s `workflow.yml` prereqs, loads `ui-variations` (+ `align-ui` for the
  states/interactions/heuristics side), states the hand-off (a graduated screen → `execute`).

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/prototype-first-workflow.md` v2.0 §9 open item ("install-skills.sh: SKILLS=(...)
array gains ui-variations only"). `ui-overhaul-implementation.md` §6.1/§6.2.
