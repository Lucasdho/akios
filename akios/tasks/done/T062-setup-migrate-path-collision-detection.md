---
id: T062
spec: specs/akios-footprint-consolidation.md
est_tokens: 16k
runner: subagent
parallel: false
area: commands/setup
checkpoint: 37
---

# T062 — `commands/setup.md` §0: migrate-path sequence (D8) + name-collision detection (design, not just rewrite)

> **State:** todo

## Description
Two pieces of real work, not a mechanical rewrite:

1. **Migrate-path sequence (§8/D8).** §0's "Recorded < installed" branch gains the opt-in
   migration flow: detect a pre-consolidation repo (root-level `specs/`, `tasks/`, `Context.md`
   etc., no `akios/`), **ask** (don't silently move) using spec §8 step 2's exact prompt shape,
   then on yes move file-by-file reusing `init-reliability-and-ux.md`'s §2–§4 verify-after-action
   discipline (source gone, destination present + non-empty, retry once, stop-and-report an
   itemized manifest on a second failure), updating `CLAUDE.md`'s `@Context.md` →
   `@akios/Context.md` import **last**, only after every move is confirmed. On no (or nothing
   stale): leave the repo as-is, don't re-ask except via `/akios:setup --consolidate`.
2. **Name-collision detection (design work — spec §13 explicitly leaves this undesigned).** If a
   repo already has an unrelated `akios/` directory, `/akios:setup` must detect this *before*
   writing anything and treat it like any other "file already exists and isn't ours" case in the
   materialize table (surface it, ask, never silently overwrite) — per spec §10's last bullet.
   This task's executor designs the detection + prompt, it is not pre-specified.

## Files
- `commands/setup.md` (§0 only — serializes after T061, same file)

## Definition of Done
- §0 gains a migrate-path branch matching spec §8's exact ask-then-move-then-repoint sequence,
  citing `init-reliability-and-ux.md` §2–§4 for the verification discipline rather than
  reinventing it.
- The migrate prompt text matches spec §8 step 2's content (what moves, what renames, "everything
  keeps working either way — this is cosmetic, not a functional requirement").
- `CLAUDE.md`'s import update is the last step in the sequence, gated on every prior move being
  confirmed (per §8 step 3 and §10's mid-migration-failure edge state).
- A designed (not stubbed) name-collision check: before any write, detect a pre-existing
  unrelated `akios/` at the target repo's root, surface it to the user, ask, and never silently
  overwrite — with a concrete decision path documented inline (not just "TODO: handle this").
- §10's edge states (fresh repo/already-implemented, same-version re-run, declined migration,
  mid-migration failure, name collision) are each reflected somewhere in §0's logic or its
  surrounding prose.
- `grep -n "specs/\|tasks/\|Context\.md\|Roadmap\.md\|Vision\.md\|workflow\.yml" commands/setup.md`
  (restricted to §0's line range) shows only `akios/`-prefixed forms.

## UI states
N/A

## Notes
Source: `specs/akios-footprint-consolidation.md` §8 (D8, full migrate-path decision + rejection),
§10 (edge states), §13 (name-collision flagged as open/undesigned). Higher token estimate than
T061 because of the genuine design work on collision detection — don't treat this as a
find-and-replace task. `runner: subagent` reflects real judgment work, not context size alone.
