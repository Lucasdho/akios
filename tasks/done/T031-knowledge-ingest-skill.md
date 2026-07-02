---
id: T031
spec: specs/knowledge-architecture.md
est_tokens: 24k
runner: subagent-eligible
parallel: false
area: knowledge-ingest-skill
checkpoint: 18
---

# T031 — `knowledge-ingest` skill + `/akios:learn` command

> **State:** done

## Description
Hand-author the `knowledge-ingest` skill (per the handoff decision: `skill-authoring.md`'s
dependency is soft — it builds a scaffolding *tool*, not a prerequisite for hand-authoring one
skill the way every other skill in this repo was authored). Owns ingestion steps 1–5 from
`knowledge-architecture.md` §4: extract (source-typed, `oss-first`-routed to `pdf`/
`pdf-reading`/`docx`/multimodal), distill into `references/*.md` (one concern per file), index +
tag (`INDEX.md` + `pack.yml` `domain_tags`/`triggers`), propose-and-confirm (never auto-adopt
attended; auto-adopt with journaled rationale under `just-vibes`), retain provenance
(`sources/` + `pack.yml` provenance list).

## Files
- `skills/knowledge-ingest/SKILL.md` (new)
- `commands/learn.md` (new — thin wrapper)
- `scripts/install-skills.sh` (add `knowledge-ingest` to the `SKILLS=()` array)

## Definition of Done
- SKILL.md documents the pack directory shape (`knowledge/<pack-name>/{pack.yml, INDEX.md,
  references/*.md, skills/, sources/}`) matching `knowledge-architecture.md` §2 exactly.
- Each source type (code / PDF-book / image-screenshot / `.md`-docs / a skill) is routed to the
  correct extraction tool per §4's table — code → the `code-references` path, PDF/book → `pdf`/
  `pdf-reading`, image → multimodal read, `.md` → direct/re-distill, a skill → placed under the
  pack's `skills/`.
- The propose-confirm discipline is documented: attended runs show the drafted INDEX + one
  sample reference and wait for confirmation before the pack goes live; under `just-vibes` the
  pack is auto-adopted with rationale journaled (mirrors align-ui/ui-variations auto-approval).
- Provenance retention documented: `pack.yml`'s `provenance:` list + `sources/` folder, so a pack
  can be re-distilled later.
- `commands/learn.md` exists: `/akios:learn <source> [--pack <name>] [--global]`, thin wrapper
  loading `knowledge-ingest`, matching the shape of other command wrappers (soft guard, load
  skill, state hand-off).
- `scripts/install-skills.sh`'s `SKILLS=()` array includes `knowledge-ingest`.
- No verbatim source dumping: SKILL.md explicitly states distillation is mandatory, raw material
  stays in `sources/`, never copied wholesale into a disclosed reference.

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/knowledge-architecture.md` §4 (D3 — ingestion pipeline), §5 (D5 — skill+command).
`skill-authoring.md`'s "DEPENDS ON" note (§9) is treated as soft per this session's handoff
decision — hand-authored directly, same as every other skill in this repo predating
`skill-authoring.md`.
