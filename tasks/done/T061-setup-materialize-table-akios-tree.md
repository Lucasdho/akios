---
id: T061
spec: specs/akios-footprint-consolidation.md
est_tokens: 12k
runner: orchestrator
parallel: false
area: commands/setup
checkpoint: 37
---

# T061 — `commands/setup.md` §3: materialize table + folder tree + footprint prose → `akios/` tree

> **State:** todo

## Description
`commands/setup.md` §3 ("Materialize the context files + folder tree") is the command that
produces the exact 15-top-level-item sprawl spec §9's worked example documents. Rewrite its
materialize table's destination column, the folder-tree diagram, and the surrounding footprint
prose so a fresh `/akios:setup` run produces the after-state in §9: `CLAUDE.md`, `AGENTS.md`,
`akios/`, the ALVA scaffold, `.claude/`, and the user's pre-existing `README.md` — 9 top-level
entries instead of 15.

## Files
- `commands/setup.md` (§3 only — §0's migrate-path branch is T062, same file, serializes after
  this task)

## Definition of Done
- §3's materialize table: every destination for `Context.md`, `Roadmap.md`, `Vision.md`,
  `workflow.yml`, `specs/`, `tasks/{todo,in-progress,review,done}/` gets the `akios/` prefix.
  `alva-usage-ledger.sh`'s destination (already `.claude/scripts/`, per T056) is unchanged.
  `CLAUDE.md`/`AGENTS.md`/ALVA-scaffold rows are unchanged.
- The folder-tree diagram in §3 matches spec §3 (D3)'s exact tree: `akios/` containing
  `Context.md, Roadmap.md, Vision.md, workflow.yml, specs/, tasks/{todo,in-progress,review,done}/,
  archive/, code-references/, .local/{trace.jsonl,just-vibes-journal.md}`.
- Footprint prose near §3 documents the three-way line from spec §1 (external-tool contract /
  akios housekeeping / user app source) so a future reader sees *why* only the middle category
  moved — mirroring the "why" note T056 added for the single-file move precedent.
- `grep -n "specs/\|tasks/\|Context\.md\|Roadmap\.md\|Vision\.md\|workflow\.yml" commands/setup.md`
  (restricted to §3's line range) shows only `akios/`-prefixed forms.
- A fresh `/akios:setup` walkthrough (read-through, not executed) against §3's new table would
  produce exactly the 9-item root layout in spec §9's "after" block.

## UI states
N/A

## Notes
Source: `specs/akios-footprint-consolidation.md` §3 (D3 tree), §9 (worked example, before/after).
Same file as T062 — do this task first (materialize table is upstream of the migrate-path logic
T062 touches), then let T062 serialize after.
