# AGENTS.md — Agentic Operating Manual

Auto-loaded every session (Claude Code, Codex, etc. read AGENTS.md). This is the
entry point. Read the linked files before touching code.

## The loop (every code task)
1. **Orient** → `Context.md` — stack, commands, architecture, conventions.
2. **Recall** → `Memory.md` — decisions already made. Don't relitigate them.
3. **Route** → `Skills.md` — which skills are mandatory for this task type.
4. **Work** → the smallest change that is correct.
5. **Record** → append new durable decisions to `Memory.md`.

## Always on (Swift / iOS)
`superpowers` · `ponytail` · `swift-dev` — big router skills, active every task.

## Mandatory skill gates
Do not skip. If a gate applies, invoke the skill BEFORE writing code.

| Trigger | Skill | When |
|---|---|---|
| About to generate ANY code | plan mode OR `superpowers:brainstorming` | before code |
| Bug, crash, flake, regression | `superpowers:systematic-debugging` + `swift-dev`→ios-debugger-agent | before any fix |
| Implementing code | `ponytail` + `swift-dev` writing standards + `fewer-permission-prompts` | while coding |
| Creating SwiftUI Views | native first + `swiftui-design-skill` (with ponytail + swift-dev) | before the view |
| Writing tests | `swift-dev` → swift-testing-pro | with the code |
| Claiming "done" | subagents: `superpowers:verification-before-completion` + `/code-review` | before finishing |

Full routing table → `Skills.md`.

## House rules
- Shortest working diff. No speculative abstractions, no scaffolding "for later".
- One runnable check behind any non-trivial logic.
- Boring over clever. Deletion over addition.
- {{PROJECT_RULE — e.g. "never touch /migrations without a backup plan"}}
