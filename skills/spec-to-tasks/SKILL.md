---
name: spec-to-tasks
description: Turn an approved spec into a lean, executable tasks.md in a single pass — replaces speckit's clarify/specify/plan/tasks phases for Swift/iOS work. Use after idea-to-spec has produced specs/<feature>.md and you need the execution backlog, or when a user runs /akios:plan. Produces atomic tasks with parallel markers, checkpoint barriers, definitions of done, and per-task UI-state coverage. Does NOT write app code — it writes the plan that task-execution runs.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "1.0.0"
---

# Spec to Tasks — one pass, spec → tasks.md

Turns an approved spec into `tasks.md`: the execution backlog for `task-execution`. **One skill,
one pass, one human confirm** — this replaces speckit's four phases (clarify/specify/plan/tasks)
and its `.specify/` + constitution machinery, none of which this skill creates or needs.

**Why it exists:** `idea-to-spec` already resolves ambiguity decision-by-decision upstream, and
the kit's gates (AGENTS.md house rules, axiom, ponytail, `/code-review`) already enforce quality
downstream. Speckit re-did both — a second spine bolted on the first, burning tokens to
re-formalize an already-formal spec and offering web/backend folder trees wrong for iOS. This
skill does the one thing that was actually missing: decompose the spec into runnable tasks.

## Inputs / output
- **In:** one or more approved `specs/<feature>.md` (passed as `$ARGUMENTS`), plus `Context.md`
  (architecture/conventions) and `MEMORY.md` (locked decisions). Read **only** these.
- **Out:** `tasks.md` at repo root. No `.specify/`, no constitution, no extra artefacts.

## The pass (do this in order, once)

1. **Read** the spec(s) + `Context.md` + `MEMORY.md`. Nothing else. Don't re-clarify what the
   spec already settled — if something is genuinely ambiguous, ask the user one direct question,
   don't spawn a clarify ceremony.
2. **Decompose** into atomic tasks. Atomic = one coherent change with one Definition of Done. If a
   task needs two unrelated DoDs, split it. Smallest task that's independently verifiable wins.
3. **Graph dependencies.** Tag every task that can run alongside its siblings `[P]`. A task is
   `[P]` only if it shares no files and no produced symbols with another `[P]` task in the same
   checkpoint.
4. **Checkpoints = barriers.** Group tasks into checkpoints. A checkpoint is a point where all its
   in-flight `[P]` tasks must finish before continuing. Each checkpoint carries an **audit**
   (verify every task's DoD). Mark a checkpoint `[major]` when it completes a vertical slice —
   `[major]` checkpoints run the **unit + integration test battery** before advancing.
5. **Designer's-eye (mandatory for any UI- or data-backed task).** `idea-to-spec` already requires
   empty states in the spec. Translate them into per-task acceptance criteria: every
   screen-touching task's DoD must cover **happy path · empty state · loading/in-flight ·
   error/offline** (e.g. spinner while a request is in flight, a connection-error warning). A UI
   task whose DoD omits these is incomplete — add them.
6. **Apply the data house rules** when scoping model/persistence tasks (these live in `AGENTS.md`,
   restated here so the backlog is self-contained):
   - **Native types over wrappers** — use Swift's own `id`/`UUID`/`Hashable`/`Codable` before
     writing a wrapper; a wrapper needs a one-line justification in the task.
   - **Protocol-first repositories** — define a `protocol` + default implementations; concretes
     inherit. A repository task's DoD includes "protocol defined, defaults provided, `Hashable` +
     JSON↔object round-trip covered."
7. **Tag each task with its axiom domain skill** (routing table below) — the executor's subagent
   starts cold and must load it.
8. **One interactive confirm.** Show the user the checkpoint/task graph + the designer's-eye
   coverage in a compact form. Get a yes or adjustments. *Then* write `tasks.md`. This single stop
   replaces speckit's four.

## tasks.md format

```markdown
---
feature: <name>
spec: specs/<feature>.md
branch: feature/<feature>        # task-execution creates this; never main
---

## Checkpoint 1 — <name>          # add [major] to run the test battery here
- [ ] T001 [P] <one-line goal>    files: <paths>   axiom: axiom-swiftui
        DoD: <bullet> · <bullet>
        UI states: happy / empty / loading / error      # UI/data tasks only
- [ ] T002    <one-line goal>     files: <paths>   axiom: axiom-data
        DoD: protocol defined · defaults provided · Hashable + JSON round-trip
  ↳ barrier: audit all DoDs → commit "checkpoint: <name>"   (+ battery if [major])

## Checkpoint 2 — <name> [major]
...
```

Rules: ids are `T001…` sequential; `[P]` = parallel-safe; one DoD block per task; checkpoints in
execution order; the `↳ barrier` line states what `task-execution` does at the boundary.

## Axiom domain skill routing (tag every task)

| Task type | axiom skill |
|---|---|
| Views, SwiftUI layouts, previews | `axiom-swiftui` |
| async/await, actors, Sendable, concurrency | `axiom-concurrency` |
| Unit tests, Swift Testing, XCTest | `axiom-testing` |
| Swift language patterns, types, protocols | `axiom-swift` |
| SwiftData, CoreData, persistence, migrations | `axiom-data` |
| Build system, Xcode config, schemes, debug | `axiom-build` |

## Hand-off
`tasks.md` is the sole input to `task-execution` (`/akios:deliver`). Stop after writing it; tell
the user it's ready and that `/akios:deliver` ships it.

## Anti-patterns (the speckit waste this skill exists to avoid)
- Creating `.specify/`, a constitution, or any second formal spec format. Don't.
- Re-clarifying a spec `idea-to-spec` already settled.
- Offering `backend/ frontend/ api/` folder trees — files land per `Context.md` `## Architecture`.
- More than one human confirm. One review, then write.
- Tasks without a DoD, or UI tasks without empty/loading/error coverage.
