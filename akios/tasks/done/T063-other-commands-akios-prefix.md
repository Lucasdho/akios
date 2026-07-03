---
id: T063
spec: specs/akios-footprint-consolidation.md
est_tokens: 6k
runner: orchestrator
parallel: true
area: commands/other
checkpoint: 37
---

# T063 — Other 10 `commands/*.md`: `akios/` path rewrite

> **State:** todo

## Description
Sweep every `commands/*.md` file other than `setup.md` (T061/T062) for the same `akios/` prefix
rewrite — each is a thin wrapper that references `specs/`, `tasks/`, `Roadmap.md`, etc. when
telling the reader where its skill reads from or writes to.

## Files
- `commands/brainstorm.md`
- `commands/deep-brainstorm.md`
- `commands/just-vibes.md`
- `commands/deliver.md`
- `commands/design.md`
- `commands/handoff.md`
- `commands/review.md`
- `commands/new-skill.md`
- `commands/learn.md`
- `commands/plan.md`

## Definition of Done
- Every `specs/`, `tasks/`, `Context.md`, `Roadmap.md`, `Vision.md`, `workflow.yml` path literal
  in the 10 files above gains the `akios/` prefix.
- `CLAUDE.md`/`AGENTS.md`/`.claude/` references (if any) are unchanged.
- `grep -l -E "specs/|tasks/|Context\.md|Roadmap\.md|Vision\.md|workflow\.yml" commands/brainstorm.md commands/deep-brainstorm.md commands/just-vibes.md commands/deliver.md commands/design.md commands/handoff.md commands/review.md commands/new-skill.md commands/learn.md commands/plan.md`
  followed by a manual check confirms every surviving match is already `akios/`-prefixed.

## UI states
N/A

## Notes
Source: `specs/akios-footprint-consolidation.md` §3, §13. Mechanical — no design judgment
needed, unlike T062. File list confirmed by grep against the current repo (10 files, not the
handoff draft's earlier estimate of 9 — `commands/setup.md` is excluded, handled separately by
T061/T062).
