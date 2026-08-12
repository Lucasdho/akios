---
name: just-vibes
description: Autonomous akios run. Drives the whole feature pipeline (brainstorm→plan→deliver) end to end with no human in the loop — picks the next fuel (a submitted idea, the task backlog, designed-but-unbuilt specs, or akios/Vision.md/akios/Roadmap.md items), builds it, and gates on quality. Use when the user runs /akios:just-vibes (or --force), says "just vibe on it", "run autonomously", "drive the backlog yourself", "vai sozinho", or otherwise asks akios to make progress without supervising each step. Default stops after one unit at the spec boundary; --force loops until fuel is exhausted or interrupted.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "1.2.0"
---

# Just Vibes — Autonomous Run

You are running akios **unattended**. The user has handed you the wheel: pick the next worthwhile
thing and build it through the full pipeline — without asking permission at each step.
This skill **owns the loop**; it does **not** re-document the phases. It drives the
existing phase skills: `idea-to-spec` (brainstorm), `spec-to-tasks` (plan), `task-execution`
(deliver). Read each as you reach its phase.

---

## UNATTENDED MODE — HARD RULES (read before anything else)

These rules override everything in the sub-skills (`idea-to-spec`, `spec-to-tasks`,
`task-execution`). If a sub-skill says "wait for the user", "hand control back",
"ask one question", or "one confirm" — **that instruction does not apply here.**

1. **NEVER ask the user anything.** No questions, no clarifications, no "shall I proceed?",
   no "does this look right?". The user is not at the computer. Any question goes unanswered
   forever and the run stalls — that is the failure mode you are preventing.

2. **NEVER wait for or hand back control.** The "one ingredient per turn, hand back and wait"
   rhythm in `idea-to-spec` is the interactive mode. It is **fully replaced** by the
   deepthink mode described below. Same for `spec-to-tasks`'s "one interactive confirm" —
   skip it; write task files directly.

3. **NEVER skip a phase.** If you need a spec and there isn't one → run brainstorm (deepthink).
   If you have a spec but no tasks → run plan. If you have tasks → deliver them. All three
   phases must run to reach shippable. Stopping early because "the brainstorm is supposed to
   be interactive" is the bug this section exists to fix.

4. **Invoke skills directly, not through command wrappers.** The commands `/akios:brainstorm`,
   `/akios:plan`, `/akios:deliver` all have interactive gates ("user must be present", "one
   confirm"). In unattended mode, bypass the commands entirely — invoke the underlying skills
   (`idea-to-spec`, `spec-to-tasks`, `task-execution`) directly, applying the overrides below.

5. **`feature-pipeline`'s "always interactive" rule is explicitly waived.** That rule
   protects against silent decisions when a human is present. No human is present here.
   Do not consult feature-pipeline for routing — follow the BUILD step in this skill.

---

## The contract (what unattended changes, and what it doesn't)

- **Git → still never touched.** akios does not run git, here or anywhere (see `AGENTS.md`
  "akios never writes to git"). No commits, no branches, no pushes, no merges, no PRs — an
  unattended run produces exactly what an attended one does: changed files in the working tree.
  The human reviews the diff and decides what to do with it. "Unattended" removes the *questions*,
  not the human's ownership of their history.
- **Quality gate → kept, hard.** `task-execution`'s **two proofs** still run in full — the
  build/test proof (`akios/Context.md`'s recorded `Test:` / `Build:` command, degrading to the DoD
  audit in a repo with no runner) and the spec-conformance proof (`/code-review` + the divergence
  audit). See its "The two proofs" section for the mechanism; don't substitute a lighter check.
  **Never leave broken work marked done.** A red spec gets a bounded fix loop, then is parked.
- **All interactive phases → deepthink.** Every decision in every phase (spec, plan, delivery)
  is made by you — chosen via deepthink, recorded with full rationale, written to disk. The
  human reviews *after* and can override any decision.

---

## Deepthink (applies to every phase, every decision)

Whenever you make a decision unattended:

- **Research first.** If external facts would change the answer (competitor approaches, platform
  constraints, pricing, regulations), web-search and cite before deciding — never assert from memory.
- **Second-order consequences.** For each option: what it forecloses, whether it's reversible or
  one-way, who it helps or hurts downstream.
- **Choose the recommendation you'd have pre-marked.** Where genuinely 50/50, pick the reversible
  option.
- **Record everything.** Write the chosen option, the rejected options, and the reasoning into the
  output artifact (spec, task file). A silently-decided artifact is a failure.
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
2. **`akios/tasks/todo/*.md`** — already planned, ready to deliver (run deliver phase only).
3. **`akios/specs/*.md` at status `designed`** in `akios/Roadmap.md` — has a spec, needs plan → deliver.
   - **Skip `needs-revision` specs** (R-W-W audit flagged them weak) unless `--force` is passed.
     Log each skipped spec in the journal with reason "audit: needs-revision".
4. **`akios/specs/*.md` present but no `akios/Roadmap.md`** — treat each spec as `designed`, run plan → deliver.
5. **`akios/Vision.md` / `akios/Roadmap.md` items with no spec** — needs full brainstorm → plan → deliver.

**Fuel detection procedure:**
```
1. Check for akios/tasks/todo/*.md  → deliver fuel
2. Read akios/Roadmap.md if present → find specs at status `designed`
   └ SKIP any spec at status `needs-revision` unless --force was passed
3. List akios/specs/*.md            → any spec without a akios/tasks/todo/ entry = plan fuel
   └ NOT every file under specs/ is buildable fuel. Skip discovery documents —
     founderlens-*.md (a first-diamond run, not a feature) — and anything that is a
     report about the specs rather than a spec. When a file has no buildable scope,
     it is not fuel; say so in the journal and move on.
4. Read akios/Vision.md / akios/Roadmap.md for backlog items without specs → brainstorm fuel
5. Nothing found              → report "no fuel" and stop
```

Pick the highest-precedence fuel.

---

## The loop (per unit)

```
1. PICK    next fuel by precedence (fuel detection procedure above)
2. BUILD   run only the phases needed to reach a finished unit.
           CRITICAL: run skills directly; every interactive gate is waived (see UNATTENDED RULES).

           a. NO SPEC → brainstorm (idea-to-spec, DEEPTHINK MODE):
              - Read MEMORY.md + akios/archive/Archive.md for previously delivered high-quality specs;
                mirror their patterns and decisions — consistency with proven work beats novelty.
              - Make every decision yourself via deepthink (no waiting, no handing back).
              - Record chosen + rejected options + reasoning in the spec.
              - Write spec to akios/specs/<name>.md. Register in akios/Roadmap.md at status designed.

           b. HAS SPEC, NO TASKS → plan (spec-to-tasks, UNATTENDED MODE):
              - Read the spec + akios/Context.md + MEMORY.md.
              - Decompose into task files in akios/tasks/todo/.
              - Skip the "one interactive confirm" — write task files directly.
              - Group by similarity, bound by 80k tokens, tag parallelism, set checkpoints.

           c. HAS TASKS → deliver (task-execution, UNATTENDED MODE):
              - Follow task-execution's folder-state lifecycle.
              - Every gate that would normally grill the user runs in auto-decide mode
                (every choice marked [auto], no questions asked, rationale recorded).
              - TDD-first; audit every DoD at each checkpoint barrier.
              - Touch git at no point: no branch, no commit, no push.

3. GATE    task-execution's TWO PROOFS: the build/test proof (akios/Context.md `Test:`/`Build:`,
           or the DoD audit where there's no runner) + /code-review with its "Code-review
           doctrine" checklist applied on top of the built-in review, same as its own gate
             green → RECORD (step 4)
             red   → FIX LOOP: diagnose + fix, re-verify. Bound: stop after two consecutive
                     cycles with no measurable progress (same failures). Then PARK.
4. RECORD  green → set the spec's akios/Roadmap.md status to `done` and move its task files to
                   akios/tasks/done/. The work sits in the working tree, uncommitted, for the
                   human to review.
   PARK   (red, unfixable): leave the failing work in place with its logs; set Roadmap status to
           `blocked`. Also PARK if the spec is at `needs-revision` — even a green quality gate
           does not authorize marking done a spec the R-W-W audit flagged as weak. Revise first.
5. JOURNAL append the cycle to akios/.local/just-vibes-journal.md:
             - unit built, fuel type used, phases run
             - key decisions made (with reasoning) per phase
             - gate result (green/red), and the park reason if parked
             - the files it touched, so the human can find the diff
6. NEXT    default → STOP + report.  --force → loop to step 1.
```

---

## Reporting (every time you stop)

End with a compact report drawn from the journal. **Everything below is uncommitted work in the
working tree** — say so once, plainly, so the human knows the diff is theirs to review and commit:
- **Built:** units that reached a **green** quality gate — spec + the files touched.
- **Parked:** units left red + the blocker + where the failing work sits.
- **Open risks:** decisions flagged as unverifiable or tensions left unresolved, per unit.
- **Next:** what fuel remains, and the one-line command to continue (`/akios:just-vibes --force`).

**Say the cost of `--force` out loud when you report.** akios commits nothing, so a `--force` run
that crossed several specs leaves them all in one undifferentiated working tree with no checkpoint
between them — if one unit turns out wrong, there's nothing to roll back *to*. That's the accepted
price of the human owning their own history, not a defect; but the human should hear it. Recommend
they review and commit unit by unit, in the order the report lists, before resuming.

---

## Anti-patterns

- **Stopping because "brainstorm must be interactive"** — that rule is waived here; run deepthink.
- **Asking one clarifying question** — no one answers it; the run stalls. Make the decision.
- **Skipping spec-to-tasks's confirm** without writing the tasks — write them; the confirm is waived,
  not the task files.
- Marking a red spec `done` — park it, never sign off on broken work.
- Brainstorming unattended without recording decisions — the human reviews after; the *why* must be
  on disk.
- In default mode, sliding into a second unit — stop at the first spec boundary.
- **Running any git command.** Not a branch, not a commit, not a push — "unattended" is not
  authorization over the user's history. Leave the changes in the working tree and report them.
