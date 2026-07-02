---
name: knowledge-ingest
description: Turns raw material (code, a PDF/book, an image/screenshot, .md docs, or a skill) into a knowledge pack the pipeline can route to. Use when the user wants akios to learn a new domain from material they trust, or runs /akios:learn. Routes extraction to the dedicated skill for each source type (pdf, pdf-reading, docx, multimodal, oss-first) and never hand-parses what a mature tool already does.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "1.0.0"
---

# Knowledge Ingest — build a pack from raw material

Turns material the user already trusts (code they like, a book, a PDF, a design system, a
company's conventions) into a **knowledge pack** the substrate can route to. This is a
*maintenance* action, like `/akios:setup` — not a pipeline phase. Invocation: `/akios:learn
<source> [--pack <name>] [--global]`, or directly by description when a user wants akios to
learn a new domain.

**Authoring note:** `skill-authoring.md` (a future spec) will eventually scaffold skills/packs
generically — this skill is hand-authored directly, the same way every other skill in this repo
predates that tool. Nothing here depends on it existing.

## The pack format (what this skill produces)

```
knowledge/<pack-name>/
  pack.yml            → manifest: name, domain_tags, triggers, version, provenance, baseline: false
  INDEX.md             → one line per reference: "<file> — what it teaches [tags]" (progressive disclosure)
  references/*.md      → the distilled knowledge, one concern per file (kind: reference)
  snippets/<name>/      → OPTIONAL: literal, copy-and-adapt code (kind: snippet — see below).
                          Always a folder, even for a single-file entry: one or more `.swift`
                          files + a mandatory `usage.md`. One shape for every entry, no branching
                          between "simple" and "bundle" snippets.
  skills/               → OPTIONAL: behavior skills this pack ships
  sources/              → OPTIONAL: the raw ingested material, kept for re-distillation + audit
```

`--global` writes to `~/.claude/akios/knowledge/<pack-name>/` (user-global, survives repos)
instead of the repo-local `knowledge/<pack-name>/`.

## Routing by source type (oss-first — never hand-parse)

| Source | Extraction | Distillation |
|---|---|---|
| **Code** (a repo, files the user likes) | the `code-references` path — index the code, pull representative patterns | one reference per pattern + an INDEX row with domain tags; keep files in `sources/` |
| **PDF / book** | the `pdf` / `pdf-reading` skill → text + tables (OCR if scanned) | chunk by chapter/concept → distill each into a concept reference; cite page ranges in provenance |
| **Image / screenshot / diagram** | multimodal read (describe the artifact) | a reference capturing the described rules/structure |
| **`.md` / docs** | ingest directly | index as-is if already distilled; else re-distill to the one-concern-per-file shape |
| **A skill** | the user drops a `SKILL.md` | placed under the pack's `skills/` (a pack can ship behavior) |

Always run `oss-first` before hand-writing an extractor for a source type not listed above — a
mature tool almost certainly exists.

## `kind: snippet` — literal code, copied and adapted, not read and re-derived (B30)

Everything above produces `kind: reference` entries (prose the pipeline reads as guidance). A
second asset kind, `kind: snippet`, carries **literal, ready-to-use Swift code** — a card
component, a repository CRUD template, a use case, a gateway protocol, a design-system file —
the user has already field-tested and trusts as a starting point. Invoked with:

```
/akios:learn <file-or-folder> --pack <name> --kind snippet [--global]
```

Behavior, layered on top of the same pipeline (§ above), diverges at two points:

1. **Skips distillation.** Unlike a `kind: reference` ingest (which chunks and distills into
   prose), a snippet **copies the source file(s) verbatim** into `snippets/<derived-name>/` —
   the whole point is to preserve the field-tested original, not paraphrase it.
2. **Drafts, doesn't finalize.** Writes a **draft** `INDEX.md` row (name, tags guessed from
   path/filename) and a **stub** `usage.md` — the user fills in the adaptation notes (what to
   rename, what to wire — DI registration, Router entry, etc.) and the `target:` field before
   confirming.

Everything else is unchanged: the **same propose-before-live confirm gate** from step 4 above
(a wrong `target:` can misplace behavior into `Foundation/`, so it is never auto-adopted
attended; under `just-vibes`, auto-adopt with the rationale journaled, same as any pack). The
**same provenance retention** (`pack.yml` + optional `sources/`) applies unchanged.

**The `target:` field.** Each snippet's `usage.md` (or an `INDEX.md` row field) declares one of:
- **`Foundation/Design-tokens`** — visual, meant to be shared from day one (a card component, a
  design-system template). `task-execution` copies it once and reuses it thereafter.
- **`Features/<F>/data`** or **`.../domain`** — behavior, inherently per-feature (a repository
  template, a use case, a gateway protocol). `task-execution` copies it fresh into each feature
  that needs one, with entity names adapted per feature.

This is a **human decision made at registration time** (this confirm-before-live step) — it does
not bypass or mutate the ALVA usage-ledger's own evidence-based Foundation-promotion rules
(`task-execution`'s Foundation ledger governs everything that is **not** a registered snippet).

A snippet that isn't valid/parseable Swift (wrong path, a non-code file dropped by mistake) is
**declined** — ingestion never writes a broken file into `snippets/`.

Consumption (the copy-and-adapt-and-prune step at task time) is `task-execution`'s job, not
this skill's — see its "copy-and-adapt-and-prune" step.

## The pipeline

1. **Extract** with the source-typed tool from the table above. Never hand-parse a PDF, never
   eyeball-transcribe an image when a multimodal read does it directly.
2. **Distill** each chunk into a `references/*.md` file — **one concern per file**, written as
   guidance the pipeline can act on, not a verbatim copy of the source. A 400-page book pasted in
   defeats progressive disclosure and blows the context budget; distillation is not optional.
3. **Index + tag** — write `INDEX.md` rows (`<file> — what it teaches [tags]`) and `pack.yml`
   `domain_tags`/`triggers` so `spec-to-tasks`' `pack:<domain>` routing can find this pack.
4. **Propose, don't auto-adopt.** Show the drafted pack (INDEX + one sample reference) and ask
   the user to confirm before it goes live — the same **observe → confirm → append** discipline
   that governs `preferences.md`. **Under `just-vibes`:** auto-adopt, journal the rationale (which
   source, why these tags) — mirrors `align-ui`/`ui-variations` auto-approval under unattended runs.
5. **Retain provenance** in `pack.yml`'s `provenance:` list (source, kind, ingestion date, page
   range if a book) and keep the raw material in `sources/` — a pack that can't be traced back to
   its source can't be safely re-distilled later.

## Why distillation is mandatory, not optional

A knowledge pack a session loads under progressive disclosure must be **actionable guidance**.
Verbatim source dumping defeats that twice: it blows the context budget on load, and it forces
the session to re-derive the guidance itself from raw material instead of consuming a distilled
rule. If a source yields nothing actionable, say so and write no reference — never pad.

## Priority-chain placement

A newly ingested pack lands at tier 2 (user-curated, `baseline: false`) — it **outranks** the
shipped baseline (`ios`, tier 4) wherever its triggers match, the same way concrete sample code
already outranks `swift-dev`'s generic advice. This is exactly why step 4's confirmation gate
matters: a wrong pack is worse than no pack, because it outranks the floor.

## Worked example

`/akios:learn ~/books/Evans-DDD.pdf --pack ddd` → the `pdf` skill extracts text; this skill
chunks by chapter and distills `references/{aggregates,bounded-context,ubiquitous-language,
repositories}.md`. A follow-up `/akios:learn ~/code/ddd-samples/ --pack ddd` indexes the code
samples, adds `references/aggregate-example.md`, drops the files in `knowledge/ddd/sources/`.
`pack.yml` gets `domain_tags: [domain-modeling, bounded-context]`, `triggers: [aggregate,
entity, value object]`, `baseline: false`. The drafted INDEX + one reference are shown; the user
confirms, the pack goes live. Later, `spec-to-tasks` tags a task modeling a "Squad" aggregate
`pack:ios` + `pack:ddd`; `task-execution` loads `swift-dev`'s `swiftdata-pro` guide **and**
`ddd`'s `aggregates.md` — the aggregate is modeled the way the book teaches, persisted the way
the `ios` pack teaches.

## Empty / edge states

- **Source yields nothing actionable:** say so plainly, write no reference — don't pad a pack
  with restated source text to look complete.
- **A pack's trigger over-fires** (matches tasks it shouldn't): tighten `triggers`/`domain_tags`
  in `pack.yml` — this is a data edit, not a skill change.
- **Two user packs conflict on one task** (both tier 2): record the conflict as an open item;
  pick the pack whose `triggers` matched more specifically, note it — never blend silently.
- **Ingesting into a pack that doesn't exist yet:** create it; `--pack` both targets and creates.
- **`--global` and `--pack` on an existing repo-local pack of the same name:** these are
  different packs (different install location) — don't merge; note the ambiguity to the user.
- **`--kind snippet` source isn't valid/parseable Swift:** decline the entry rather than write a
  broken file into `snippets/`.
- **Declared `target:` folder doesn't exist yet in the consuming project** (e.g.
  `Foundation/Design-tokens` not scaffolded): created as part of the copy at task-execution time,
  same as any first-file-in-a-folder case — not this skill's concern at ingestion time.

## Anti-patterns

- Hand-parsing a PDF, image, or code file instead of routing to the dedicated extraction skill.
- Copying source text verbatim into a `references/*.md` file instead of distilling it.
- Auto-adopting a pack without confirmation outside `just-vibes` (attended runs always propose).
- Skipping provenance (`pack.yml` + `sources/`) — makes the pack impossible to re-distill later.
- Building a bespoke pack directory shape instead of the one `swift-dev`/`code-references`
  already validated (`pack.yml` + `INDEX.md` + `references/*.md`).
