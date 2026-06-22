---
description: Start a feature — turn an idea into an approved spec (pipeline Phase 1, idea-to-spec).
disable-model-invocation: true
---

# /akios:brainstorm — Design phase (workflow.yml: brainstorm)

**Guard (soft).** Confirm this repo is initialized: `AGENTS.md` + `workflow.yml` +
`.claude/.agentic-kit-version` present, and the `brainstorm` phase's `prereqs` from
`workflow.yml` (`Context.md`, `Roadmap.md`) exist. If something is missing, **don't hard-block** —
say what's missing and **offer** to run `/akios:init` first.

**Run.** Load the `ios-feature-pipeline` skill for conduct and execute the **`brainstorm`** phase
(`idea-to-spec`) only — `workflow.yml` is the phase contract; don't re-document the phases here.
This phase is interactive; the user must be present. On approval, set the spec's status to
`designed` in `Roadmap.md`.

**Stay in flow.** Design only — write no app code or data files here, even on a direct "just build
X" mid-session. If a build/data need surfaces, apply the pipeline's *anti-drift* reflex: name it,
decide whether it's this spec or its own, register a new spec in `Roadmap.md` if distinct, and
route it through the full pipeline — don't execute it inline.

Feature idea (pass as the spec input): `$ARGUMENTS`

**If the idea is really several specs**, run `idea-to-spec`'s *Intake* triage first: split them,
ask the user one/some/all, then design the chosen specs **sequentially** — one spec's questions at
a time, each labeled and registered in `Roadmap.md` — never merged into one.

Stop when an approved spec is written to `specs/<feature>.md`. Tell the user the spec path and that
`/akios:plan <spec>` is the next step.
