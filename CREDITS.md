# Credits & Licenses

This kit ships only skills authored here. It has **no required external plugins** and bundles no
third-party skill trees. All skills are MIT except where noted.

## Authored by this kit (`skills/`)

| Skill | Author | License | Source |
|---|---|---|---|
| `feature-pipeline` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `idea-to-spec` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `deep-brainstorm` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `founderlens-behavior` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `spec-to-tasks` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `task-execution` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `just-vibes` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `knowledge-ingest` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `skill-author` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `oss-first` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `handoff` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |

_Skill `version:` fields in frontmatter are an independent track from the kit's `VERSION` file
— they reflect the skill's own revision history, not the kit release._

## Prior art, no longer bundled

> **Dropped in 1.0.0** — the `agentic-kit` meta-skill and its `references/sandbox.md`
> (graduated permission levels + `settings.json` templates). That doc was originally inspired by
> [keskinonur/claude-code-ios-dev-guide](https://github.com/keskinonur/claude-code-ios-dev-guide)
> (MIT) and had since been rewritten for this kit. Credit and thanks for the prior art.

> **Dropped in 1.0.0** — the kit's Swift/iOS layer was removed when akios became stack-agnostic.
> That layer bundled open-source Swift skills, chiefly from
> **[twostraws/swift-agent-skills](https://github.com/twostraws/swift-agent-skills)** (Paul Hudson,
> MIT), alongside work by
> [daetojemax](https://github.com/daetojemax/figma-to-swiftui-skill),
> Thomas Ricouard, Daniel Devesa Derksen-Staats, and
> [arjitj2](https://github.com/arjitj2/swiftui-design-principles) (MIT © 2026 arjitj2).
> Credit and thanks to all of them for the prior art. The Swift layer lives on in the git history
> at tag `v0.9.1`.

> **Dropped in 0.5.0** — the kit previously required `axiom` (CharlesWiltgen, MIT) and
> `superpowers` (Jesse Vincent / obra, MIT) as external plugins. They were replaced by the kit's
> own domain routing and `task-execution` (execution discipline). Credit and thanks to both
> projects for the prior art.

## Built into Claude Code (not bundled)
`/code-review`, `/verify`, and `fewer-permission-prompts` ship with the Claude Code CLI.
