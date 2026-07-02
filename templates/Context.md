# Context.md — How this project works

> The first thing an agent reads. Keep it current; stale context is worse than none.

## Stack
{{LANGUAGE / FRAMEWORK / RUNTIME / DB}}

## Commands
- Install: `{{install}}`
- Run / dev: `{{dev}}`
- Test: `{{test}}`
- Lint / format: `{{lint}}`
- Build: `{{build}}`

## Architecture
{{One paragraph: entry points, key directories, how data flows.}}

## Xcode targets
<!-- How files get into a target — so the agent doesn't re-derive it each time. -->
- Target membership: {{synchronized groups (Xcode 16+, objectVersion ≥ 77) — drop files in <target-folder> and they auto-include (.swift compiled, others → bundle Resources), no .pbxproj edit | manual — files must be added to the target explicitly}}
- Test resources: {{where test fixtures live; tests read them via Bundle(for:) / Bundle.module}}
- `scratchs/` (top-level, rejected `ui-variations` rounds) is **excluded from every target** —
  compilable and previewable standalone, but never added to the app's target membership.

## Conventions
- {{naming, error handling, commit style, branch naming}}

## Gotchas
- {{the thing that bites a newcomer / the agent}}
