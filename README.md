# agentic-kit

A meta-system you plug into any repo to make agentic coding more efficient.
It drops a `CLAUDE.md` that imports the operating manual, context files, a
path-scoped Swift rule, and a SessionStart hook that reminds the agent of the
default gates each session.

```
CLAUDE.md          @AGENTS.md import — the file Claude Code actually auto-loads
AGENTS.md          entry point — the loop, skill gates, and routing
Context.md         stack, commands, architecture, conventions
Memory.md          durable decisions across sessions
.claude/rules/swift.md   loads the Swift gate whenever a .swift file is read
```

## When to use it
- **Use it in:** Swift / iOS / iPadOS / macOS repos you build with an agent.
  The gates are Swift-specific (swift-dev, SwiftUI design, Swift Testing).
- **Don't use it in:** non-Swift projects — the routing won't fit. Fork the
  structure (AGENTS.md + hook + your own gate table) instead.
- **One repo, one install.** It's per-project: each repo gets its own
  `AGENTS.md` / `Context.md` / `Memory.md` and its own SessionStart hook.

## How it's invoked
You don't "run" the kit — it shapes the agent's behavior passively:
1. **At session start**, Claude Code loads `CLAUDE.md`, which imports `@AGENTS.md`
   in full (and re-injects it after `/compact`); the SessionStart hook re-states
   the gates; the always-on skills (`ponytail`, `superpowers`) self-activate.
2. **`AGENTS.md` orients** the agent: the loop, the gate table, routing.
3. **`.claude/rules/swift.md` fires per file**: whenever Claude reads a `.swift`
   file, the Swift gate (invoke `swift-dev`, `ponytail`) loads — even mid-session.
4. **Skills trigger themselves** by description, or you invoke one with `/skill-name`.
5. **`Memory.md` / `Context.md`** carry project facts and decisions across sessions.

> Why `CLAUDE.md`: Claude Code auto-loads `CLAUDE.md`, not `AGENTS.md`. `install.sh`
> creates a `CLAUDE.md` that imports `@AGENTS.md` for you (or prepends the import
> to an existing one), so the gates reach Claude Code by default — not just the
> hook reminder.

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
   ~/.claude/skills/ and prints the marketplace commands for the two plugins
   (ponytail, superpowers) — run those /plugin commands so I have every skill.
3. Run: ~/iOS-agentic-kit/install.sh "$(pwd)"
   It drops CLAUDE.md (importing @AGENTS.md), AGENTS.md, Context.md, Memory.md,
   the .claude/rules/swift.md path-scoped rule, and wires the SessionStart hook
   into .claude/settings.json. Idempotent; it never overwrites existing files
   (an existing CLAUDE.md just gets the @AGENTS.md import prepended).
4. Read the codebase and fill in every {{...}} placeholder in Context.md and
   AGENTS.md — stack, build/test/lint/run commands, architecture, conventions,
   and any project-specific skill gates. Leave no {{...}} behind.
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
~/iOS-agentic-kit/install.sh /path/to/your/repo
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
