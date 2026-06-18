---
name: ios-agentic-kit
description: The agentic-kit meta-system for Swift/iOS repos — what it installs, how it routes work, and how to set it up. Use when setting up agentic Claude Code workflows in a Swift/iOS/iPadOS/macOS repo, when you see a CLAUDE.md that imports @AGENTS.md + @Context.md, when deciding which gate/skill a Swift task routes to (idea-to-spec, oss-first, ios-feature-pipeline, ponytail, superpowers, axiom), or when installing/updating the kit.
license: MIT
metadata:
  author: Lucas Oliveira
  version: 1.0.0
---

# iOS Agentic Kit

A meta-system you plug into any Swift/iOS repo to make agentic coding efficient and
disciplined. Installing it drops a small set of always-loaded context files and a
SessionStart hook that route every task to the right skill. This skill documents what
the kit is, how it routes, and how to install it.

> Canonical source: the [`iOS-agentic-kit`](https://github.com/Lucasdho/iOS-agentic-kit)
> repo. This skill is authored there (`skills/ios-agentic-kit/`) and installed by
> `install-skills.sh`. Edit it in the repo, not in `~/.claude/skills/`.

## What it installs (per repo)

| File | Role |
|---|---|
| `CLAUDE.md` | The file Claude Code auto-loads; imports `@AGENTS.md` + `@Context.md` |
| `AGENTS.md` | Operating manual — the loop, the gate table, routing (single source of truth) |
| `Context.md` | Stack, commands, architecture, conventions |
| `.claude/rules/swift.md` | Path-scoped rule — loads the Axiom gate whenever a `.swift` file is read |
| `.claude/hooks/agentic-kit-inject.sh` | SessionStart hook — re-states the gates each session |

Durable decisions are **not** a repo file — they live in Claude Code's native auto-memory
(`MEMORY.md`), written automatically and surviving compaction.

## How it's invoked

You don't "run" the kit — it shapes the agent's behavior passively:

1. **Session start** — Claude Code loads `CLAUDE.md`, which imports `@AGENTS.md` + `@Context.md`
   in full; the SessionStart hook re-states the gates; `superpowers` self-activates via
   its own hook (and `ponytail` too, if installed — it's optional).
2. **`AGENTS.md` orients** — the loop, the gate table, routing.
3. **`.claude/rules/swift.md` fires per file** — reading any `.swift` loads the Axiom gate;
   route to the domain hub and let it dispatch the right sub-skill (progressive closure, no
   context blowup).
4. **Skills trigger themselves** by description, or you invoke one with `/skill-name`.

## The gate table (route every task)

| Trigger | Skill | When |
|---|---|---|
| Building a new feature end-to-end | `ios-feature-pipeline` → idea→spec→speckit→execute | before starting |
| Designing a system / turning an idea into a spec | `idea-to-spec` → write specs to `specs/` | before building |
| About to generate ANY code | plan mode OR `superpowers:brainstorming` | before code |
| Hand-writing complex code, docs, types, or a format conversion | `oss-first` — is there a mature tool/lib first? | before generating |
| Bug, crash, flake, regression | `superpowers:systematic-debugging` + `axiom-xcode` | before any fix |
| Implementing code | `axiom` (domain skill) + `fewer-permission-prompts` (+ `ponytail` if installed) | while coding |
| Creating / polishing SwiftUI Views | native first + `axiom-swiftui` (`ponytail` if installed) | before the view |
| Writing tests | `axiom-testing` | with the code |
| Claiming "done" | `superpowers:verification-before-completion` + `/code-review` | before finishing |

Axiom domain hubs use **progressive closure** — each hub (~400 words) dispatches to sub-skills
on demand, so only the relevant domain loads during long plan/execute sessions.

## Skills the kit relies on

| Skill | Type | How it installs |
|---|---|---|
| `idea-to-spec`, `oss-first`, `ios-feature-pipeline`, `ios-agentic-kit` | authored | copied to `~/.claude/skills/` by `install-skills.sh` |
| `superpowers`, `axiom` | plugin (required) | `/plugin marketplace add` + `/plugin install` (printed by the script) |
| `ponytail` | plugin (optional, recommended) | efficiency overlay — `/plugin install`; the kit works without it |
| `/code-review`, `fewer-permission-prompts` | built-in | ship with the Claude Code CLI |

## Full pipeline with speckit (optional)

`ios-feature-pipeline` orchestrates the path from raw idea to running code. With speckit
initialized (`.specify/` present):

| Phase | Tool | Mode |
|---|---|---|
| 1 — Design | `/idea-to-spec` | Interactive — user present |
| 2 — Clarify | `/speckit-clarify` | Automated |
| 3 — Specify | `/speckit-specify` | Automated |
| 4 — Plan | `/speckit-plan` | Automated — constitution enforces Axiom gates |
| 5 — Tasks | `/speckit-tasks` | Automated |
| 6 — Execute | `superpowers:subagent-driven-development` | Fresh subagents, Axiom domain skill per task |

Invoke `/ios-feature-pipeline` for the full phase guide and the degraded path for projects
without speckit.

## Installing the kit into a repo

```sh
# 1. get the kit
git clone https://github.com/Lucasdho/iOS-agentic-kit.git ~/iOS-agentic-kit
# 2. install the authored skills into ~/.claude/skills/
~/iOS-agentic-kit/install-skills.sh
# 3. plug the kit into your repo (idempotent; never overwrites existing files)
~/iOS-agentic-kit/install.sh /path/to/your/repo        # installs at the git root
# ~/iOS-agentic-kit/install.sh --here /path/to/subdir  # or an exact subfolder
```

Then fill in the `{{...}}` placeholders in `Context.md` / `AGENTS.md`. The required
plugins (`superpowers`, `axiom`) and the optional `ponytail` install via their
marketplaces — `install-skills.sh` prints the exact commands. Check staleness with `~/iOS-agentic-kit/check-update.sh`.

> **Use it in** Swift/iOS/iPadOS/macOS repos — the gates are Swift-specific. **Don't use it in**
> non-Swift projects; fork the structure (AGENTS.md + hook + your own gate table) instead.

## Generic Claude-Code-for-iOS reference

Setup material not specific to this kit (adapted from `keskinonur/claude-code-ios-dev-guide`):

- [references/xcodebuildmcp.md](references/xcodebuildmcp.md) — XcodeBuildMCP tools, scopes, config
- [references/sandbox.md](references/sandbox.md) — sandbox permission levels (read-only → full dev)
- [references/hooks.md](references/hooks.md) — Swift hook events, configs, scripts
- [references/prd-workflow.md](references/prd-workflow.md) — PRD / spec / task templates + commands
- [references/project-structure.md](references/project-structure.md) — `.claude/` layout, subagents
