# Handoff — footprint-consolidation-plan

> Session: 2026-07-02 (late), continuing on 2026-07-03
> Phase: plan
> Spec: specs/akios-footprint-consolidation.md
> Task: none yet — tasks/todo/ has not been written

## Context in one paragraph

This is an `/akios:plan` pass (no argument given, so the target spec was inferred) running the
`spec-to-tasks` skill against `specs/akios-footprint-consolidation.md` — status `designed` in
`Roadmap.md`, reopens backlog item B35, supersedes `init-reliability-and-ux.md` §5. The spec
consolidates akios's footprint in a consumer repo: akios-owned housekeeping files move under a
new `akios/` folder; external-tool-contract files (`CLAUDE.md`, `AGENTS.md`) and user app source
stay at repo root; `.akios/` (runtime journal) renames to `akios/.local/`. The session found a
genuine scope gap the spec text doesn't resolve — whether **this repo itself** (akios, which
dogfoods its own conventions) should also physically migrate its own root
(`Context.md`/`Roadmap.md`/`Vision.md`/`workflow.yml`/`specs/`/`tasks/`) into `akios/` — and
asked the user via `AskUserQuestion`. **User answered: yes, migrate this repo too.** A 16-task,
6-checkpoint backlog (T058–T073) was drafted and shown to the user as `spec-to-tasks`'s single
mandated confirm step. The user has not yet said "go" — they instead ran `/context` twice, asked
for a status summary, and asked for a list of risky changes/conflicts (all answered in-session,
no scope changes resulted). **Zero files have been written or edited this session.** Everything
so far is read-only research + one confirmed decision + the proposed table.

## Where we are

- Last action: answered the user's "list risky changes and conflicts" question in plain text.
  User has not yet responded to the T058–T073 table itself.
- Next action: get the user's go/adjust on the table below (re-paste it if the user's reply
  doesn't obviously reference it), **renumber checkpoints from relative 1–6 to the real global
  values (see "Checkpoint numbering" below) before writing anything**, then write the 16 task
  files into `tasks/todo/` per `templates/task.md`'s format, set
  `specs/akios-footprint-consolidation.md`'s status to `planned` in `Roadmap.md`, and hand off
  per `spec-to-tasks`'s instruction ("tell the user the backlog is ready, `/akios:deliver` ships
  it").
- Checkpoint: N/A — still in `plan`, not `deliver`. No task has started execution.

## The proposed backlog (not yet confirmed, not yet written)

**Spec:** `specs/akios-footprint-consolidation.md`

| # | Task | Area | Files | est_tokens | runner | [P]? |
|---|---|---|---|---|---|---|
| T058 | `workflow.yml` — `bootstrap.creates` + phase `prereqs`/`outputs` get `akios/` prefix | workflow-contract | 1 | 4k | orchestrator | ✅ |
| T059 | `templates/AGENTS.md` — artifact-map table path rewrite + low-priority `~/.claude/akios/` vs repo-local `akios/` disambiguation note | templates/AGENTS | 1 | 10k | orchestrator | ✅ |
| T060 | Other 7 templates (`CLAUDE.md`,`Context.md`,`Roadmap.md`,`Vision.md`,`spec.md`,`task.md`,`rules/swift.md`) path rewrite | templates/other | 7 | 6k | orchestrator | ✅ |
| **CP1** | barrier — audit T058–T060 | | | | | |
| T061 | `commands/setup.md` §3 materialize table + folder tree + footprint prose → new `akios/` tree | commands/setup | 1 | 12k | orchestrator | ❌ |
| T062 | `commands/setup.md` §0 — D8 migrate-path sequence (ask→move→verify→repoint) + §13's name-collision detection design (spec explicitly leaves this **undesigned** — T062's executor must design it, not just rewrite paths) | commands/setup | 1 | 16k | subagent-eligible | ❌ (serializes after T061, same file) |
| T063 | Other 9 `commands/*.md` sweep | commands/other | 9 | 6k | orchestrator | ✅ |
| **CP2** | barrier — audit T061–T063 | | | | | |
| T064 | Skills: `idea-to-spec` + `spec-to-tasks` | skills/planning | 3 | 9k | orchestrator | ✅ |
| T065 | Skill: `task-execution` | skills/task-execution | 1 | 9k | orchestrator | ✅ |
| T066 | Skills: `just-vibes` + `deep-brainstorm` | skills/orchestration | 2 | 12k | orchestrator | ✅ |
| T067 | Skills: `align-ui` + `ui-variations` | skills/design | 2 | 7k | orchestrator | ✅ |
| T068 | Skills: `knowledge-ingest` + `skill-author` + `handoff` | skills/meta | 3 | 8k | orchestrator | ✅ |
| T069 | Skills: `swift-dev` + review-doctrine guide + `ios-feature-pipeline` + `ios-agentic-kit` + sandbox ref | skills/ios-kit | 5 | 13k | orchestrator | ✅ |
| **CP3** | barrier — audit T064–T069 | | | | | |
| T070 | `scripts/*.sh` (7 files) path rewrite | scripts | 7 | 8k | orchestrator | ❌ |
| **CP4** | barrier | | | | | |
| T071 | Root docs: `README.md`, `START-HERE.md`, `docs/architecture/plugin-architecture.md` | root-docs | 3 | 6k | orchestrator | ❌ |
| **CP5** | barrier | | | | | |
| T072 **[major]** | Self-migrate this repo's own root (`Context.md`,`Roadmap.md`,`Vision.md`,`workflow.yml`,`specs/`,`tasks/` → `akios/`; `.gitignore`'s `.akios/`→`akios/.local/`) + smoke-verify. **This repo has no root `CLAUDE.md` and no existing `.akios/` dir** — skip those two D8 sub-steps as no-ops for this repo specifically; only add the `akios/.local/` line to `.gitignore`. | repo-root-migration | ~6 | 14k | subagent-eligible | ❌ |
| **CP6 [major]** | barrier — audit T072, verify no old-path survivors outside historical `tasks/done/**` | | | | | |
| T073 **[major]** | Release checkpoint (= checkpoint 7 overall): full orphan-reference grep audit, VERSION bump, CHANGELOG entry | release | n/a | 5k | orchestrator | ❌ |

Stated to the user: 7 checkpoints total, 16 tasks, 3 parallel clusters (CP1, CP2, CP3 each have
`[P]` tasks); deliberately excludes `tasks/done/**` (67 files) and existing `specs/*.md` prose
(17 files) as historical, non-live-instruction records — a judgment call, not spec-mandated (see
Risks below); `CHANGELOG.md` past entries never rewritten, only a new entry added at T073; UI
states N/A for all 16 tasks (docs/plugin repo, no screens).

## Decisions made this session (not yet in artifacts)

- **Self-migrate this repo too.** User confirmed via `AskUserQuestion` after I flagged it as a
  genuine spec-scope gap (spec text only covers consumer repos + templates, not akios's own
  dogfooded root). Drives T072.
- **Checkpoint numbering is a GLOBAL incrementing counter, not per-plan-pass relative.**
  Confirmed by grepping `tasks/*/*.md` frontmatter: highest existing `checkpoint:` value is
  **35** (two tasks at 34, one at 35 — see `tasks/done/T056-init-footprint-consolidation.md` for
  precedent). The table above uses relative CP1–CP6 labels for readability when presented to the
  user — **before writing task files, renumber to the real global sequence: CP1→36, CP2→37,
  CP3→38, CP4→39, CP5→40, CP6→41, T073(CP7)→42.** This was unresolved in the prior session and
  is now settled — don't re-litigate it, just apply the mapping.
- **Historical files excluded from the rewrite by inference, not spec text**: `tasks/done/**`
  and existing `specs/*.md` prose are treated like `CHANGELOG.md`'s past entries (never
  rewritten). Told to the user in the risks list; not yet explicitly re-confirmed as accepted.
- **Sibling-spec cross-reference convention after the move**: defaulted to root-relative
  (`akios/specs/x.md`) over same-directory-relative (`x.md`) for consistency with everything
  else. Proposed to the user, not yet confirmed — low stakes, apply the default if the user
  doesn't object when confirming the table.
- **D8's generic migrate-path steps have two no-ops for this specific repo**: no root
  `CLAUDE.md` exists here (relies on the user's global `~/.claude/CLAUDE.md`), and no `.akios/`
  runtime journal dir exists yet. T072's DoD should skip those two sub-steps rather than error
  trying to edit/move things that don't exist, but still add the `akios/.local/` gitignore line
  pre-emptively for future runtime journal writes.

## Open questions

- **Primary blocker: has the user said "go" on the table above?** If the most recent user
  message (after this handoff was written) is an unambiguous confirmation, proceed straight to
  writing task files (apply the checkpoint renumbering first). If it requests changes, apply them
  and re-confirm only if the changes are substantial — the skill allows exactly one interactive
  confirm total, already spent showing this table once.
- Is the historical-file exclusion (item above) acceptable, or does the user want full path
  consistency across `tasks/done/**` and old `specs/*.md` prose too (~84 more files)?
- Sibling-spec cross-reference convention — root-relative default, unless the user overrides.

## Risks / tensions

- **T072 (self-migration) is the highest blast-radius task** — moves this repo's own operating
  files while this very tool depends on those paths to function. Sequenced last (CP6, after every
  instruction-text checkpoint already points at the new paths) specifically to minimize the
  window where this repo's own `/akios:plan`/`/akios:deliver` would be internally inconsistent
  with itself.
- **T062 requires new design, not mechanical rewrite** — spec §13 explicitly leaves
  name-collision detection (repo already has an unrelated `akios/` dir) as an open item to design
  during implementation, not skip.
- **T061/T062 same-file serialization** — both write `commands/setup.md`; correctly marked
  non-`[P]`, not a real conflict, just noting so the executor doesn't try to parallelize them.
- **Pre-existing uncommitted drift in the working tree, unrelated to this plan** — confirmed via
  `git status`/`git diff` just before this handoff was written: `Context.md`,
  `skills/just-vibes/SKILL.md`, `skills/knowledge-ingest/SKILL.md`, `skills/swift-dev/SKILL.md`,
  `skills/task-execution/SKILL.md` all have small uncommitted wording/path fixes (e.g.
  `Context.md`'s `tasks.md` retirement note, `task-execution/SKILL.md`'s
  `review-doctrine/GUIDE.md` path fix), two `CODE_OF_CONDUCT.md` files under
  `skills/swift-dev/skills/{swift-concurrency-pro,swift-testing-pro}/` are deleted, and
  `docs/architecture/plugin-architecture.{md,html,mmd}` is untracked. **None of this was created
  by this session** — it predates this plan pass (likely leftover from the prior "rename:
  execute phase → deliver" commit's session). Don't assume a clean tree; don't fold these into
  T058–T073's commits; leave them for the user to handle separately unless they say otherwise.
- No destructive actions have occurred. No file has been created, edited, or moved by this
  session — purely research + one confirmed decision + the unconfirmed table.

## Suggested skills (in order)

1. `spec-to-tasks` (already loaded once this session; reload cold) — resume at its step 10 (one
   interactive confirm), apply the checkpoint renumbering, then write the 16 files.
2. No other skill needed until the table is confirmed and written — this session never reaches
   `task-execution`.

## References

- `specs/akios-footprint-consolidation.md` — the plan target, §1–§13 (D1–D8 decisions, §9 worked
  example, §13 open items including the name-collision flag).
- `Roadmap.md` → `## Specs` table — row to flip to `planned` once task files are written.
- `workflow.yml` — phase contract; `plan` phase: `prereqs: [specs/*.md]`,
  `outputs: [tasks/todo/*.md]`, `roadmap: planned`.
- `templates/task.md` — exact frontmatter/body format for the 16 task files.
- `tasks/done/T056-init-footprint-consolidation.md` — style + checkpoint-numbering precedent for
  the prior (now-superseded) footprint task.
- `commands/setup.md` — primary rewrite target (T061/T062), current renamed form of the old
  `commands/init.md`.
- `templates/AGENTS.md` — artifact-map table, rewrite target T059.
