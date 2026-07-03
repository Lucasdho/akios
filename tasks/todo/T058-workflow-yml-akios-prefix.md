---
id: T058
spec: specs/akios-footprint-consolidation.md
est_tokens: 4k
runner: orchestrator
parallel: true
area: workflow-contract
checkpoint: 36
---

# T058 — `workflow.yml`: `akios/` prefix on `bootstrap.creates` + phase `prereqs`/`outputs`

> **State:** todo

## Description
`workflow.yml` is the machine-readable phase contract commands and phase detection parse
directly — it must lead the rewrite, not follow it. Per spec §3 (D3) and §13, every path literal
under the "akios housekeeping" category (`specs/`, `tasks/`, `Context.md`, `Roadmap.md`,
`Vision.md`, `workflow.yml` itself as a self-reference if present) gets the `akios/` prefix in
`bootstrap.creates` and in each phase's `prereqs`/`outputs` lists. External-tool-contract paths
(`CLAUDE.md`, `AGENTS.md`, `.claude/`) and ALVA scaffold paths are untouched (§1, §4, §6).

## Files
- `workflow.yml`

## Definition of Done
- Every `specs/`, `tasks/`, `Context.md`, `Roadmap.md`, `Vision.md` path literal in
  `bootstrap.creates` and all phase `prereqs`/`outputs` gains the `akios/` prefix
  (`akios/specs/`, `akios/tasks/todo/`, `akios/Context.md`, `akios/Roadmap.md`, `akios/Vision.md`).
- `CLAUDE.md`, `AGENTS.md`, `.claude/` path literals are unchanged.
- `python3 -c "import yaml, sys; yaml.safe_load(open(sys.argv[1]))" workflow.yml` still parses
  as valid YAML after the edit.
- `grep -n "prereqs\|outputs\|creates" workflow.yml` shows only `akios/`-prefixed housekeeping
  paths, no bare `specs/`/`tasks/`/`Context.md`/`Roadmap.md`/`Vision.md` survivors.

## UI states
N/A (docs/plugin repo, no screens)

## Notes
Source: `specs/akios-footprint-consolidation.md` §3 (D3 tree), §13 first consequence bullet.
This is the contract file every command reads — land it first in the checkpoint group so
downstream tasks (T059–T073) reference a `workflow.yml` that already agrees with the new shape.
