# akios

A Claude Code plugin that gives your agent a structured, repeatable workflow for building
Swift / iOS apps — design, plan, execute — so features ship clean instead of being improvised
session by session.

## What it does

- **Design** (`/akios:brainstorm`) — turn a rough idea into an approved spec
- **Plan** (`/akios:plan`) — break the spec into a task backlog with estimates and checkpoints
- **Execute** (`/akios:execute`) — implement, test, and code-review each task; stop before push/merge
- **Autonomous run** (`/akios:just-vibes`) — drive the whole pipeline unattended; quality gate stays on

The kit ships 8 skills (Swift domain knowledge, idea-to-spec, task execution, and more),
a phase contract (`workflow.yml`), and a SessionStart hook that re-states the workflow gates
every session so the agent never drifts.

## Install

Inside Claude Code:

```
/plugin marketplace add Lucasdho/akios
/plugin install akios
```

Then, inside the repo you want to set up:

```
/akios:init
```

`init` interviews you, scans the repo, fills in templates, creates the folder tree
(`specs/`, `tasks/`, `archive/`), and wires the hook. No external dependencies required.

## Commands

| Command | What it does |
|---|---|
| `/akios:init` | Onboard a repo — interview → scan → fill templates → wire hook |
| `/akios:brainstorm "<idea>"` | Idea → approved spec in `specs/` |
| `/akios:plan <spec>` | Spec → task backlog in `tasks/todo/` |
| `/akios:execute` | Implement tasks; stop before push/merge |
| `/akios:just-vibes [idea]` | Full pipeline, unattended; `--force` to loop |

All commands are typed-only (`disable-model-invocation`) — they never auto-fire.

## Who it's for

Swift / iOS / iPadOS / macOS repos you build with an agent. The workflow gates and bundled
skills are Swift-specific. For non-Swift projects, fork the structure (AGENTS.md + hook + your
own gate table) instead.

## Learn more

- **[START-HERE.md](START-HERE.md)** — first-time setup walkthrough + build your first feature
- **[CHANGELOG.md](CHANGELOG.md)** — what's new in each version
- **[CREDITS.md](CREDITS.md)** — attribution

---

MIT License · [Lucasdho](https://github.com/Lucasdho)
