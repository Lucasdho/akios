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
  version: "1.0.0"
---

# OSS-First: Find the Tool Before Writing the Tokens

## Why this matters

When an LLM hand-generates output that a mature tool produces deterministically (API docs,
format conversions, generated types, changelogs), the result is more expensive AND worse:
tokens are spent on boilerplate, output drifts from the source of truth, and it must be
regenerated every time something changes. A well-established package does the same job in
one command, identically every run, for free. The AI's job shifts from *producing the
output* to *picking and wiring up the right tool* — which is a much better use of tokens.

Example: instead of writing Markdown docs for a 40-endpoint Swagger spec (~thousands of
output tokens, stale tomorrow), install `redoc-cli` or `widdershins` and generate them from
the spec itself in seconds.

## When to activate

Activate when a task smells like a **commodity problem** — something many developers have
needed before. Strong signals:

- The output is *derived* from an existing artifact (spec → docs, schema → types, code → diagram)
- The task is a well-known category: lint, format, convert, scaffold, migrate, bundle, compress, validate
- Doing it by hand would mean generating a large volume of mechanical, low-creativity tokens
- The output will need to be regenerated whenever the input changes

Do NOT force this workflow when:

- The logic is genuinely custom business logic (no generic tool can know it)
- The task is tiny (a 5-line transformation doesn't justify a dependency)
- The user explicitly wants hand-written output
- Adding a dependency is riskier than the tokens saved (e.g., security-sensitive contexts,
  locked-down environments)

When in doubt, spend 30 seconds checking if a tool exists before generating anything by hand.
That check is almost always worth it.

## Workflow

### Step 1 — Define the problem as a search

Reduce the user's task to its commodity core. "Document my Swagger" → "OpenAPI → static
docs generator". "Keep my changelog updated" → "conventional-commits changelog generator".
Identify the input artifact, the desired output, and the user's ecosystem (look at the
project: package.json → npm, pyproject.toml/requirements → PyPI, go.mod → Go, Cargo.toml →
crates.io).

### Step 2 — Search and shortlist (2–4 candidates)

Search the relevant registry and the web. Useful non-token-hungry probes:

```bash
npm view <pkg> license version
npm search <keywords> --json | head -50
pip index versions <pkg>          # or check pypi.org/project/<pkg>
```

Web search for "<problem> open source tool", "<problem> cli", "best <category> <year>".
Check the GitHub repo of each candidate. Shortlist 2–4 real contenders — not 10.

### Step 3 — Evaluate against the criteria

Score each candidate on the criteria in `references/evaluation.md` (read it for the full
rubric and per-ecosystem registry tips). The short version, in priority order:

1. **Maturity & community** — active maintenance (commit in last ~12 months), meaningful
   adoption (stars/downloads relative to the niche), issues getting responses
2. **Permissive license** — MIT, Apache-2.0, BSD, ISC. Flag GPL/AGPL explicitly rather
   than silently recommending it
3. **Light footprint** — few dependencies, easy to install AND easy to remove
4. **CLI-first** (big plus) — runs as a command, so future regenerations cost zero tokens
5. **MCP availability** (big plus) — if an MCP server exists for the tool/service, mention it

Disqualify anything unmaintained (years dead, unanswered critical issues) unless it's a
genuinely "finished" tool with no real alternative — say so if that's the case.

### Step 4 — Recommend with a comparison

Present a compact comparison so the user can decide quickly. ALWAYS use this structure:

```markdown
## Recommendation: <tool>

| | <tool A> ⭐ recommended | <tool B> | <tool C> |
|---|---|---|---|
| Maturity | 24k stars, active | 8k stars, last commit 2023 | 3k stars, active |
| License | MIT | Apache-2.0 | GPL-3.0 ⚠️ |
| Dependencies | 3 | 40+ | 5 |
| CLI | ✅ | ✅ | ❌ lib only |
| Install | `npm i -D <tool>` | ... | ... |

**Why <tool A>**: <1–3 sentences>
**Token economics**: <what the tool replaces, e.g. "regenerating docs by hand on every
spec change vs. one `npx <tool>` command — zero tokens after setup">
```

Keep claims honest: report numbers you actually verified, and say "couldn't verify" when
you couldn't. Don't invent star counts.

### Step 5 — Offer the next move (then act on it)

After the recommendation, offer — don't assume — the follow-through:

1. **Install** it in the project
2. **Teach** — a short "how to use" for the team (commands, config, common flags)
3. **Example** — working code/config snippet wired to the user's actual files
4. **Run** it end-to-end and show the result

If the user says "go ahead" (or asked for execution upfront), do all four in order: install,
add a minimal config/script entry (e.g., a `package.json` script), run it on their real
input, and show the output. Prefer wiring it as a repeatable command (`npm run docs`,
`make docs`) so the human never needs the AI for this task again — that's the whole point.

### Step 6 — Close the loop

Briefly state what was saved: what the tool now does deterministically, how to rerun it,
and what (if anything) still needs AI judgment. One or two sentences, not a report.

## Examples

**Example 1**
User: "Documenta os endpoints do meu swagger.json"
Instead of: writing Markdown for every endpoint by hand.
Do: detect Node project → shortlist Redocly CLI / widdershins / Scalar → recommend with
comparison → on approval, `npx @redocly/cli build-docs swagger.json -o docs/api.html`,
add `"docs": "redocly build-docs swagger.json -o docs/api.html"` to package.json scripts.

**Example 2**
User: "Preciso de tipos TypeScript pra esse JSON schema"
Instead of: hand-writing interfaces that drift from the schema.
Do: recommend `json-schema-to-typescript` (or `quicktype` for multi-language), generate
via CLI, wire as a script.

**Example 3 (correctly NOT triggering)**
User: "Escreve a regra de cálculo de comissão dos vendedores"
This is custom business logic — no generic tool knows their commission rules. Write the code.
