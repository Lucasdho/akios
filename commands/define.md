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

**Stay in flow.** Design only — write no app code or data files here, even if the user gives a
direct "just build X" instruction mid-session. If a build/data need surfaces, apply the pipeline's
*Staying in flow (anti-drift)* reflex: name it, decide whether it's this spec or its own, register
a new spec if distinct, and route it through the full pipeline — don't execute it inline.

Feature idea (pass as the spec input): `$ARGUMENTS`

**If the idea is really several specs**, run `idea-to-spec`'s *Intake* triage first: split them,
ask the user one/some/all, then design the chosen specs **sequentially** — one spec's questions at
a time, each labeled and registered in `## Specs` — never merged into one.

Stop when an approved spec is written to `specs/<feature>.md`. Tell the user the spec
path and that `/akios:plan <spec>` is the next step.
