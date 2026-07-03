---
id: T060
spec: specs/akios-footprint-consolidation.md
est_tokens: 6k
runner: orchestrator
parallel: true
area: templates/other
checkpoint: 36
---

# T060 — Remaining 7 templates: `akios/` path rewrite

> **State:** todo

## Description
Sweep the other 7 template files for the same `akios/` prefix rewrite T059 applies to
`templates/AGENTS.md`. `templates/CLAUDE.md`'s import line is the one semantic (not just
mechanical) change: `@Context.md` → `@akios/Context.md` per spec §2's stated consequence
(`@AGENTS.md` import is unchanged — `AGENTS.md` stays at root).

## Files
- `templates/CLAUDE.md`
- `templates/Context.md`
- `templates/Roadmap.md`
- `templates/Vision.md`
- `templates/spec.md`
- `templates/task.md`
- `templates/rules/swift.md`

## Definition of Done
- `templates/CLAUDE.md`'s import changes from `@Context.md` to `@akios/Context.md`; `@AGENTS.md`
  is unchanged (per spec §2).
- Any `specs/`, `tasks/`, `Roadmap.md`, `Vision.md`, `workflow.yml` path literal inside
  `templates/Context.md`, `templates/Roadmap.md`, `templates/Vision.md`, `templates/spec.md`,
  `templates/task.md`, `templates/rules/swift.md` gains the `akios/` prefix.
- `templates/task.md`'s `spec:` frontmatter placeholder (`specs/{{spec}}.md`) becomes
  `akios/specs/{{spec}}.md`.
- `grep -rn "specs/\|tasks/\|Context\.md\|Roadmap\.md\|Vision\.md\|workflow\.yml" templates/CLAUDE.md templates/Context.md templates/Roadmap.md templates/Vision.md templates/spec.md templates/task.md templates/rules/swift.md`
  shows only `akios/`-prefixed forms (or `@akios/Context.md` for the import line).

## UI states
N/A

## Notes
Source: `specs/akios-footprint-consolidation.md` §2 (D2 consequence — the one semantic edit),
§3 (D3 — the mechanical rewrite). Mostly mechanical; only `templates/CLAUDE.md`'s import line
needs care to match §2's exact wording (`@AGENTS.md` untouched).
