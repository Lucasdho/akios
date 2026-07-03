---
id: T036
spec: specs/skeleton-library.md
est_tokens: 12k
runner: orchestrator
parallel: false
area: init-skeleton-selection
checkpoint: 22
---

# T036 — `/akios:init` gains the greenfield skeleton-selection flow

> **State:** done

## Description
Layer `skeleton-library.md`'s architecture-keyed skeleton selection onto `commands/init.md`'s
existing fresh-repo flow, without overwriting or duplicating the ALVA scaffold logic Session 1
already wrote (T009+T010, commit `b53a03d`). Implements §3 (D2 — gated on `mode: new` only),
§4 (D3/D3b — folds into the existing "Architecture" interview question, doesn't add a second),
§5 (D6 — copy the skeleton's tree before the Scan step and before Materialize writes
`Context.md`), and §6 (a skeleton never ships akios's own meta files).

## Files
- `commands/init.md`

## Definition of Done
- **Step 1 (Interview), Mode question:** immediately after `Mode` resolves to `new`, the flow
  lists the distinct `architecture:` tags found across `~/.claude/akios/skeletons/*/manifest.yml`
  plus an explicit "none / default scaffold" option. If exactly one skeleton matches the chosen
  tag, it's used directly; if more than one (variants), a second, narrower pick by `name` runs.
  If **zero skeletons are registered anywhere**, this question is skipped entirely and the
  existing free-text "Architecture" question runs unchanged (documented as a zero-regression
  case).
- **Existing "Architecture" interview question is not duplicated.** The doc states explicitly
  that the chosen skeleton's `description:` + `stack:` pre-fill that existing question's answer
  (still user-editable) — no second, parallel question is added.
- **Copy-before-scan ordering.** A new instruction states: if a skeleton is chosen, its file tree
  is copied into the repo root **before** step 2 (Scan) runs and before step 3 (Materialize)
  writes `Context.md`/`AGENTS.md`/etc. — so the scan sees real files, not an empty repo.
- **Gate confirmed explicit.** The doc states this entire step runs **only** when `mode: new` —
  never for `feature`/`one-shot`, and never on a migrate-path re-run (`init.md` §0's "Recorded <
  installed" branch) — cross-referencing why (repo already has code; a whole-tree copy there
  risks clobbering existing files).
- **Meta-file boundary preserved.** A skeleton's tree never includes `AGENTS.md`, `Context.md`,
  `Roadmap.md`, `Vision.md`, or `.claude/` — those always come from step 3's templates, applied
  after the skeleton copy. This does not change step 3's existing skip-if-exists rules for those
  files; it only clarifies a skeleton itself never supplies them.
- **Self-check (step 5/6) gains one more line:** confirm no skeleton-sourced file overwrote
  `AGENTS.md`/`Context.md`/`Roadmap.md`/`Vision.md`/`.claude/`.
- **Does not touch or duplicate** the existing ALVA scaffold instructions (`Router/ Container/
  Foundation/{Design-tokens,Code-tokens}/ scratchs/`, `usage-ledger.json`) already in step 3 —
  those stand as Session 1 wrote them; a chosen skeleton's own tree may itself contain an ALVA
  shape (per its `architecture: alva` tag), but the plugin's own scaffold step is unconditional
  either way (skip-if-exists already covers the overlap case).

## UI states
N/A (docs-only repo; `/akios:init` is a CLI onboarding flow, not a SwiftUI screen)

## Notes
Source: `specs/skeleton-library.md` §3 (D2), §4 (D3/D3b), §5 (D6), §6, §7 (worked example), §8
(edge states). No ingestion path is designed for skeletons in this pass (§11's explicit "OPEN —
flagged, not resolved" item) — `~/.claude/akios/skeletons/<name>/` is hand-assembled manual work,
same posture as content curation. Mechanism only; no skeleton content is populated.
