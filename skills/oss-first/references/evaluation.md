# Evaluation Rubric & Registry Tips

## Scoring rubric

Evaluate each shortlisted candidate. You don't need a numeric score — the rubric exists so
your comparison covers the dimensions the user cares about, in this priority order.

### 1. Maturity & community (most important)

- **Maintenance**: last release / last commit. <6 months = healthy; 6–18 months = fine for
  stable tools; >2 years = flag it. A "done" tool (e.g., a spec-complete converter) can be
  old and still safe — use judgment and say why.
- **Adoption**: GitHub stars and registry downloads, judged *relative to the niche*. 2k
  stars is huge for an OpenAPI linter, tiny for a web framework.
- **Issue health**: are maintainers responding? Many open issues is normal for popular
  projects; *unanswered* critical bugs are the red flag.
- **Bus factor**: single-maintainer projects are acceptable but worth mentioning.

### 2. License

- Safe to recommend freely: MIT, Apache-2.0, BSD-2/3, ISC, MPL-2.0 (file-level copyleft).
- Flag explicitly, with one sentence on the implication: GPL-2.0/3.0 (copyleft — fine as a
  CLI dev-tool, risky if linked into distributed code), AGPL (network copyleft), BUSL/SSPL
  (source-available, not OSI open source), "free for non-commercial".
- CLI tools used only at build time rarely create license obligations on the user's code —
  say this when relevant, it often unblocks a GPL'd dev tool.

### 3. Footprint

- Dependency count (for npm: `npm view <pkg> dependencies`; install size on packagephobia.com).
- Prefer tools runnable without permanent install: `npx`, `pipx run`, `uvx`, `docker run`.
- Easy to remove = low commitment. Mention the uninstall story if it's nontrivial.

### 4. CLI-first (big nice-to-have)

A CLI means every future run costs **zero tokens** — the human or CI reruns it without AI
involvement. Library-only tools still help but keep the AI in the loop for glue code.

### 5. MCP availability (big nice-to-have)

If the tool or its ecosystem has an MCP server, the user can wire it into Claude directly.
Check: web search "<tool> MCP server", and the MCP registry if available in the session.

## Where to look, per ecosystem

| Ecosystem | Registry | Quick checks |
|---|---|---|
| JavaScript/TS | npmjs.com | `npm view <pkg>`, npmtrends.com for download comparison |
| Python | pypi.org | `pip index versions`, pypistats.org, check `Programming Language :: Python :: 3.12+` classifiers |
| Go | pkg.go.dev | import count shown on page; `go install <pkg>@latest` for CLIs |
| Rust | crates.io | recent downloads graph, lib.rs for curated comparisons |
| Java/Kotlin | central.sonatype.com | check release cadence |
| Ruby | rubygems.org | downloads, ruby-toolbox.com for category comparisons |
| Cross-language CLIs | GitHub, Homebrew | `brew info <tool>` shows popularity analytics |

General web searches that work well: "<problem> cli github", "awesome <category>"
(awesome-lists are curated shortcuts), "<tool A> vs <tool B>".

## Common commodity problems → known-good starting points

These are starting points to verify, not pre-made answers — check maintenance status before
recommending, since tools fall out of favor.

| Problem | Candidates to check first |
|---|---|
| OpenAPI/Swagger → docs | Redocly CLI, Scalar, widdershins, Slate |
| OpenAPI → client/server code | openapi-generator, oazapfts, orval |
| JSON Schema → types | json-schema-to-typescript, quicktype, datamodel-code-generator (py) |
| DB schema → migrations/types | Prisma, Atlas, sqlc, Alembic |
| Code → diagrams | mermaid-cli, tsuml2, py2puml, dbdiagram |
| Changelog generation | release-please, changesets, git-cliff, semantic-release |
| Lint/format | eslint+prettier / biome (JS), ruff (py), golangci-lint |
| File conversion (docs) | pandoc (the universal answer) |
| Image processing | sharp (node), ImageMagick, Pillow |
| PDF manipulation | qpdf, pdfcpu, pypdf |
| Env/secrets scanning | gitleaks, trufflehog |
| License auditing | license-checker (npm), pip-licenses |
