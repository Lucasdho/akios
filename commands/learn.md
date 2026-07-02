---
description: Turn raw material (code, PDF/book, image, docs, or a skill) into a knowledge pack the pipeline can route to.
disable-model-invocation: true
---

# /akios:learn — Ingest a knowledge pack (workflow.yml: knowledge-ingest, maintenance action)

**Not a pipeline phase.** Like `/akios:init`, this is a maintenance action — run it whenever the
user wants akios to learn a domain from material they trust.

**Run.** Load the `knowledge-ingest` skill (single source of truth for the pipeline — don't
re-document it) against `<source>`:

- Extract with the source-typed tool (`pdf`/`pdf-reading` for a book/PDF, multimodal for an
  image/screenshot, the `code-references` path for code, direct ingestion for `.md` docs, or
  drop a `SKILL.md` straight into the pack's `skills/`). Never hand-parse what a dedicated skill
  already does — `oss-first` first for anything not covered.
- Distill each chunk into `references/*.md` (one concern per file) and write `INDEX.md` +
  `pack.yml` (`domain_tags`, `triggers`, `baseline: false`, `provenance`).
- **Propose, don't auto-adopt:** show the drafted INDEX + one sample reference and wait for
  confirmation before the pack goes live. Under `just-vibes`, auto-adopt with the rationale
  journaled.

`--pack <name>` targets or creates a named pack (repeatable ingestion into the same pack).
`--global` writes to `~/.claude/akios/knowledge/<name>/` instead of the repo-local `knowledge/`.

Arguments (`<source> [--pack <name>] [--global]`), pass as `$ARGUMENTS`: `$ARGUMENTS`

Stop when the pack exists and (attended) the user has confirmed it. Tell the user the pack is
live and which triggers route tasks to it.
