# agentic-kit

A meta-system you plug into any repo to make agentic coding more efficient.
It drops four context files at the repo root and a SessionStart hook that
re-injects the mandatory skill gates every session.

```
AGENTS.md   entry point, auto-loaded by the agent — the loop + skill gates
Context.md  stack, commands, architecture, conventions
Memory.md   durable decisions across sessions
Skills.md   which skills are mandatory per task type
```

## Install with a Claude Code agent (recommended)
Don't follow steps by hand — paste this prompt into Claude Code from inside the
repo you want to set up, and let the agent do it:

```text
Install the agentic-kit into this repo for me.

1. Get the kit. Clone it to ~/iOS-agentic-kit if it isn't there yet:
     git clone https://github.com/Lucasdho/iOS-agentic-kit.git ~/iOS-agentic-kit
   If the folder already exists, run `git -C ~/iOS-agentic-kit pull` to update.
2. Install the required skills: ~/iOS-agentic-kit/install-skills.sh
   It copies the plain skills (swift-dev, swiftui-design-skill) into
   ~/.claude/skills/ and prints the marketplace commands for the two plugins
   (ponytail, superpowers) — run those /plugin commands so I have every skill.
3. Run: ~/iOS-agentic-kit/install.sh "$(pwd)"
   It copies AGENTS.md, Context.md, Memory.md, Skills.md to the repo root and
   wires the SessionStart reinforcement hook into .claude/settings.json. It is
   idempotent and never overwrites existing files.
4. Read the codebase and fill in every {{...}} placeholder in Context.md and
   Skills.md — stack, build/test/lint/run commands, architecture, conventions,
   and any project-specific skill overrides. Leave no {{...}} behind.
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
Then fill in the `{{...}}` placeholders in `Context.md` / `Skills.md`.

### Skills the kit needs
| Skill | Type | How it installs |
|---|---|---|
| `swift-dev`, `swiftui-design-skill` | plain skill | copied to `~/.claude/skills/` by `install-skills.sh` |
| `ponytail`, `superpowers` | plugin | `/plugin marketplace add` + `/plugin install` (printed by the script) |
| `/code-review`, `fewer-permission-prompts` | built-in | ship with the Claude Code CLI |

Credits & licenses for all of the above → [CREDITS.md](CREDITS.md).

## Why a hook and not just docs
`AGENTS.md` is auto-loaded, but the per-task gates are easy to drift past
mid-session. The SessionStart hook re-states them in context every start —
cheap reinforcement, no framework.
