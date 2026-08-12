---
name: oss-first
description: >-
  Before generating complex code, extensive documentation, or file transformations by hand,
  search for an established open-source tool that already solves the problem deterministically
  — cheaper, faster, and higher quality than token-by-token generation. Use this skill
  proactively whenever a task is a "commodity problem" that mature tooling likely solves:
  generating API docs from a Swagger/OpenAPI spec, converting file formats,
  linting/formatting, scaffolding projects, generating types from schemas, creating
  changelogs, diagrams from code, database migrations, parsing, minification, image
  processing, and similar. Also use it when the user asks "is there a tool/library/package
  for X", "what's the best open source option for X", or complains about token cost or AI
  rewriting things that tools already do.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "2.0.0"
---

# OSS-First: Find the Tool Before Writing the Tokens

Hand-generating what a mature tool produces deterministically is both more expensive and worse:
the output drifts from its source and must be regenerated on every change. A tool does it
identically every run, for free. Your job shifts from *producing the output* to *picking and
wiring up the right tool*.

## When to activate

A **commodity problem** — something many people have needed before. Signals:

- The output is *derived* from an existing artifact (spec → docs, schema → types, code → diagram)
- It's a known category: lint, format, convert, scaffold, migrate, bundle, compress, validate
- Doing it by hand means a large volume of mechanical, low-creativity tokens
- The output must be regenerated whenever the input changes

**Don't force it** when the logic is genuinely custom, the task is tiny (a 5-line transform
doesn't justify a dependency), the user wants it hand-written, or a dependency is riskier than
the tokens saved. When unsure, spend 30 seconds checking — that check almost always pays.

## The pass

**1. Restate the task as a search.** Reduce it to its commodity core: "document my Swagger" →
"OpenAPI → static docs generator". Identify input, desired output, and the project's ecosystem
(`package.json` → npm, `pyproject.toml` → PyPI, `go.mod` → Go, `Cargo.toml` → crates.io).

**2. Shortlist 2–4 real contenders**, not ten. Search the registry and the web; check each
candidate's repo. Cheap probes: `npm view <pkg> license version`, `npm search <keywords> --json`,
`pip index versions <pkg>`.

**3. Evaluate**, in priority order — see `references/evaluation.md` for the full rubric:

1. **Maturity** — commit within ~12 months, adoption meaningful for the niche, issues answered
2. **Permissive license** — MIT / Apache-2.0 / BSD / ISC. Flag GPL/AGPL explicitly, never silently
3. **Light footprint** — few dependencies, easy to install *and* to remove
4. **CLI-first** — a command means future regenerations cost zero tokens
5. **MCP available** — mention it if an MCP server exists for the tool or service

Disqualify anything unmaintained, unless it's genuinely *finished* with no live alternative — and
say that's why.

**4. Recommend with a compact comparison** so the user decides fast:

```markdown
## Recommendation: <tool>

| | <tool A> ⭐ | <tool B> | <tool C> |
|---|---|---|---|
| Maturity | 24k stars, active | 8k stars, last commit 2023 | 3k stars, active |
| License | MIT | Apache-2.0 | GPL-3.0 ⚠️ |
| Dependencies | 3 | 40+ | 5 |
| CLI | ✅ | ✅ | ❌ lib only |
| Install | `npm i -D <tool>` | … | … |

**Why <tool A>**: <1–3 sentences>
**What it replaces**: <the hand-work it removes, and what a rerun costs now>
```

Report only numbers you actually verified; say "couldn't verify" otherwise. Never invent stars.

**5. Offer the follow-through, then do it.** Install · a short how-to · a snippet wired to their
real files · run it end-to-end. On "go ahead", do all four and wire it as a repeatable command
(`npm run docs`, `make docs`) so the human never needs an AI for this task again — that's the
entire point. Close with one or two sentences: what is now deterministic, how to rerun it, and
what still needs judgment.

## Worked examples

- *"Documenta os endpoints do meu swagger.json"* → detect Node → shortlist Redocly CLI /
  widdershins / Scalar → recommend → `npx @redocly/cli build-docs swagger.json -o docs/api.html`,
  wired as a `docs` script. **Not:** writing Markdown for 40 endpoints by hand.
- *"Preciso de tipos TypeScript pra esse JSON schema"* → `json-schema-to-typescript` (or
  `quicktype` for multi-language), generated via CLI and wired as a script. **Not:** hand-written
  interfaces that drift from the schema.
- *"Escreve a regra de cálculo de comissão dos vendedores"* → **correctly does not trigger.**
  Custom business logic; no generic tool knows their rules. Write the code.
