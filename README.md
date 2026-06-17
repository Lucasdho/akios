# agentic-kit

A meta-system you plug into any repo to make agentic coding more efficient.
It drops a `CLAUDE.md` that imports the operating manual, context files, a
path-scoped Swift rule, and a SessionStart hook that reminds the agent of the
default gates each session.

```
CLAUDE.md          @AGENTS.md import — the file Claude Code actually auto-loads
AGENTS.md          entry point — the loop, skill gates, and routing
Context.md         stack, commands, architecture, conventions
.claude/rules/swift.md   loads the Swift gate whenever a .swift file is read
```
Durable decisions are NOT a repo file — they live in Claude Code's native
auto-memory (`~/.claude/projects/<project>/memory/MEMORY.md`), which is written
automatically and survives compaction.

## When to use it
- **Use it in:** Swift / iOS / iPadOS / macOS repos you build with an agent.
  The gates are Swift-specific (swift-dev, SwiftUI design, Swift Testing).
- **Don't use it in:** non-Swift projects — the routing won't fit. Fork the
  structure (AGENTS.md + hook + your own gate table) instead.
- **One repo, one install.** It's per-project: each repo gets its own
  `AGENTS.md` / `Context.md` and its own SessionStart hook.

## How it's invoked
You don't "run" the kit — it shapes the agent's behavior passively:
1. **At session start**, Claude Code loads `CLAUDE.md`, which imports `@AGENTS.md`
   and `@Context.md` in full; the SessionStart hook re-states the gates; the
   always-on skills (`ponytail`, `superpowers`) self-activate via their own hooks.
   A **project-root** `CLAUDE.md` is also re-injected after `/compact` (a CLAUDE.md
   in a subdirectory is not — another reason install defaults to the git root).
2. **`AGENTS.md` orients** the agent: the loop, the gate table, routing.
3. **`.claude/rules/swift.md` fires per file**: whenever Claude reads a `.swift`
   file, the Swift gate (invoke `swift-dev`, `ponytail`) loads — even mid-session.
4. **Skills trigger themselves** by description, or you invoke one with `/skill-name`.
5. **`Context.md`** (project facts) rides into context via the `@Context.md` import;
   **native auto-memory** (`MEMORY.md`) carries durable decisions.

> Why `CLAUDE.md`: Claude Code auto-loads `CLAUDE.md`, not `AGENTS.md`. `install.sh`
> creates a `CLAUDE.md` that imports `@AGENTS.md` + `@Context.md` for you (or
> prepends any missing import to an existing one), so the gates and project context
> reach Claude Code by default — not just the hook reminder.

## Install with a Claude Code agent (recommended)
Don't follow steps by hand — paste this prompt into Claude Code from inside the
repo you want to set up, and let the agent do it:

```text
Install the agentic-kit into this repo for me.

1. Get the kit. Clone it to ~/iOS-agentic-kit if it isn't there yet:
     git clone https://github.com/Lucasdho/iOS-agentic-kit.git ~/iOS-agentic-kit
   If the folder already exists, run `git -C ~/iOS-agentic-kit pull` to update.
2. Install the required skills: ~/iOS-agentic-kit/install-skills.sh
   It copies the plain skills (swift-dev, idea-to-spec, oss-first) into
   ~/.claude/skills/. Then verify the two plugins (ponytail, superpowers) are
   actually available. If either is missing, give me the exact command to add it
   and STOP until I confirm — do not continue without every skill:
     /plugin marketplace add DietrichGebert/ponytail  &&  /plugin install ponytail
     /plugin marketplace add obra/superpowers         &&  /plugin install superpowers
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
4. Read the codebase (respecting 3a) and fill in every {{...}} placeholder in
   Context.md and AGENTS.md — stack, build/test/lint/run commands, architecture
   (from 3b), target (from 3c), conventions, project-specific gates. No {{...}} left.
5. Show me a summary of what changed and what you filled in.

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
| Skill | Type | How it installs |
|---|---|---|
| `swift-dev`, `idea-to-spec`, `oss-first` | plain skill | copied to `~/.claude/skills/` by `install-skills.sh` |
| `ponytail`, `superpowers` | plugin | `/plugin marketplace add` + `/plugin install` (printed by the script) |
| `/code-review`, `fewer-permission-prompts` | built-in | ship with the Claude Code CLI |

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

## Updating bundled skills
`skills-bundle.zip` is a snapshot — it does **not** track upstream. The bundled
third-party skills will drift from their sources over time. To refresh:

```sh
# plugins — update via their marketplaces in Claude Code, then they live in ~/.claude
/plugin update ponytail
/plugin update superpowers

# swift-dev sub-skills from twostraws/swift-agent-skills (per-skill, as needed)
npx skills add twostraws/swift-agent-skills --skill <name>

# standalone sub-skills
npx skills add arjitj2/swiftui-design-principles
npx skills add daetojemax/figma-to-swiftui-skill
```
Then re-snapshot: `./bundle-skills.sh && ./test-kit.sh`, and bump the date +
versions in [CREDITS.md](CREDITS.md). The snapshot date and pinned versions are
recorded there.

## Why a hook and not just docs
`AGENTS.md` is auto-loaded, but the per-task gates are easy to drift past
mid-session. The SessionStart hook re-states them in context every start —
cheap reinforcement, no framework.
