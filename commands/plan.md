---
description: Turn an approved spec into a lean task backlog (pipeline Phase 2, spec-to-tasks).
disable-model-invocation: true
---

# /akios:plan — Spec-to-tasks (workflow.yml: plan)

**Works without `/akios:setup`.** Never block on missing kit files, and never make
`/akios:setup` a prerequisite. If `akios/` isn't there, create the directories you need as you go;
if `akios/Context.md` is missing, ask only the questions this command actually needs (nothing else),
use the answers now, and offer once — at the end, never as a gate — to run `/akios:setup` so the
answers persist. A repo that has never seen akios gets the full value of this command on the first
try.

**No spec?** Don't stop. If `$ARGUMENTS` carries enough of a description to plan against, plan
against it and save it as `akios/specs/<slug>.md` so the backlog has something to point at. If it
doesn't, say what's missing in one line and offer `/akios:brainstorm` — that's a routing suggestion,
not a gate.

**Run.** Load the `spec-to-tasks` skill (single source of truth — don't re-document the pass) and
run it against the spec: one pass, one human confirm, producing **task files under `akios/tasks/todo/`**
(`T<NNN>-<slug>.md`) with `est_tokens` + `runner`, `[P]` markers by area, checkpoint grouping,
definitions of done, and per-task UI-state coverage. Set the spec's status to `planned` in
`akios/Roadmap.md`. No scaffold directory and no second spec format.

**Posture override (optional).** A `--learning` or `--delivery` flag in `$ARGUMENTS` overrides
`akios/Roadmap.md`'s `posture` for this session only (doesn't rewrite the Roadmap value); absent, use
the Roadmap default. See `spec-to-tasks`'s "Posture (learning vs. delivery)".

Spec path or text (pass as `$ARGUMENTS`): `$ARGUMENTS`

Stop when the task files exist in `akios/tasks/todo/`. Tell the user the backlog is ready and that
`/akios:deliver` ships it.
