# akios — Parallel & Sequential Execution Scheduling
**Working spec · v1.0 · 2026-07-01**

Gives akios a repeatable way to look at a **batch of queued specs or task backlogs** (not just the
tasks inside one spec, which `spec-to-tasks` already parallelizes via `[P]`) and decide which pairs
are safe to dispatch as **concurrent delegated agents** (subagents, isolated `git worktree`s) versus
which must **serialize** because they collide on the kit's own shared machinery. Surfaced live during
the v0.8.0 build: Session 2 was mid-flight rewriting `task-execution/SKILL.md`,
`spec-to-tasks/SKILL.md`, `Roadmap.md`, `AGENTS.md`, and `install-skills.sh` when the question "can
we run something else in parallel?" came up — the honest answer was no, because nearly every
remaining backlog spec touches those same files, and running two agents against them in one working
directory would race on git commits, task-file numbering, and `Roadmap.md` line edits. Right now that
answer is worked out by hand, ad hoc, per session. This spec makes it a computable, repeatable step
instead. Answers backlog **B37** (self-surfaced from this session's own friction — same pattern as
B36's self-audit). See `akios-backlog-map.md` G12.

> **State:** designed

---

## 1. The two collision classes (D1)

`spec-to-tasks` already solves this **within one spec**: a task is tagged `[P]`/`parallel: true`
only if it shares no files and no produced symbols with another `[P]` task in the same checkpoint
(`spec-to-tasks/SKILL.md` step 4). This spec generalizes the same collision test **across specs** —
the unit being scheduled is no longer a task, it's a whole spec's build (or a whole task-execution
run), and the agents doing the work are no longer sequential steps in one session, they're
independently dispatched agents (subagents or worktree-isolated sessions).

Two distinct collision classes, both must clear before two specs can run concurrently:

- **File/symbol collision** — the same test `spec-to-tasks` already runs, just widened from "this
  checkpoint's tasks" to "every file either spec's task backlog is expected to touch." Two specs
  whose backlogs would touch the same file — even in non-conflicting ways — collide.
- **Spine collision (new)** — a small, named set of files nearly every capability-spec in this kit
  touches, regardless of subject matter, because they're the kit's own shared machinery:
  `skills/task-execution/SKILL.md`, `skills/spec-to-tasks/SKILL.md`, `Roadmap.md`, `AGENTS.md`,
  `workflow.yml`, `scripts/install-skills.sh`, `CHANGELOG.md`, `VERSION`,
  `.claude-plugin/plugin.json`. Two specs that both edit any spine file collide **even if the edits
  don't logically conflict** — two agents editing the same file concurrently in one working
  directory race on commits, and two agents on separate worktree branches both editing it need a
  manual merge afterward either way. Spine collision is conservative by design: it flags more pairs
  than strictly necessary, on the theory that a false "serialize" costs some wall-clock time, but a
  false "parallelize" risks corrupted state or lost work.

**Decision & reason:** treating spine files as an always-collide set (rather than predicting whether
two edits to `task-execution/SKILL.md` would textually conflict) is deliberately coarse. Predicting
textual conflict ahead of time (rejected) requires diffing hypothetical edits that don't exist yet —
the spec hasn't been decomposed into tasks. A fixed spine list is cheap, legible, and checked in
seconds; the cost of over-serializing a few pairs is far lower than the cost of a missed collision
corrupting `Roadmap.md` or losing a commit.

---

## 2. Computing the graph (D2)

Given a batch of queued specs (e.g. everything `designed`/`planned` in `Roadmap.md` at once — exactly
the situation `akios-backlog-map.md` §5 hand-solved for the v0.8.0 backlog), build a
dependency/collision graph:

- **Nodes** = specs (or, once decomposed, top-level task-execution runs).
- **Hard edges (must-serialize-after)** — declared dependencies: a spec's own text names another
  spec as a prerequisite (e.g. `snippet-library.md` "depends only on `knowledge-architecture.md`
  existing"). These come from reading each spec's intro/decision text, not inference.
- **Soft edges (collide, no inherent order)** — spine collision or file/symbol collision with no
  declared dependency either direction. Two specs like this *can* run in either order but **not
  concurrently**; note the collision, let a human (or `just-vibes`, unattended) pick the order.
- **No edge** — no declared dependency, no file/symbol overlap, no spine touch on either side. Safe
  to dispatch as concurrent agents, each in its own `git worktree` (never the same working
  directory — even collision-free specs shouldn't share a live tree while both are mid-build, since
  "no overlap" is a prediction from spec text, not a guarantee against surprises found during
  execution).

Output: a short table (new artifact, e.g. `tasks/execution-graph.md`, regenerated per batch — not
committed as permanent state, since it's a snapshot of a queue that changes every session) with one
row per spec: `spec | blocked-by | collides-with (soft) | parallel-safe (bool)`.

**Decision & reason:** `akios-backlog-map.md` §5 "Recommended build order" is already exactly this
graph, computed by hand for one 36-item backlog. Naming the mechanism and giving it a repeatable
procedure means every *future* multi-spec batch (a second backlog map, a fresh repo's first wave of
specs) gets the same rigor without a human re-deriving it from scratch by reading every spec's prose
end to end. A fully automated dependency-graph tool that statically analyzes spec text (rejected, for
now) is more than this kit needs — the spine list plus a declared-dependency read is a five-minute
manual pass that caught everything the v0.8.0 build actually needed. Flagged in §7 as revisitable if
batches get large enough that manual computation stops scaling.

---

## 3. Delegation guidance (D3) — what to do with the graph

- **`parallel-safe = true` pairs** → safe to dispatch as concurrent `Agent` calls with
  `isolation: "worktree"`, each on its own branch. Still a human decision *when* to actually spend
  the parallel agent-time (cost/value, not just safety) — this spec only answers "is it safe," not
  "should we."
- **Soft-collision pairs** → serialize, but say so explicitly rather than silently picking an order.
  State the collision (which spine file, or which shared target file) so the human understands
  *why* it's sequential, not just that it is.
- **Hard-dependency pairs** → serialize in the declared order; don't start the dependent spec's
  `spec-to-tasks` pass until the prerequisite spec's Roadmap row reads `done`.
- **Merging parallel worktree work back** — once two worktree-isolated builds both land, merging
  their branches is a normal git merge, reviewed like any other; this spec doesn't change that
  step, it only decides *whether it was safe to let them diverge* in the first place.

---

## 4. Where this plugs in

- **`akios-backlog-map.md`-style index specs** — any spec playing that role (a backlog map, a
  multi-spec sprint plan) computes this graph as part of writing its own "recommended build order"
  section, instead of hand-reasoning file overlap prose per item the way §5 currently does. Future
  index specs should include a `spine collisions` note per phase, not just a numbered list.
- **Orchestration by the user or `just-vibes`** — before dispatching more than one agent against
  this repo at once (subagent or worktree), run the two-collision-class check from §1 against the
  specs in play. Under `just-vibes` (unattended), the auto-decided order gets journaled the same way
  other auto-decisions are (mirrors `align-ui`'s `[auto]` marking).

---

## 5. Worked example — this session

`ui-overhaul-implementation.md` and `knowledge-architecture.md` (Session 2) both edit
`task-execution/SKILL.md`, `spec-to-tasks/SKILL.md`, `Roadmap.md`, and `install-skills.sh` — spine
collision on all four, plus a soft file/symbol collision on `AGENTS.md`'s priority-chain wording.
Verdict: serialize — exactly the order the approved 3-session plan already put them in. This spec
would have produced the same answer the human reasoned out by hand, but as a checked step rather
than intuition.

Contrast: `skill-authoring.md` (G3 — mostly new files: a new skill, a new command, one
`install-skills.sh` line) and `code-review-doctrine.md` (G6 — a new review reference + a hook into
the existing `/code-review` skill) share no declared dependency and only one soft spine touch each
(`install-skills.sh`, for the former only). Verdict: **parallel-safe** — a candidate pair for
concurrent worktree-isolated agents once Session 2 clears. This is the affirmative case this spec
exists to catch, not just the negative one.

---

## 6. Edge states

- **A spec touches no spine file and has no file overlap with anything else queued** (a pure new
  skill + new command + new doc) — trivially parallel-safe against everything else in that state.
- **Every spec in the batch touches the same spine file** (true for most of this kit's own backlog,
  since `task-execution`/`spec-to-tasks`/`Roadmap.md` are load-bearing for nearly everything) — the
  graph degenerates to a fully serial chain. That's a correct answer, not a failure of the
  mechanism; it just means this kit's own backlog rarely parallelizes well, which matches what
  Session 2 found in practice.
- **A spec's own text is silent on dependencies it actually has** — treat silence as "no declared
  dependency," not "confirmed independent"; the spine-collision check still catches the mechanical
  risk even when the prose misses a logical one.

---

## 7. Deliberate exclusions

- **No automatic worktree creation or auto-merge.** This spec decides *safety*, not *execution* —
  dispatching agents and merging their work back are separate, already-existing mechanisms (`Agent`
  tool `isolation: "worktree"`, ordinary git merge).
- **No static text-diff prediction of spine-file conflicts.** The spine list is a fixed, coarse
  always-collide set (§1) — precise conflict prediction is out of scope until the coarse version
  stops being good enough.
- **No change to the existing intra-spec `[P]` mechanism** in `spec-to-tasks` — this spec sits one
  level above it (spec-to-spec), not a replacement.

---

## 8. Open / next

- **[CONSEQUENCE — to implement]** A short procedure (not necessarily a new skill — could be a
  section added to `spec-to-tasks/SKILL.md` or `akios-backlog-map.md`'s own template) for computing
  the graph from §2 given a batch of queued specs.
- **[CONSEQUENCE — to implement]** The spine-file list (§1) should live somewhere both
  `spec-to-tasks` and any future index spec can read as ground truth, rather than being re-typed per
  spec — likely a short list in `AGENTS.md` alongside the other kit-wide constants.
- **[OPEN — revisit if batches grow]** whether manual graph computation (a five-minute read) stops
  scaling once a backlog map has 50+ items, at which point light tooling (a script that greps each
  spec's declared "Files" sections) might replace the by-hand pass.
