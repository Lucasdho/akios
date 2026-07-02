---
id: T052
spec: specs/collaboration-autonomy.md
est_tokens: 9k
runner: orchestrator
parallel: false
area: autonomy-flag-plumbing
checkpoint: 32
---

# T052 — `autonomy: manual | auto` — the 4th `Roadmap.md` flag

> **State:** todo

## Description
Ship the flag itself (`collaboration-autonomy.md` §1, D1): a fourth orthogonal `Roadmap.md`
field beside `mode`, `collaboration`, `posture` — set at `/akios:init` and overridable per
session/run without rewriting the Roadmap default. Documents the flag's independence from
`collaboration` (§2, D2) in `AGENTS.md` so a reader has one place to see both flags' combined
behavior.

## Files
- `templates/Roadmap.md` (new `## Autonomy` section + `autonomy:` line, mirrors `## Posture`)
- `Roadmap.md` (this repo's own — `autonomy: manual`, dogfooding the flag; matches this arc's
  actual lived behavior per the spec's §7 worked example)
- `workflow.yml` (new `autonomy: [manual, auto]` enum beside `collaboration`/`posture`)
- `commands/init.md` (interview step 1 gains the Autonomy question; materialize table's
  `Roadmap.md` row; self-check confirms the value is present)
- `templates/AGENTS.md` (short "Delivery autonomy" pointer section near "Working alongside
  teammates" — the D2 combination table + a one-line summary of what `manual`/`auto` each do)

## Definition of Done
- `templates/Roadmap.md` has an `## Autonomy` section with `autonomy: {{manual | auto}}` and a
  comment stating the default (`manual`), the per-run-override rule (doesn't rewrite the line),
  and its independence from `collaboration` (not inferred from it).
- `Roadmap.md` (root) has `autonomy: manual` set.
- `workflow.yml` declares `autonomy: [manual, auto]` with the same doc-comment shape as
  `collaboration`/`posture`.
- `commands/init.md` step 1 asks the Autonomy question; the materialize table's `Roadmap.md` row
  mentions filling `autonomy:`; step 5's self-check lists `autonomy:` alongside
  `mode:`/`collaboration:`/`posture:`.
- `templates/AGENTS.md` has a short section stating `autonomy` answers "is unattended delivery
  authorized," independent of `collaboration`'s "who else works here," with the four-combination
  summary from `collaboration-autonomy.md` §2.
- `grep -n "autonomy:" templates/Roadmap.md Roadmap.md workflow.yml commands/init.md` all hit.

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/collaboration-autonomy.md` §1 (D1), §2 (D2), §11 first three CONSEQUENCEs.
Threading the flag through `just-vibes`'s DELIVER gate and `task-execution`'s Finish gate (§3, §4,
§5, §6) is T053 — this task is the flag + its documentation only.
