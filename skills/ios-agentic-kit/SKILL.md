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

**New / non-CLI user?** If someone seems new or asks how to start or set up the kit, point
them to `START-HERE.md` (plain-language front door) and offer to run the guided setup for
them — don't make them follow shell steps by hand.

## The workflow (spine)

The kit's job is to bind scattered skills into **one spec-driven flow** from idea to shipped code:

```
idea-to-spec → spec-to-tasks → task-execution → verify + /code-review
```

For any end-to-end feature, **start with `/ios-feature-pipeline`** — it's the canonical orchestrator
that owns the full phase guide and the artifact handoffs. (v2 dropped speckit: design rigor lives in
`idea-to-spec`, quality gates in `AGENTS.md` + axiom + ponytail; the four speckit phases collapsed
into one `spec-to-tasks` pass.) Everything below (install, per-step routing, references) is in
service of running that spine.

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

Where each artifact (specs, rules, hooks, skills, agents, tasks, trace) is created and
stored is the **`## Where things live` artifact map** in the installed `AGENTS.md` — the
canonical lookup for placing and finding files. Edit it there, not here.

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

## Per-step routing (and off-spine tasks)

Which skill fires at each step of the spine — and for one-off work that isn't a full feature. In an
installed repo the project `AGENTS.md` carries the canonical copy of this table (auto-loaded every
session); the copy here is the portable version for repos without the kit installed.

| Trigger | Skill | When |
|---|---|---|
| Building a new feature end-to-end | `ios-feature-pipeline` → idea-to-spec → spec-to-tasks → task-execution | before starting |
| Designing a system / turning an idea into a spec | `idea-to-spec` → write specs to `specs/` | before building |
| About to generate ANY code | plan mode OR `superpowers:brainstorming` | before code |
| Hand-writing complex code, docs, types, or a format conversion | `oss-first` — is there a mature tool/lib first? | before generating |
| Bug, crash, flake, regression | `superpowers:systematic-debugging` + `axiom-build` | before any fix |
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

## Setup reference

Optional setup material — permission tuning and custom hooks. Not part of the spine; reach
for it when you're hardening a repo's `.claude/` config:

- [references/sandbox.md](references/sandbox.md) — graduated permission levels + `settings.json` templates
- [references/hooks.md](references/hooks.md) — Swift hook events, configs, and opt-in lint/format/protect scripts
