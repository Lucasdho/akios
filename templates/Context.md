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
- `architecture: {{alva | none}}` — the opt-in signal every skill reads. `alva` = this project
  adopted the kit's optional iOS vertical-slice doctrine (ALVA; full doctrine:
  `akios/specs/alva-architecture-doctrine.md`), so the ALVA scaffold, the Foundation usage-ledger,
  and the `alva-architecture` guide/gates apply. Anything else (`none` or a named architecture, e.g.
  `mvvm`, `tca`) means the agent follows the description below and **skips** the ledger and slice-shape
  gates. `/akios:setup` writes this line; default `none`.
- {{One paragraph: entry points, key directories, how data flows. Under `architecture: alva` this is
  the slice tree — `Router/ Container/ Foundation/ Features/<F>/`; otherwise describe your own shape.}}

## Xcode targets
<!-- How files get into a target — so the agent doesn't re-derive it each time. -->
- Target membership: {{synchronized groups (Xcode 16+, objectVersion ≥ 77) — drop files in <target-folder> and they auto-include (.swift compiled, others → bundle Resources), no .pbxproj edit | manual — files must be added to the target explicitly}}
- Test resources: {{where test fixtures live; tests read them via Bundle(for:) / Bundle.module}}
- `scratchs/` (top-level, rejected `ui-variations` rounds, ALVA only) is **excluded from every target** —
  compilable and previewable standalone, but never added to the app's target membership.

## Conventions
- {{naming, error handling, commit style, branch naming}}

## Gotchas
- {{the thing that bites a newcomer / the agent}}
