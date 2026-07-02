# Handoff — Session 3a: snippet-library.md + skeleton-library.md + skill-authoring.md

> Session: 2026-07-01, continuing from Session 2
> Phase: execute
> Spec: specs/snippet-library.md, then specs/skeleton-library.md, then specs/skill-authoring.md
> Task: none open yet — this session creates and runs its own tasks/todo/ backlog

## Context in one paragraph

akios (this repo) is a Claude Code plugin for Swift/iOS work, not a Swift app. The whole backlog
in `specs/akios-backlog-map.md` (37 items) is being built toward a single **v0.8.0** release.
Originally negotiated as 3 code sessions; **Session 3 has now been split further into 3a/3b/3c**
because Session 2 (which built `ui-overhaul-implementation.md` + `knowledge-architecture.md`)
burned ~316k tokens and 203 tool calls for two specs — token estimates for these builds are
consistently bad, so smaller sub-sessions are now the standing practice (see
`MEMORY.md` → `feedback_subagent_dispatch.md` if you have memory access; if not, the rule is:
cold-start every subagent with a handoff file, never fork, and split large batches of work into
more, smaller sessions rather than fewer big ones). **This session (3a) builds three specs**:
`snippet-library.md` → `skeleton-library.md` → `skill-authoring.md`. Session 3b (a separate,
later cold-start session) will build `operating-modes.md` + `verification-and-learning-loop.md`
+ `code-review-doctrine.md` + write-and-build the two unwritten specs (G9
`collaboration-autonomy.md`, G10 `init-reliability-and-ux.md`). Session 3c will do the v0.8.0
closeout (Roadmap all `done`, CHANGELOG consolidation, VERSION + `plugin.json` bump). **Do not
do 3b or 3c's work in this session** — stop after skill-authoring.md is done and write the return
handoff.

## Where we are

- Session 1 (commits `4c910be`..`a4c5c5e` on branch `alva+ui-strategies`) shipped
  `alva-adoption.md` (T001–T011) — ALVA (Agent-Legible Vertical Architecture) is the kit's
  architectural doctrine.
- Session 2 (commits `6c8ee16`..`4df4122`) shipped `ui-overhaul-implementation.md` (T012–T026)
  and `knowledge-architecture.md` (T027–T032). Both are `done` in `Roadmap.md`. Task numbering
  ended at **T032**; checkpoint numbering ended at **19** (`[major]` checkpoints 15 and 19).
- Working tree is otherwise clean on `alva+ui-strategies`, nothing pushed, nothing merged.
- Next action: build `specs/snippet-library.md` in full, then `specs/skeleton-library.md`, then
  `specs/skill-authoring.md`, using the kit's own pipeline exactly as Sessions 1–2 did.
- **Continue task numbering from T033. Continue checkpoint numbering from 20.**
- Checkpoint: none in flight. Start fresh at "read the spec" for `snippet-library.md`.

## Decisions made this session (not yet in artifacts)

- **Build order is fixed: `snippet-library.md` → `skeleton-library.md` → `skill-authoring.md`**,
  per `akios-backlog-map.md`'s own recommended build order (G7 before G8 before G3). Reason:
  `snippet-library.md` depends on `knowledge-architecture.md`'s pack format (already shipped in
  Session 2) — build it first while that context is freshest. `skeleton-library.md` is
  independent of `snippet-library.md` (the spec says either order is fine) but sequenced second
  here for continuity. `skill-authoring.md` is independent of both but is sequenced last per the
  backlog map's own step ordering.
- **All three specs are explicitly mechanism-only builds — no content curation.**
  `snippet-library.md` §10 and `skeleton-library.md` §9 both say curating actual snippet/skeleton
  *content* is deferred, manual, future work the user does incrementally. Build the mechanism
  (pack extension, ingestion mode, `init.md` selection flow, `skill-author` skill) — do not
  populate `~/.claude/akios/knowledge/ios-factory/` or `~/.claude/akios/skeletons/` with real
  content.
- **`skill-authoring.md` §1 describes a version-bump step as part of the *tool it builds*** (when
  a future `/akios:new-skill` run creates a new skill, that tool bumps VERSION/CHANGELOG/
  plugin.json as part of its own registration automation). **This is not the same thing as this
  build session's own version bump** — per the standing `feedback_plugin_version_bump` rule and
  the approved plan, **this session does not bump VERSION/CHANGELOG/plugin.json for its own
  work**; that's reserved for Session 3c's closeout. Build `skill-author`'s bump-automation logic
  as spec'd (§1), just don't invoke it on this session's own commits.
- Per repo convention, use the same checkpoint/task-file conventions Sessions 1–2 established
  (`templates/task.md` shape, one commit per checkpoint, `[major]` on each spec's release
  checkpoint, move files `tasks/todo/ → tasks/in-progress/ → tasks/done/`).

## Open questions

- None blocking. If something in any of the three specs is genuinely ambiguous, resolve it the
  way `spec-to-tasks` prescribes: ask **one direct question**, no clarify ceremony — don't invent
  an answer silently if it changes a locked design decision.

## Risks / tensions

- **A stray, uncommitted `.gitignore` edit exists in the working tree** (adds a `/tasks` line).
  It was made by a concurrent process during Session 2, is **not** intentional — this repo
  deliberately tracks `tasks/` (see the comment block directly above that line in `.gitignore`,
  and `Roadmap.md`'s "Project type" note: it dogfoods its own kit). **Do not commit this edit.**
  If it silently causes `git add` to skip new task files (it did once during Session 2, fixed
  with a follow-up `git add -f` commit), catch it the same way — force-add the task files, leave
  `.gitignore` itself uncommitted/untouched. The user may revert it themselves; that's their call,
  not this session's.
- **`skeleton-library.md`'s build touches `commands/init.md`**, which Session 1 already edited
  heavily for the ALVA scaffold (T009+T010, commit `b53a03d`). Read the current state of
  `commands/init.md` before editing — layer the skeleton-selection step (§3–§5 of
  `skeleton-library.md`) on top of what's there, don't overwrite or duplicate the ALVA scaffold
  logic.
- **All three specs touch `scripts/install-skills.sh`** (a spine file per
  `specs/parallel-execution-scheduling.md`) — `snippet-library.md` via `/akios:learn --kind
  snippet` (already-registered command, just a new flag — check if it needs a new entry at all),
  `skill-authoring.md` definitely (new `skill-author` skill + `/akios:new-skill` command need
  registering). This is fine *within* this single session (one agent, sequential edits) but is
  exactly why this sub-session should not run concurrently with Session 3b in the same working
  directory or an unmerged worktree — both would race on that file. Session 3b should only start
  after this session's commits land.
- `snippet-library.md`'s copy-and-adapt-and-prune step and `skill-authoring.md`'s registration
  automation both plausibly touch `skills/task-execution/SKILL.md` and/or
  `skills/spec-to-tasks/SKILL.md` (also spine files) — same reasoning, keep this session's edits
  sequential internally, and don't let 3b start concurrently.

## Suggested skills (in order)

1. Read `specs/snippet-library.md`, `specs/skeleton-library.md`, `specs/skill-authoring.md` in
   full (this handoff summarizes them, but re-read for exact wording before decomposing into
   tasks).
2. `spec-to-tasks` mechanics (`skills/spec-to-tasks/SKILL.md`) — apply its steps by hand (as
   Sessions 1–2 did) to decompose each spec, in the fixed order above, into
   `tasks/todo/T0NN-*.md` files. Continue numbering from **T033**, checkpoints from **20**.
3. `task-execution` mechanics (`skills/task-execution/SKILL.md`) — implement each task, commit at
   every checkpoint, move task files `tasks/todo/ → tasks/in-progress/ → tasks/done/`. DoD
   verified by inspection + grep per `Roadmap.md`'s "Project type" note (plugin/docs repo, no
   Swift build/test).
4. Flip each spec's `Roadmap.md` row to `done` as it completes (three separate release
   checkpoints, one per spec, each `[major]`).
5. When all three specs are fully built and committed, write the return handoff (see below) and
   **stop** — do not proceed to Session 3b's items (`operating-modes.md`,
   `verification-and-learning-loop.md`, `code-review-doctrine.md`, G9 `collaboration-autonomy.md`,
   G10 `init-reliability-and-ux.md`) or Session 3c's closeout. Those are explicitly out of scope
   for this session.

## References

- `/Users/lucasoliveira/.claude/plans/claude-agora-a-tranquil-mountain.md` — the original 3-session
  plan (Session 3 in there is now split into 3a/3b/3c per this handoff; the plan file itself is
  not being rewritten, treat this handoff as the authoritative scope for 3a).
- `Roadmap.md` — current spec statuses.
- `specs/akios-backlog-map.md` — G7 (`snippet-library.md`), G8 (`skeleton-library.md`), G3
  (`skill-authoring.md`), and §5's recommended build order.
- `specs/parallel-execution-scheduling.md` — the spine-collision reasoning behind why this
  sub-session must fully land before Session 3b starts.
- `tasks/handoffs/session-2-ui-overhaul-knowledge-return.md` — Session 2's return handoff; useful
  precedent for task/checkpoint numbering style, reconciliation-note style, and how to document
  "already satisfied by an earlier session" findings without relitigating them.
- `tasks/done/T001-*.md` … `T032-*.md` — prior task files, template for shape and DoD-writing
  style.
- Hard gate, non-negotiable, carried over from Sessions 1–2: **no `git push`, no merge, no
  `just-vibes`, no auto-push**, even though `Roadmap.md` says `collaboration: solo`. Commit
  locally on `alva+ui-strategies` at every checkpoint. Stop short of pushing.

## Write a return handoff when done

When `snippet-library.md`, `skeleton-library.md`, and `skill-authoring.md` are all fully built
and committed (or if you have to stop early), write
`tasks/handoffs/session-3a-snippet-skeleton-skillauthoring-return.md` using the "Handoff Return"
format from `skills/handoff/SKILL.md`: what was done, artifacts produced (commit range, task
files, Roadmap rows flipped), what's still open, and the recommended next step (Session 3b).
