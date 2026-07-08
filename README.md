# AKIOS - Agentic Kit for IOS

An agent workflow kit for building Swift / iOS apps: brainstorm, plan, design, deliver,
and keep the work grounded in specs instead of improvising session by session.

Akios is currently a full Claude Code plugin and a Codex-ready plugin. Claude Code gets the
complete `/akios:*` command surface, setup flow, and `.claude` hooks; Codex support exposes the
shared skill family through `.codex-plugin/plugin.json` while command/setup parity is still in
progress.

## What it does

- **Brainstorm** (`/akios:brainstorm`) — turn a rough idea into an approved spec
- **Plan** (`/akios:plan`) — break the spec into a task backlog with estimates and checkpoints
- **Design** (`/akios:design`) — explore, remix, and graduate SwiftUI variations for UI-scoped tasks before implementation
- **Deliver** (`/akios:deliver`) — implement, test, and code-review each task; stop before push/merge
- **Autonomous run** (`/akios:just-vibes`) — drive the whole pipeline unattended; quality gate stays on

The kit ships a full skill family (Swift domain knowledge, idea-to-spec, task execution,
whole-app cartography, autonomous runs, and more — see `skills/ios-agentic-kit/SKILL.md`
for the current set), a phase contract (`akios/workflow.yml`), and a SessionStart hook that
re-states the workflow gates every session so the agent never drifts.

## Install

### Claude Code

Inside Claude Code:

```
/plugin marketplace add Lucasdho/akios
/plugin install akios
```

Then, inside the repo you want to set up:

```
/akios:setup
```

`setup` interviews you, scans the repo, fills in templates, creates the `akios/` folder tree
(`akios/specs/`, `akios/tasks/`, `akios/archive/`), and wires the hook. No external dependencies required.

### Codex

Codex can install Akios as a plugin through the `.codex-plugin/plugin.json` manifest and use the
shared skills in `skills/`. This first Codex release does not claim full command parity yet:
`/akios:setup` and the rest of the slash-command flow are still Claude-first because they depend
on `CLAUDE.md`, `.claude/`, `~/.claude`, and Claude Code hook environment variables.

## Commands

| Command | What it does |
|---|---|
| `/akios:setup` | Onboard a repo — interview → scan → fill templates → wire hook |
| `/akios:brainstorm "<idea>"` | Idea → approved spec in `akios/specs/` |
| `/akios:deep-brainstorm [focus]` | Map the whole app → a complete spec family in one session |
| `/akios:plan <spec>` | Spec → task backlog in `akios/tasks/todo/` |
| `/akios:design` | Explore, remix, and graduate a screen's SwiftUI variations (UI-scoped tasks only) |
| `/akios:deliver` | Implement tasks; stop before push/merge |
| `/akios:just-vibes [idea]` | Full pipeline, unattended; `--force` to loop |
| `/akios:handoff` | Write a handoff doc for another agent session, or return results |

All commands are typed-only (`disable-model-invocation`) — they never auto-fire.

Codex note: treat the commands above as the Claude Code interface for now. In Codex, use the
installed Akios skills directly until the setup/hooks layer is ported to Codex-native paths.

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
