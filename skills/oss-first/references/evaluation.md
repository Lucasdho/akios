# Evaluation Rubric & Registry Tips

The five criteria are listed in `SKILL.md`. This file carries the judgment calls behind them.

## Maturity — reading the signals

- **Maintenance:** <6 months since last commit = healthy; 6–18 months = fine for stable tools;
  >2 years = flag it. A *finished* tool (a spec-complete converter) can be old and still safe —
  use judgment and say why.
- **Adoption:** stars and downloads judged *relative to the niche*. 2k stars is huge for an
  OpenAPI linter and tiny for a web framework.
- **Issue health:** many open issues is normal for a popular project; *unanswered critical bugs*
  are the red flag.
- **Bus factor:** single-maintainer is acceptable, but worth mentioning.

## License — what to flag and why

- Recommend freely: MIT, Apache-2.0, BSD-2/3, ISC, MPL-2.0 (file-level copyleft).
- Flag with one sentence on the implication: GPL-2.0/3.0 (copyleft — fine as a CLI dev-tool,
  risky linked into distributed code), AGPL (network copyleft), BUSL/SSPL (source-available, not
  OSI open source), "free for non-commercial".
- A CLI used only at build time rarely creates obligations on the user's own code — saying this
  often unblocks an otherwise-disqualified GPL dev tool.

## Footprint

Dependency count (`npm view <pkg> dependencies`; install size on packagephobia.com). Prefer tools
runnable without a permanent install: `npx`, `pipx run`, `uvx`, `docker run`. Mention the
uninstall story when it's nontrivial.

## Where to look, per ecosystem

| Ecosystem | Registry | Quick checks |
|---|---|---|
| JavaScript/TS | npmjs.com | `npm view <pkg>`, npmtrends.com to compare downloads |
| Python | pypi.org | `pip index versions`, pypistats.org, Python 3.12+ classifiers |
| Go | pkg.go.dev | import count on the page; `go install <pkg>@latest` for CLIs |
| Rust | crates.io | downloads graph, lib.rs for curated comparisons |
| Java/Kotlin | central.sonatype.com | release cadence |
| Ruby | rubygems.org | downloads, ruby-toolbox.com for category comparisons |
| Cross-language CLIs | GitHub, Homebrew | `brew info <tool>` shows popularity analytics |

Searches that work: "<problem> cli github", "awesome <category>", "<tool A> vs <tool B>".

## Commodity problems → starting points

Verify maintenance before recommending — these are leads, not answers.

| Problem | Check first |
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
