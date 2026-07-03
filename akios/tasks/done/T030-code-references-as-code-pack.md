---
id: T030
spec: specs/knowledge-architecture.md
est_tokens: 6k
runner: orchestrator
parallel: true
area: code-pack-reframe
checkpoint: 17
---

# T030 — `code-references/` reframed as the project's code pack

> **State:** done

## Description
Reframe `code-references/` (the user-uploaded `.swift` + `INDEX.md` mechanism) as "the
project's auto-built code pack" — same INDEX-gated loading discipline, new framing, so it reads
as tier 2 of the widened priority chain (T027) rather than a bespoke one-off mechanism. Per
`knowledge-architecture.md` §4, `code-references/` is the "code" row of the ingestion source
table — already the pattern the `knowledge-ingest` skill (T031) generalizes.

## Files
- `skills/task-execution/SKILL.md` (priority-chain reference — code-references framing)
- `skills/idea-to-spec/SKILL.md` (any mention of code-references as a source)

## Definition of Done
- `task-execution/SKILL.md`'s "priority chain" section (or wherever it names
  `code-references/`) now describes it as "the project's code pack" alongside its existing
  INDEX-tag-matching description — not a rewrite, a one-line reframing.
- No change to the actual loading mechanism (INDEX-gated, load only the matching file) — this
  task is framing only, per `knowledge-architecture.md`'s own decision that packs reuse the
  `code-references` shape rather than replacing it.

## UI states
N/A (docs-only repo)

## Notes
Parallel with T029 — different files. Source: `specs/knowledge-architecture.md` §1 (D1 table)
and §4 ("code-references/ is now the project's code pack").
