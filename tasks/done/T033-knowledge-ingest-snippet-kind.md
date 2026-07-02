---
id: T033
spec: specs/snippet-library.md
est_tokens: 9k
runner: orchestrator
parallel: false
area: knowledge-ingest-snippet-kind
checkpoint: 20
---

# T033 — `knowledge-ingest` + `/akios:learn` gain `kind: snippet`

> **State:** done

## Description
Extend the pack format `knowledge-ingest` already implements with the second asset kind
`snippet-library.md` defines: literal, copy-and-adapt Swift code alongside the existing prose
`kind: reference`. Implements §2 (pack extension, `snippets/` sibling dir), §3 (copy-and-adapt
consumption model — distillation skipped for snippets), §4 (bundle shape — always a folder, even
for a single file, `usage.md` mandatory), §5 (`target:` field vocabulary), §6 (`/akios:learn
--kind snippet` ingestion behavior), and §9's snippet-specific edge states.

## Files
- `skills/knowledge-ingest/SKILL.md`
- `commands/learn.md`

## Definition of Done
- Pack format section gains `snippets/<name>/` as a sibling of `references/` in the directory
  tree, with the bundle shape from §4: one or more `.swift` files + mandatory `usage.md`, always
  a folder (never a bare file), matching the tree in `snippet-library.md` §4 exactly.
- New `kind: snippet` row/behavior documented in the routing table: unlike `kind: reference`,
  ingestion **skips distillation** — source file(s) are copied verbatim into
  `snippets/<derived-name>/`, and a **draft** `INDEX.md` row + stub `usage.md` are written (name,
  tags guessed from path/filename) for the user to fill in before confirming.
- `target:` field documented: each snippet's `usage.md` (or an `INDEX.md` row field) declares
  `Foundation/Design-tokens` (shared, visual, copied once) or `Features/<F>/data|domain`
  (feature-local, copied fresh per feature) — per `snippet-library.md` §5. Note this is a
  human decision at registration time, not a mutation of the ALVA usage-ledger's promotion rules.
- Same propose-before-live confirm gate reused (no new gate invented) — a snippet never goes
  live without the existing observe → confirm → append step; under `just-vibes`, auto-adopt with
  rationale journaled, same as any other ingestion.
- Provenance handling extended: `pack.yml` records source path + ingestion date for a snippet
  same as a reference; `sources/` remains optional.
- Edge states added: an ingested source that isn't valid/parseable Swift declines the entry
  rather than writing a broken file into `snippets/`; a declared `target:` folder that doesn't
  exist yet in the consuming project is created at copy time (cross-referenced to
  `task-execution`'s copy step, T034).
- `commands/learn.md`'s invocation line gains `--kind <reference|snippet>` (default `reference`,
  preserving today's behavior when the flag is omitted).
- `scripts/install-skills.sh` needs **no change** — `knowledge-ingest` is already registered;
  this task only extends an existing skill's behavior, confirmed by inspection.

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/snippet-library.md` §2–§6, §9. Working pack name `ios-factory` is provisional
(spec's own wording) — do not hardcode it as anything more than an example in the docs. No
content population (`~/.claude/akios/knowledge/ios-factory/`) — mechanism only, per the spec's
own `> State: designed — mechanism only` note and §10.
