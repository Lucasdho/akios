---
id: T026
spec: specs/ui-overhaul-implementation.md
est_tokens: 4k
runner: orchestrator
parallel: false
area: release-checkpoint
checkpoint: 15
---

# T026 — UI-overhaul release checkpoint: Roadmap flips (version bump deferred)

> **State:** todo

## Description
`ui-overhaul-implementation.md` §6.4 calls for a version/CHANGELOG/plugin.json bump. **Per the
approved 3-session v0.8.0 plan, that bump is deferred to the final session's closeout** — this
task is the audit-only release checkpoint: flip every Roadmap row this backlog closes, and
confirm every T012–T025 DoD is still green before moving to `knowledge-architecture.md`.

## Files
- `Roadmap.md`

## Definition of Done
- `Roadmap.md` rows flipped `designed → done`: `prototype-first-workflow.md`,
  `swiftui-design-doctrine.md`, `ui-overhaul-implementation.md` (`planned → done`).
- `ui-first-architecture.md`'s row is **left as `designed`** — it is explicitly not a source
  spec for this backlog (its §1/§2 are superseded, its §3–§8 laws already live inside
  `alva-adoption.md`'s reconciled tree); no independent build closes it, so it is not flipped
  here as a side effect.
- Every task T012–T025's DoD re-verified green (spot-check via grep per each task's own DoD).
- Commit message notes explicitly: version/CHANGELOG/plugin.json bump is deferred to the
  v0.8.0 closeout session, per the standing `feedback_plugin_version_bump` rule (bump happens
  once, at the end, not per-spec).

## UI states
N/A (docs-only repo)

## Notes
[major] checkpoint — this is the vertical-slice completion point for the whole
`ui-overhaul-implementation.md` spec. Mirrors Session 1's T011 pattern exactly.
