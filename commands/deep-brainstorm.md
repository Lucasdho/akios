---
description: Map the entire app — run whole-product discovery and produce a complete family of specs covering every major surface area. The "zoom out first" complement to /akios:brainstorm.
disable-model-invocation: true
---

# /akios:deep-brainstorm — Whole-app mapping (workflow.yml: deep-brainstorm)

**Works without `/akios:setup`.** Never block on missing kit files, and never make
`/akios:setup` a prerequisite. If `akios/` isn't there, create the directories you need as you go;
if `akios/Context.md` is missing, ask only the questions this command actually needs (nothing else),
use the answers now, and offer once — at the end, never as a gate — to run `/akios:setup` so the
answers persist. A repo that has never seen akios gets the full value of this command on the first
try.

Whole-app mapping is in fact the *best* first command in a fresh repo — it produces the product
understanding `/akios:setup` would otherwise have to interview for. Create `akios/specs/` and
`akios/Roadmap.md` as you write, and offer `/akios:setup` at the end to persist the stack answers.

**Run.** Load the `deep-brainstorm` skill and execute the full whole-app mapping session.
The session is interactive; the user must be present for Discover + Cartograph + Scope.
The Spec-burst phase (Phase 4) writes all specs in one pass without interruption.

**If `founderlens-behavior` skill is available** (installed or referenced in MEMORY.md): the
Discover phase may invoke it for the first-diamond run. If a `akios/specs/founderlens-*.md` already
exists, summarize its decisions and offer to skip straight to Cartograph.

App context or focus (optional — narrows the mapping session): `$ARGUMENTS`

**On completion:**
- All identified specs are written to `akios/specs/*.md` (one per domain).
- `akios/Roadmap.md` is updated with every new spec at status `designed` and its priority tier.
- A compact summary is shown: app map dimensions, scope counts, spec list, open questions,
  suggested execution order.

**Next steps after this command:**
- `/akios:just-vibes --force` — build the full backlog autonomously.
- `/akios:plan <spec>` — pick one spec and proceed through plan → deliver interactively.
- `/akios:brainstorm <idea>` — add a new feature spec on top of the map.
