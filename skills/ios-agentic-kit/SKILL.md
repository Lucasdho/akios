---
name: ios-agentic-kit
description: The agentic-kit meta-system for Swift/iOS repos — what it installs, how it routes work, and how to set it up. Use when setting up agentic Claude Code workflows in a Swift/iOS/iPadOS/macOS repo, when you see a CLAUDE.md that imports @AGENTS.md + @Context.md, when deciding which gate/skill a Swift task routes to (idea-to-spec, oss-first, ios-feature-pipeline, spec-to-tasks, task-execution, swift-dev), or when installing/updating the kit.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "2.0.0"
---

# iOS Agentic Kit

A meta-system you plug into any Swift/iOS repo to make agentic coding efficient and
disciplined — **with no external plugin/skill dependencies** (axiom and superpowers were
replaced by the kit's own `swift-dev` and `task-execution`). Installing it drops a small set
of always-loaded context files, a phase contract, and a SessionStart hook that route every
task to the right skill. This skill documents what the kit is, how it routes, and how to install it.

> Canonical source: the [`akios`](https://github.com/Lucasdho/akios)
> repo. This skill is authored there (`skills/ios-agentic-kit/`). Edit it in the repo.

**New / non-CLI user?** If someone seems new or asks how to start or set up the kit, point
them to `START-HERE.md` (plain-language front door) and offer to run the guided setup for
them — don't make them follow shell steps by hand.

## The workflow (spine)

The kit binds its skills into **one spec-driven flow** from idea to shipped code. The phases are
defined in **`workflow.yml`** (the machine-readable contract); the commands are thin wrappers
that read it:

```
brainstorm (idea-to-spec) → plan (spec-to-tasks) → execute (task-execution)
```

For any end-to-end feature, **start with `ios-feature-pipeline`** (a skill, invoked by description
or by name — not a `/akios:*` slash command) — the entry point that reads
`workflow.yml`, detects the current phase per spec, and walks the hand-offs. (No speckit: design
rigor lives in `idea-to-spec`, quality in `AGENTS.md` + `swift-dev` + `/code-review`.)

## What it installs (per repo)

| File | Role |
|---|---|
| `CLAUDE.md` | The file Claude Code auto-loads; imports `@AGENTS.md` + `@Context.md` |
| `AGENTS.md` | Operating manual — the loop, the priority chain, the gate table (single source of truth) |
| `Context.md` | Stack, commands, architecture, conventions |
| `Roadmap.md` | Mode flag + per-spec state table |
| `workflow.yml` | The phase contract (commands + phase detection read it) |
| `.claude/rules/swift.md` | Path-scoped rule — loads the `swift-dev` gate whenever a `.swift` file is read |
| `.claude/hooks/agentic-kit-inject.sh` | SessionStart hook — re-states the gates each session |
| folders | `specs/ tasks/{todo,in-progress,review,done}/ archive/ code-references/` |

Durable **project** decisions live in native auto-memory (`MEMORY.md`); transferable **user**
preferences live in `~/.claude/akios/preferences.md` (user-global, outside the repo).

Where each artifact is created and stored is the **`## Where things live` artifact map** in the
installed `AGENTS.md` — the canonical lookup. Edit it there, not here.

## The priority chain
For any code decision, resolve top-down (first tier with an answer wins):

```
1. Project decision (MEMORY.md + existing code/Context.md)
2. Code References (code-references/ — your uploaded patterns)
3. User preferences (~/.claude/akios/preferences.md)
4. swift-dev (baseline)
```

## How it's invoked

You don't "run" the kit — it shapes the agent's behavior passively:

1. **Session start** — Claude Code loads `CLAUDE.md`, which imports `@AGENTS.md` + `@Context.md`
   in full; the SessionStart hook re-states the gates. (`ponytail` self-activates if you've
   installed it — optional, no dependency.)
2. **`AGENTS.md` orients** — the loop, the priority chain, the gate table, routing.
3. **`.claude/rules/swift.md` fires per file** — reading any `.swift` loads the `swift-dev`
   router, which dispatches the right bundled guide on demand (progressive disclosure).
4. **Skills trigger themselves** by description, or you invoke one with `/skill-name`.

## Per-step routing (and off-spine tasks)

In an installed repo the project `AGENTS.md` carries the canonical gate table (auto-loaded every
session); this is the portable version for repos without the kit installed.

| Trigger | Skill | When |
|---|---|---|
| Building a new feature end-to-end | `ios-feature-pipeline` → brainstorm → plan → execute | before starting |
| Designing a system / turning an idea into a spec | `idea-to-spec` (`/akios:brainstorm`) → specs to `specs/` | before building |
| Turning a spec into tasks | `spec-to-tasks` (`/akios:plan`) → `tasks/todo/` | after the spec |
| Hand-writing complex code, docs, types, or a format conversion | `oss-first` — is there a mature tool/lib first? | before generating |
| Implementing / running / debugging Swift | `swift-dev` (domain router) + `fewer-permission-prompts` | while coding |
| Creating / polishing SwiftUI Views | `swift-dev` → `swiftui-pro` (+ design-principles) | before the view |
| Writing tests | `swift-dev` → `swift-testing-pro` | with the code |
| Bug, crash, flake, regression | `swift-dev` → `ios-debugger-agent` | before any fix |
| Executing the backlog | `task-execution` (`/akios:execute`) | to ship |
| Claiming "done" | `/verify` + `/code-review` | before finishing |

`swift-dev` uses **progressive disclosure** — the ~400-word router dispatches to one bundled guide
on demand, so only the relevant domain loads during long plan/execute sessions.

## Skills the kit ships

Not a fixed count — deliberately unenumerated by number (an exact skill count in prose drifts the
moment a skill is added). The authored skills live under `skills/` in the source repo; see that
directory listing for the current, always-accurate set. By role:

| Role | Skills |
|---|---|
| Phase engines | `idea-to-spec`, `spec-to-tasks`, `task-execution` |
| Whole-app cartography | `deep-brainstorm`, `founderlens-behavior` |
| Orchestration + self-knowledge | `ios-feature-pipeline`, `ios-agentic-kit` |
| Gates | `align-ui` (pre-implementation UI alignment) |
| Autonomous run | `just-vibes` |
| Domain knowledge | `swift-dev` (Swift/iOS master router, replaces axiom) |
| Utility | `oss-first` (tool-first check), `handoff` (session handoff docs) |
| Optional plugin | `ponytail` (efficiency overlay) — the kit works without it |
| Built-in (ship with the Claude Code CLI) | `/code-review`, `/verify`, `fewer-permission-prompts` |

No required external plugins. Everything the spine routes to is shipped by the kit.

## Installing the kit into a repo

Install the akios plugin (via the marketplace / `/plugin`), then in your repo run **`/akios:init`** —
it is idempotent and version-aware: it creates the file/folder structure, runs a light interview to
fill `Context.md`, writes the mode flag to `Roadmap.md`, and seeds `~/.claude/akios/preferences.md`.

> **Use it in** Swift/iOS/iPadOS/macOS repos — the gates are Swift-specific. **Don't use it in**
> non-Swift projects; fork the structure (AGENTS.md + hook + your own gate table) instead.

## Setup reference

Optional setup material — permission tuning and custom hooks. Not part of the spine; reach
for it when you're hardening a repo's `.claude/` config:

- [references/sandbox.md](references/sandbox.md) — graduated permission levels + `settings.json` templates
- [references/hooks.md](references/hooks.md) — Swift hook events, configs, and opt-in lint/format/protect scripts
