# AGENTS.md — Agentic Operating Manual

Auto-loaded every session (Claude Code, Codex, etc. read AGENTS.md). This is the
single source of truth for how to work here — the skill gates live below, not in
a separate file.

## The loop (every code task)
1. **Orient** → `Context.md` — stack, commands, architecture, conventions.
2. **Recall** → `Memory.md` — decisions already made. Don't relitigate them.
3. **Route** → the gate table below — which skill fits this task type.
4. **Work** → the smallest change that is correct.
5. **Record** → append new durable decisions to `Memory.md`.

## Always on (Swift / iOS)
Big router skills, active every task — they redirect to the right internal guides:
- `superpowers` — process discipline (brainstorm, debug, TDD, verify).
- `ponytail` — efficiency: no over-building, no rewriting what already works.
- `swift-dev` — master router for all Swift/iOS work; loads the right guides.

## Skill gates
The SessionStart hook re-states these every session, but it only reminds — it
does not enforce. Treat them as the default workflow; skip one only with reason.

| Trigger | Skill | When |
|---|---|---|
| Designing a system / turning an idea into a spec | `idea-to-spec` → write specs to `specs/` (see below) | before building |
| About to generate ANY code | plan mode OR `superpowers:brainstorming` | before code |
| About to hand-write complex code, docs, types, or a format conversion | `oss-first` — is there a mature tool/lib first? | before generating |
| Bug, crash, flake, regression | `superpowers:systematic-debugging` + `swift-dev`→ios-debugger-agent | before any fix |
| Implementing code | `ponytail` + `swift-dev` writing standards + `fewer-permission-prompts` | while coding |
| Creating / polishing SwiftUI Views | native first + `swift-dev`→swiftui-design-principles (with ponytail) | before the view |
| Writing tests | `swift-dev`→swift-testing-pro | with the code |
| Claiming "done" | subagents: `superpowers:verification-before-completion` + `/code-review` | before finishing |

`swift-dev` auto-routes its own sub-skills (figma-to-swiftui · ios-accessibility ·
ios-debugger-agent · swift-concurrency-pro · swift-testing-pro · swiftdata-pro ·
swiftui-design-principles · swiftui-performance-audit · swiftui-pro ·
swiftui-ui-patterns · swiftui-view-refactor) — you don't invoke those directly.

## Specs (idea-to-spec)
When `idea-to-spec` produces specs:
- Store versioned specs in a `specs/` folder at the repo root — one file per domain.
- Keep an **orchestration doc** that registers every spec and the domain it owns,
  so specs don't overlap and the next session knows what already exists. Use the
  project `CLAUDE.md` for this (a `## Specs` section: spec file → domain → status),
  or `specs/INDEX.md` if you prefer to keep it out of `CLAUDE.md`.
- Before designing something new, read that orchestration doc first.

## Project-specific gates
{{e.g. "always /security-review when touching Keychain / auth / networking"}}

## House rules
- Shortest working diff. No speculative abstractions, no scaffolding "for later".
- One runnable check behind any non-trivial logic.
- Boring over clever. Deletion over addition.
- {{PROJECT_RULE — e.g. "never touch /migrations without a backup plan"}}
