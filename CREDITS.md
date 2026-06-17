# Credits & Licenses

This kit bundles skills authored by other people. Credit and license below.
All third-party skills are **MIT** except where noted. MIT lets you redistribute
**as long as you keep the copyright notice + license text** — the bundled `.zip`
includes each plugin's `LICENSE` file for that reason.

## Top-level skills

| Skill | Author | License | Source |
|---|---|---|---|
| `swift-dev` | **Lucas Oliveira** (you) | your own | this kit's author |
| `swiftui-design-skill` | **wholiver** | MIT (v1.0.0) | SKILL.md frontmatter |
| `ponytail` (plugin) | **Dietrich Gebert** | MIT © 2026 | https://github.com/DietrichGebert/ponytail |
| `superpowers` (plugin) | **Jesse Vincent** (obra) | MIT © 2025 | https://github.com/obra/superpowers |
| `bug-hunt-swarm` | Anthropic (anthropic-skills) | **unspecified** | local skill — see note |

## Inside `swift-dev` (your skill bundles these sub-guides)

| Sub-skill | Author | License |
|---|---|---|
| `swiftui-pro` | **Paul Hudson** | MIT (v1.1) |
| `swiftdata-pro` | **Paul Hudson** | MIT (v1.0) |
| `swift-testing-pro` | **Paul Hudson** | MIT (v1.0) |
| `swift-concurrency-pro` | **Paul Hudson** | MIT (v1.0) |
| `ios-accessibility` | derived from **Daniel Devesa Derksen-Staats** — *Developing Accessible iOS Apps* (Apress) & #365DaysIOSAccessibility; sample code MIT | MIT © 2025 |
| `figma-to-swiftui`, `swiftui-ui-patterns`, `swiftui-view-refactor`, `swiftui-performance-audit`, `ios-debugger-agent` | Lucas Oliveira (no separate author header) | your own |

> `swift-testing-pro` / `swift-concurrency-pro` reference Apple's Swift Testing &
> Swift Concurrency (swift.org, Apache-2.0 w/ Runtime Library Exception). Paul
> Hudson's guide text is MIT; the underlying Apple APIs are documented, not copied.

## Built into Claude Code (NOT bundled)
`/code-review` and `fewer-permission-prompts` ship with the Claude Code CLI.

## Redistribution verdict
- **MIT skills** (`swiftui-design-skill`, `ponytail`, `superpowers`, Paul Hudson
  guides, `ios-accessibility`) — OK to redistribute **with attribution + their
  LICENSE retained**. Keep this file and the bundled `LICENSE` files together.
- **`bug-hunt-swarm`** — no license declared. **Do not publish it publicly** until
  you confirm terms with Anthropic; safe to keep for personal/internal use.
- **`swift-dev`** — yours; license it however you like (consider stating one).
