---
id: T064
spec: specs/akios-footprint-consolidation.md
est_tokens: 9k
runner: orchestrator
parallel: true
area: skills/planning
checkpoint: 38
---

# T064 — Skills `idea-to-spec` + `spec-to-tasks`: `akios/` path rewrite

> **State:** todo

## Description
These two skills are the `brainstorm` and `plan` phase owners — both read/write `specs/` and
`tasks/todo/` directly and reference `Roadmap.md` status transitions. Rewrite every path literal
to the `akios/`-prefixed form.

## Files
- `skills/idea-to-spec/SKILL.md`
- `skills/spec-to-tasks/SKILL.md`

## Definition of Done
- Every `specs/`, `tasks/todo/`, `Roadmap.md`, `Context.md`, `Vision.md` path literal in both
  files gains the `akios/` prefix.
- `spec-to-tasks`'s references to `templates/task.md`'s frontmatter format stay consistent with
  T060's updated `templates/task.md` (`spec: akios/specs/{{spec}}.md`).
- `grep -n "specs/\|tasks/\|Context\.md\|Roadmap\.md\|Vision\.md" skills/idea-to-spec/SKILL.md skills/spec-to-tasks/SKILL.md`
  shows only `akios/`-prefixed forms.

## UI states
N/A

## Notes
Source: `specs/akios-footprint-consolidation.md` §3, §13. Mechanical rewrite.
