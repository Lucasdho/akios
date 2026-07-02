---
description: Autonomous run — akios drives the whole pipeline itself (brainstorm→plan→deliver→ship) on the next fuel, stopping at the spec boundary by default.
disable-model-invocation: true
---

# /akios:just-vibes — Autonomous run (workflow.yml: just-vibes run-style)

**Guard (soft).** Confirm the repo is initialized (`AGENTS.md` + `workflow.yml` +
`.claude/.agentic-kit-version`). If not, **don't hard-block** — offer `/akios:setup` first.

**This is the explicit, knowing opt-out of the hard human push/merge gate.** Invoking just-vibes
*is* your authorization to deliver without stopping for per-spec push/merge approval. The **quality
gate stays** (verify + code-review + fix loop); broken work is never delivered.

**Run.** Load the `just-vibes` skill (single source of truth for the loop — don't re-document it).
It will:
- **Pick fuel** by precedence: explicit idea (below) → `tasks/todo/*.md` → `specs/*.md` at status
  `designed` → `Vision.md` / `Roadmap.md` items with no spec. In **team** mode, skip work already
  claimed by another akios instance signature.
- **Claim** the unit (signature claim record; commit + push in team mode), then run only the phases
  needed to reach shippable (unattended **deepthink** brainstorm if there's no spec → plan → deliver).
- **Quality gate:** `/verify` + `/code-review`; green → **deliver** per the `collaboration` flag in
  `Roadmap.md` (solo: merge + push the default branch · team: push `feature/<spec>` + open a PR).
  Red → bounded **fix loop**; still red → **park** (keep the branch + logs), do not deliver.
- **Journal** each cycle to `.akios/just-vibes-journal.md`.

**Default vs `--force`:**
- **`/akios:just-vibes [idea]`** — run **one unit** end-to-end, then **STOP at the spec boundary**
  and report (delivered / parked / PRs). A human can step in between specs.
- **`/akios:just-vibes --force [idea]`** — **loop** over all fuel with **no stop between specs**,
  until sources are exhausted or you interrupt. Reports the same way when it stops.

Arguments (idea and/or `--force`), pass as `$ARGUMENTS`: `$ARGUMENTS`
