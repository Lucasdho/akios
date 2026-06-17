# Credits & Licenses

This kit bundles skills authored by other people. All third-party skills are
MIT except where noted; the bundled `.zip` includes each plugin's `LICENSE`.

## Top-level skills

| Skill | Author | License | Source |
|---|---|---|---|
| `swift-dev` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `idea-to-spec` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `oss-first` | Lucas Oliveira | MIT © 2026 | see `LICENSE` |
| `ponytail` (plugin) | Dietrich Gebert | MIT © 2026 | https://github.com/DietrichGebert/ponytail |
| `superpowers` (plugin) | Jesse Vincent (obra) | MIT © 2025 | https://github.com/obra/superpowers |

## Inside `swift-dev`

Most sub-skills come from **twostraws/swift-agent-skills** — a curated
collection of open-source Swift agent skills maintained by **Paul Hudson**,
licensed **MIT** (https://github.com/twostraws/swift-agent-skills) — except
where a different source is listed below. Original skill authors:

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

`swift-testing-pro` / `swift-concurrency-pro` reference Apple's Swift Testing &
Swift Concurrency (swift.org, Apache-2.0 w/ Runtime Library Exception); the
guide text is MIT, the underlying Apple APIs are documented, not copied.

## Built into Claude Code (not bundled)
`/code-review` and `fewer-permission-prompts` ship with the Claude Code CLI.

## Bundle snapshot & drift
`skills-bundle.zip` is a **snapshot** taken **2026-06-17** — it does not
auto-update. Pinned versions at snapshot time:

| Source | Version / ref |
|---|---|
| ponytail | 4.7.0 |
| superpowers | 5.1.0 |
| swiftui-design-principles | 1.1.1 |
| twostraws/swift-agent-skills (swift-dev sub-skills) | snapshot 2026-06-17 |
| daetojemax/figma-to-swiftui-skill | snapshot 2026-06-17 |

To refresh, see "Updating bundled skills" in [README.md](README.md), then
re-run `./bundle-skills.sh` and `./test-kit.sh`, and update this date.
