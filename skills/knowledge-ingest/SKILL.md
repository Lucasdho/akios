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
*maintenance* action, like `/akios:init` — not a pipeline phase. Invocation: `/akios:learn
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
  references/*.md      → the distilled knowledge, one concern per file
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

## Anti-patterns

- Hand-parsing a PDF, image, or code file instead of routing to the dedicated extraction skill.
- Copying source text verbatim into a `references/*.md` file instead of distilling it.
- Auto-adopting a pack without confirmation outside `just-vibes` (attended runs always propose).
- Skipping provenance (`pack.yml` + `sources/`) — makes the pack impossible to re-distill later.
- Building a bespoke pack directory shape instead of the one `swift-dev`/`code-references`
  already validated (`pack.yml` + `INDEX.md` + `references/*.md`).
