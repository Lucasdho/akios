---
id: T072
spec: specs/akios-footprint-consolidation.md
est_tokens: 14k
runner: subagent
parallel: false
area: repo-root-migration
checkpoint: 41
---

# T072 [major] — Self-migrate this repo's own root into `akios/`

> **State:** todo

## Description
This repo (akios itself) dogfoods its own conventions — `Context.md`, `Roadmap.md`, `Vision.md`,
`workflow.yml`, `specs/`, `tasks/` currently live at repo root, same as any pre-consolidation
consumer repo. **User-confirmed scope decision** (via `AskUserQuestion` in the session that drafted
this backlog): this repo migrates too, not just the templates it ships to consumers. Sequenced
**last of the mechanical tasks** (after T058–T071 already point every instruction file at the new
`akios/` paths) specifically to minimize the window where this repo's own `/akios:plan`/
`/akios:deliver` would be internally inconsistent with itself.

This repo has **no root `CLAUDE.md`** (relies on the user's global `~/.claude/CLAUDE.md`) and
**no existing `.akios/` directory** — both are no-ops for this specific migration, skip them
rather than erroring on a missing source.

## Files
- `Context.md` → `akios/Context.md`
- `Roadmap.md` → `akios/Roadmap.md`
- `Vision.md` → `akios/Vision.md`
- `workflow.yml` → `akios/workflow.yml`
- `specs/` → `akios/specs/`
- `tasks/` → `akios/tasks/` (all four state subfolders + `handoffs/`)
- `.gitignore` (add `akios/.local/` line; no `.akios/` line exists to remove/rename here)

## Definition of Done
- `Context.md`, `Roadmap.md`, `Vision.md`, `workflow.yml` moved to `akios/` using `git mv` (or
  moved + re-added) so history follows the file; `specs/` and `tasks/` moved wholesale (git
  history preserved per-file).
- Each move verified landed before proceeding to the next: source gone, destination present and
  non-empty — reusing `init-reliability-and-ux.md`'s §2–§4 verify-after-action discipline (retry
  once on a confirmed miss, stop-and-report an itemized manifest on a second failure), per spec
  §8 step 3.
- `.gitignore` gains an `akios/.local/` line (pre-emptively, for future runtime-journal writes);
  no `.akios/` line existed here to rename, confirmed no-op.
- No root `CLAUDE.md` existed to update its `@Context.md` import — confirmed no-op, not an error.
- Every file this backlog already rewrote (T058–T071) that pointed at the *old* root paths
  (`specs/`, `tasks/`, `Context.md`, `Roadmap.md`, `Vision.md`, `workflow.yml`) now correctly
  resolves against the new `akios/`-nested location — i.e. this repo's own commands/skills work
  against its own new layout immediately after this task lands.
- `git status` after the move shows renames (not delete+add pairs that lose history) for every
  moved file.
- `find . -maxdepth 1 -name "Context.md" -o -maxdepth 1 -name "Roadmap.md" -o -maxdepth 1 -name "Vision.md" -o -maxdepth 1 -name "workflow.yml" -o -maxdepth 1 -name "specs" -o -maxdepth 1 -name "tasks"`
  (run from repo root) returns nothing — confirms none of the six survive at the old root
  location.
- `ls akios/` shows `Context.md, Roadmap.md, Vision.md, workflow.yml, specs/, tasks/` all present.

## UI states
N/A

## Notes
Source: `specs/akios-footprint-consolidation.md` §3 (D3 tree), §8 (D8 migration discipline,
reused here even though this is a first-party migration not a consumer-repo one), the
`AskUserQuestion` decision recorded in `tasks/handoffs/footprint-consolidation-plan.md`
("Self-migrate this repo too"). **Highest blast-radius task in this backlog** — this repo's own
tooling depends on the paths being moved to keep functioning; do this task in one uninterrupted
pass, don't leave it half-moved across a context boundary. `tasks/handoffs/` itself moves as part
of `tasks/` → `akios/tasks/` — this very task file will live at
`akios/tasks/done/T072-repo-root-self-migration.md` once archived.
