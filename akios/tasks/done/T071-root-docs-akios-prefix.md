---
id: T071
spec: specs/akios-footprint-consolidation.md
est_tokens: 6k
runner: orchestrator
parallel: false
area: root-docs
checkpoint: 40
---

# T071 — Root docs: `README.md`, `START-HERE.md`, `docs/architecture/plugin-architecture.{md,html,mmd}`

> **State:** todo

## Description
The human-facing onboarding docs and the architecture audit (added by the immediately-prior
commit, `0f75544`) both reference the old root-level housekeeping paths. Rewrite all references
to the `akios/`-prefixed form so a new reader isn't oriented against a stale folder tree.

## Files
- `README.md`
- `START-HERE.md`
- `docs/architecture/plugin-architecture.md`
- `docs/architecture/plugin-architecture.mmd`
- `docs/architecture/plugin-architecture.html`

## Definition of Done
- Every `specs/`, `tasks/`, `Context.md`, `Roadmap.md`, `Vision.md`, `workflow.yml` path literal
  in the 5 files above gains the `akios/` prefix.
- Any folder-tree diagram or artifact-map illustration in `README.md`, `START-HERE.md`, or the
  architecture doc's Mermaid diagram (`.mmd`, and its rendered `.md`/`.html` counterparts) matches
  spec §9's after-state (`CLAUDE.md`, `AGENTS.md`, `akios/`, ALVA scaffold, `.claude/`).
- `grep -n "specs/\|tasks/\|Context\.md\|Roadmap\.md\|Vision\.md\|workflow\.yml" README.md START-HERE.md docs/architecture/plugin-architecture.md docs/architecture/plugin-architecture.mmd docs/architecture/plugin-architecture.html`
  shows only `akios/`-prefixed forms.

## UI states
N/A

## Notes
Source: `specs/akios-footprint-consolidation.md` §3, §9 (before/after tree — the exact target
state for any diagram in these docs). The architecture doc set (`.md`/`.mmd`/`.html`) was
generated together in commit `0f75544` (2026-07-02) — keep all three variants in sync rather than
editing only the `.md` source.
