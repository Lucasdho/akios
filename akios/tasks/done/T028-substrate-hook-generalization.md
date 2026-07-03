---
id: T028
spec: specs/knowledge-architecture.md
est_tokens: 8k
runner: orchestrator
parallel: false
area: substrate-hooks
checkpoint: 16
---

# T028 — Substrate hooks generalize: `pack:<domain>` tagging in spec-to-tasks + task-execution

> **State:** done

## Description
Generalize the two named substrate hooks per `knowledge-architecture.md` §1's table: `spec-to-
tasks` tags each task with a `pack:<domain>` (defaulting to `pack:ios` when the repo is Swift,
alongside the existing `swift_dev:` sub-skill tag which remains the *ios pack's* realization of
that tag) and `task-execution`'s "load the task's swift-dev domain sub-skill by scope" widens to
"load the task's pack reference by scope" (still concretely `swift-dev`'s guide when the pack is
`ios`). No behavior changes for a Swift-only repo — the widening only matters once a second pack
exists.

## Files
- `skills/spec-to-tasks/SKILL.md` (step 9, the swift-dev domain-tagging step)
- `skills/task-execution/SKILL.md` (the task lifecycle's "load the task's swift-dev domain
  sub-skill by scope" line)

## Definition of Done
- `spec-to-tasks/SKILL.md`'s tagging step states a task carries a `pack:<domain>` tag (default
  `pack:ios` for Swift repos) in addition to its `swift_dev:` sub-skill — the sub-skill is the
  `ios` pack's concrete guide reference, not a separate mechanism.
- `task-execution/SKILL.md`'s lifecycle step is reworded to "load the task's pack reference by
  scope (the `ios` pack's realization is `swift-dev`'s bundled guide; a non-`ios` pack loads its
  own `INDEX.md`-selected reference)."
- Neither file's existing Swift-specific behavior changes for a repo with only the `ios` pack —
  `grep -n "pack:ios"` in both files confirms the default is stated explicitly.

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/knowledge-architecture.md` §1 (D1) table. Parallel with T029 conceptually but
touches different files than it — sequenced same checkpoint (16) for atomicity of the "substrate
hooks" concept, not parallel-tagged since both edits land together in one narrative.
