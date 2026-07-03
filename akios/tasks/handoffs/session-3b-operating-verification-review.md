# Handoff — Session 3b: operating-modes.md + verification-and-learning-loop.md + code-review-doctrine.md

> Session: 2026-07-01, continuing from Session 3a
> Phase: execute
> Spec: specs/operating-modes.md, then specs/verification-and-learning-loop.md, then specs/code-review-doctrine.md
> Task: none open yet — this session creates and runs its own tasks/todo/ backlog

## Context in one paragraph

akios (this repo) is a Claude Code plugin for Swift/iOS work, not a Swift app. The whole backlog
in `specs/akios-backlog-map.md` (37 items) is being built toward a single **v0.8.0** release.
The original 3-session plan's "Session 3" has been split into smaller cold-start sub-sessions
(3a, 3b, 3c, 3d) because Session 2 burned ~316k tokens on two specs — token estimates for these
builds are consistently bad, so smaller sessions are now the standing practice: cold-start every
subagent with a handoff file (never fork), and keep each session's scope to roughly what one
already-designed, medium spec costs. **Session 3a** (just completed) built `snippet-library.md`,
`skeleton-library.md`, `skill-authoring.md` — three already-designed specs, ~193k tokens, clean.
**This session (3b) builds three more already-designed specs**, same shape as 3a:
`operating-modes.md` → `verification-and-learning-loop.md` → `code-review-doctrine.md`. A later
session, **3c**, will *write* (design, not just build) two new specs — G9
`collaboration-autonomy.md` and G10 `init-reliability-and-ux.md` — then build them (heavier work:
design + build, not just build, so it's kept separate). **Session 3d** will do the v0.8.0 closeout
(Roadmap all `done`, CHANGELOG consolidation, VERSION + `plugin.json` bump). **Do not do 3c or
3d's work in this session** — stop after `code-review-doctrine.md` is done and write the return
handoff.

## Where we are

- Session 1 (`4c910be`..`a4c5c5e`): `alva-adoption.md` (T001–T011).
- Session 2 (`6c8ee16`..`4df4122`): `ui-overhaul-implementation.md` (T012–T026),
  `knowledge-architecture.md` (T027–T032).
- Session 3a (`79047c6`..`07f5ff7`): `snippet-library.md` (T033–T035), `skeleton-library.md`
  (T036–T037), `skill-authoring.md` (T038–T041). Checkpoints 20–25.
- All six specs above are `done` in `Roadmap.md`. Working tree clean on `alva+ui-strategies`.
  The branch is on GitHub (`origin/alva+ui-strategies`) through commit `3c23b8e` — the user
  confirmed they pushed that themselves; **this session still does not push or merge**, same
  standing gate as every prior session.
- **Continue task numbering from T042. Continue checkpoint numbering from 26.**
- Checkpoint: none in flight. Start fresh at "read the spec" for `operating-modes.md`.

## Decisions made this session (not yet in artifacts)

- **Build order: `operating-modes.md` → `verification-and-learning-loop.md` →
  `code-review-doctrine.md`**, matching `akios-backlog-map.md` §5 step 8's listed order. The three
  are declared independent of each other in that spec (each "plugs into `task-execution` +
  `just-vibes`" separately) — this order is just a sequencing choice for one agent building them
  serially, not a dependency requirement.
- **Real (soft, already-satisfied) dependencies to be aware of, not blocking:**
  - `verification-and-learning-loop.md` §3 places the hurdles ledger in the project's **code
    pack** (tier 2 of the priority chain) — this requires `knowledge-architecture.md`'s pack
    format, which Session 2 already shipped. No new design needed, just wire `hurdles.md` into
    the existing pack/priority-chain machinery.
  - `code-review-doctrine.md` §2.2's DRY check reads `Foundation/usage-ledger.json` — this
    requires `alva-adoption.md`'s ledger, which Session 1 already shipped
    (`scripts/alva-usage-ledger.sh`). Wire the read, don't redesign the ledger.
  - `operating-modes.md` §5 says learning posture "feeds G5" (verification-and-learning-loop's
    hurdle capture) — build `operating-modes.md` first so its posture flag exists by the time
    `verification-and-learning-loop.md`'s capture-eagerness wiring references it, though nothing
    breaks badly if built in the other order (the flag is additive).
- **`operating-modes.md` §1 adds a third `Roadmap.md` flag (`posture: learning | delivery`)** —
  this touches `Roadmap.md`'s template/header, a spine file. Do this edit once, cleanly, in this
  spec's own checkpoint; don't let it collide with anything else touching `Roadmap.md` in the
  same session (nothing else in 3b's scope should need to touch the `## Mode` block).
- **`verification-and-learning-loop.md` §4's auto-build/test hook is scoped N/A for this repo**
  (no `xcodebuild` here — it's a plugin/docs repo). Build the hook mechanism + its `.claude/hooks/`
  installation path per the spec (for *installed iOS projects*), but don't expect to exercise it
  against this repo itself — the DoD is "hook exists and installs correctly," not "hook ran
  successfully here." The spec's own §4 "Plugin-repo note" says this explicitly.
- Per repo convention, no VERSION/CHANGELOG/plugin.json bump this session — deferred to 3d's
  closeout.

## Open questions

- None blocking. If something in any of the three specs is genuinely ambiguous, resolve it the
  way `spec-to-tasks` prescribes: ask **one direct question**, no clarify ceremony.

## Risks / tensions

- All three specs plausibly touch `skills/task-execution/SKILL.md` (a spine file per
  `specs/parallel-execution-scheduling.md`): `operating-modes.md` §3 (posture threading),
  `verification-and-learning-loop.md` §1/§5 (divergence audit, hurdle loading), and
  `code-review-doctrine.md` §4 (doctrine loaded at the gate). This is fine *within* this single
  session (sequential edits, one agent) — it's exactly why this sub-session should not run
  concurrently with any other instance touching the same file. Nothing else should be running
  against this repo while 3b is in flight.
- `operating-modes.md` and `code-review-doctrine.md` also touch `skills/just-vibes/SKILL.md`
  (posture-aware journaling; doctrine loaded at GATE) — another shared file across all three
  specs in this session; same reasoning, sequential is fine, don't run concurrently with anything
  else.
- `verification-and-learning-loop.md`'s hurdles ledger and `code-review-doctrine.md`'s
  `review-doctrine` reference both add new files under the `ios` pack
  (`skills/swift-dev/` or wherever Session 2 landed the pack manifest — check
  `skills/swift-dev/pack.yml` from Session 2's build for the actual pack root before adding
  files) — read the current pack structure before adding, don't guess the path.

## Suggested skills (in order)

1. Read `specs/operating-modes.md`, `specs/verification-and-learning-loop.md`,
   `specs/code-review-doctrine.md` in full before decomposing into tasks.
2. `spec-to-tasks` mechanics (`skills/spec-to-tasks/SKILL.md`) — decompose each spec, in the fixed
   order above, into `tasks/todo/T0NN-*.md` files. Continue numbering from **T042**, checkpoints
   from **26**.
3. `task-execution` mechanics (`skills/task-execution/SKILL.md`) — implement, commit at every
   checkpoint, move task files `tasks/todo/ → tasks/in-progress/ → tasks/done/`. DoD by
   inspection + grep (plugin/docs repo, no Swift build/test).
4. Flip each spec's `Roadmap.md` row to `done` as it completes (three release checkpoints, each
   `[major]`).
5. When all three are built and committed, write the return handoff (see below) and **stop** —
   do not proceed to 3c (writing G9/G10) or 3d (closeout).

## References

- `Roadmap.md` — current spec statuses.
- `specs/akios-backlog-map.md` §3 (G4/G5/G6), §5 step 8 — build-order rationale.
- `specs/parallel-execution-scheduling.md` — spine-collision reasoning.
- `tasks/handoffs/session-3a-snippet-skeleton-skillauthoring-return.md` — precedent for
  task/checkpoint numbering style and reconciliation-note style.
- `tasks/done/T001-*.md` … `T041-*.md` — prior task files, template for shape/DoD style.
- Hard gate, non-negotiable: **no `git push`, no merge, no `just-vibes`, no auto-push.** Commit
  locally on `alva+ui-strategies` at every checkpoint. Stop short of pushing — the user has
  pushed once themselves already, but that doesn't authorize this session to push; only the user
  pushes, when they choose to.

## Write a return handoff when done

When `operating-modes.md`, `verification-and-learning-loop.md`, and `code-review-doctrine.md` are
all fully built and committed (or if you have to stop early), write
`tasks/handoffs/session-3b-operating-verification-review-return.md` using the "Handoff Return"
format from `skills/handoff/SKILL.md`: what was done, artifacts produced (commit range, task
files, Roadmap rows flipped), what's still open, and the recommended next step (Session 3c: write
+ build G9 `collaboration-autonomy.md` and G10 `init-reliability-and-ux.md`).
