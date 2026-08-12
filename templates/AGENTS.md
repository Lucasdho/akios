# AGENTS.md — Agentic Operating Manual

Loaded every session via the project `CLAUDE.md`, which imports `@AGENTS.md` (Claude Code
auto-loads `CLAUDE.md`). akios targets the Claude agent. This is the single source of truth
for how to work here — the skill gates live below, not in a separate file.

## The loop (every code task)
1. **Orient** → `akios/Context.md` — stack, commands, architecture, conventions
   (auto-loaded for you via the `@akios/Context.md` import in `CLAUDE.md`).
2. **Recall** → your native auto-memory (`MEMORY.md`, loaded automatically) for
   decisions already made. Don't relitigate them.
3. **Route** → the gate table below — which skill fits this task type.
4. **Work** → the smallest change that is correct, honoring the priority chain.
5. **Record** → save durable decisions to auto-memory (Claude writes it itself;
   tell it "remember that …" for anything that should survive the session).

## akios never writes to git
**Never run a git command that changes anything.** No commits, no branches, no `git add`, no
pushes, no merges, no tags. Not at a checkpoint, not at the end of a task, not "so the work isn't
lost", and not because the user approved the *work* — approving a change is not approving a commit,
and those are different questions. Don't offer to commit either; leave the diff in the working tree
and report what changed. If the user directly tells you to commit, that's an instruction and you
follow it — but you never propose it.

This holds in every mode, `/akios:just-vibes` included: running unattended removes the *questions*,
not the human's ownership of their history. Every run ends the same way — changed files in the
working tree, and a report of what changed.

Reading git is fine and often useful (`git status`, `git diff`, `git log`); the prohibition is on
writes.

## Stack — read it, never assume it
akios ships **no** language or framework knowledge, and assumes nothing about what kind of project
this is — app, library, monorepo, infrastructure, docs, dataset, or something with no code in it
at all. Everything this kit knows about *this* project lives in `akios/Context.md`: what the repo
is, its stack, its architecture, and — most importantly — the exact install / run / test / lint /
build commands under `## Commands`. A `none` there is a real answer: it means that step doesn't
exist here, and the DoD audit stands in for it. Never fill a `none` with a guess.

**Never guess an invocation.** Every phase reads its build and test commands from there. If a
command is missing or stale, ask once and update `akios/Context.md` — don't improvise one and
don't hardcode one into a task.

Your own general knowledge of the language in play is the *floor* of the priority chain (tier 3),
used only when the project and the user's preferences are both silent. To raise that floor for this
project, record the decision — in `akios/Context.md`, in a spec, or in auto-memory — so it becomes
tier 1 next session instead of being re-derived.

## Architecture
This project's architecture is described in `akios/Context.md` `## Architecture`, including the
vocabulary it uses for module boundaries and shared code. **Follow the project's own architecture;
akios does not impose one.**

## Operating posture (learning vs. delivery)
`akios/Roadmap.md` carries a second flag beside `mode`: `posture: learning | delivery`
(default `delivery`, written by `/akios:setup`, overridable for one session via a command flag —
`/akios:deliver --learning` — or a spoken switch, without rewriting the Roadmap default).
Posture changes **only** how akios communicates and captures — never what it builds; a learning-
mode feature and a delivery-mode feature produce identical code.

A closed, named **teaching surface** — everything else is identical between postures:

| Behavior | Delivery (default) | Learning |
|---|---|---|
| Decision annotation | recorded to the artifact, no narration | inline one-liner: what, the principle, the tradeoff |
| Principle citation | none | names the doctrine + the owning reference/spec |
| Alternatives shown | in the artifact only | surfaced briefly at the decision point |
| Capture eagerness (prefs/hurdles) | propose at natural pauses, 2nd-occurrence rule | propose more eagerly + explain why it's worth remembering |
| End-of-unit digest | outcome report only | a short "what you learned" recap (3–5 principles) |
| Pace / checkpoints | as planned | may add a soft pause after a teachable checkpoint (never a hard gate) |

Every phase skill (`idea-to-spec`, `spec-to-tasks`, `task-execution`) reads `posture`
the same way it already reads `mode` and toggles only this surface. Under `just-vibes`
(no human present), learning posture writes a **"Lessons"** section to
`akios/.local/just-vibes-journal.md` per unit instead of narrating live; delivery journals outcomes
only.

## The priority chain (whose answer wins)
For any code decision (pattern, naming, architecture), resolve **top-down — the first tier
with a relevant answer wins, lower tiers only fill silence**:

```
1. Project decision already made  (MEMORY.md + existing code / akios/Context.md)
2. Global user preference         (~/.claude/akios/preferences.md)
3. Your own general knowledge     (the floor — used only when both tiers above are silent)
```

A repo's established architecture isn't rewritten because of a general preference — the project is
on top, and existing code in the repo *is* a project decision even when nobody wrote it down.
Tier 3 is your own model knowledge, deliberately last: what this project already does beats a
general best practice every time. The way to grow tier 1 is to record decisions as they're made —
in `akios/Context.md`, in the spec, or in auto-memory.

## How to execute (orchestration)
The feature spine's phases are defined in **`workflow.yml`** (the machine-readable contract —
commands and phase detection read it). `task-execution` owns the *deliver* phase loop;
`spec-to-tasks` owns *plan*; `idea-to-spec` owns *brainstorm*. For a vague "build X" request,
**`feature-pipeline`** is the entry point — it reads `workflow.yml` and walks you through
the phases.

Note: a spawned subagent starts cold — it does NOT inherit these gates. When you dispatch one
for gated work, restate the relevant gate (and the task's `refs:`) in its prompt.

## Sizing the work & subagent economy
Match the machinery — and the model — to the size of the job. Two questions before you start or dispatch:

**1. Quick task or real spec?**
- *Quick task* — one file, or a mechanical change across a few, low-risk, no new domain (a rename, a
  one-liner, mirroring an existing module, a copy tweak). **Do it inline, now** — no spec, no pipeline.
- *Real spec* — multi-file, new behavior, a new domain, or anything you'd want reviewed as a unit.
  Route it through the spine (brainstorm → plan → deliver) and let `task-execution` own the loop.

Mis-sizing costs both ways: a full pipeline for a one-liner is overhead the user pays for nothing; a
quick patch for a real feature ships half-baked. When genuinely unsure, ask one sizing question rather
than guessing.

**2. Should you dispatch a subagent at all? Usually no.**
Work **inline by default** — a subagent is cold (re-fed context, fresh tooling) and billed on top of
your session, so it rarely pays for itself. Reach for one only when **both** hold:
- **Context pressure** — the driving session is at **≥120k tokens (~60% of a 200k window)**, i.e. inline
  work is starting to crowd the window (a distinct, earlier threshold from `task-execution`'s own
  **110k** context-warn line — that one triggers a mandatory `/compact` before the next spec; this one
  is the subagent-dispatch judgment call), **and**
- **The task is heavy and isolatable** — a large, self-contained chunk (a whole spec's tasks, a wide
  mechanical sweep) that genuinely benefits from running in its own window.

Below that bar, just do it inline — offloading a light task, or one while you have ample context, spends
money to save nothing. If subagents are unavailable, inline is the answer anyway.

This kit uses three similarly-valued thresholds for three different things — say which one you mean:

| Name | Value | Measures | Where | Triggers |
|---|---|---|---|---|
| Inter-spec compact line | 110k / 135k | The **orchestrator's own** context, between specs | `task-execution/SKILL.md` "Context management" | warn at 110k → finish current task; urgent `/compact` at 135k |
| Subagent-dispatch judgment | 120k | The **orchestrator's own** context, before deciding to dispatch at all | this section, above | at/above it, dispatching a heavy isolatable task becomes worth considering |
| Subagent lineage budget | 120k | **A subagent's own context**, accumulated across the tasks it has chained through so far | `task-execution/SKILL.md` "Batch chaining" | at/above it, that link finishes its current task, hands off, and terminates — it does not start another task |

The dispatch-judgment line and the lineage budget share a value by coincidence, not identity — one
is checked against the orchestrator's window, the other against a subagent's own.

**3. When you do dispatch: cheapest model that fits, and only the slice it needs.**
- *Orchestration tier.* The driving session runs on **opus or sonnet** — sonnet is the budget option
  and is a fine default; reach for opus when the planning/judgment genuinely warrants it. Pick per
  budget, not by reflex.
- *Subagent tier.* A **simple, well-scoped** subtask (mechanical edit, a focused search, one test file,
  a refactor with a clear precedent) → **haiku**. **Implementing a spec's tasks end-to-end** (judgment,
  multi-step, TDD across files) → **sonnet**. Never dispatch a *more capable* model than the subtask
  needs — that's spending the orchestrator's tier on work a cheaper one ships correctly.
- *Never clone your context into a subagent.* A subagent starts cold and is billed for **every token you
  hand it** — passing your whole window is the single most expensive mistake here. Send only the slice:
  the task + its DoD, its `refs:` list, the project's test command, the matching
  `akios/Context.md` gotcha, the precedent file path. If you're about to paste the conversation, stop —
  summarize the slice instead.

## Skill gates
These are a routing aid, **not a toll booth on every file**.

**Proportionality (read before routing).** A skill earns its overhead only when it
injects knowledge you don't already have or enforces discipline on risky work. Match the
ceremony to the task:

- **Just do it** (no gate) when the change is a *mechanical application of a pattern already
  established in this repo* and is low-risk — e.g. "make the Board module like the Squad module",
  renames, obvious one-liners, moving code. Recognizing the existing pattern **is** the routing;
  loading a guide to copy a pattern you can already see adds latency, not correctness.
- **Load a guide** when there's genuine uncertainty it would resolve: a new domain, an
  unfamiliar or version-sensitive API, concurrency or persistence nuance, a design
  with no in-repo precedent, or anything you'd hesitate to ship unreviewed.

When in doubt, the cost of skipping is a missed best-practice; the cost of over-gating is the
overhead the user is paying for nothing. Bias toward the smaller of the two. The gates below are
the *map of where knowledge lives* — consult it when you need the knowledge, not reflexively.

**Skipping the gate ≠ skipping care.** "Just do it" means do it directly, not do it recklessly.
Read the files first and diagnose before writing; delete dead code and duplicates so the diff gets
*smaller*, not bigger. Check `git status` before your first edit and say so if the tree is already
dirty — your changes and the user's shouldn't get tangled. Speed comes from reading first and
reusing the existing pattern as a spec, not from cutting the safety rails.

| Trigger | Skill | When |
|---|---|---|
| Building a new feature end-to-end | `feature-pipeline` → brainstorm → plan → deliver | before starting |
| Mapping a whole product at once | `deep-brainstorm` (`/akios:deep-brainstorm`) → a spec family | before the first spec |
| Designing a system / turning an idea into a spec | `idea-to-spec` (`/akios:brainstorm`) → write specs to `akios/specs/` | before building |
| Turning a spec into tasks | `spec-to-tasks` (`/akios:plan`) → `akios/tasks/todo/` | after the spec |
| About to hand-write complex code, docs, types, or a format conversion | `oss-first` — is there a mature tool/lib first? | before generating |
| Delivering the backlog | `task-execution` (`/akios:deliver`) | to ship |
| Running unattended (drive the whole pipeline yourself) | `just-vibes` (`/akios:just-vibes` · `--force` to loop) | hands-off |
| Compacting a session into a handoff | `handoff` (`/akios:handoff`) | before pivoting or splitting work |
| Claiming "done" | `/verify` + `/code-review` | before finishing |

### Deepthink (user-triggered)
Proportionality runs the other way too: when the user flags a decision as high-stakes and wants
the full tradeoffs ("this one's really important", "deepthink this", "vai fundo nessa"), slow down
on **that one decision**: ground it with cited research if external facts would change the answer,
lay out each option's second-order consequences (what it forecloses, reversible vs one-way, who it
helps or hurts), recommend with a reason, and record the reasoning (in the spec if one exists —
not just the chosen option). Then return to normal pace. It's opt-in, so it adds no standing
overhead. Inside `idea-to-spec` the full protocol applies (see its "Deepthink mode").

## Where things live (artifact map)
One lookup for where every artifact is created and stored — so files land consistently and
the agent (or a newcomer) finds them fast. These are the kit's fixed conventions; your own
source dirs are described in `akios/Context.md` `## Architecture`.

| Artifact | Location | Naming | Found / loaded via |
|---|---|---|---|
| Operating files | repo root (`CLAUDE.md`/`AGENTS.md`); `akios/` (`Context.md`) | `CLAUDE.md`, `AGENTS.md`, `akios/Context.md` | Claude Code auto-loads `CLAUDE.md`, which imports `AGENTS.md` (root) and `akios/Context.md` |
| Phase contract | `akios/` | `workflow.yml` | commands + phase detection read it |
| Spec state | `akios/` | `akios/Roadmap.md` | mode flag + posture flag + one line per spec |
| Product vision | `akios/` | `akios/Vision.md` | north star + prioritized wishlist; top-tier `just-vibes` fuel |
| Specs | `akios/specs/` | `<domain>.md`, one file per domain | `akios/Roadmap.md` `## Specs` table |
| Tasks | `akios/tasks/<state>/` | `T<NNN>-<slug>.md`; state = folder (`todo/ in-progress/ review/ done/`) | moved between folders = state change |
| Handoffs | `akios/tasks/handoffs/` | `<slug>.md` + `<slug>-return.md` | written and read by `handoff` |
| Archived specs | `akios/archive/` | `<spec>.md` + `Archive.md` (summary index) | read `Archive.md` first; open full file on demand |
| User preferences | `~/.claude/akios/preferences.md` (not in repo) | — | priority chain tier 3 |
| Durable decisions | native auto-memory (not in repo) | `MEMORY.md` | written automatically; survives compaction |
| Run journal | `akios/.local/` | `just-vibes-journal.md` (append-only) | local runtime; **gitignored** — not shared |
| Project source | per `akios/Context.md` `## Architecture` | project-specific | `akios/Context.md` |

> **Not the same folder:** this table's `akios/` is a **per-project** folder created at repo root
> by `/akios:setup`. It's unrelated to `~/.claude/akios/` (the "User preferences" row above) —
> that one is a **user-global** home for preferences and packs, outside any single repo. Same
> name, different scope; they never collide in practice, but don't conflate them.

Adding a new artifact? Put it where the table says and name it the same way. If it's a spec,
add a row to the `akios/Roadmap.md` `## Specs` table so the next session knows it exists.

## Specs & Roadmap (idea-to-spec)
- Store versioned specs in `akios/specs/` — one file per domain.
- `akios/Roadmap.md` is the orchestration doc: the **mode flag** (`new`/`one-shot`/`feature`, written
  by `/akios:setup`) plus **one line per spec** (spec → domain → status
  `designed/planned/in-progress/done`). Phase detection is per-spec — different specs can be in
  different phases.
- **Single source of truth.** Spec state lives **only** in `akios/Roadmap.md` — never mirror the `## Specs`
  table into `CLAUDE.md` or anywhere else. One file updates; nothing else can drift out of sync.
  `CLAUDE.md` imports the operating files; it does not track spec state.
- Before designing something new, read `akios/Roadmap.md` first.

## Full feature workflow (the spine)
Defined in `workflow.yml`; entry point is **`feature-pipeline`**. At a glance:

`brainstorm (idea-to-spec) → plan (spec-to-tasks) → deliver (task-execution)`

Three phases: `brainstorm` (interactive design → `akios/specs/<feature>.md`) → `plan` (one pass →
`akios/tasks/todo/*.md` with `[P]` markers, est_tokens/runner, DoDs, state coverage) → `deliver`
(folder-state lifecycle, TDD-first, DoD audit at each checkpoint, `/verify` + `/code-review`, then
hand the working tree back **uncommitted**). See `feature-pipeline` for the conduct;
`workflow.yml` for the contract. No scaffold directory and no second spec format.

**Match the permission mode to the phase.** `brainstorm` + `plan` are design work — run them in
**plan mode** (read-only; review the spec/backlog before a single edit lands). `deliver` writes
real files — switch to **accept-edits / auto mode** so you're not approving every individual edit
while the agent works a known plan. `Shift+Tab` cycles modes mid-session. This is workflow economy,
not just safety: plan mode stops premature writes during design-of-the-spec; accept-edits stops
death-by-prompt once code starts landing.

### Staying in flow (anti-drift)
The spine's most common failure is **jumping out of the current phase or spec** when a concrete
build instruction surfaces mid-design — e.g. during brainstorm the user says "just create the seed
data / 5 records / that model" and you start hand-writing files, skipping plan and deliver, often
folding a *different* domain into the spec in flight.

Two rules close that gap:

- **WHAT is not HOW.** A mid-phase instruction to build something ("create X", "add Y") names a
  *what*; it does **not** authorize skipping to execution. Stay in the phase you're in.
- **When a build need surfaces mid-phase, STOP and route it — don't execute it inline.** Reflex:
  1. **Name** it: "that's an implementation/data task, not part of this design phase."
  2. **Classify scope:** does it belong to the *current* spec, or is it a *distinct domain*?
     A different domain (its own data, its own DoD) is its **own spec** — register it in
     `akios/Roadmap.md`, don't silently absorb it into the spec in flight.
  3. **Route:** if it's a true blocker, finish the current spec's design, then run that need
     through its own `brainstorm → plan → deliver`. If not a blocker, note it and stay on task.
  4. Only *then*, when you're legitimately in deliver for the right spec, write code or data.

If you catch yourself already mid-drift (writing files in a design phase), name the error, stop,
and re-route. Recovering is cheap; shipping the wrong thing in the wrong spec is not.

A phase ends only at its hand-off artifact (spec → tasks → reviewed code). Don't run the next
phase's work early — no application code or data files during brainstorm or plan.

### Autonomous run (just-vibes) — driving the spine yourself
`/akios:just-vibes` runs the whole spine **unattended**: it picks the next fuel (a submitted idea →
`akios/tasks/todo/` → designed specs → `akios/Vision.md`/`akios/Roadmap.md`), builds it, gates on quality, and delivers.
**Default** does one unit then stops at the spec boundary; **`--force`** loops until fuel is exhausted
or you interrupt. It is the **explicit opt-out of being asked** — but the **quality gate stays**:
verify + code-review + a bounded fix loop, and a spec that won't go green is **parked**, never
marked done. It commits nothing either (see "akios never writes to git"): the run ends with changed
files in the working tree, same as any other. Unattended brainstorm runs in a
**deepthink** posture (research + decision records) since no one's there to decide live. The loop,
fuel precedence, and reporting live in the `just-vibes` skill — don't re-document them here.

## Project-specific gates
{{e.g. "always /security-review when touching auth / secrets / networking"}}

## House rules
- **Stack-agnostic by construction.** akios carries process, not framework knowledge. Read
  `akios/Context.md` for this project's stack and commands, and follow the patterns the repo
  already uses. Never assume a build tool, a folder convention, or a test runner the project
  hasn't recorded.
- Shortest working diff. No speculative abstractions, no scaffolding "for later".
- One runnable check behind any non-trivial logic.
- Boring over clever. Deletion over addition.
- **Honor the priority chain** (above) before applying any default.
- **Native types over wrappers.** Use the language's own identity / equality / serialization
  primitives before writing a wrapper type. A wrapper needs a one-line justification.
- **Interface-first data access.** Define the abstraction + default implementations; concrete types
  implement it. Smaller, reviewable PRs. A repository's done-bar is: interface defined, defaults
  provided, equality + serialization round-trip covered.
- {{PROJECT_RULE — e.g. "never touch /migrations without a backup plan"}}
