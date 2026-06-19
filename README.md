# iOS Agentic Kit

> 👋 **New here, or not a command-line person?** Start with **[START-HERE.md](START-HERE.md)** —
> it sets you up and builds your first feature by pasting one block and answering plain
> questions. The rest of this README is the technical reference.

A meta-system you plug into any Swift/iOS repo to make agentic coding more efficient.
It drops a `CLAUDE.md` that imports the operating manual, context files, a
path-scoped Swift rule, and a SessionStart hook that reminds the agent of the
default gates each session.

```
CLAUDE.md          @AGENTS.md import — the file Claude Code actually auto-loads
AGENTS.md          entry point — the loop, skill gates, and routing
Context.md         stack, commands, architecture, conventions
.claude/rules/swift.md   loads the Axiom gate whenever a .swift file is read
```
Durable decisions are NOT a repo file — they live in Claude Code's native
auto-memory (`~/.claude/projects/<project>/memory/MEMORY.md`), which is written
automatically and survives compaction.

## When to use it
- **Use it in:** Swift / iOS / iPadOS / macOS repos you build with an agent.
  The gates are Swift-specific (Axiom domain skills, SwiftUI design, Swift Testing).
- **Don't use it in:** non-Swift projects — the routing won't fit. Fork the
  structure (AGENTS.md + hook + your own gate table) instead.
- **One repo, one install.** It's per-project: each repo gets its own
  `AGENTS.md` / `Context.md` and its own SessionStart hook.

## How it's invoked
You don't "run" the kit — it shapes the agent's behavior passively:
1. **At session start**, Claude Code loads `CLAUDE.md`, which imports `@AGENTS.md`
   and `@Context.md` in full; the SessionStart hook re-states the gates;
   `superpowers` self-activates via its own hook (and `ponytail` too, if installed —
   it's optional).
   A **project-root** `CLAUDE.md` is also re-injected after `/compact` (a CLAUDE.md
   in a subdirectory is not — another reason install defaults to the git root).
2. **`AGENTS.md` orients** the agent: the loop, the gate table, routing.
3. **`.claude/rules/swift.md` fires per file**: whenever Claude reads a `.swift`
   file, the Axiom gate loads — route to the domain hub, let it dispatch the right
   sub-skill (progressive closure, no context blowup).
4. **Skills trigger themselves** by description, or you invoke one with `/skill-name`.
5. **`Context.md`** (project facts) rides into context via the `@Context.md` import;
   **native auto-memory** (`MEMORY.md`) carries durable decisions.

> Why `CLAUDE.md`: Claude Code auto-loads `CLAUDE.md`, not `AGENTS.md`. `install.sh`
> creates a `CLAUDE.md` that imports `@AGENTS.md` + `@Context.md` for you (or
> prepends any missing import to an existing one), so the gates and project context
> reach Claude Code by default — not just the hook reminder.

## Full pipeline (idea → shipped code)

The `ios-feature-pipeline` skill orchestrates the complete path in **three lean phases** — no
speckit, no `.specify/`, no constitution (v2 dropped them: design rigor already lives in
`idea-to-spec`, quality gates in `AGENTS.md` + axiom + ponytail + `/code-review`):

| Phase | Tool | Mode | Produces |
|---|---|---|---|
| 1 — Design | `idea-to-spec` (`/akios:define`) | Interactive — user present, always | `specs/<feature>.md` |
| 2 — Plan | `spec-to-tasks` (`/akios:plan`) | One pass, one confirm | `tasks.md` (`[P]` markers, checkpoints, DoDs, UI states) |
| 3 — Execute | `task-execution` (`/akios:deliver`) | Branch, checkpoint commits, verify + review | Implemented, reviewed feature |

`spec-to-tasks` collapses what used to be four speckit phases into one pass. `task-execution`
runs the backlog on a per-spec branch, commits at each checkpoint, runs the unit + integration
battery at `[major]` checkpoints, and stops at a hard human gate before any push or merge.
Subagents are opt-in (each task is pre-tagged with its Axiom domain skill); execution never
depends on them. Invoke `/ios-feature-pipeline` for the full phase guide.

## Install as a plugin (recommended)
The kit ships as a Claude Code plugin, **`akios`**. Two lines inside Claude Code:

```text
/plugin marketplace add Lucasdho/iOS-agentic-kit
/plugin install akios
```

This installs the authored skills and registers four typed commands. Then, **inside the
repo you want to set up**, run `/akios:init` — it interviews you, scans the repo, fills the
`{{...}}` placeholders, wires the gate hook, and checks dependencies. (Plugins can't
auto-install other plugins, so `init` prints the install lines for the required
`superpowers` + `axiom` and optional `ponytail`.)

### Commands
| Command | What it does | Pipeline phase |
|---|---|---|
| `/akios:init` | Onboard this repo (interview → scan → fill files → wire hooks → check deps) | — |
| `/akios:define "<idea>"` | Turn a feature idea into an approved spec | 1 (`idea-to-spec`) |
| `/akios:plan <spec>` | Spec → task backlog in one pass (`spec-to-tasks`) | 2 |
| `/akios:deliver <tasks.md>` | Implement, test, review; stop before push/merge (`task-execution`) | 3 |

All four are typed-only (`disable-model-invocation`) — they never auto-fire. The three
pipeline commands are thin wrappers over `ios-feature-pipeline`; they guard for an
initialized repo and send you to `/akios:init` if needed.

## Install with a Claude Code agent
Paste a single setup prompt into Claude Code from inside the repo you want to set up, and
let the agent clone the kit, install the skills, check the plugins, run `install.sh`, and
fill in the templates — asking you about folders, architecture, and target along the way.

The ready-to-paste block (plain-language framed) lives in **[START-HERE.md](START-HERE.md)
§ 2** — single source for the agent install, so the novice path and this one don't drift.

## Install manually (cross-agent / no plugin)
For Codex, Gemini, or any non-plugin setup — a plugin command can't write into your repo,
so these scripts drop the same context files directly:
```sh
# 1. get the kit
git clone https://github.com/Lucasdho/iOS-agentic-kit.git ~/iOS-agentic-kit
# 2. install the required skills into ~/.claude/skills/
~/iOS-agentic-kit/scripts/install-skills.sh
# 3. plug the kit into your repo
~/iOS-agentic-kit/scripts/install.sh /path/to/your/repo        # installs at the git root
# ~/iOS-agentic-kit/scripts/install.sh --here /path/to/subdir  # or install in an exact subfolder
```
`install.sh` is idempotent (never overwrites existing files, wires the hook once).
Then fill in the `{{...}}` placeholders in `Context.md` / `AGENTS.md`.

### Skills the kit needs
| Skill | Type | Role | How it installs |
|---|---|---|---|
| `ios-agentic-kit` | authored | This kit's own guide — gates, routing, install | refreshed to `~/.claude/skills/` by `install-skills.sh` |
| `idea-to-spec` | authored | Idea → versioned specs in `specs/` | refreshed to `~/.claude/skills/` by `install-skills.sh` |
| `oss-first` | authored | Force tool/lib search before hand-writing complex code | refreshed to `~/.claude/skills/` by `install-skills.sh` |
| `ios-feature-pipeline` | authored | 3-phase orchestrator (idea-to-spec → spec-to-tasks → task-execution) | refreshed to `~/.claude/skills/` by `install-skills.sh` |
| `spec-to-tasks` | authored | One-pass spec → `tasks.md` (replaces speckit) | refreshed to `~/.claude/skills/` by `install-skills.sh` |
| `task-execution` | authored | Run `tasks.md` → committed, reviewed code (replaces subagent-driven-development) | refreshed to `~/.claude/skills/` by `install-skills.sh` |
| `superpowers` | plugin (required) | brainstorming, debugging, TDD, verification | `/plugin marketplace add` + `/plugin install` |
| `axiom` | plugin (required) | Swift/iOS domain hubs (progressive closure) | `/plugin marketplace add` + `/plugin install` |
| `ponytail` | plugin *(optional, recommended)* | Laziness/efficiency, anti over-build — kit works without it | `/plugin marketplace add` + `/plugin install` |
| `/code-review`, `fewer-permission-prompts` | built-in | review the diff; trim permission prompts | ship with the Claude Code CLI |

Authored skills are tracked in `skills/` (the repo is their source of truth). Installing the
`akios` plugin ships them automatically; `install-skills.sh` is only for the manual /
cross-agent path, overwriting the installed copies on every run so they never drift.
Credits & licenses for all of the above → [CREDITS.md](CREDITS.md).

## Staying up to date
The kit is versioned (`VERSION`). `install.sh` stamps the installed version into
`.claude/.agentic-kit-version` in each repo. To check whether a repo's install is
current — and whether your kit clone is behind GitHub:

```sh
~/iOS-agentic-kit/scripts/check-update.sh /path/to/your/repo   # or run with no arg in the repo
```
It reports two things and exits non-zero if either is stale:
- **kit:** whether your `~/iOS-agentic-kit` clone is behind its remote (→ `git pull`).
- **project:** whether the repo's stamped version matches the kit (→ re-run `install.sh`).

A repo installed before versioning shows "no kit install / installed before
versioning" — just re-run `install.sh` to update and stamp it.

> Maintainer: bump `VERSION` whenever you change templates, the hook, the rule,
> or install logic, so downstream `check-update.sh` flags the staleness.

## Updating skills
The authored skills live in `skills/` and are the repo's source of truth; the
plugins are installed and updated through their marketplaces. To refresh:

```sh
# authored skills (idea-to-spec, oss-first, ios-feature-pipeline, ios-agentic-kit)
# pull the latest kit; install-skills.sh overwrites the installed copies
git -C ~/iOS-agentic-kit pull && ~/iOS-agentic-kit/scripts/install-skills.sh

# plugins — update via their marketplaces in Claude Code
/plugin update ponytail
/plugin update superpowers
/plugin update axiom
```
The plugin versions this kit was validated against are pinned in
[CREDITS.md](CREDITS.md); update them there when you re-pin.

## Why a hook and not just docs
`AGENTS.md` is auto-loaded, but the per-task gates are easy to drift past
mid-session. The SessionStart hook re-states them in context every start —
cheap reinforcement, no framework.
