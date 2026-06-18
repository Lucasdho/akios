# Skills used by this kit

> Author credits & license terms for every skill → [CREDITS.md](CREDITS.md).

## Bundled (in `skills/` and `skills-bundle.zip`)
| Skill | Source on disk | Role in the kit |
|---|---|---|
| `idea-to-spec` | `~/.claude/skills/idea-to-spec` | Idea → versioned specs in `specs/`, domain registered in CLAUDE.md |
| `oss-first` | `~/.claude/skills/oss-first` | Force open-source/tooling search before hand-writing complex code |
| `ios-feature-pipeline` | `~/.claude/skills/ios-feature-pipeline` | Full-lifecycle orchestrator: idea-to-spec → speckit pipeline → subagent-driven-development |
| `ponytail` (plugin) | `~/.claude/plugins/cache/ponytail` | Laziness/efficiency, anti over-build |
| `superpowers` (plugin) | `~/.claude/plugins/cache/.../superpowers` | brainstorming, systematic-debugging, TDD, verification |
| `axiom` (plugin, v27) | `~/.claude/plugins/cache/.../axiom` | 28 domain hub skills for Swift/iOS with progressive closure: axiom-swiftui, axiom-concurrency, axiom-testing, axiom-swift, axiom-data, axiom-xcode, and more |

Regenerate with `./bundle-skills.sh`.

## NOT bundled — built into Claude Code
These ship with the Claude Code CLI itself; install the CLI to get them.
- `/code-review` — review the diff before finishing.
- `fewer-permission-prompts` — allowlist common read-only calls.

## Axiom domain hubs (auto-routed within axiom, progressive closure)
axiom-swiftui · axiom-concurrency · axiom-testing · axiom-swift · axiom-data ·
axiom-xcode · axiom-accessibility · axiom-networking · axiom-performance ·
axiom-security · axiom-shipping · axiom-ai · and more
