---
description: Implement and ship from the task backlog (pipeline Phase 3, task-execution + verify + code-review).
disable-model-invocation: true
---

# /akios:deliver — Deliver (workflow.yml: deliver)

**Works without `/akios:setup`.** Never block on missing kit files, and never make
`/akios:setup` a prerequisite. If `akios/` isn't there, create the directories you need as you go;
if `akios/Context.md` is missing, ask only the questions this command actually needs (nothing else),
use the answers now, and offer once — at the end, never as a gate — to run `/akios:setup` so the
answers persist. A repo that has never seen akios gets the full value of this command on the first
try.

This is the one command with a real input requirement: **task files in `akios/tasks/todo/`**. If the
backlog is empty, say so in one line and offer `/akios:plan` — a routing suggestion, not a gate.
If `akios/Context.md` is missing, ask for the **test command** (and the build command, if the project
has a separate one) before the first checkpoint — that single answer is what deliver actually needs
— and offer at the end to persist it via `/akios:setup`.

**Run.** Load the `task-execution` skill (single source of truth — don't re-document the loop) and
run it against the backlog in `akios/tasks/todo/`:

- Branch per spec; move each task file `todo → in-progress → review → done`; consult the priority
  chain before any pattern; write tests first (light bar for presentation code with no meaningful
  unit test); audit every DoD at each checkpoint barrier.
- **Build/test commands come from `akios/Context.md` `## Commands`** — never guess an invocation.
- **Runner routing** from each task: `≤20k → orchestrator` (inline), `>20k → subagent`. Subagents
  are opt-in and start cold — their prompt MUST name the task's `refs:` list and the
  project's test command. If the subagent layer is unavailable, degrade to inline.
- Manage context (warn 110k / urgent `/compact` 135k). **Mandatory `/compact` between every spec** — never start a new spec without compacting first.
- On spec completion, archive (`archive/Archive.md` + move spec) and record durable decisions to `MEMORY.md`.
- `/verify` and `/code-review` before claiming done.
- **Never write to git.** No commits, no `git add`, no push, no merge — not at a checkpoint, not at
  the end, and don't offer to. Only `/akios:just-vibes` commits. Finish by reporting what landed and
  what the proofs said, leaving the diff in the working tree for the user to review and commit.

**Posture override (optional).** A `--learning` or `--delivery` flag in `$ARGUMENTS` overrides
`akios/Roadmap.md`'s `posture` for this session only — it does not rewrite the Roadmap value. Absent a
flag, use the Roadmap default (`delivery` if unset). See `task-execution`'s "Operating posture".

Backlog (pass as `$ARGUMENTS`): `$ARGUMENTS`  (defaults to `akios/tasks/todo/`)
