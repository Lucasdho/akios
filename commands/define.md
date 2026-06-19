---
description: Start a feature — turn an idea into an approved spec (pipeline Phase 1, idea-to-spec).
disable-model-invocation: true
---

# /akios:define — Design phase (pipeline Phase 1)

**Guard.** First confirm this repo is initialized: it must have `AGENTS.md` and
`.claude/.agentic-kit-version`. If either is missing, STOP and tell the user:
"This repo isn't set up for akios yet — run `/akios:init` first." Offer to run it.

**Run.** Load the `ios-feature-pipeline` skill (it is the single source of truth for
the phases — do not re-document them here) and execute **Phase 1 — Design
(`idea-to-spec`)** only. This phase is interactive; the user must be present.

Feature idea (pass as the spec input): `$ARGUMENTS`

Stop when an approved spec is written to `specs/<feature>.md`. Tell the user the spec
path and that `/akios:plan <spec>` is the next step.
