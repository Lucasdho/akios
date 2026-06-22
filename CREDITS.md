# Credits & Licenses

This kit ships skills authored here and bundles open-source Swift skills inside `swift-dev`.
It has **no required external plugins**. All skills are MIT except where noted.

## Authored by this kit (`skills/`)

| Skill | Author | License | Source |
|---|---|---|---|
| `ios-agentic-kit` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `idea-to-spec` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `oss-first` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `ios-feature-pipeline` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `spec-to-tasks` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `task-execution` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `swift-dev` (router) | Lucas Oliveira | MIT © 2026 | see `LICENSE` |

_Skill `version:` fields in frontmatter are an independent track from the kit's `VERSION` file
— they reflect the skill's own revision history, not the kit release._

The `skills/ios-agentic-kit/references/` docs (sandbox permission levels, hooks) were
originally inspired by
[keskinonur/claude-code-ios-dev-guide](https://github.com/keskinonur/claude-code-ios-dev-guide)
(MIT); they have since been rewritten for this kit.

## Inside `swift-dev`

Most sub-skills come from **twostraws/swift-agent-skills** — a curated collection of
open-source Swift agent skills maintained by **Paul Hudson**, licensed **MIT**
(https://github.com/twostraws/swift-agent-skills) — except where a different source is listed
below. Original skill authors:

| Sub-skill | Original author / source |
|---|---|
| `swiftui-pro` | Paul Hudson |
| `swiftdata-pro` | Paul Hudson |
| `swift-testing-pro` | Paul Hudson |
| `swift-concurrency-pro` | Paul Hudson |
| `swiftui-ui-patterns` | twostraws/swift-agent-skills |
| `swiftui-performance-audit` | twostraws/swift-agent-skills |
| `ios-debugger-agent` | twostraws/swift-agent-skills |
| `figma-to-swiftui` | daetojemax — https://github.com/daetojemax/figma-to-swiftui-skill |
| `swiftui-view-refactor` | rewritten from Thomas Ricouard (Dimillian) — "SwiftUI in 2025: Forget MVVM" |
| `ios-accessibility` | Daniel Devesa Derksen-Staats — *Developing Accessible iOS Apps* (Apress) & #365DaysIOSAccessibility |
| `swiftui-design-principles` | arjitj2 — https://github.com/arjitj2/swiftui-design-principles (MIT © 2026 arjitj2) |

`swift-testing-pro` / `swift-concurrency-pro` reference Apple's Swift Testing & Swift
Concurrency (swift.org, Apache-2.0 w/ Runtime Library Exception); the guide text is MIT, the
underlying Apple APIs are documented, not copied.

## Optional plugin (installed via marketplace, not bundled)

| Plugin | Required? | Author | License | Source | Pinned ref |
|---|---|---|---|---|---|
| `ponytail` | optional | Dietrich Gebert | MIT © 2026 | https://github.com/DietrichGebert/ponytail | 4.7.0 |

Install with `/plugin marketplace add … && /plugin install …`. It lives in `~/.claude/plugins/`,
updates via `/plugin update`, and carries its own `LICENSE`.

> **Dropped in 0.5.0:** the kit previously required `axiom` (CharlesWiltgen, MIT) and
> `superpowers` (Jesse Vincent / obra, MIT) as external plugins. They were replaced by the kit's
> own `swift-dev` (domain routing) and `task-execution` (execution discipline). Credit and thanks
> to both projects for the prior art.

## Built into Claude Code (not bundled)
`/code-review`, `/verify`, and `fewer-permission-prompts` ship with the Claude Code CLI.
