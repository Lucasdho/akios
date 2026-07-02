# Handoff — Session 2: ui-overhaul-implementation.md + knowledge-architecture.md

> Session: 2026-07-01, continuing from Session 1
> Phase: execute
> Spec: specs/ui-overhaul-implementation.md, then specs/knowledge-architecture.md
> Task: none open yet — this session creates and runs its own tasks/todo/ backlog

## Context in one paragraph

akios (this repo) is a Claude Code plugin for Swift/iOS work, not a Swift app. The whole backlog
in `specs/akios-backlog-map.md` (36 items) is being built toward a single **v0.8.0** release
across **3 code sessions** the user negotiated explicitly. Session 1 (already done, committed on
branch `alva+ui-strategies`) shipped G11 (`contract-consistency-reconciliation`, drift fixes) and
the full `alva-adoption.md` build (T001–T011) — ALVA (Agent-Legible Vertical Architecture,
vertical slices under `Features/<F>/{domain,data,presentation,contract,tests}`) is now the
kit's architectural doctrine, imported into `AGENTS.md`, `swift-dev`'s new `alva-architecture`
guide, `spec-to-tasks`, `task-execution`, `idea-to-spec`, `align-ui`, `deep-brainstorm`, and
`/akios:init`'s scaffold. **Session 2 (this one) builds the next two specs onto that foundation.**
The full plan lives at `/Users/lucasoliveira/.claude/plans/claude-agora-a-tranquil-mountain.md` —
read it for the full 3-session breakdown and rationale before starting.

## Where we are

- Last action: Session 1 closed (commit `a4c5c5e`), `Roadmap.md` rows for
  `alva-architecture-doctrine.md` and `alva-adoption.md` are `done`. Working tree clean on
  branch `alva+ui-strategies`, nothing pushed.
- Next action: build `specs/ui-overhaul-implementation.md` in full, then
  `specs/knowledge-architecture.md` in full, using the kit's own pipeline (see "Suggested
  skills" below) exactly as Session 1 did for `alva-adoption.md`.
- Checkpoint: none in flight. Start fresh at "read the spec" for
  `ui-overhaul-implementation.md`.

## Decisions made this session (not yet in artifacts)

- **Phase 1 of `ui-overhaul-implementation.md` (§ "Foundation + slice scaffold") is largely
  already satisfied by Session 1's `alva-adoption.md` build** — do not re-implement it. Verify
  each Phase 1 DoD against what already shipped and mark it done on that basis:
  - 1.1 (import the doctrine into `AGENTS.md`/`Context.md`) ⇄ T001 (`4c910be`)
  - 1.2 (`swift-dev` architecture guide) ⇄ T002 (`01d349a`, `skills/swift-dev/skills/alva-architecture/GUIDE.md`)
  - 1.3 (Foundation ledger PoC) ⇄ T003 (`1f0880a`, `scripts/alva-usage-ledger.sh` — built as a
    plain-grep script, not a ripgrep pre-commit hook as the spec text literally says; the spec's
    *intent* — a working ledger generator wired to pre-commit — is satisfied, treat the
    implementation detail as reconciled, not a gap)
  - 1.4 (`/akios:init` scaffold) ⇄ T009+T010 (`b53a03d`)
  Still write a short Phase-1 task that does nothing but **audit and cross-reference** these DoDs
  against the spec's own wording, so the spec's checklist gets ticked with a paper trail — don't
  silently skip it.
- **Phase 0** (add the `design` phase to `workflow.yml`/`pipeline.md`, between `plan` and
  `execute`) is real, unbuilt work — start actual construction here.
- **`knowledge-architecture.md` §5 lists `skill-authoring.md` (G3, a Session-3 spec) as a
  "DEPENDS ON."** That dependency is soft: `skill-authoring.md` builds a *scaffolding tool* for
  authoring skills, not a prerequisite for hand-authoring one. Hand-author the `knowledge-ingest`
  skill directly in this session (same as every other skill in this repo was hand-authored before
  `skill-authoring.md` existed); a future Session 3 can retrofit it through the scaffolding tool
  if that ever becomes valuable, but nothing here blocks on that.
- Per repo convention (see `feedback_plugin_version_bump` memory), **no version/CHANGELOG/plugin.json
  bump happens in this session** — that's reserved for the final v0.8.0 closeout (Session 3, or a
  Session 4 if 3 doesn't fit everything). `ui-overhaul-implementation.md`'s own Phase 6.4 calls for
  a version bump; **skip that step specifically** and note in the task/commit that it's deferred.

## Open questions

- None blocking. If something in either spec is genuinely ambiguous, resolve it the way
  `spec-to-tasks` prescribes: ask **one direct question**, no clarify ceremony — don't invent an
  answer silently if it changes a locked design decision.

## Risks / tensions

- `ui-overhaul-implementation.md` Phase 2 (`ui-variations` skill) and Phase 3 (reshaping
  `align-ui`, `spec-to-tasks`, `task-execution`, `deep-brainstorm`, `idea-to-spec`) touch files
  Session 1 already edited (`align-ui/SKILL.md`, `spec-to-tasks/SKILL.md`,
  `task-execution/SKILL.md`, `deep-brainstorm/SKILL.md`, `idea-to-spec/references/spec-format.md`).
  **Read the current state of each file before editing** — Session 1's ALVA changes are already
  in there; this session's edits must layer on top, not overwrite or duplicate them.
- `ui-overhaul-implementation.md` Phase 4 (`swiftui-design-system` reference,
  `swiftui-design-principles` retrofit) touches a **vendored guide** (arjitj2, MIT v1.1.1) —
  preserve its rule *values*, only re-home call-site examples to token/role syntax, per the
  spec's own DoD wording.
- Hard gate, non-negotiable, carried over from Session 1: **no `git push`, no merge, no
  `just-vibes`, no auto-push** even though `Roadmap.md` says `collaboration: solo` (which would
  normally let `just-vibes` auto-push). Commit locally on the current branch
  (`alva+ui-strategies`) at every checkpoint, exactly like Session 1's 9 commits. Stop short of
  pushing — that requires the user's explicit confirmation in a later turn, not this session's.

## Suggested skills (in order)

1. Read `specs/ui-overhaul-implementation.md` in full (already done this session, informs this
   handoff) — the next session should re-read it itself rather than trust this summary for exact
   task text.
2. `spec-to-tasks` mechanics (`skills/spec-to-tasks/SKILL.md`) — apply its steps by hand (no need
   to invoke it as a literal slash command in a plugin-docs repo context; Session 1 did the same)
   to decompose `ui-overhaul-implementation.md`'s Phases 0, 1(audit-only), 2, 3, 4, 5, 6 into
   `tasks/todo/T0NN-*.md` files, following the exact frontmatter/DoD shape in
   `templates/task.md` / the SKILL.md's "Task file format" section. Continue the `T0NN` numbering
   from `T012` (T001–T011 are taken by `alva-adoption.md`'s build).
3. `task-execution` mechanics (`skills/task-execution/SKILL.md`) — implement each task, commit at
   every checkpoint (mirroring Session 1's one-commit-per-checkpoint pattern), move task files
   `tasks/todo/ → tasks/in-progress/ → tasks/done/`. DoD verified by inspection + grep per
   `Roadmap.md` "Project type" note (this is a plugin/docs repo — no Swift build/test).
4. Flip `ui-overhaul-implementation.md`'s `Roadmap.md` row to `done` when all 6 phases land.
5. Repeat steps 1–4 for `specs/knowledge-architecture.md` (read it fully first — it's dense, see
   its own §1–§9). Continue `T0NN` numbering from wherever phase-1 build left off.
6. When both specs are fully built and committed, write the return handoff (see below) and stop
   — do not proceed to Session 3's items (`snippet-library.md`, `skeleton-library.md`,
   `skill-authoring.md`, `operating-modes.md`, `verification-and-learning-loop.md`,
   `code-review-doctrine.md`, G9, G10, the v0.8.0 closeout). Those are explicitly out of scope for
   this session per the approved 3-session plan.

## References

- `/Users/lucasoliveira/.claude/plans/claude-agora-a-tranquil-mountain.md` — the full approved
  3-session plan; the source of truth for scope boundaries and the closeout mechanics.
- `Roadmap.md` — current spec statuses; the status-enum comment at the top explains the
  `needs-revision`/`blocked` side-states if anything goes wrong mid-build.
- `specs/alva-adoption.md`, `specs/alva-architecture-doctrine.md` — the ALVA doctrine Session 1
  landed; both specs this session builds re-home onto it.
- `tasks/done/T001-*.md` … `T011-*.md` — Session 1's task files, useful as a template for shape
  and DoD-writing style.
- Commits `4c910be`..`a4c5c5e` on branch `alva+ui-strategies` — Session 1's full diff, for
  exactly which files already carry ALVA-era edits before this session touches them again.
- `MEMORY.md` (auto-memory) — `feedback_plugin_version_bump.md`: always bump
  `.claude-plugin/plugin.json` in the same commit as VERSION + CHANGELOG, before pushing. Not
  relevant to *this* session's work directly (no bump happens here) but must not be violated if
  any commit in this session touches those files by accident.

## Write a return handoff when done

When `ui-overhaul-implementation.md` and `knowledge-architecture.md` are both fully built and
committed (or if you have to stop early — e.g. a genuine open question, or Session 2 running out
of room), write `tasks/handoffs/session-2-ui-overhaul-knowledge-return.md` using the "Handoff
Return" format from `skills/handoff/SKILL.md`: what was done, artifacts produced (commit range,
task files, Roadmap rows flipped), what's still open, and the recommended next step for the
originating session (which will be Session 3 planning, or a resumed Session 2 if you had to stop
early).
