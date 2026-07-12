---
name: spec-to-tasks
description: Turn an approved spec into a lean, executable backlog of task files under akios/tasks/todo/ in a single pass — the plan phase for Swift/iOS work. Use after idea-to-spec has produced akios/specs/<feature>.md and you need the execution backlog, or when a user runs /akios:plan. Produces atomic task files with est_tokens + runner, parallel markers, checkpoint barriers, definitions of done, and per-task UI-state coverage. Does NOT write app code — it writes the plan that task-execution runs.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "2.0.0"
---

# Spec to Tasks — one pass, spec → akios/tasks/todo/

Turns an approved spec into the execution backlog for `task-execution`: **one task file per task
under `akios/tasks/todo/`**. One skill, one pass, one human confirm — no multi-phase ceremony and no
scaffold directory or second spec format to bootstrap; this skill neither creates nor needs one.

**Why it exists:** `idea-to-spec` already resolves ambiguity decision-by-decision upstream, and
the kit's gates (`AGENTS.md` house rules, `swift-dev`, `/code-review`) enforce quality downstream.
This skill does the one thing that was missing: decompose the spec into runnable, sized tasks.

## Inputs / output
- **In:** one or more approved `akios/specs/<feature>.md` (passed as `$ARGUMENTS`), plus `akios/Context.md`
  (architecture/conventions) and `MEMORY.md` (locked decisions). Read **only** these.
- **Out:** task files in `akios/tasks/todo/` (`T<NNN>-<slug>.md`, see the `task.md` template), and the
  spec's status set to `planned` in `akios/Roadmap.md`. No single `tasks.md`.

## The pass (do this in order, once)

1. **Read** the spec(s) + `akios/Context.md` + `MEMORY.md`. Nothing else. Don't re-clarify what the spec
   already settled — if something is genuinely ambiguous, ask one direct question, no clarify ceremony.
2. **Decompose by similarity + size.** (The area convention below assumes `architecture: alva`; for
   any other architecture, `area` follows the project's own structure as described in `akios/Context.md`.)
   - **Group by similarity** — same file / area / concern travels together. Under `architecture: alva`,
     for a new or touched feature, `area` follows the slice sub-folder it belongs to
     (`Features/<F>/domain`, `.../data`, `.../presentation/<View>`, `.../contract`, `.../tests`) — not
     an app-wide layer; a task never spans two features' internals, and cross-feature work is a
     `contract/` change on one side and a consumer change on the other, as separate tasks.
   - **Bound by size** — estimate each task's cost and keep it under the **80k soft ceiling**; split
     a task that would exceed it. Atomic = one coherent change with one Definition of Done.
3. **Estimate cost (rough proxy).** `est_tokens ≈ Σ touched-file sizes + description weight`. For
   **new** files, estimate from the spec description (acknowledged as rough). Record `est_tokens`
   on the task and derive `runner`: **`≤20k → orchestrator`** (always runs in the main session),
   **`>20k → subagent-eligible`**. This field sizes the task — it does not mandate dispatch;
   `task-execution` still applies `AGENTS.md`'s subagent-economy rule (session context pressure
   **and** an isolatable task) before actually dispatching one.

   *Worked example:* a task editing two existing files (~3k + ~5k tokens) plus one new ~4k-token
   view, with a two-sentence description (~0.1k) → `est_tokens ≈ 12k` → `runner: orchestrator`.
   A task touching six files across a data layer + its tests (~9k) plus a new ~15k-token
   migration path, description weight ~0.5k → `est_tokens ≈ 25k` → `runner: subagent-eligible`.
4. **Graph parallelism by area.** Tag a task `[P]` (`parallel: true`) only if it shares no files
   and no produced symbols with another `[P]` task in the same checkpoint — i.e. a **different
   area**. Same-area tasks **serialize**.
5. **Checkpoints = barriers.** Group tasks into checkpoints in execution order. A checkpoint is a
   point where all its in-flight `[P]` tasks must finish before continuing; each carries an
   **audit** (verify every DoD). Mark `[major]` when it completes a vertical slice — `[major]`
   runs the unit + integration test battery before advancing.
5b. **UI build-order stage shape.** A screen-touching task decomposes into the A3 stages,
   named explicitly and homed where the project's architecture puts view code (under
   `architecture: alva`, nested *inside* `presentation/<View>/`; otherwise the project's own UI folder):
   `components [P] (swiftui-pro)` → `ui-variations dumb-screen (design phase)` → `make-it-live
   (wiring, deliver phase)`. The middle stage is always `ui-variations` — never a retired skill
   (`html-to-swiftui`, `visual-grounding`) or the parked `figma-to-swiftui`. Components tagged
   `[P]` within the same checkpoint are independent leaf pieces; the dumb-screen and make-it-live
   stages serialize after them.
6. **Designer's-eye (mandatory for any UI- or data-backed task).** Translate the spec's empty
   states into per-task acceptance criteria: every screen-touching task's DoD covers **happy ·
   empty · loading/in-flight · error/offline**. A UI task whose DoD omits these is incomplete.
7. **Apply the data house rules** when scoping model/persistence tasks:
   - **Native types over wrappers** — Swift's own `id`/`UUID`/`Hashable`/`Codable` first; a wrapper
     needs a one-line justification in the task.
   - **Protocol-first repositories** — `protocol` + defaults; concretes inherit. A repository task's
     DoD includes "protocol defined, defaults provided, `Hashable` + JSON↔object round-trip covered."
8. **Foundation-consult step (`architecture: alva` only; every task that creates a helper, protocol,
   or component).** Add a DoD line: "consulted `Foundation/Design-tokens`/`Code-tokens` before writing
   new shared code — reused if found, else born inside this feature." This is the executable form of
   ALVA P6 (`swift-dev`'s `alva-architecture` guide) — the task, not the agent's judgment, is what
   carries the reminder forward into execution. **Under any other architecture, omit this DoD line**
   and let reuse follow the project's own convention.
9. **Tag each task with its knowledge pack + domain sub-skill** (routing below) — the executor's
   subagent starts cold and must load it. Every task carries a `pack:<domain>` tag, defaulting to
   `pack:ios` for a Swift repo; a task also touching a second domain (e.g. a DDD-modeled feature)
   carries both (`pack:ios` + `pack:ddd`). For the `ios` pack, the concrete reference is
   `swift-dev`'s bundled guide — tag the `swift_dev:` sub-skill exactly as before; a non-`ios`
   pack's concrete reference is its own `INDEX.md`-selected file (`knowledge-architecture.md`
   §1/§2). **Under `architecture: alva`**, a task that scaffolds a new feature/slice, or touches
   `Router/`/`Container/`, is tagged `alva-architecture` first, alongside whatever code-level guide
   also applies; under any other architecture there is no such tag.
10. **One interactive confirm.** Show the checkpoint/task graph + est_tokens/runner + designer's-eye
    coverage compactly. Get a yes or adjustments. *Then* write the task files into `akios/tasks/todo/`.

## Task file format
One file per task in `akios/tasks/todo/`, following `templates/task.md`:

```markdown
---
id: T001
spec: akios/specs/<feature>.md
est_tokens: 14k
runner: orchestrator        # ≤20k orchestrator · >20k subagent-eligible
parallel: true              # true = [P]; shares no files/symbols with siblings this checkpoint
area: Squad/presentation/SquadList   # slice sub-folder; same-area tasks serialize
checkpoint: 1               # [major] checkpoints run the test battery
pack: pack:ios              # knowledge pack(s) the cold subagent loads; default pack:ios, add a 2nd (pack:ios pack:ddd) for a cross-domain task
swift_dev: swiftui-pro      # domain sub-skill the cold subagent must load
---

# T001 — <one-line goal>
> **State:** todo                       # state is the folder: todo→in-progress→review→done

## Description … ## Files … ## Definition of Done … ## UI states … ## Notes
```

State is the **containing folder**; `task-execution` moves the file `todo → in-progress → review
→ done`. Checkpoint order and `[major]` markers are carried on each task's `checkpoint` field.

## swift-dev domain routing (tag every task)

| Task type | swift-dev sub-skill |
|---|---|
| New feature/slice scaffold, DI wiring, navigation/coordinators | `alva-architecture` |
| Views, SwiftUI layouts, previews | `swiftui-pro` |
| async/await, actors, Sendable, concurrency | `swift-concurrency-pro` |
| Unit tests, Swift Testing | `swift-testing-pro` |
| SwiftData, persistence, migrations | `swiftdata-pro` |
| VoiceOver, Dynamic Type, a11y | `ios-accessibility` |
| Run / build / debug behavior | `ios-debugger-agent` |
| UI polish, widgets, design | `swiftui-design-principles` |

## Posture (learning vs. delivery)
Read `akios/Roadmap.md`'s `posture` flag the same way every phase does (see `AGENTS.md`
"Operating posture" / `akios/specs/operating-modes.md` §3 for the flag mechanic). The
phase-specific delta: in **learning** mode the step-10 confirm also states *why* the graph came
out this way — why these checkpoint boundaries, why a task is `[P]` (or isn't), why it carries the
`pack:<domain>` tag it does. **Delivery** (default) shows the graph without that commentary. Never
changes the decomposition — same tasks, checkpoints, and tags in both postures.

## Hand-off
`akios/tasks/todo/` is the sole input to `task-execution` (`/akios:deliver`). Stop after writing the
files + updating `akios/Roadmap.md`; tell the user the backlog is ready and that `/akios:deliver` ships it.

## Anti-patterns
Each is the inverse of a step above:
- Creating a scaffold directory or any other second formal spec format.
- Re-clarifying what the spec already settled.
- A task missing `est_tokens`/`runner`, a DoD, or (UI/data task) empty/loading/error coverage.
- **More than one human confirm** — one review, then write. *(net-new)*
