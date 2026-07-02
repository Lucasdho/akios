---
id: T042
spec: specs/operating-modes.md
est_tokens: 9k
runner: orchestrator
parallel: false
area: posture-flag-plumbing
checkpoint: 26
---

# T042 — `posture: learning | delivery` — the third `Roadmap.md` flag

> **State:** done

## Description
Ship the flag itself (`operating-modes.md` §1, D1): a third orthogonal `Roadmap.md` field beside
`mode` and `collaboration`, set at `/akios:init` and overridable per session without rewriting
the Roadmap default. Also documents the closed teaching-surface (§2) as a house behavior in
`AGENTS.md` so every phase skill has one place to read what posture actually changes.

## Files
- `templates/Roadmap.md` (new `## Posture` section + `posture:` line, mirrors `## Collaboration`)
- `Roadmap.md` (this repo's own — `posture: delivery`, dogfooding the same flag)
- `workflow.yml` (new `posture: [learning, delivery]` enum beside `modes`/`collaboration`)
- `commands/init.md` (interview step 1 gains the Posture question; materialize table's
  `Roadmap.md` row; self-check confirms the value is present)
- `templates/AGENTS.md` (new "Operating posture" section — the §2 teaching-surface table + the
  just-vibes Lessons-section pointer)

## Definition of Done
- `templates/Roadmap.md` has a `## Posture` section with `posture: {{learning | delivery}}` and a
  comment stating the default (`delivery`), the per-session-override rule (doesn't rewrite the
  line), and orthogonality to `mode`/`collaboration`.
- `Roadmap.md` (root) has `posture: delivery` set, matching the template's default.
- `workflow.yml` declares `posture: [learning, delivery]` with the same doc-comment shape as
  `collaboration`.
- `commands/init.md` step 1 asks the Posture question; the materialize table's `Roadmap.md` row
  mentions filling `posture:`; step 5's self-check lists `posture:` alongside `mode:`/`collaboration:`.
- `templates/AGENTS.md` has an "Operating posture" section reproducing the closed teaching-surface
  table (decision annotation, principle citation, alternatives shown, capture eagerness,
  end-of-unit digest, pace/checkpoints) and states posture changes communication/capture only,
  never what's built.
- `grep -n "posture:" templates/Roadmap.md Roadmap.md workflow.yml commands/init.md` all hit.

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/operating-modes.md` §1 (D1), §2 (D2), §8 first CONSEQUENCE. Threading the flag
through each phase skill's actual behavior (D3), the just-vibes journal Lessons section (D4), and
session-override *parsing* are T043 — this task is the flag + its documentation only.
