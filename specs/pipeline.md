# akios — Pipeline
**Working spec · v1.0 · akios refactor annex**

Defines the runtime behavior of the three phases (`brainstorm → plan → execute`): the
`workflow.yml` contract shape, phase detection by context, prerequisite gating, task
decomposition and cost-based routing, the per-task execution lifecycle (TDD-first), context
budgeting, and the archive/summary mechanism. Complements `plugin-architecture.md` (which
fixed the folder layout, command set, and skill boundary) and feeds `preferences-and-priority.md`
(the decision chain and feedback logging). Everything here is settled unless marked *open*.

Worked example threaded throughout: a **dark-mode toggle** feature (continued from
`plugin-architecture.md` §8).

---

## 1. The `workflow.yml` contract  *(Decision 1 — chose A: declarative minimal)*

The phase contract is the single source of truth; commands and the by-context detector read it.

```yaml
version: 1
modes: [new, one-shot, feature]      # init writes the active one to Roadmap.md

bootstrap:                            # init is NOT a phase
  command: /akios:init
  creates: [CLAUDE.md, AGENTS.md, Context.md, Roadmap.md,
            specs/, tasks/, archive/, code-references/]

phases:
  - id: brainstorm
    command: /akios:brainstorm
    skill: idea-to-spec
    prereqs: [Context.md, Roadmap.md]
    outputs: [specs/*.md]
    roadmap: designed

  - id: plan
    command: /akios:plan
    skill: spec-to-tasks
    prereqs: [specs/*.md]
    outputs: [tasks/todo/*.md]
    roadmap: planned

  - id: execute
    command: /akios:execute
    skill: task-execution
    prereqs: [tasks/todo/*.md]
    outputs: [tasks/done/*.md]
    roadmap: done
```

- **Per phase:** `id · command · skill · prereqs · outputs · roadmap`. Gate = "all `prereqs`
  exist"; detection = "which `outputs` exist."
- **Declined:** *B — rich schema* (re-implements a workflow engine in yml, duplicating skill
  logic); *C — ultra-minimal* (couples phases linearly, can't express a phase depending on more
  than one predecessor). The *contract* (what) lives in yml; the *conduct* (how) lives in skills.

---

## 2. Phase detection & gating  *(Decision 2 — chose A: soft gate)*

- **By-context detection:** on a vague request ("vamos implementar isso"), the agent computes
  *current phase = the highest phase whose `outputs` already exist for the relevant spec*, reads
  the **mode** from `Roadmap.md`, and proposes the next action. Commands remain the explicit path;
  detection is the implicit one.
- **Per-spec state:** `Roadmap.md` holds **one line per spec** (`designed / planned / in-progress
  / done`), so different specs sit in different phases simultaneously.
- **Gate posture — soft gate + offer:** if a phase's prereqs are missing, do **not** hard-block.
  State what's missing and **offer** to run the prerequisite phase (or jump to it).
  - **Declined:** *B — hard gate* (rigid; annoys power users); *C — auto-run prereq* (dangerous —
    `brainstorm` is interactive; auto-firing an interactive phase the user didn't ask for is wrong).

---

## 3. Task decomposition (`plan`)  *(Decision 3 — chose A: size-bounded, similarity-grouped)*

`spec-to-tasks` turns a spec into task files under `tasks/todo/`:

- **Group by similarity** (same file / area / concern), then **bound by size**: each task's
  estimate must stay **< 80k** (soft ceiling) or it is split further.
- **Cost proxy** *(locked in `plugin-architecture.md` §9)*: `est_tokens ≈ Σ touched-file sizes +
  description weight`. For **new** files, the size is estimated from the spec description (rough —
  see risk in §9).
- **Recorded on the task file:** `est_tokens` and the derived `runner`
  (`≤20k → orchestrator`, `>20k → subagent`). `execute` reads these; it does not recompute.
- **Parallelism:** tasks in **different areas** get a `[P]` marker (run in parallel); **same-area**
  tasks serialize (avoid conflicts). This replaces the plain `[P]` of the current `spec-to-tasks`.
- **Declined:** *B — fixed granularity* (giant or dozens-of-tiny tasks); *C — defer sizing to
  execute* (breaks `tasks/todo/*.md` granularity; a task could need splitting mid-run).

Task file structure carries **State + Description + body** (state is the containing folder, §4);
model the spec/task templates on `speckit/templates/` as the structural reference.

---

## 4. Execution lifecycle (`execute`)  *(Decision 4 — chose A)*

State is the **containing folder** — moving a file changes state (cheap, diff-friendly):

```
for each task in tasks/todo  (respect [P]; same-area serializes):
  move → tasks/in-progress/
  load swift-dev sub-skills by task scope
  TDD  → failing test → implement → green
  move → tasks/review/
  /code-review  (+ verify when applicable)
  move → tasks/done/          (only when review passes; failure loops back to in-progress)
runner:   ≤20k inline (orchestrator) · >20k subagent (cold → restate gate + domain skill)
context:  warn at 120k · urgent /compact at 180k · compress only between specs
human gate: per-task review is automatic; push/merge is the human gate at the end
automode: execute recommends switching plan→automode when there is a queue of independent [P] tasks
```

- **TDD posture — tests-first where meaningful, lighter bar for UI:**
  - **Logic / data / concurrency** → write the failing test first (Swift Testing /
    `swift-dev:swift-testing-pro`), then implement to green.
  - **Pure SwiftUI views** → no useful unit test of layout exists; the bar is a working **Preview**
    + the **happy / empty / loading / error** states (already mandated by `spec-to-tasks`) +
    a snapshot test **if** the project has the harness.
  - **Declined:** *B — strict TDD everywhere* (forces brittle low-value view tests); *C — TDD
    optional* (contradicts the "tests before code" requirement).
- **Subagents are opt-in / capability-gated:** a dispatched subagent starts cold — its prompt
  restates the relevant gate and includes the task's swift-dev domain sub-skill. This environment
  may deny a subagent `xcodebuild`; routing must degrade to inline when so.

---

## 5. Archive & summary  *(Decision 5 — chose A: single index)*

On **spec completion** (all its tasks `done`):

1. Append a **summary block** to `archive/Archive.md` — decisions, files touched, outcome.
2. Move the full spec to `archive/<spec>.md`.
3. Clear that spec's `tasks/done/` files (content captured in the summary + git).

Future sessions read **only `archive/Archive.md`** (cheap) and open a full archived file on demand.
This single index *is* the anti-scan mechanism requested.

- **Division with `MEMORY.md` (no duplication):** `Archive.md` = the **spec-level** record ("what
  it did + where the files are"); `MEMORY.md` = **durable decisions** worth recall in future
  sessions. On completion, key decisions go to `MEMORY.md`; the what/where stays in `Archive.md`.
- **Declined:** *B — one summary file per spec* (re-creates something to scan); *C — git-only*
  (forces git archaeology; contradicts the anti-scan goal).

---

## 6. Worked example — dark-mode toggle

1. **init** (existing repo, `feature` mode): structure created; `Roadmap.md` has `mode: feature`.
2. **brainstorm** (soft gate sees `Context.md`+`Roadmap.md` → ok): `specs/dark-mode-toggle.md`;
   `Roadmap.md` line → `dark-mode-toggle: designed`.
3. **plan**: `spec-to-tasks` produces e.g.
   - `tasks/todo/01-theme-store.md` — logic; `est_tokens: 12k`; `runner: orchestrator`; `[P]`
   - `tasks/todo/02-settings-toggle-view.md` — UI; `est_tokens: 9k`; `runner: orchestrator`; `[P]`
   - `tasks/todo/03-persist-pref.md` — data; `est_tokens: 14k`; `runner: orchestrator`
     (same area as 01 → serialized after it)
   Roadmap → `planned`.
4. **execute**: `01` → in-progress → failing test for theme state → implement → green → review →
   `/code-review` → done. `02` (UI) → Preview + happy/empty(n/a)/loading(n/a)/error states +
   snapshot if harness → review → done. `03` serializes after `01`. Roadmap → `in-progress` → `done`.
5. **archive**: summary appended to `archive/Archive.md`; spec moved to `archive/dark-mode-toggle.md`;
   `tasks/done/` cleared; "chose system-driven `@Environment(\.colorScheme)` override" → `MEMORY.md`.

---

## 7. Empty / zero states

- **Fresh repo:** empty `specs/ tasks/ archive/ code-references/`; `Roadmap.md` with only the mode
  flag → valid "nothing designed yet" state; a bare `/brainstorm` is offered.
- **`tasks/` between phases:** empty `tasks/todo` after everything is consumed → execute reports
  "no tasks pending" and points at the next un-planned spec.
- **Empty `archive/Archive.md`:** first-ever completion creates the file with its first block.

---

## 8. Deliberate exclusions

- **No mid-run re-sizing of tasks** — sizing happens at `plan` (Decision 3-C declined).
- **No auto-run of interactive phases** (Decision 2-C declined).
- **No per-task push/merge** — the only human gate is at the end, before push/merge.

---

## 9. Open / next

- **Next session:** `preferences-and-priority.md` (spec #3) — the feedback-logging mechanism
  (when/how phases append to `~/.claude/akios/preferences.md`), Code References progressive
  disclosure, and the full application of the priority chain
  (`project → code-references → preferences → swift-dev`, from `plugin-architecture.md` §5.3).
- **[TECHNICAL RISK — validate before relying on it] Token-cost proxy:** `est_tokens` for new
  files is a guess from the spec description; verify it doesn't misroute large-but-simple or
  small-but-complex tasks (orchestrator vs subagent, and the 80k split).
- **[CAPABILITY RISK] Subagent tooling:** environments may deny subagents `xcodebuild`; the
  `>20k → subagent` route must degrade to inline rather than fail.
- **[DEFERRED] `project-scaffolding.md`** (spec #4) — per-architecture base projects.
