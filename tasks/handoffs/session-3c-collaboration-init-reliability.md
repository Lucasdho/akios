# Handoff — Session 3c: write + build collaboration-autonomy.md (G9) + init-reliability-and-ux.md (G10)

> Session: 2026-07-02, continuing from Session 3b
> Phase: brainstorm/idea-to-spec, then plan/execute
> Spec: two NEW specs to write — `specs/collaboration-autonomy.md`, `specs/init-reliability-and-ux.md`
> Task: none open yet — this session writes two specs, then creates and runs its own tasks/todo/ backlog for both

## Context in one paragraph

akios (this repo) is a Claude Code plugin for Swift/iOS work, not a Swift app. The whole backlog
in `specs/akios-backlog-map.md` (37 items) is being built toward a single **v0.8.0** release.
The original "Session 3" has been split into cold-start sub-sessions (3a, 3b, 3c, 3d) to keep
each one's token cost bounded — Session 2 (building two specs in one pass) burned ~316k tokens;
3a and 3b (three specs each, already-designed) stayed in the ~190-205k range. **This session
(3c) is different from 3a/3b: the two specs it needs don't exist yet.** `akios-backlog-map.md`
§3 registers them as gaps (**G9** and **G10**) with a one-line thesis each, but nobody has
written the actual spec. This session must **write both specs first** (using this repo's own
`idea-to-spec`-style decision-by-decision authoring, the same voice/format every other spec in
`specs/` uses), then **build both** the same way Sessions 1–3b built already-designed specs.
Because a full human is not present overnight, **resolve open design decisions autonomously**,
the same way `skeleton-library.md` did (see its own "Autonomous decision pass" note at the top of
that file) — take the recommended position, record alternatives and why they were rejected, note
consequences, and mark it un-reviewed by a human yet. Do not stall waiting for an answer.

## Where we are

- Sessions 1, 2, 3a, 3b are all `done` in `Roadmap.md` (9 specs total, T001–T051, checkpoints
  1–31). Working tree clean on `alva+ui-strategies`, 15 commits ahead of
  `origin/alva+ui-strategies` (all local-only; the user pushed once themselves earlier in this
  arc — that doesn't authorize this session to push; still no push/merge/`just-vibes` here).
- **Continue task numbering from T052. Continue checkpoint numbering from 32.**
- Only `parallel-execution-scheduling.md` (self-referential, non-blocking, see its own Roadmap
  note) and the two specs this session writes remain not-`done` after this session, ahead of
  Session 3d's closeout.

## What to write — G9: `collaboration-autonomy.md`

**Backlog B32** (raw demand, `akios-backlog-map.md` §1): "just-vibes push/merge automation must
be asked as its own question, separate from `collaboration: solo/team` — a repo can be worked on
by a group while the user is the only one running akios on it."

**G9 one-line thesis** (already registered, `akios-backlog-map.md` §3): "Split 'who else works on
this repo' (`collaboration: solo/team`) from 'should just-vibes auto-push/merge' — two independent
questions, not one flag standing in for both."

**Live precedent from this very build arc** (useful worked-example material): `Roadmap.md` in
this repo has said `collaboration: solo` throughout Sessions 1–3b — which, under today's actual
kit behavior, would let `just-vibes --force` auto-push. Every session in this arc has explicitly
overridden that and kept a manual no-push gate instead, precisely because "I'm the only one
running akios" (`collaboration: solo`) is not the same fact as "it's safe to auto-push to a
shared branch/repo." That lived tension **is** backlog B32, observed in production, not just
theorized. Use it as the worked example if it fits naturally.

**Design surface to cover** (not prescriptive line-by-line — decide the actual mechanism
yourself, autonomously, per the format below):
- What's the new flag/question, and where does it live (`Roadmap.md`, alongside `collaboration`
  and the `posture` flag `operating-modes.md` just added)?
- Does it default conservatively (e.g. "ask, never assume auto-push is safe") or infer from
  `collaboration`? What breaks today if `just-vibes --force` under `collaboration: solo` currently
  auto-pushes/merges without a separate check?
- How does this interact with the existing hard human gate `task-execution` already has before
  any push/merge (every session in this arc has honored a *stronger-than-default* version of that
  gate by hand) — does this spec formalize what's already been happening ad hoc?
- Set at `/akios:init` time (interview question), overridable per-session, same lifecycle pattern
  `operating-modes.md` just established for `posture` — reuse that precedent rather than inventing
  a fourth flag lifecycle from scratch.

## What to write — G10: `init-reliability-and-ux.md`

**Backlog B33, B34, B35** (raw demands):
- B33: "`/akios:init` must narrate what it's doing while it runs, not execute long steps
  silently."
- B34: "`/akios:init`'s file-materialization step must survive tool-call errors (failed `cp`, an
  auto-mode-blocked batched `chmod +x` forcing a fallback to per-file calls that then also error)
  without leaving the agent stuck in an ambiguous 'did it land or not' state."
- B35: "Consolidate every akios-generated file under one folder, and offer the user an option to
  gitignore all of it, so `/akios:init` doesn't pollute the person's repo."

**G10 one-line thesis** (already registered): "`/akios:init` narrates its steps as it runs,
verifies each materialization step actually landed instead of assuming, avoids batched calls that
trip the auto-mode classifier, and keeps its footprint in one gitignore-able folder."

**Live precedent from this very build arc** (useful worked-example material, directly relevant to
B34): earlier in this same v0.8.0 arc, a plain `git checkout -- .gitignore` was denied by the
auto-mode permission classifier mid-session (an "Irreversible Local Destruction" block on
discarding a concurrent, uncommitted edit) — the orchestrating session had to stop, explain, and
leave it for the human rather than silently working around it or getting stuck. That is exactly
the class of failure B34 describes (a tool call an agent expected to succeed gets blocked, and
the agent needs a defined way to surface "did it land or not" rather than assume or stall).
Session 3a separately had to work around a stray `.gitignore` edit silently causing `git add` to
skip new files — another concrete "ambiguous did-it-land-or-not" near-miss. Use these as real,
lived worked examples if they fit.

**Design surface to cover**:
- Narration: what does `/akios:init` print/report as it runs each step (Scan, Materialize,
  Self-check, etc. — read `commands/init.md`'s current step structure first), and at what
  granularity (per-file? per-step?) without becoming noisy.
- Verification: after each materialization action (copy/write/chmod), how does init confirm the
  result landed (e.g. re-stat the file, re-check permissions) instead of assuming success from a
  non-error return, and what does it do on a confirmed miss (retry once? report and stop? fall
  back to a narrower per-file call proactively rather than reactively)?
- Batching: B34 names a specific real failure mode (a batched `chmod +x` tripping the auto-mode
  classifier, forcing fallback to per-file calls that then also fail) — decide whether init should
  avoid broad batched calls proactively (e.g. always chmod per-file) or keep batching with a
  defined fallback-and-verify path. Consider consulting `commands/init.md`'s current
  materialization step for what it does today.
- Footprint consolidation (B35): akios-generated files today are scattered (`.claude/`, `Roadmap.md`,
  `Vision.md`, `AGENTS.md`, `Context.md`, task folders, `.akios/` — check what Session 3b's hook
  work just added to `.gitignore` for `.akios/`). Decide what can realistically consolidate under
  one folder without breaking tool conventions that expect certain files at repo root (e.g.
  `AGENTS.md`/`CLAUDE.md` likely must stay at root for Claude Code itself to find them) — this may
  mean the consolidation is partial (e.g. `.akios/` holds internal state, but root-level convention
  files stay put with a documented reason), and offering a gitignore option specifically for the
  consolidated folder.

## Decisions made this session (not yet in artifacts)

- **Write G9 first, then G10** — no dependency either direction, but G9 is the smaller of the two
  (one flag + one question) and G10 touches more surface (`commands/init.md`'s narration,
  verification, and footprint), so sequencing the smaller one first keeps early momentum.
- **Use the exact spec format and voice already established across this family** — read at least
  two exemplar specs before writing (`operating-modes.md` for a small, single-flag spec close in
  shape to G9; `skeleton-library.md` for the "autonomous decision pass" precedent this session
  must also use, since no human is present overnight). Structure: title + one-paragraph intro +
  `> **State:** designed` + numbered `## N. <Section> (D<n>)` decision sections each with
  "**Decision & reason:**" + a worked example section + an "Empty / edge states" section + a
  "Deliberate exclusions" section + a "Backlog placement" section (updating
  `akios-backlog-map.md`'s G9/G10 rows is not needed — they already exist; just add the
  `Roadmap.md` row) + an "Open / next" section.
- **Mark both specs' autonomous decisions clearly**, mirroring `skeleton-library.md`'s exact
  framing: "at the user's explicit request [substitute: because no human was present overnight],
  the remaining open decisions in this spec were resolved autonomously... the recommended position
  was taken for each, alternatives are recorded with why they were rejected... Nothing here is
  more final than any other `designed` spec; it is simply un-reviewed by a human yet."
- No VERSION/CHANGELOG/plugin.json bump this session — reserved for Session 3d's closeout.

## Open questions

- None blocking — this entire session is licensed to resolve its own open design questions
  autonomously (see above). If something would be genuinely irreversible or high-blast-radius to
  guess wrong (not just a design taste call), note it prominently in the return handoff instead of
  guessing silently — but exhaust the "make the reasonable, recorded, reversible call" path first
  before treating anything as blocking.

## Risks / tensions

- Both new specs will need `Roadmap.md` rows added (a spine file, already touched by every prior
  session in this arc — fine, sequential, just don't collide with anything else running
  concurrently; nothing else should be running against this repo right now).
- G10's build will touch `commands/init.md` — already touched by Session 1 (ALVA scaffold),
  Session 3a (skeleton-selection step), and Session 3b (posture interview question). Read its
  current full state before editing; layer on top, don't overwrite prior sessions' additions.
- G9's build may touch `skills/just-vibes/SKILL.md` — already touched by Session 3b (posture
  journaling, three-proofs GATE). Same reasoning: read current state first.

## Suggested skills (in order)

1. Read `specs/akios-backlog-map.md` §1 (B32-B35) and §3 (G9/G10 one-liners) — already quoted
   above, but re-read in place for full context.
2. Read 2-3 exemplar specs for format/voice: `operating-modes.md`, `skeleton-library.md` (for the
   autonomous-decision-pass framing), and skim one more (`snippet-library.md` or
   `code-review-doctrine.md`) to confirm the section-numbering/decision-ID convention is
   consistent across the family.
3. Write `specs/collaboration-autonomy.md` (G9) in full, in that voice/format, resolving open
   decisions autonomously per above.
4. Write `specs/init-reliability-and-ux.md` (G10) in full, same approach.
5. Commit both new spec files (they're `designed`, not built yet — add `Roadmap.md` rows for both
   with status `designed` in this same commit or the next one).
6. `spec-to-tasks` mechanics — decompose both specs (G9 first, then G10) into
   `tasks/todo/T0NN-*.md`, continuing from **T052**, checkpoints from **32**.
7. `task-execution` mechanics — implement, commit per checkpoint, move task files. DoD by
   inspection + grep (plugin/docs repo).
8. Flip both `Roadmap.md` rows to `done`.
9. Write the return handoff (see below) and **stop** — do not proceed to Session 3d's v0.8.0
   closeout (Roadmap consolidation, CHANGELOG, VERSION + `plugin.json` bump). That is a separate,
   later cold-start session.

## References

- `Roadmap.md` — current spec statuses.
- `specs/akios-backlog-map.md` — full backlog context, §1 (B32-B35), §3 (G9/G10).
- `specs/skeleton-library.md` — read in full for the "autonomous decision pass" precedent (its
  intro paragraph right after the title/state line).
- `specs/operating-modes.md` — read in full for a same-family, similarly-scoped spec (a single new
  flag threaded through the pipeline) to mirror in shape.
- `specs/parallel-execution-scheduling.md` — spine-collision reasoning behind not running this
  session concurrently with anything else touching the same repo.
- `tasks/handoffs/session-3b-operating-verification-review-return.md` — precedent for
  task/checkpoint numbering style and reconciliation-note style.
- `tasks/done/T001-*.md` … `T051-*.md` — prior task files, template for shape/DoD style.
- Hard gate, non-negotiable: **no `git push`, no merge, no `just-vibes`, no auto-push.** Commit
  locally on `alva+ui-strategies` at every checkpoint.

## Write a return handoff when done

When both specs are written, built, committed, and flipped to `done` in `Roadmap.md` (or if you
have to stop early), write
`tasks/handoffs/session-3c-collaboration-init-reliability-return.md` using the "Handoff Return"
format from `skills/handoff/SKILL.md`: what was decided (including every autonomous decision made
and its rejected alternatives — this is the first human read of those calls), artifacts produced
(commit range, task files, Roadmap rows flipped), what's still open, and the recommended next
step (Session 3d: the v0.8.0 closeout).
