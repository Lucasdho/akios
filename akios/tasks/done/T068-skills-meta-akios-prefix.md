---
id: T068
spec: specs/akios-footprint-consolidation.md
est_tokens: 8k
runner: orchestrator
parallel: true
area: skills/meta
checkpoint: 38
---

# T068 — Skills `knowledge-ingest` + `skill-author` + `handoff`: `akios/` path rewrite

> **State:** todo

## Description
`knowledge-ingest` writes knowledge packs and may reference `Roadmap.md`/`Context.md` routing;
`skill-author` scaffolds new skills and registers them (touches `install-skills.sh`, covered
separately by T070, but may reference `specs/`/`tasks/` in its own doc); `handoff` writes
session handoff docs into `tasks/handoffs/` and reads `Roadmap.md`/`Context.md` for the
"where we are" section. Rewrite all three.

## Files
- `skills/knowledge-ingest/SKILL.md`
- `skills/skill-author/SKILL.md`
- `skills/handoff/SKILL.md`

## Definition of Done
- Every `specs/`, `tasks/`, `Roadmap.md`, `Context.md`, `Vision.md` path literal in all three
  files gains the `akios/` prefix, including `handoff`'s own output location
  (`akios/tasks/handoffs/`).
- `grep -n "specs/\|tasks/\|Roadmap\.md\|Context\.md\|Vision\.md" skills/knowledge-ingest/SKILL.md skills/skill-author/SKILL.md skills/handoff/SKILL.md`
  shows only `akios/`-prefixed forms.

## UI states
N/A

## Notes
Source: `specs/akios-footprint-consolidation.md` §3, §13. This task itself (T068) is a case in
point for `handoff`'s own output path — the handoff this backlog was drafted from lives at
`tasks/handoffs/footprint-consolidation-plan.md`; post-T072 that becomes
`akios/tasks/handoffs/`.
