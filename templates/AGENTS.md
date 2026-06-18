# AGENTS.md — Agentic Operating Manual

Loaded every session via the project `CLAUDE.md`, which imports `@AGENTS.md`
(Claude Code reads CLAUDE.md, not this file directly; Codex and other agents read
AGENTS.md directly). This is the single source of truth for how to work here —
the skill gates live below, not in a separate file.

## The loop (every code task)
1. **Orient** → `Context.md` — stack, commands, architecture, conventions
   (auto-loaded for you via the `@Context.md` import in `CLAUDE.md`).
2. **Recall** → your native auto-memory (`MEMORY.md`, loaded automatically) for
   decisions already made. Don't relitigate them.
3. **Route** → the gate table below — which skill fits this task type.
4. **Work** → the smallest change that is correct.
5. **Record** → save durable decisions to auto-memory (Claude writes it itself;
   tell it "remember that …" for anything that should survive the session).

## Always on (Swift / iOS)
Big router skills, active every task — they redirect to the right internal guides:
- `superpowers` — process discipline (brainstorm, debug, TDD, verify).
- `ponytail` — efficiency: no over-building, no rewriting what already works.
- `axiom` — Swift/iOS domain skills with progressive closure; load the hub for your
  domain and it dispatches the right sub-skill: `axiom-swiftui` (views/layout) ·
  `axiom-concurrency` (async/await/actors) · `axiom-testing` (Swift Testing/XCTest) ·
  `axiom-swift` (language) · `axiom-data` (SwiftData/CoreData) · `axiom-xcode` (build/debug).

## How to execute (orchestration)
For *how* the work runs — not what to build — consult **`superpowers` first**.
It owns the execution playbook: context optimization, when and how to spawn
subagents, parallelizing fan-out work, writing and executing plans, and
subagent-driven development. Reach for it before improvising an approach to:
- splitting a task across parallel agents → `superpowers:dispatching-parallel-agents`
- driving a multi-step build through subagents → `superpowers:subagent-driven-development`
- turning a plan into reviewed execution → `superpowers:writing-plans` / `executing-plans`

Note: a spawned subagent starts cold — it does NOT inherit these gates. When you
dispatch one for gated work, restate the relevant gate in its prompt.

## Skill gates
The SessionStart hook re-states these every session, but it only reminds — it
does not enforce. Treat them as the default workflow; skip one only with reason.

| Trigger | Skill | When |
|---|---|---|
| Building a new feature end-to-end | `ios-feature-pipeline` → idea→spec→speckit→execute | before starting |
| Designing a system / turning an idea into a spec | `idea-to-spec` → write specs to `specs/` (see below) | before building |
| About to generate ANY code | plan mode OR `superpowers:brainstorming` | before code |
| About to hand-write complex code, docs, types, or a format conversion | `oss-first` — is there a mature tool/lib first? | before generating |
| Bug, crash, flake, regression | `superpowers:systematic-debugging` + `axiom-xcode` | before any fix |
| Implementing code | `ponytail` + `axiom` (domain skill) + `fewer-permission-prompts` | while coding |
| Creating / polishing SwiftUI Views | native first + `axiom-swiftui` (with ponytail) | before the view |
| Writing tests | `axiom-testing` | with the code |
| Claiming "done" | subagents: `superpowers:verification-before-completion` + `/code-review` | before finishing |

Axiom domain hubs use progressive closure — each hub (~400 words) dispatches to
sub-skills on demand. Only the relevant domain loads; context is not blown during
long plan and execution sessions.

## Specs (idea-to-spec)
When `idea-to-spec` produces specs:
- Store versioned specs in a `specs/` folder at the repo root — one file per domain.
- Keep an **orchestration doc** that registers every spec and the domain it owns,
  so specs don't overlap and the next session knows what already exists. Use the
  project `CLAUDE.md` for this (a `## Specs` section: spec file → domain → status),
  or `specs/INDEX.md` if you prefer to keep it out of `CLAUDE.md`.
- Before designing something new, read that orchestration doc first.

## Speckit integration (optional, enhances idea-to-spec)
When speckit is initialized in this repo (`.specify/` present), run the full
structured pipeline after `idea-to-spec` produces a spec:
- **`/speckit-clarify`** → resolves ambiguities
- **`/speckit-specify`** → structured spec with acceptance scenarios
- **`/speckit-plan`** → research + data model + constitution check (Axiom gates)
- **`/speckit-tasks`** → trackable task list ready for execution

Then execute with `superpowers:subagent-driven-development`. Include the relevant
Axiom domain skill in every subagent context block — subagents start cold.
The `ios-feature-pipeline` skill documents all phases and subagent context rules.

## Project-specific gates
{{e.g. "always /security-review when touching Keychain / auth / networking"}}

## House rules
- Shortest working diff. No speculative abstractions, no scaffolding "for later".
- One runnable check behind any non-trivial logic.
- Boring over clever. Deletion over addition.
- {{PROJECT_RULE — e.g. "never touch /migrations without a backup plan"}}
