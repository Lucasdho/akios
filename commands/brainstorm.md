---
description: Start a feature — turn an idea into an approved spec (pipeline Phase 1, idea-to-spec).
disable-model-invocation: true
---

# /akios:brainstorm — Brainstorm phase (workflow.yml: brainstorm)

**Works without `/akios:setup`.** Never block on missing kit files, and never make
`/akios:setup` a prerequisite. If `akios/` isn't there, create the directories you need as you go;
if `akios/Context.md` is missing, ask only the questions this command actually needs (nothing else),
use the answers now, and offer once — at the end, never as a gate — to run `/akios:setup` so the
answers persist. A repo that has never seen akios gets the full value of this command on the first
try.

For this command specifically, you need almost nothing: a spec is a design document. Write it to
`akios/specs/<feature>.md` (creating `akios/specs/` if absent) and record its row in
`akios/Roadmap.md` (creating the file from the kit's Roadmap template if absent). Read
`akios/Context.md` if it exists; if it doesn't, ask about the project only where the design genuinely
depends on it, and note the assumption in the spec instead of interrogating the user.

**Run.** Load the `feature-pipeline` skill for conduct and execute the **`brainstorm`** phase
(`idea-to-spec`) only — `workflow.yml` is the phase contract; don't re-document the phases here.
This phase is interactive; the user must be present. On approval, set the spec's status to
`designed` in `akios/Roadmap.md`.

**Stay in flow.** Design only — write no code or data files here, even on a direct "just build
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
