# iOS Agentic Kit

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

## Full pipeline with speckit (optional)

The `ios-feature-pipeline` skill orchestrates the complete path from raw idea to
running code. When speckit is initialized in the project, the pipeline is:

| Phase | Tool | Mode |
|---|---|---|
| 1 — Design | `/idea-to-spec` | Interactive — user present, always |
| 2 — Clarify | `/speckit-clarify` | Automated |
| 3 — Specify | `/speckit-specify` | Automated |
| 4 — Plan | `/speckit-plan` | Automated — constitution enforces Axiom gates |
| 5 — Tasks | `/speckit-tasks` | Automated |
| 6 — Execute | `superpowers:subagent-driven-development` | Fresh subagents, Axiom domain skill per task |

Invoke `/ios-feature-pipeline` to get the full phase guide including subagent
context rules and the degraded path for projects without speckit.

To add the speckit workflow template to a project that has speckit initialized:
```sh
cp ~/iOS-agentic-kit/templates/workflows/ios-feature-pipeline.yml \
   /path/to/your/repo/.specify/workflows/
```
(Requires `npx speckit init` in the project first.)

## Install with a Claude Code agent (recommended)
Don't follow steps by hand — paste this prompt into Claude Code from inside the
repo you want to set up, and let the agent do it:

```text
Install the agentic-kit into this repo for me.

1. Get the kit. Clone it to ~/iOS-agentic-kit if it isn't there yet:
     git clone https://github.com/Lucasdho/iOS-agentic-kit.git ~/iOS-agentic-kit
   If the folder already exists, run `git -C ~/iOS-agentic-kit pull` to update.
2. Install the required skills: ~/iOS-agentic-kit/install-skills.sh
   It copies the authored skills (idea-to-spec, oss-first, ios-feature-pipeline,
   ios-agentic-kit) into ~/.claude/skills/, refreshing them from the repo. Then
   verify the REQUIRED plugins (superpowers, axiom) are available. If either is
   missing, give me the exact command and STOP until I confirm — don't continue
   without them:
     /plugin marketplace add obra/superpowers         &&  /plugin install superpowers
     /plugin marketplace add CharlesWiltgen/Axiom     &&  /plugin install axiom
   ponytail is OPTIONAL but recommended (efficiency overlay). Offer to install it,
   but don't STOP if it's missing:
     /plugin marketplace add DietrichGebert/ponytail  &&  /plugin install ponytail
3. Run: ~/iOS-agentic-kit/install.sh "$(pwd)"
   Installs at the git repo root by default; pass `--here <path>` to install in an
   exact subfolder (e.g. the app dir when it sits below .git). It drops CLAUDE.md
   (importing @AGENTS.md), AGENTS.md, Context.md, .claude/rules/swift.md,
   and wires the SessionStart hook. Idempotent; never overwrites existing files.

   BEFORE running it, ASK me three things (these shape what gets written, and a
   blind scan both wastes tokens and gets them wrong):
   a. **Folders** — which directories are the real source, and which to ignore
      (Pods, build output, generated, fixtures, vendored code). Don't read the
      ignored ones. If I don't answer, scan only obvious source dirs and skip the
      usual noise.
   b. **Architecture** — TCA, MVVM+C, MVVM, VIPER, MVC, or Vanilla? Or none yet?
      If I don't answer, infer from the code as cheaply as you can and default to
      proposing **MVVM** — state it as a suggestion, not a fact.
   c. **Target** — device family (iPhone / iPad / universal) and minimum OS.
      Confirm with me; read these from the APP target only. In an Xcode project the
      `*Tests`/`*UITests` targets carry Xcode's default deployment target and
      universal device family — never read the app's min OS or device family from
      a test target.
4. [Optional — full pipeline] If this repo uses speckit (.specify/ exists):
   Copy the pipeline workflow template:
     cp ~/iOS-agentic-kit/templates/workflows/ios-feature-pipeline.yml \
        "$(pwd)/.specify/workflows/"
   If speckit isn't initialized yet, run `npx speckit init` first.
5. Read the codebase (respecting 3a) and fill in every {{...}} placeholder in
   Context.md and AGENTS.md — stack, build/test/lint/run commands, architecture
   (from 3b), target (from 3c), conventions, project-specific gates. No {{...}} left.
6. Show me a summary of what changed and what you filled in.

Do not commit anything unless I ask.
```

## Install manually
```sh
# 1. get the kit
git clone https://github.com/Lucasdho/iOS-agentic-kit.git ~/iOS-agentic-kit
# 2. install the required skills into ~/.claude/skills/
~/iOS-agentic-kit/install-skills.sh
# 3. plug the kit into your repo
~/iOS-agentic-kit/install.sh /path/to/your/repo        # installs at the git root
# ~/iOS-agentic-kit/install.sh --here /path/to/subdir  # or install in an exact subfolder
```
`install.sh` is idempotent (never overwrites existing files, wires the hook once).
Then fill in the `{{...}}` placeholders in `Context.md` / `AGENTS.md`.

### Skills the kit needs
| Skill | Type | Role | How it installs |
|---|---|---|---|
| `ios-agentic-kit` | authored | This kit's own guide — gates, routing, install | refreshed to `~/.claude/skills/` by `install-skills.sh` |
| `idea-to-spec` | authored | Idea → versioned specs in `specs/` | refreshed to `~/.claude/skills/` by `install-skills.sh` |
| `oss-first` | authored | Force tool/lib search before hand-writing complex code | refreshed to `~/.claude/skills/` by `install-skills.sh` |
| `ios-feature-pipeline` | authored | Full-lifecycle orchestrator (idea → speckit → execute) | refreshed to `~/.claude/skills/` by `install-skills.sh` |
| `superpowers` | plugin (required) | brainstorming, debugging, TDD, verification | `/plugin marketplace add` + `/plugin install` |
| `axiom` | plugin (required) | Swift/iOS domain hubs (progressive closure) | `/plugin marketplace add` + `/plugin install` |
| `ponytail` | plugin *(optional, recommended)* | Laziness/efficiency, anti over-build — kit works without it | `/plugin marketplace add` + `/plugin install` |
| `/code-review`, `fewer-permission-prompts` | built-in | review the diff; trim permission prompts | ship with the Claude Code CLI |

Authored skills are tracked in `skills/` (the repo is their source of truth);
`install-skills.sh` overwrites the installed copies on every run so they never drift.
Credits & licenses for all of the above → [CREDITS.md](CREDITS.md).

## Staying up to date
The kit is versioned (`VERSION`). `install.sh` stamps the installed version into
`.claude/.agentic-kit-version` in each repo. To check whether a repo's install is
current — and whether your kit clone is behind GitHub:

```sh
~/iOS-agentic-kit/check-update.sh /path/to/your/repo   # or run with no arg in the repo
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
git -C ~/iOS-agentic-kit pull && ~/iOS-agentic-kit/install-skills.sh

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
