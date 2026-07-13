# ALVA integration — `spec-to-tasks`

`spec-to-tasks` is self-sufficient standalone; this file is its ALVA-architecture bridge. Read it
only when `akios/Context.md` declares `architecture: alva`. Without it, the SKILL.md body already
states the architecture-neutral fallback. Depth lives in `swift-dev`'s `alva-architecture` GUIDE
(`skills/swift-dev/skills/alva-architecture/GUIDE.md`) and `akios/specs/alva-adoption.md` — this
file does not restate the doctrine.

## Slice-folder `area` convention (step 2)
For a new or touched feature, a task's `area` follows the slice sub-folder it belongs to
(`Features/<F>/domain`, `.../data`, `.../presentation/<View>`, `.../contract`, `.../tests`) — not
an app-wide layer. A task never spans two features' internals; cross-feature work is a `contract/`
change on one side and a consumer change on the other, written as **separate** tasks.

## Foundation-consult DoD line (step 8)
Every task that creates a helper, protocol, or component gets this DoD line:

> consulted `Foundation/Design-tokens`/`Code-tokens` before writing new shared code — reused if
> found, else born inside this feature.

This is the executable form of ALVA P6 (`swift-dev`'s `alva-architecture` guide) — the task, not
the agent's judgment, carries the reminder forward into execution.

## `alva-architecture`-first tagging (step 9)
A task that scaffolds a new feature/slice, or touches `Router/`/`Container/`, is tagged
`alva-architecture` **first**, alongside whatever code-level guide (`swiftui-pro`, `swiftdata-pro`,
…) also applies.
