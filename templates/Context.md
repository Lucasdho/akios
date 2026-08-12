# Context.md — How this project works

> The first thing an agent reads. Keep it current; stale context is worse than none.
> **This is the only file in the kit that names a language, a framework, or a command.**
> Everything akios knows about this project's stack it learns from here.

## What this repo is
{{One line, in your own words: an app, a library, a CLI, a monorepo, infrastructure, a docs site,
a dataset, notes. akios assumes nothing about the kind of project this is.}}

## Stack
{{LANGUAGE / FRAMEWORK / RUNTIME / DB — as many as apply, or "none" per slot. "Markdown only" and
"several, per package" are both valid. A monorepo lists each stack with the path it governs.}}

## Commands
<!-- Load-bearing. Every phase reads its build/test invocation from this block rather than
     guessing one. Use the real, runnable strings — copy them from package.json / Makefile /
     the CI workflow, don't paraphrase.
     "none" is a correct answer, not a gap: write it for any slot this project genuinely lacks
     and the agent falls back to the DoD audit instead of inventing a command. A fabricated
     invocation here is the worst possible entry in this file.
     No test runner but some other verification (a link check, a schema validation, a lint)?
     Name that under Test — it is what "prove it works" means here.
     Monorepo? Repeat this block per package, headed by its path. -->
- Install: `{{install}}`
- Run / dev: `{{dev}}`
- Test: `{{test}}`
- Lint / format: `{{lint}}`
- Build: `{{build}}`

## Architecture
- `architecture: {{named architecture, e.g. mvvm | hexagonal | layered | none}}` — the signal every
  skill reads. akios imposes no architecture; this records the one the project already follows.
- {{One paragraph: entry points, key directories, how data flows.}}
- **Module boundaries:** {{what a "module"/"feature"/"slice" is called here, and what counts as its
  public surface vs. its internals. `spec-to-tasks` reuses this vocabulary for a task's `area:`,
  and the code-review gate uses it to judge boundary violations. Write "flat — no module boundaries"
  if the project has none.}}
- **Shared / common code:** {{where cross-cutting code lives, and the bar for putting something
  there. Write "none" if the project has no shared layer.}}

## Build & packaging notes
<!-- How a new file actually becomes part of the build — so the agent doesn't re-derive it each
     time. Delete this section if the project's build picks up files automatically. -->
- New file inclusion: {{automatic (glob/convention-based) | must be registered in <file>}}
- Test resources: {{where test fixtures live and how tests load them}}

## Conventions
- {{naming, error handling, commit style, branch naming}}

## Gotchas
- {{the thing that bites a newcomer / the agent}}
