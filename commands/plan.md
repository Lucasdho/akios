---
description: Turn an approved spec into a lean task backlog (pipeline Phase 2, spec-to-tasks).
disable-model-invocation: true
---

# /akios:plan — Spec-to-tasks (workflow.yml: plan)

**Guard (soft).** Confirm the repo is initialized and the `plan` phase's `prereqs` from
`workflow.yml` exist (`specs/*.md`). If no spec exists, **don't hard-block** — say so and **offer**
to run `/akios:brainstorm` first.

**Run.** Load the `spec-to-tasks` skill (single source of truth — don't re-document the pass) and
run it against the spec: one pass, one human confirm, producing **task files under `tasks/todo/`**
(`T<NNN>-<slug>.md`) with `est_tokens` + `runner`, `[P]` markers by area, checkpoint grouping,
definitions of done, and per-task UI-state coverage. Set the spec's status to `planned` in
`Roadmap.md`. No `.specify/`, no constitution, no speckit.

**Posture override (optional).** A `--learning` or `--delivery` flag in `$ARGUMENTS` overrides
`Roadmap.md`'s `posture` for this session only (doesn't rewrite the Roadmap value); absent, use
the Roadmap default. See `spec-to-tasks`'s "Posture (learning vs. delivery)".

Spec path or text (pass as `$ARGUMENTS`): `$ARGUMENTS`

Stop when the task files exist in `tasks/todo/`. Tell the user the backlog is ready and that
`/akios:deliver` ships it.
