# Credits & Licenses

This kit ships skills authored here and relies on third-party plugins installed
via their marketplaces. All skills are MIT except where noted.

## Authored by this kit (`skills/`)

| Skill | Author | License | Source |
|---|---|---|---|
| `ios-agentic-kit` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `idea-to-spec` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `oss-first` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `ios-feature-pipeline` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |

The `skills/ios-agentic-kit/references/` material (XcodeBuildMCP, sandbox levels,
hooks, PRD workflow, project structure) is adapted from
[keskinonur/claude-code-ios-dev-guide](https://github.com/keskinonur/claude-code-ios-dev-guide)
(MIT) — each reference file carries the attribution header.

## Plugins the kit relies on (installed via marketplace, not bundled)

| Plugin | Required? | Author | License | Source | Pinned ref |
|---|---|---|---|---|---|
| `superpowers` | required | Jesse Vincent (obra) | MIT © 2025 | https://github.com/obra/superpowers | 5.1.0 |
| `axiom` | required | CharlesWiltgen | MIT | https://github.com/CharlesWiltgen/Axiom | v27 |
| `ponytail` | optional (recommended) | Dietrich Gebert | MIT © 2026 | https://github.com/DietrichGebert/ponytail | 4.7.0 |

Install with `/plugin marketplace add … && /plugin install …` (commands printed by
`install-skills.sh`). They live in `~/.claude/plugins/`, update via `/plugin update`,
and carry their own `LICENSE`. The pinned refs above are the versions this kit was
validated against — newer releases generally work; update them here when you re-pin.

## Built into Claude Code (not bundled)
`/code-review` and `fewer-permission-prompts` ship with the Claude Code CLI.
