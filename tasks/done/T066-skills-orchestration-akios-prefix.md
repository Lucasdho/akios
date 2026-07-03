---
id: T066
spec: specs/akios-footprint-consolidation.md
est_tokens: 12k
runner: orchestrator
parallel: true
area: skills/orchestration
checkpoint: 38
---

# T066 — Skills `just-vibes` + `deep-brainstorm`: `akios/` path rewrite

> **State:** todo

## Description
`just-vibes` drives the whole spine unattended and writes its journal to the runtime dir —
per spec §5 (D5) that journal path renames from `.akios/just-vibes-journal.md` to
`akios/.local/just-vibes-journal.md`. `deep-brainstorm` reads/writes `specs/` and `Roadmap.md`
for whole-app mapping. Rewrite both.

## Files
- `skills/just-vibes/SKILL.md`
- `skills/deep-brainstorm/SKILL.md`

## Definition of Done
- `skills/just-vibes/SKILL.md`'s journal path reference changes from `.akios/just-vibes-journal.md`
  to `akios/.local/just-vibes-journal.md`, matching spec §5 (D5)'s rename.
- Every other `specs/`, `tasks/`, `Roadmap.md`, `Vision.md`, `Context.md` path literal in both
  files gains the `akios/` prefix.
- `grep -n "\.akios/\|specs/\|tasks/\|Roadmap\.md\|Vision\.md\|Context\.md" skills/just-vibes/SKILL.md skills/deep-brainstorm/SKILL.md`
  shows zero bare `.akios/` survivors and only `akios/`-prefixed forms elsewhere.

## UI states
N/A

## Notes
Source: `specs/akios-footprint-consolidation.md` §3, §5 (D5 — the journal rename is the one
semantic change here, not just a prefix add). `just-vibes` is the highest-traffic reader of the
journal path — verify this one carefully since a stale `.akios/` reference here would silently
write to the wrong (old, now-nonexistent-post-T072) directory.
