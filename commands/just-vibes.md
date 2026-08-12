---
description: Autonomous run — akios drives the whole pipeline itself (brainstorm→plan→deliver) on the next fuel, stopping at the spec boundary by default.
disable-model-invocation: true
---

# /akios:just-vibes — Autonomous run (workflow.yml: just-vibes run-style)

**Works without `/akios:setup`.** Never block on missing kit files. Create `akios/` and its
subfolders as the run needs them. If no test command is
recorded and you can't infer one confidently from the repo's own config files, degrade the
build/test proof to the DoD audit rather than guessing an invocation or stalling.

**This is the explicit, knowing opt-out of being asked.** Invoking just-vibes *is* your
authorization to let it decide unattended — no clarifying questions, no per-step approval. The
**quality gate stays** (verify + code-review + fix loop); a red unit is parked, never marked done.

**It still writes nothing to git.** No branch, no commit, no push, no merge, no PR — running
unattended is not authorization over your history. The run ends the way every akios run ends:
changed files in your working tree and a report of what changed.

**Run.** Load the `just-vibes` skill (single source of truth for the loop — don't re-document it).
It will:
- **Pick fuel** by precedence: explicit idea (below) → `akios/tasks/todo/*.md` → `akios/specs/*.md`
  at status `designed` → `akios/Vision.md` / `akios/Roadmap.md` items with no spec.
- **Build** — run only the phases the unit needs (unattended **deepthink** brainstorm if there's no
  spec → plan → deliver).
- **Quality gate:** the two proofs — build/test (`akios/Context.md` `Test:`, or the DoD audit where
  there's no runner) + `/code-review`; green → mark the spec `done` in `akios/Roadmap.md`.
  Red → bounded **fix loop**; still red → **park** it (left in place with its logs, marked `blocked`).
- **Journal** each cycle to `akios/.local/just-vibes-journal.md`.

**Default vs `--force`:**
- **`/akios:just-vibes [idea]`** — run **one unit** end-to-end, then **STOP at the spec boundary**
  and report (built / parked). A human can step in between specs.
- **`/akios:just-vibes --force [idea]`** — **loop** over all fuel with **no stop between specs**,
  until sources are exhausted or you interrupt. Reports the same way when it stops.

Arguments (idea and/or `--force`), pass as `$ARGUMENTS`: `$ARGUMENTS`
