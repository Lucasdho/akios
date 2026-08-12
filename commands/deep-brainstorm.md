---
description: Map an entire subject — run whole-subject discovery and produce a complete family of specs covering every major dimension. The "zoom out first" complement to /akios:brainstorm. Use when the user wants the whole picture mapped before starting, not one feature designed.
---

# /akios:deep-brainstorm — Whole-subject mapping (workflow.yml: deep-brainstorm)

**Works without `/akios:setup`.** Never block on missing kit files, and never make
`/akios:setup` a prerequisite. If `akios/` isn't there, create the directories you need as you go;
if `akios/Context.md` is missing, ask only the questions this command actually needs (nothing else),
use the answers now, and offer once — at the end, never as a gate — to run `/akios:setup` so the
answers persist. A repo that has never seen akios gets the full value of this command on the first
try.

Whole-subject mapping is in fact the *best* first command in a fresh repo — it produces the
understanding `/akios:setup` would otherwise have to interview for. Create `akios/specs/` and
`akios/Roadmap.md` as you write, and offer `/akios:setup` at the end to persist the answers.

**The subject is whatever the user brought.** An app, a game, a novel, a course, a business, a
research question, a decision. Do not assume software and do not translate the subject into a
software project so the dimensions fit — the skill carries lens decks for different kinds of
subject and derives a new one when none fits.

**Run.** Load the `deep-brainstorm` skill and execute the full mapping session.
The session is interactive; the user must be present for Discover + Cartograph + Scope.
The Spec-burst phase (Phase 4) writes all specs in one pass without interruption.

The Discover phase may invoke `founderlens-behavior` for the first-diamond run. If a
`akios/specs/founderlens-*.md` already exists, summarize its decisions and offer to skip straight
to Cartograph.

Subject or focus (optional — narrows the session): `$ARGUMENTS`

**On completion:**
- All identified specs are written to `akios/specs/*.md` (one per domain).
- `akios/Roadmap.md` is updated with every new spec at status `designed` and its priority tier.
- A compact summary is shown: map dimensions, scope counts, spec list, open questions,
  suggested order.

**Next steps after this command:**
- `/akios:just-vibes --force` — work the full backlog autonomously.
- `/akios:plan <spec>` — pick one spec and proceed through plan → deliver interactively.
- `/akios:brainstorm <idea>` — add a new spec on top of the map.
