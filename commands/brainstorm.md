---
description: Start a feature — turn an idea into an approved spec (pipeline Phase 1, idea-to-spec).
disable-model-invocation: true
---

# /akios:brainstorm — Design phase (akios/workflow.yml: brainstorm)

**Guard (soft).** Confirm this repo is initialized: `AGENTS.md` + `akios/workflow.yml` +
`.claude/.agentic-kit-version` present, and the `brainstorm` phase's `prereqs` from
`akios/workflow.yml` (`akios/Context.md`, `akios/Roadmap.md`) exist. If something is missing, **don't hard-block** —
say what's missing and **offer** to run `/akios:setup` first.

**Run.** Load the `ios-feature-pipeline` skill for conduct and execute the **`brainstorm`** phase
(`idea-to-spec`) only — `akios/workflow.yml` is the phase contract; don't re-document the phases here.
This phase is interactive; the user must be present. On approval, set the spec's status to
`designed` in `akios/Roadmap.md`.

**Stay in flow.** Design only — write no app code or data files here, even on a direct "just build
X" mid-session. If a build/data need surfaces, apply the pipeline's *anti-drift* reflex: name it,
decide whether it's this spec or its own, register a new spec in `akios/Roadmap.md` if distinct, and
route it through the full pipeline — don't execute it inline.

**Posture override (optional).** A `--learning` or `--delivery` flag in `$ARGUMENTS` overrides
`akios/Roadmap.md`'s `posture` for this session only (doesn't rewrite the Roadmap value); absent, use
the Roadmap default. See `idea-to-spec`'s "Posture (learning vs. delivery)".

Feature idea (pass as the spec input): `$ARGUMENTS`

**If the idea is really several specs**, run `idea-to-spec`'s *Intake* triage first: split them,
ask the user one/some/all, then design the chosen specs **sequentially** — one spec's questions at
a time, each labeled and registered in `akios/Roadmap.md` — never merged into one.

Stop when an approved spec is written to `akios/specs/<feature>.md`. Tell the user the spec path and that
`/akios:plan <spec>` is the next step.
