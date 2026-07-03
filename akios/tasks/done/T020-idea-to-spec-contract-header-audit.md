---
id: T020
spec: specs/ui-overhaul-implementation.md
est_tokens: 2k
runner: orchestrator
parallel: true
area: idea-to-spec-audit
checkpoint: 11
---

# T020 — `idea-to-spec` / `Feature-spec.md` contract header — audit only (satisfied by T006)

> **State:** done

## Description
`ui-overhaul-implementation.md` §3.6's DoD is identical in substance to `alva-adoption.md`
§7.6, already shipped as Session 1's T006 (`skills/idea-to-spec/references/spec-format.md` "get
a contract/Foundation header" section + `SKILL.md` line 171). Audit-only: confirm the DoD is
still met, no new work.

## Files
None — audit only.

## Definition of Done
- `skills/idea-to-spec/references/spec-format.md` still has the "Feature specs get a
  contract/Foundation header (ALVA)" section (Exports/Consumes bullets).
- `skills/idea-to-spec/SKILL.md` still references it (re-verified against T006's own DoD).
- Confirmed: no file changed by this task.

## UI states
N/A (docs-only repo)

## Notes
Parallel with T015/T016/T017/T018/T019 — audit only, touches no files. [major] checkpoint —
this closes Phase 3, the whole "reshape existing pipeline skills" block; audit every task above
before the checkpoint commit.
