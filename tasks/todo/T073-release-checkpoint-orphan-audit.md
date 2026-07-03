---
id: T073
spec: specs/akios-footprint-consolidation.md
est_tokens: 5k
runner: orchestrator
parallel: false
area: release
checkpoint: 42
---

# T073 [major] — Release checkpoint: orphan-reference grep audit, VERSION bump, CHANGELOG entry

> **State:** todo

## Description
Final checkpoint (CP7) closing this backlog. A full-repo grep audit confirming no live
instruction file still points at a pre-`akios/` path, then the standard version-bump ritual
(`VERSION` + `CHANGELOG.md` + `.claude-plugin/plugin.json` per the plugin-version-bump rule).
Historical files (`tasks/done/**`, existing `specs/*.md` prose predating this migration) are
**deliberately excluded** from the rewrite — same treatment as `CHANGELOG.md`'s own past entries
— confirmed as a judgment call to the user during the planning session, not itself spec-mandated.

## Files
- `VERSION`
- `CHANGELOG.md`
- `.claude-plugin/plugin.json`
- `akios/Roadmap.md` (flip `akios-footprint-consolidation.md`'s status to `done`)

## Definition of Done
- Full-repo grep for orphaned pre-migration path literals outside the deliberately-excluded
  historical set: `grep -rn "^specs/\|[^i]specs/\|(^|[^a])tasks/\|Context\.md\|Roadmap\.md\|Vision\.md\|workflow\.yml" --include=*.md --include=*.sh --include=*.yml . | grep -v "akios/" | grep -v "^./akios/tasks/done/" | grep -v "^./akios/specs/"`
  (or equivalent) turns up zero survivors — every non-historical reference already carries the
  `akios/` prefix from T058–T072.
- `.akios/` (the old runtime-journal name) has zero remaining references anywhere in a live
  instruction file (commands/skills/templates/scripts) — all point at `akios/.local/`.
- `VERSION` bumped (minor, per semver — this is a structural/breaking change to the plugin's own
  footprint, not a patch).
- `CHANGELOG.md` gets a new entry describing the `akios/` folder consolidation (both the
  templates-for-consumers change and this repo's own self-migration).
- `.claude-plugin/plugin.json` version bumped in the same commit as `VERSION`/`CHANGELOG.md` —
  per the standing plugin-version-bump rule (marketplace reads the remote manifest).
- `akios/Roadmap.md`'s row for `akios-footprint-consolidation.md` flips from `designed` to `done`.
- `akios/Roadmap.md`'s row for `init-reliability-and-ux.md` (already annotated "§5 superseded")
  is left as-is — no further edit needed, the supersession note already exists.

## UI states
N/A

## Notes
Source: `specs/akios-footprint-consolidation.md` §12 (Roadmap/backlog placement), §13 (open/next
recap — everything there is now closed by T058–T072, except the two explicitly-deferred
low-priority items already resolved inline by T059's disambiguation note). This is the barrier
task for CP7 — run the audit *before* the version bump, not after, so a survivor found here still
blocks the release rather than shipping alongside it.
