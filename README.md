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

## Install into a repo
```sh
~/agentic-kit/install.sh /path/to/your/repo
```
Idempotent: never overwrites existing files, wires the hook once.
Then fill in the `{{...}}` placeholders in `Context.md` / `Skills.md`.

## Why a hook and not just docs
`AGENTS.md` is auto-loaded, but the per-task gates are easy to drift past
mid-session. The SessionStart hook re-states them in context every start —
cheap reinforcement, no framework.
