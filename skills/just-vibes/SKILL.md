---
name: just-vibes
description: Autonomous akios run. Drives the whole feature pipeline (brainstorm→plan→design→deliver→ship) end to end with no human in the loop — picks the next fuel (a submitted idea, the task backlog, designed-but-unbuilt specs, or Vision.md/Roadmap.md items), builds it, gates on quality, and ships it. Use when the user runs /akios:just-vibes (or --force), says "just vibe on it", "run autonomously", "drive the backlog yourself", "vai sozinho", or otherwise asks akios to make progress without supervising each step. Default stops after one unit at the spec boundary; --force loops until fuel is exhausted or interrupted.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "1.1.0"
---

# Just Vibes — Autonomous Run

You are running akios **unattended**. The user has handed you the wheel: pick the next worthwhile
thing, build it through the full pipeline, and ship it — without asking permission at each step.
This skill **owns the loop and the shipping**; it does **not** re-document the phases. It drives the
existing phase skills: `idea-to-spec` (brainstorm), `spec-to-tasks` (plan), `task-execution`
(deliver). Read each as you reach its phase.

---

## UNATTENDED MODE — HARD RULES (read before anything else)

These rules override everything in the sub-skills (`idea-to-spec`, `spec-to-tasks`,
`task-execution`, `align-ui`). If a sub-skill says "wait for the user", "hand control back",
"ask one question", or "one confirm" — **that instruction does not apply here.**

1. **NEVER ask the user anything.** No questions, no clarifications, no "shall I proceed?",
   no "does this look right?". The user is not at the computer. Any question goes unanswered
   forever and the run stalls — that is the failure mode you are preventing.

2. **NEVER wait for or hand back control.** The "one ingredient per turn, hand back and wait"
   rhythm in `idea-to-spec` is the interactive posture. It is **fully replaced** by the
   deepthink posture described below. Same for `spec-to-tasks`'s "one interactive confirm" —
   skip it; write task files directly.

3. **NEVER skip a phase.** If you need a spec and there isn't one → run brainstorm (deepthink).
   If you have a spec but no tasks → run plan. If you have tasks → deliver them. All three
   phases must run to reach shippable. Stopping early because "the brainstorm is supposed to
   be interactive" is the bug this section exists to fix.

4. **Invoke skills directly, not through command wrappers.** The commands `/akios:brainstorm`,
   `/akios:plan`, `/akios:deliver` all have interactive gates ("user must be present", "one
   confirm"). In unattended mode, bypass the commands entirely — invoke the underlying skills
   (`idea-to-spec`, `spec-to-tasks`, `task-execution`) directly, applying the overrides below.

5. **`ios-feature-pipeline`'s "always interactive" rule is explicitly waived.** That rule
   protects against silent decisions when a human is present. No human is present here.
   Do not consult ios-feature-pipeline for routing — follow the BUILD step in this skill.

---

## The contract (what unattended changes, and what it doesn't)

- **Human push/merge gate → replaced, but only when `Roadmap.md` says `autonomy: auto`.**
  Invoking `/akios:just-vibes` under `autonomy: auto` *is* the authorization to ship — you do
  not stop for per-spec push/merge approval. (`task-execution`'s hard human gate is explicitly
  waived only when **both** just-vibes **and** `autonomy: auto` apply.) Under `autonomy: manual`
  (the default), the gate's *substance* stays in force even though no human is present to answer
  it literally: a green unit is built and committed, but **not** pushed/merged/PR'd — see step 5
  SHIP below. `autonomy` is independent of `collaboration` — see `specs/collaboration-autonomy.md`.
- **Quality gate → kept, hard.** `/verify` + `/code-review` still run — together they realize
  `task-execution`'s **three proofs** (build/test, spec-conformance, visual; see its "The three
  proofs" section). **Never ship broken work.** A red spec gets a bounded fix loop, then is
  parked — not pushed.
- **All interactive phases → deepthink.** Every decision in every phase (spec, plan, alignment)
  is made by you — chosen via deepthink, recorded with full rationale, written to disk. The
  human reviews *after* and can override any decision.

---

## Deepthink posture (applies to every phase, every decision)

Whenever you make a decision unattended:

- **Research first.** If external facts would change the answer (competitor approaches, platform
  constraints, pricing, regulations), web-search and cite before deciding — never assert from memory.
- **Second-order consequences.** For each option: what it forecloses, whether it's reversible or
  one-way, who it helps or hurts downstream.
- **Choose the recommendation you'd have pre-marked.** Where genuinely 50/50, pick the reversible
  option.
- **Record everything.** Write the chosen option, the rejected options, and the reasoning into the
  output artifact (spec, task file, alignment doc). A silently-decided artifact is a failure.
- **Flag, don't smooth.** Tensions and unverifiable assumptions go into the artifact as marked
  open risks, not quiet resolutions.

---

## Default vs --force

- **Default** (`/akios:just-vibes [idea]`): build **one unit** end to end, ship, then **STOP
  at the spec boundary** and report.
- **`--force`**: loop over all fuel — **no stop between specs** — until exhausted or interrupted.

---

## Fuel — what to work on next (precedence, most-ready first)

1. **Explicit idea** passed as an argument (highest — the user told you what to do).
2. **`tasks/todo/*.md`** — already planned, ready to deliver (run deliver phase only).
3. **`tasks.md`** (legacy single-file format) — tasks exist, run deliver phase using the file as
   the backlog. Treat each unchecked `[ ]` item as a pending task in checkpoint order.
4. **`specs/*.md` at status `designed`** in `Roadmap.md` — has a spec, needs plan → deliver.
   - **Skip `needs-revision` specs** (R-W-W audit flagged them weak) unless `--force` is passed.
     Log each skipped spec in the journal with reason "audit: needs-revision".
5. **`specs/*.md` present but no `Roadmap.md`** — treat each spec as `designed`, run plan → deliver.
6. **`Vision.md` / `Roadmap.md` items with no spec** — needs full brainstorm → plan → deliver
   (with `design` between plan and deliver for any UI-scoped task the plan produces).

> **`needs-revision` specs:** Roadmap status set by the deep-brainstorm R-W-W audit when a spec
> scores below 41/100. Skipped in default mode — the spec needs revision before it's
> deliver-ready. Pass `--force` to include them (at your own risk; audit findings apply).

**Fuel detection procedure:**
```
1. Check for tasks/todo/*.md  → deliver fuel
2. Check for tasks.md         → deliver fuel (legacy)
3. Read Roadmap.md if present → find specs at status `designed`
   └ SKIP any spec at status `needs-revision` unless --force was passed
4. List specs/*.md            → any spec without a tasks/todo/ entry = plan fuel
5. Read Vision.md / Roadmap.md for backlog items without specs → brainstorm fuel
6. Nothing found              → report "no fuel" and stop
```

Pick the highest-precedence fuel that is **not already claimed by another akios instance**.

---

## The loop (per unit)

```
1. PICK    next fuel by precedence (fuel detection procedure above)
2. CLAIM   record ownership in a COMMITTED file (task frontmatter `owner:`, or Roadmap spec
           line) signed with this instance's signature (.claude/hooks/akios-instance.sh).
           Team mode: commit "claim: <unit> by <sig>" + push; rejected → yield and re-pick.
3. BUILD   run only the phases needed to reach shippable.
           CRITICAL: run skills directly; every interactive gate is waived (see UNATTENDED RULES).

           a. NO SPEC → brainstorm (idea-to-spec, DEEPTHINK MODE):
              - Read MEMORY.md + archive/Archive.md for prior decisions to reuse.
              - Make every decision yourself via deepthink (no waiting, no handing back).
              - Record chosen + rejected options + reasoning in the spec.
              - Write spec to specs/<name>.md. Register in Roadmap.md at status designed.

           b. HAS SPEC, NO TASKS → plan (spec-to-tasks, UNATTENDED MODE):
              - Read the spec + Context.md + MEMORY.md.
              - Decompose into task files in tasks/todo/ (or update tasks.md for legacy projects).
              - Skip the "one interactive confirm" — write task files directly.
              - Group by similarity, bound by 80k tokens, tag parallelism, set checkpoints.

           c. HAS TASKS → deliver (task-execution, UNATTENDED MODE):
              - Follow task-execution's folder-state lifecycle.
              - align-ui gate: if a task is UI-scoped, run align-ui in auto-decide mode
                (every choice marked [auto], no questions asked, alignment doc written).
              - TDD-first posture, commit at each checkpoint barrier.
              - Human push/merge gate: waived only under `autonomy: auto` (this skill is the
                authorization there); under `autonomy: manual` the gate's substance holds — see
                step 5 SHIP.

4. GATE    /verify + /code-review (load `skills/review-doctrine/GUIDE.md` first, same as
           task-execution's own gate — see its "Code-review doctrine" section) — the three
           proofs (build/test, spec-conformance, visual)
             green → SHIP (step 5)
             red   → FIX LOOP: diagnose + fix, re-verify. Bound: stop after two consecutive
                     cycles with no measurable progress (same failures). Then PARK.
5. SHIP    gated by Roadmap.md `autonomy` flag FIRST, then `collaboration`:
             autonomy: manual → skip push/merge/PR entirely. Commits stay local on
                                 feature/<spec>. Update Roadmap status per the quality-gate
                                 result exactly as autonomy: auto would (green → done, red →
                                 blocked) — manual gates SHIPPING, not build completion. Append
                                 "Shipping: deferred — autonomy: manual, awaiting human
                                 push/merge" to the journal (step 6) and CONTINUE the loop under
                                 --force (this unit does not stop the whole run).
             autonomy: auto   → proceed per `collaboration`:
                                   solo → merge feature/<spec> into default branch + push
                                   team → push feature/<spec> + open a PR (gh)
                                 Commit trailer carries Akios-Instance. Update Roadmap status → done.
   PARK   (red, unfixable): keep branch + logs; set Roadmap status to `blocked`; DO NOT ship.
           Also PARK if the spec is at `needs-revision` — even a green quality gate does not
           authorize shipping a spec the R-W-W audit flagged as weak. Revise the spec first.
           (PARK is unrelated to `autonomy: manual`'s deferral — PARK means red/unfixable; a
           manual-deferred unit is green, just not self-shipped.)
6. JOURNAL append the cycle to .akios/just-vibes-journal.md:
             - unit built, fuel type used, phases run
             - key decisions made (with reasoning) per phase
             - gate result (green/red), shipping outcome or park reason or deferred (autonomy: manual)
             - branch / PR link (if shipped)
             - under posture: learning — also append a "Lessons" subsection (see below)
7. NEXT    default → STOP + report.  --force → loop to step 1.
```

---

## Coordination with teammates (multi-instance)

just-vibes is the most likely place two akios instances collide, so it is **claim-first**:
- Claim before building; a unit owned by **another** instance's `Akios-Instance` signature is
  off-limits — skip to the next fuel.
- `git pull` before claiming; **push-rejection is the lock** — if your claim push is rejected,
  pull, re-check ownership, and yield if it was taken.
- The claim push is **coordination**, not shipping — it happens exactly as described here
  regardless of the `autonomy` flag. `autonomy: manual` only withholds step 5's shipping action
  (merge to default branch, or push-for-PR + PR open); it never disables claim-lock semantics.
- `Roadmap.md` uses **monotonic-status merge** (higher status wins); never reorder its `## Specs`
  table — edit only your unit's row.

---

## Posture under just-vibes (learning vs. delivery)

No human is present to narrate to, so `posture: learning` (`Roadmap.md`, default `delivery`)
redirects the teaching to the journal instead of live narration:

- **Learning:** every unit's journal entry (step 6) gains a **"Lessons"** subsection — the 3–5
  principles the unit exercised, the decisions and their *why* (citing the owning pack/spec), and
  any entry auto-appended to the **hurdles ledger** (`code-references/hurdles.md`, see
  `task-execution`'s "Hurdles ledger" section) or `preferences.md` this unit. This is the artifact
  a returning human reads to learn what happened *and why* — the unattended analogue of live
  narration.
- **Delivery (default):** journal outcomes only, exactly as documented above — no Lessons
  subsection.
- Both postures keep every other unattended rule unchanged (deepthink decisions, no questions
  asked, quality gate not relaxed) — posture only ever adds or omits the Lessons subsection.

See `specs/operating-modes.md` §4 (D4) for the source design.

## Reporting (every time you stop)

End with a compact report drawn from the journal:
- **Shipped:** units shipped + where (merged branch / PR links). Only populated under
  `autonomy: auto`.
- **Built (unshipped):** units that reached a **green** quality gate under `autonomy: manual` —
  branch name + spec, ready for a human to push/merge. Distinct from Parked (red) and Shipped
  (already shipped) — don't conflate a policy-withheld shipment with a broken one.
- **Parked:** units left red + the blocker + branch name (so a human can pick them up).
- **Skipped:** fuel owned by teammates (with their signature) — for visibility, not action.
- **Open risks:** decisions flagged as unverifiable or tensions left unresolved, per unit.
- **Next:** what fuel remains, and the one-line command to continue (`/akios:just-vibes --force`).

---

## Anti-patterns

- **Stopping because "brainstorm must be interactive"** — that rule is waived here; run deepthink.
- **Asking one clarifying question** — no one answers it; the run stalls. Make the decision.
- **Skipping spec-to-tasks's confirm** without writing the tasks — write them; the confirm is waived,
  not the task files.
- Shipping a red spec — park it, never ship broken work.
- Brainstorming unattended without recording decisions — the human reviews after; the *why* must be
  on disk.
- In default mode, sliding into a second unit — stop at the first spec boundary.
- Grabbing a unit another instance's signature already claimed.
- Pushing, merging, or opening a PR under `autonomy: manual` — that flag exists precisely to
  withhold shipping; build and commit, then defer (§5 SHIP), never override it because "just
  this once seems safe."
- Stopping the whole `--force` run because one unit deferred under `autonomy: manual` — deferral
  is not a stall condition; keep looping over remaining fuel.
