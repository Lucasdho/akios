---
id: T043
spec: specs/operating-modes.md
est_tokens: 16k
runner: orchestrator
parallel: false
area: posture-threading
checkpoint: 26
---

# T043 — Thread posture through every phase skill + just-vibes Lessons + session overrides

> **State:** done

## Description
Realizes `operating-modes.md` §3 (D3, threading), §4 (D4, just-vibes journal) and the
session-override half of §1 (D1). Each phase skill reads `posture` (as it already reads
`collaboration`) and toggles only the named teaching surface (§2) — never the underlying
decisions. `just-vibes` gains the unattended analogue (a written "Lessons" journal subsection).
Command wrappers document the `--learning`/`--delivery` session-override flag.

## Files
- `skills/idea-to-spec/SKILL.md` — new "Posture" section: learning surfaces the *why* behind each
  design decision live (already stored in the spec).
- `skills/spec-to-tasks/SKILL.md` — new "Posture" section: learning explains the decomposition
  (checkpoints, `[P]`, pack tags) at the step-10 confirm.
- `skills/task-execution/SKILL.md` — new "Operating posture" section (priority-chain/doctrine
  annotation + end-of-unit digest) placed after "The priority chain"; "Feedback logging" section
  amended for learning's eager-capture behavior.
- `skills/align-ui/SKILL.md` — new "Posture" section: learning names the Nielsen heuristic +
  native-over-custom rationale per decision.
- `skills/just-vibes/SKILL.md` — step 6 (JOURNAL) gains the Lessons-subsection line; new "Posture
  under just-vibes" section describing the written analogue to live narration.
- `commands/execute.md`, `commands/plan.md`, `commands/brainstorm.md`, `commands/design.md` —
  each documents the optional `--learning`/`--delivery` `$ARGUMENTS` flag (session-only override,
  doesn't rewrite `Roadmap.md`).

## Definition of Done
- All four phase skills (`idea-to-spec`, `spec-to-tasks`, `task-execution`, `align-ui`) contain a
  posture-reading section stating: (a) default `delivery`, (b) session override doesn't rewrite
  the Roadmap value, (c) the specific teaching-surface behavior toggled in that skill, (d) posture
  never changes the underlying decision/output.
- `task-execution/SKILL.md`'s posture section explicitly covers priority-chain/doctrine inline
  annotation and the end-of-unit digest, and cross-references the just-vibes journal redirect.
- `just-vibes/SKILL.md` documents the "Lessons" journal subsection (learning) vs. outcomes-only
  (delivery), and that every other unattended rule (deepthink, no questions, quality gate) is
  unchanged by posture.
- Each of the four command wrappers documents the `--learning`/`--delivery` flag as a session-only
  override.
- `grep -rln "Posture" skills/idea-to-spec/SKILL.md skills/spec-to-tasks/SKILL.md skills/task-execution/SKILL.md skills/align-ui/SKILL.md skills/just-vibes/SKILL.md` returns all five files.
- No behavior in either posture changes *what* gets built — every edit only adds narration/journal
  content, never a new decision path.

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/operating-modes.md` §3 (D3), §4 (D4), §1 (D1 session-override clause). Depends on
T042's flag existing in `Roadmap.md`/`workflow.yml` (same checkpoint, sequenced after). This task
does not touch `verification-and-learning-loop.md`'s hurdles ledger content (G5, not yet built) —
the "eager capture" language here is forward-referencing that spec's mechanism, which T045–T048
(next spec in this session) actually builds.
