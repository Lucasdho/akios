# AKIOS — Agentic Kit

A stack-agnostic agent workflow kit: brainstorm, plan, deliver, and keep the work grounded in
specs instead of improvising session by session. It works the same in a TypeScript service, a
Python pipeline, a Go CLI, or a Rust library — because it carries **process, not framework
knowledge**.

Akios is a full Claude Code plugin and a Codex-ready plugin. Claude Code gets the complete
`/akios:*` command surface and setup flow; Codex support exposes the shared skill family through
`.codex-plugin/plugin.json` while command/setup parity is still in progress.

## What it does

- **Brainstorm** (`/akios:brainstorm`) — turn a rough idea into an approved spec, decision by decision
- **Deep brainstorm** (`/akios:deep-brainstorm`) — map a whole product into a complete spec family in one session
- **Plan** (`/akios:plan`) — break the spec into a task backlog with estimates, checkpoints, and DoDs
- **Deliver** (`/akios:deliver`) — implement, test, and code-review each task; leave the diff for you to commit
- **Autonomous run** (`/akios:just-vibes`) — drive the whole pipeline unattended; the quality gate stays on

The kit ships a skill family (see the `skills/` directory for the current set) and a phase
contract (`workflow.yml`). Nothing else: no hooks, no shell scripts, no build step.

## How it stays stack-agnostic

The kit knows nothing about your language until `/akios:setup` asks. Everything it learns lands
in one file — `akios/Context.md` — which records your stack, your architecture, your module
boundaries, and, critically, your real install/test/build commands. Every phase reads its
invocations from there rather than guessing one.

The priority chain makes that explicit: **project decisions → your preferences → the model's
general knowledge**. That last tier is the floor, and it only answers when the two above it are
silent — what your repo already does outranks any general best practice.

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

`setup` interviews you, scans the repo, fills in templates, and creates the `akios/` folder tree
(`akios/specs/`, `akios/tasks/`, `akios/archive/`). No external dependencies required.

### Codex

Codex can install Akios as a plugin through the `.codex-plugin/plugin.json` manifest and use the
shared skills in `skills/`. This release does not claim full command parity yet: `/akios:setup`
and the rest of the slash-command flow are still Claude-first because they depend on `CLAUDE.md`,
`.claude/`, and `~/.claude`.

## Commands

| Command | What it does |
|---|---|
| `/akios:setup` | Onboard a repo — interview → scan → fill templates |
| `/akios:brainstorm "<idea>"` | Idea → approved spec in `akios/specs/` |
| `/akios:deep-brainstorm [focus]` | Map the whole product → a complete spec family in one session |
| `/akios:plan <spec>` | Spec → task backlog in `akios/tasks/todo/` |
| `/akios:deliver` | Implement tasks; hand the working tree back uncommitted |
| `/akios:just-vibes [idea]` | Full pipeline, unattended; `--force` to loop |
| `/akios:handoff` | Write a handoff doc for another agent session, or return results |

All commands are typed-only (`disable-model-invocation`) — they never auto-fire.

Codex note: treat the commands above as the Claude Code interface for now. In Codex, use the
installed Akios skills directly until the setup layer is ported to Codex-native paths.

## Who it's for

Any repo where work benefits from specs, a task backlog, and a repeatable idea-to-ship loop —
in any language. The gates are process gates, not language gates.

## Learn more

- **[START-HERE.md](START-HERE.md)** — first-time setup walkthrough + build your first feature
- **[CHANGELOG.md](CHANGELOG.md)** — what's new in each version
- **[CREDITS.md](CREDITS.md)** — attribution

---

MIT License · [Lucasdho](https://github.com/Lucasdho)
