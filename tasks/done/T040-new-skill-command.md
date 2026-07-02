---
id: T040
spec: specs/skill-authoring.md
est_tokens: 4k
runner: orchestrator
parallel: false
area: new-skill-command
checkpoint: 24
---

# T040 — `/akios:new-skill` command wrapper

> **State:** done

## Description
Thin command wrapper for `skill-author`, matching the shape of the other maintenance-action
wrappers (`commands/init.md`, `commands/learn.md`): a short soft-guard + skill load + hand-off,
no re-documentation of the skill's own pipeline.

## Files
- `commands/new-skill.md` (new)

## Definition of Done
- `commands/new-skill.md` exists with the house frontmatter shape (`description`,
  `disable-model-invocation: true`).
- Invocation form documented: `/akios:new-skill <name> [--pack]` — `--pack` routes to the
  knowledge-pack scaffold (§2 D2); its absence routes to the behavior-skill scaffold (the
  routing question `skill-author` asks, auto-decided under `just-vibes`).
- States it's a **maintenance action**, not a `workflow.yml` phase (matches §4 D4) — same
  framing as `commands/init.md`/`commands/learn.md`'s own opening lines.
- Loads `skill-author` as the single source of truth for the pipeline (extract → scaffold →
  self-register → smoke-test) — does not restate its steps.
- Stops when the skill/pack exists, is registered in `install-skills.sh`, and (attended) the
  drafted description has passed the trigger check — mirrors `commands/learn.md`'s "stop when...
  confirmed" closing line.

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/skill-authoring.md` §1 ("/akios:new-skill <name>"), §5 (worked examples show both
the plain and `--pack` invocation forms).
