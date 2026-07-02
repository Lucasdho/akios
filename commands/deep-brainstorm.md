---
description: Map the entire app — run whole-product discovery and produce a complete family of specs covering every major surface area. The "zoom out first" complement to /akios:brainstorm.
disable-model-invocation: true
---

# /akios:deep-brainstorm — Whole-app mapping (workflow.yml: deep-brainstorm)

**Guard (soft).** Confirm this repo is initialized: `AGENTS.md` + `workflow.yml` +
`.claude/.agentic-kit-version` present, and `Context.md` exists. If something is missing,
**don't hard-block** — say what's missing and **offer** to run `/akios:setup` first.

**Run.** Load the `deep-brainstorm` skill and execute the full whole-app mapping session.
The session is interactive; the user must be present for Discover + Cartograph + Scope.
The Spec-burst phase (Phase 4) writes all specs in one pass without interruption.

**If `founderlens-behavior` skill is available** (installed or referenced in MEMORY.md): the
Discover phase may invoke it for the first-diamond run. If a `specs/founderlens-*.md` already
exists, summarize its decisions and offer to skip straight to Cartograph.

App context or focus (optional — narrows the mapping session): `$ARGUMENTS`

**On completion:**
- All identified specs are written to `specs/*.md` (one per domain).
- `Roadmap.md` is updated with every new spec at status `designed` and its priority tier.
- A compact summary is shown: app map dimensions, scope counts, spec list, open questions,
  suggested execution order.

**Next steps after this command:**
- `/akios:just-vibes --force` — build the full backlog autonomously.
- `/akios:plan <spec>` — pick one spec and proceed through plan → deliver interactively.
- `/akios:brainstorm <idea>` — add a new feature spec on top of the map.
