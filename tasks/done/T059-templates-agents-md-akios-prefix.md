---
id: T059
spec: specs/akios-footprint-consolidation.md
est_tokens: 10k
runner: orchestrator
parallel: true
area: templates/AGENTS
checkpoint: 36
---

# T059 — `templates/AGENTS.md`: artifact-map path rewrite + `akios/` vs `~/.claude/akios/` disambiguation

> **State:** todo

## Description
`templates/AGENTS.md`'s "Where things live (artifact map)" table is the canonical lookup a
consumer repo's agent reads for artifact locations — every row currently pointing at
`specs/`, `tasks/<state>/`, `Context.md`, `Roadmap.md`, `Vision.md`, `workflow.yml` gets the
`akios/` prefix per spec §3 (D3). `CLAUDE.md`/`AGENTS.md`/`Path rules`/`Hooks` rows (external-tool
or `.claude/`-owned) are unchanged. Also resolves spec §13's low-priority open item: add a
one-line disambiguation note distinguishing this repo-local `akios/` folder from the pre-existing,
unrelated `~/.claude/akios/` (user-global preferences/skeletons home) so a reader doesn't conflate
the two.

## Files
- `templates/AGENTS.md`

## Definition of Done
- The artifact-map table's rows for `Spec state`, `Product vision`, `Specs`, `Tasks`, `Archived
  specs`, `Code references`, `Skill trace + run journal` all show `akios/`-prefixed locations
  (`akios/Roadmap.md`, `akios/Vision.md`, `akios/specs/`, `akios/tasks/<state>/`, `akios/archive/`,
  `akios/code-references/`, `akios/.local/`).
- The "Skill trace + run journal" row's location changes from `.akios/` to `akios/.local/`,
  matching spec §5 (D5)'s rename.
- Rows for `Operating files`, `Phase contract`, `User preferences`, `Path rules`, `Hooks`,
  `Instance claims` are unchanged (root-level or `.claude/`-owned, per §1/§4).
- A one-line note (near the artifact-map table or the `User preferences` row) disambiguates
  repo-local `akios/` from the global `~/.claude/akios/` — per spec §13's low-priority open item.
- Any other `specs/`/`tasks/`/`Context.md`/`Roadmap.md`/`Vision.md`/`workflow.yml` reference
  elsewhere in the file (e.g. "Specs & Roadmap" section, "Full feature workflow" section) also
  gets the `akios/` prefix.
- `grep -n "specs/\|tasks/\|Context\.md\|Roadmap\.md\|Vision\.md\|workflow\.yml" templates/AGENTS.md`
  shows only `akios/`-prefixed forms.

## UI states
N/A

## Notes
Source: `specs/akios-footprint-consolidation.md` §3, §13 (last open bullet). This file is the
single largest reference surface outside `commands/setup.md` — read it in full before editing,
several sections (priority chain, artifact map, "Specs & Roadmap") reference these paths.
