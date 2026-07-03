# akios — Subagent Context Chaining

**Working spec · v1.0 · 2026-07-03**

Formalizes what a subagent does across a **batch of sequential tasks**, so neither the orchestrator
nor the subagent's own context balloons over a multi-task run. Today's dispatch doctrine
(`task-execution/SKILL.md` "Runner routing + model tier", `AGENTS.md` "Sizing the work & subagent
economy") answers *whether* to dispatch a subagent for one task, and is explicit that the subagent
starts cold and must never inherit the orchestrator's full context — but it is silent on what
happens when a subagent is handed **several** queued tasks in a row. Left unspecified, that gap
gets filled two ways in practice, both bad: a fresh cold subagent spins up per task (full
rediscovery cost paid again on every task in a domain the previous subagent already understood), or
one subagent is handed the whole batch and just keeps going until it stops — which is exactly how a
real v0.8.0 Session 2 background build agent ballooned to ~300k tokens (see
`[[feedback_subagent_dispatch]]` memory). That incident is the same failure mode the orchestrator's
own 110k/135k compaction lines (`task-execution/SKILL.md` "Context management") already exist to
prevent — just unguarded on the subagent side of the fence. This spec closes that gap with a
repeatable protocol instead of an ad hoc judgment call. Answers backlog **B38**. See
`akios-backlog-map.md` G14.

> **State:** designed

---

## 1. Chain, don't spawn-per-task, don't run-unbounded (D1)

Three options for a subagent-eligible **batch** (≥2 queued tasks that share a domain/slice, e.g.
several tasks in the same feature from one `spec-to-tasks` checkpoint):

- **Spawn-per-task (rejected)** — dispatch a brand-new cold subagent for every task in the batch.
  Correctly bounds each subagent's context (it only ever does one task), but pays the cold-start
  discovery cost — reading the domain's `swift-dev` sub-skill, the precedent files, the slice
  layout — once per task instead of once per batch. For a 5-task batch in one feature slice, that's
  4 redundant discovery passes.
- **Hand off the whole batch, unbounded (rejected)** — one subagent, no plan for what happens as its
  own context grows across tasks. This is what actually happened in the incident this spec answers:
  nothing capped it, so it ran until ~300k tokens.
- **Chain the batch through one lineage, budgeted (chosen)** — one subagent works the batch's tasks
  **in sequence inside one session**, compacting itself between tasks (§3) so the discovery cost is
  paid once but the accumulated context doesn't keep growing unchecked. When that session's own
  context crosses a fixed budget (§2), it stops cleanly, hands off in writing, and the orchestrator
  spawns a **fresh cold subagent** to pick up the remainder of the batch (§4) — same batch, same
  domain, new context window. The chain can have any number of links; each link is bounded, so the
  batch as a whole is never limited by any single context window.

**Decision & reason:** chaining gets the discovery-cost saving of "one subagent, whole batch"
without the incident's failure mode, because no single link is allowed to grow past the budget in
§2 — the batch's total length is handled by adding links, not by growing one link indefinitely.

---

## 2. Naming the budget — a third, distinct "120k" (D2)

This kit already uses two numbers that look alike and mean different things, and B36's self-audit
caught them once already being *confused* with each other (`AGENTS.md` misquoting
`task-execution`'s 110k line as 120k). Adding a third similar number without naming it precisely
would recreate exactly that drift. For the record, all three, side by side:

| Name | Value | Measures | Where | Triggers |
|---|---|---|---|---|
| Inter-spec compact line | 110k / 135k | The **orchestrator's own** context, between specs | `task-execution/SKILL.md` "Context management" | warn at 110k → finish current task; urgent `/compact` at 135k |
| Subagent-dispatch judgment | 120k | The **orchestrator's own** context, before deciding to dispatch at all | `AGENTS.md` "Sizing the work & subagent economy" | at/above it, dispatching a heavy isolatable task becomes worth considering |
| **Subagent lineage budget (this spec)** | **120k** | **A subagent's own context**, accumulated across the tasks it has chained through so far | this spec | at/above it, that link finishes its current task, hands off (§3), and terminates — it does not start another task |

**Decision & reason:** the coincidence that the dispatch-judgment line and the lineage budget are
both 120k is exactly the number the feedback specified, and there's no principled reason to pick a
different one just to look distinct — but the two must never be read as the same measurement. One
is "should the orchestrator delegate," checked against the orchestrator's window; the other is
"should this subagent stop and relay," checked against the subagent's own window. Any future doc
that states "120k" near subagent dispatch **must** say which of the two it means — a bare "120k"
is the drift this table exists to prevent.

---

## 3. In-lineage protocol: finish, compact, continue (D3)

Between tasks, while under budget, a chain link does not terminate and is not re-spawned — it stays
alive and keeps working the batch:

1. Finish the current task to its DoD (per normal `task-execution` checkpoint discipline) and
   commit.
2. **Compact in place** — the same operation the orchestrator runs at a spec boundary
   (`task-execution/SKILL.md` "Context management"), run here at a **task** boundary instead of a
   spec boundary: drop the completed task's raw tool-call noise and exploratory narrative, keep the
   durable state (which tasks in the batch are done, files touched, decisions made, DoD evidence).
   A task boundary is a safe compression point for the same reason a spec boundary is — there is no
   live mid-task state (partial edits, an open DoD check) to lose.
3. Check accumulated context against the 120k lineage budget (§2).
   - **Under budget** → pull the next queued task from the batch and continue in the same session.
   - **At/over budget** → stop taking new tasks; go to §4.
4. **Empty queue** → the batch is done. Report back to the orchestrator (§5) and terminate normally
   — no handoff file needed, there is nothing left to relay.

---

## 4. Crossing the budget: finish, write, relay, terminate (D4)

When step 3 above finds the lineage at or over 120k tokens:

1. **Finish the current task cleanly** — same rule as the orchestrator's own 110k line: never stop
   mid-task. If a *single* task's own tool churn pushes the lineage over budget before that task
   even completes, finish it anyway; flag in the handoff (step 2) that one task alone approached the
   budget, since that's a signal the task was mis-sized for `spec-to-tasks` (a candidate for
   splitting next time the batch's spec is planned).
2. **Write a handoff file**, using `skills/handoff/SKILL.md`'s format, at
   `akios/tasks/handoffs/subagent-<spec-slug>-<link-number>.md` (e.g.
   `subagent-alva-adoption-2.md` for the second link in a chain working that spec's batch). Content:
   which of the batch's tasks are done vs. still queued, the domain/slice context the next link
   needs (so it doesn't have to rediscover it from scratch), and any decision made mid-batch not yet
   captured in a task file or commit. This is the same handoff discipline
   `[[feedback_subagent_dispatch]]` already recommends for large builds — this spec is what makes it
   the default for *any* chained batch, not just ones a human remembers to ask for.
3. **Return a slim status to the orchestrator** — one line: which tasks completed, the handoff file
   path, nothing else. The cold-start discipline already says never clone the orchestrator's context
   into a subagent (`AGENTS.md` "Never clone your context into a subagent"); this is the same rule
   applied in the other direction — never let a subagent dump its accumulated context back into the
   orchestrator on the way out either. That's the second half of "both stay low" (§5).
4. **Terminate.** This is the only point in the lineage where a link actually ends — never mid-batch
   for any other reason, and never silently.

---

## 5. Orchestrator's role in the cascade (D5)

On receiving the step-4 return:

- **Spawn a fresh, cold subagent immediately** to continue the batch — never absorb the remaining
  tasks into the orchestrator's own session "to save a dispatch." Doing that just relocates the
  context growth from the subagent side to the orchestrator side, defeating the entire point.
- **Prompt the new link with the slice, not the history**: the remaining task list, the handoff file
  path from step 4.2, and the same per-dispatch essentials cold-start discipline already requires
  (domain sub-skill, relevant `Context.md` gotcha). The new link reads the handoff file itself for
  batch-specific detail — the orchestrator's prompt is the pointer, not a copy.
- **Repeat** §3–§5 until the batch's queue is empty. The orchestrator's own context cost for an
  N-link chain is N short dispatch prompts plus N one-line returns — not the sum of everything each
  link did.

---

## 6. When chaining applies (D6)

This spec only changes what happens **after** a batch already clears the existing eligibility bar
(`task-execution/SKILL.md` "Runner routing + model tier": task marked `subagent-eligible` **and**
`AGENTS.md`'s dispatch-judgment line says yes). It does not change that bar and does not make
dispatch more likely on its own.

- **A single isolated task** — no batch, nothing to chain. Ordinary one-shot cold dispatch per
  existing doctrine; §§1–5 don't engage.
- **A multi-task batch, same domain/slice, meant to run in order** — chaining applies. This is the
  common case `spec-to-tasks` produces within one checkpoint of one feature.
- **Multiple tasks that are independent and collision-free** (`parallel-execution-scheduling.md`'s
  intra-checkpoint `[P]` marking) — those are candidates for *concurrent* separate dispatches, not a
  sequential chain; this spec and `parallel-execution-scheduling.md` answer different axes
  (sequential depth vs. concurrent breadth, §7) and don't compete for the same batch.

---

## 7. Where this plugs in

- **`task-execution/SKILL.md` "Runner routing + model tier"** — once a batch clears the existing
  eligibility check, this spec's §§1–5 become the default execution shape for it instead of an
  unspecified "however the session happens to run it."
- **`skills/handoff/SKILL.md`** — reused as-is for the handoff file format; this spec only adds a
  naming/location convention for chain-internal handoffs (`subagent-<spec-slug>-<link-number>.md`)
  and makes writing one at the budget line **mandatory**, not situational.
- **`parallel-execution-scheduling.md`** — orthogonal, not overlapping: that spec decides whether two
  *different* specs' batches are safe to run as concurrent agents at all (breadth); this spec decides
  how *one* batch's sequential tasks flow through however many subagent links it takes to finish
  without any one link's context blowing up (depth). A scheduling decision from that spec can hand
  this spec a batch to chain; this spec never decides concurrency.
- **`[[feedback_subagent_dispatch]]` memory** — this spec is that memory's ad hoc recommendation
  ("write a handoff file, cold-start, split into multiple sessions") turned into a threshold-
  triggered, repeatable protocol. The memory's incident (~300k token subagent) is exactly the case
  §2's 120k lineage budget exists to catch before it happens again.

---

## 8. Worked example — the incident this spec answers

The v0.8.0 Session 2 background build agent (`[[feedback_subagent_dispatch]]`) was handed a
multi-task batch and kept working it in one session with no budget check, reaching ~300k tokens
before anyone noticed. Under this spec: link 1 works the batch's tasks, compacting after each one
(§3); the first time its own context crosses 120k (likely partway through the batch, well before
300k), it finishes its in-flight task, writes
`akios/tasks/handoffs/subagent-<that-spec>-1.md` naming the done/remaining tasks, returns a
one-line status, and terminates. The orchestrator spawns link 2 with that handoff path. Link 2 picks
up where link 1 stopped, at a fresh, low context baseline. The batch finishes across however many
links it takes — 2, 3, whatever the batch's real size demands — and no single link ever approaches
the size that made the real incident worth writing a memory about.

---

## 9. Edge states

- **A batch of exactly one subagent-eligible task** — trivially "the chain has one link"; §3's
  compact-and-continue step never fires (no next task to pull), §4 only fires if that single task's
  own churn crosses 120k on its own (D4 step 1's flagged case).
- **The lineage crosses budget immediately after the very first task** — correct and expected for a
  batch of heavy tasks; a 2-task chain is not a failure of this protocol, it's what "budgeted" means
  when the tasks themselves are large.
- **A chain link crashes or is killed before it can write a handoff** — out of scope for this spec's
  happy path; falls back to ordinary session-recovery (re-derive from the last commit + task-file
  states, same as any interrupted subagent today). Not worse than today's unhandled case, just not
  specifically improved by this spec.

---

## 10. Deliberate exclusions

- **No automatic detection of which tasks belong in the same chain.** §6's "same domain/slice,
  meant to run in order" grouping is read from the batch's own task files / checkpoint structure
  (as `spec-to-tasks` already produces them) — this spec doesn't add a new classifier.
- **No change to the 110k/135k orchestrator lines or the orchestrator-side 120k dispatch-judgment
  line.** All three stand exactly as documented; §2 only adds a fourth, explicitly disambiguated
  number for a different subject (a subagent's own window, not the orchestrator's).
- **No change to model-tier selection.** A chain link keeps whatever model tier the batch's tasks
  were assigned under existing doctrine (haiku for mechanical, sonnet for judgment/TDD) — chaining
  is orthogonal to which model runs each link.

---

## 11. Open / next

- **[CONSEQUENCE — to implement]** Add §§1–6 (in condensed form) to `task-execution/SKILL.md`'s
  "Runner routing + model tier" section, and the §2 disambiguation table to `AGENTS.md` near its
  existing 120k dispatch-judgment line, so the two 120ks are never quoted without their qualifier
  again.
- **[CONSEQUENCE — to implement]** Register the `akios/tasks/handoffs/subagent-<spec-slug>-
  <link-number>.md` naming convention in `skills/handoff/SKILL.md`'s "Output format" section
  alongside the existing `<topic>` / `<topic>-return.md` patterns.
- **[OPEN — revisit if it matters in practice]** whether the 120k lineage budget should ever differ
  from the orchestrator's 120k dispatch-judgment line on purpose (e.g. a smaller subagent model tier
  might warrant a lower cap) — left at parity with the number the feedback specified until a real
  chained run gives a reason to diverge.
