---
name: just-vibes
description: Autonomous akios run. Drives the whole feature pipeline (brainstorm→plan→execute→deliver) end to end with no human in the loop — picks the next fuel (a submitted idea, the task backlog, designed-but-unbuilt specs, or Vision.md/Roadmap.md items), builds it, gates on quality, and delivers. Use when the user runs /akios:just-vibes (or --force), says "just vibe on it", "run autonomously", "drive the backlog yourself", "vai sozinho", or otherwise asks akios to make progress without supervising each step. Default stops after one unit at the spec boundary; --force loops until fuel is exhausted or interrupted.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "1.0.0"
---

# Just Vibes — Autonomous Run

You are running akios **unattended**. The user has handed you the wheel: pick the next worthwhile
thing, build it through the full pipeline, and deliver it — without asking permission at each step.
This skill **owns the loop and the delivery**; it does **not** re-document the phases. It drives the
existing phase skills: `idea-to-spec` (brainstorm), `spec-to-tasks` (plan), `task-execution`
(execute). Read each as you reach its phase.

## The contract (what unattended changes, and what it doesn't)

- **Human push/merge gate → replaced.** Invoking `/akios:just-vibes` *is* the authorization to
  deliver. You do not stop for per-spec push/merge approval. (`task-execution`'s hard human gate is
  explicitly waived **only** under just-vibes.)
- **Quality gate → kept, hard.** `/verify` + `/code-review` still run. **Never deliver broken work.**
  A red spec gets a bounded fix loop, then is parked — not pushed.
- **Interactive brainstorm → unattended deepthink.** No human is present to answer design decisions,
  so `idea-to-spec` runs its **"Unattended (just-vibes) brainstorm"** posture: deepthink per material
  decision, competitor/solution research, reuse of previously delivered specs, every decision recorded
  for post-hoc review.

## Default vs --force

- **Default** (`/akios:just-vibes [idea]`): build **one unit** (the submitted idea, else the single
  next fuel item) end to end, deliver, then **STOP at the spec boundary** and report. The gap between
  specs is where a human can step in.
- **`--force`**: keep looping over fuel — **no stop between specs** — until fuel is exhausted or the
  user interrupts. Same delivery + reporting; it just doesn't stop after one.

## Fuel — what to work on next (precedence, most-ready first)

1. **Explicit idea** passed as an argument (highest — the user told you what to do).
2. **`tasks/todo/*.md`** — already planned, ready to execute (just run the execute phase).
3. **`specs/*.md` at status `designed`** in `Roadmap.md` — has a spec, needs plan → execute.
4. **`Vision.md` / `Roadmap.md` items with no spec** — needs the full brainstorm → plan → execute.

Read `Roadmap.md` first to know what exists and each spec's status. Pick the highest-precedence fuel
that is **not already claimed by another akios instance** (team mode — see Coordination). If nothing
is available, stop and report "no fuel".

## The loop (per unit)

```
1. PICK    next fuel by precedence (respect teammate claims in team mode)
2. CLAIM   record ownership in a COMMITTED file (task frontmatter `owner:`, or the Roadmap spec
           line when no tasks exist yet) signed with this instance's signature
           (.claude/hooks/akios-instance.sh); team mode: commit "claim: <unit> by <sig>" + push.
           push rejected / already claimed by another signature → yield, pick the next fuel.
3. BUILD   run only the phases needed to reach shippable:
             no spec   → idea-to-spec  (UNATTENDED DEEPTHINK) → specs/<x>.md w/ decision records
             no tasks  → spec-to-tasks → tasks/todo/
             tasks      → task-execution (branch per spec, TDD, per-task review)
4. GATE    /verify + /code-review
             green → DELIVER (step 5)
             red   → FIX LOOP: diagnose + fix, re-verify. Bound it: stop after two consecutive
                     cycles make no measurable progress (same failures, no closer). Then PARK.
5. DELIVER per Roadmap.md `collaboration`:
             solo → merge feature/<spec> into the default branch + push it
             team → push feature/<spec> + open a PR (gh)
           commit trailer carries Akios-Instance. Update Roadmap status → done.
   PARK   (red, unfixable): keep feature/<spec> + logs; set the spec's Roadmap status note to
           `blocked`; DO NOT deliver. Record why in the journal.
6. JOURNAL append the cycle to .akios/just-vibes-journal.md (unit, decisions, outcome, branch/PR).
7. NEXT    default → STOP + report.  --force → release nothing claimed-but-undone, loop to step 1.
```

## Coordination with teammates (multi-instance)

just-vibes is the most likely place two akios instances collide, so it is **claim-first**. Follow the
**"Working alongside teammates"** rules in `AGENTS.md` and the **claim protocol** in `task-execution`:
- Claim before building; a unit owned by **another** instance's `Akios-Instance` signature is off
  limits — skip to the next fuel.
- `git pull` before claiming; **git push-rejection is the lock** — if your claim push is rejected,
  pull, re-check ownership, and yield if it was taken.
- `Roadmap.md` is the single source of truth with a **monotonic-status merge** (higher status wins);
  never reorder its `## Specs` table — edit only your unit's line.

## Reporting (every time you stop)

End with a compact report drawn from the journal:
- **Delivered:** units shipped + where (merged branch / PR links).
- **Parked:** units left red + the blocker + branch name (so a human can pick them up).
- **Skipped:** fuel owned by teammates (with their signature) — for visibility, not action.
- **Next:** what fuel remains, and the one-line command to continue (`/akios:just-vibes --force`).

## Anti-patterns

- Delivering a red spec because the loop "ran out of patience" — park it, don't ship it.
- Asking the user to approve a push mid-run — that's the gate just-vibes intentionally waived; just
  deliver per the `collaboration` flag and report at the boundary.
- Brainstorming unattended **without** the deepthink posture (no research, no decision records) —
  the human reviews after the fact, so the *why* must be on disk.
- Grabbing a unit another instance's signature already claimed.
- In default mode, sliding into a second unit — stop at the first spec boundary; `--force` is opt-in.
