---
name: spec-to-tasks
description: Turn an approved spec into a lean, executable backlog of task files under akios/tasks/todo/ in a single pass — the kit's plan phase. Use after idea-to-spec has produced akios/specs/<feature>.md and you need the execution backlog, or when a user runs /akios:plan. Stack-agnostic. Produces atomic task files with est_tokens + runner, parallel markers, checkpoint barriers, definitions of done, and per-task state coverage. Does NOT write code — it writes the plan that task-execution runs.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "3.0.0"
---

# Spec to Tasks — one pass, spec → akios/tasks/todo/

Turns an approved spec into the execution backlog for `task-execution`: **one task file per task
under `akios/tasks/todo/`**. One skill, one pass, one human confirm.

**Language-agnostic.** Areas, folders, and domain tags come from what `akios/Context.md` records
about *this* project's architecture. Never assume a stack, a folder convention, or a test runner.

## Inputs / output
- **In:** one or more approved `akios/specs/<feature>.md` (passed as `$ARGUMENTS`), plus `akios/Context.md`
  (architecture/conventions) and `MEMORY.md` (locked decisions). Read **only** these.
- **Out:** task files in `akios/tasks/todo/` (`T<NNN>-<slug>.md`, see the `task.md` template), and the
  spec's status set to `planned` in `akios/Roadmap.md`. No single `tasks.md`.

## The pass (do this in order, once)

1. **Read** the spec(s) + `akios/Context.md` + `MEMORY.md`. Nothing else. Don't re-clarify what the spec
   already settled — if something is genuinely ambiguous, ask one direct question, no clarify ceremony.
2. **Decompose by similarity + size.**
   - **Group by similarity** — same file / area / concern travels together. `area` follows the
     project's own structure as recorded in `akios/Context.md` `## Architecture`; never invent a
     folder convention the project doesn't use.
   - **Bound by size** — estimate each task's cost and keep it under the **80k soft ceiling**; split
     a task that would exceed it. Atomic = one coherent change with one Definition of Done.
3. **Estimate cost (rough proxy).** `est_tokens ≈ Σ touched-file sizes + description weight`. For
   **new** files, estimate from the spec description (acknowledged as rough). Record `est_tokens`
   on the task and derive `runner`: **`≤20k → orchestrator`** (always runs in the main session),
   **`>20k → subagent-eligible`**. This field sizes the task — it does not mandate dispatch;
   `task-execution` still applies `AGENTS.md`'s subagent-economy rule (session context pressure
   **and** an isolatable task) before actually dispatching one.

   *Worked example:* a task editing two existing files (~3k + ~5k tokens) plus one new ~4k-token
   module, with a two-sentence description (~0.1k) → `est_tokens ≈ 12k` → `runner: orchestrator`.
   A task touching six files across a data layer + its tests (~9k) plus a new ~15k-token
   migration path, description weight ~0.5k → `est_tokens ≈ 25k` → `runner: subagent-eligible`.
4. **Graph parallelism by area.** Tag a task `[P]` (`parallel: true`) only if it shares no files
   and no produced symbols with another `[P]` task in the same checkpoint — i.e. a **different
   area**. Same-area tasks **serialize**.
5. **Checkpoints = barriers.** Group tasks into checkpoints in execution order. A checkpoint is a
   point where all its in-flight `[P]` tasks must finish before continuing; each carries an
   **audit** (verify every DoD). Mark `[major]` when it completes a vertical slice — `[major]`
   runs the project's full test battery (`akios/Context.md` `## Commands`) before advancing.
6. **Build-order shape (bottom-up).** Decompose a feature so leaf pieces land before the things
   that compose them: independent leaf units (tagged `[P]` within a checkpoint) → the composition
   that uses them → the wiring that connects it to real data/services. Home each task where *this*
   project's architecture puts that kind of code, per `akios/Context.md` — never a folder shape
   imported from another project.
7. **Designer's-eye (mandatory for any user-facing or data-backed task).** Translate the spec's
   empty states into per-task acceptance criteria: every user-facing task's DoD covers **happy ·
   empty · loading/in-flight · error/offline**. A user-facing task whose DoD omits these is
   incomplete.
8. **Apply the data house rules** when scoping model/persistence tasks:
   - **Native types over wrappers** — the language's own identity/equality/serialization
     primitives first; a custom wrapper needs a one-line justification in the task.
   - **Interface-first repositories** — define the abstraction plus defaults; concretes implement
     it. A repository task's DoD includes "interface defined, defaults provided, equality +
     serialization round-trip covered."
9. **Point each task at the code it should follow** — the executor's subagent starts cold. When
   an existing file in the repo is the pattern to mirror, name it in the task's `## Files` section.
   When nothing in the repo is a precedent, say so; the executor falls through to its own general
   knowledge, which is the documented floor of the priority chain.
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
area: <project's own folder/module for this concern>   # same-area tasks serialize
checkpoint: 1               # [major] checkpoints run the test battery
---

# T001 — <one-line goal>
> **State:** todo                       # state is the folder: todo→in-progress→review→done

## Description … ## Files … ## Definition of Done … ## States … ## Notes
```

State is the **containing folder**; `task-execution` moves the file `todo → in-progress → review
→ done`. Checkpoint order and `[major]` markers are carried on each task's `checkpoint` field.

## Hand-off
`akios/tasks/todo/` is the sole input to `task-execution` (`/akios:deliver`). Stop after writing the
files + updating `akios/Roadmap.md`; tell the user the backlog is ready and that `/akios:deliver` ships it.

## Anti-patterns
Each is the inverse of a step above:
- Re-clarifying what the spec already settled.
- Assuming a folder layout, language, or test runner that `akios/Context.md` doesn't record.
- A task missing `est_tokens`/`runner`, a DoD, or (user-facing/data task) empty/loading/error coverage.
- More than one human confirm — one review, then write.
