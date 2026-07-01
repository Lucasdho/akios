# Roadmap

> Spec-level state for this repo. One line per spec. The agent reads this to know
> what already exists and which phase each spec is in (see `workflow.yml`).
> Phase detection is per-spec: different specs can sit in different phases.
> **Single source of truth** — do not duplicate the `## Specs` table elsewhere (e.g. CLAUDE.md).

## Mode
<!-- Written by /akios:init. One of: new | one-shot | feature.
     `brainstorm` reads this instead of re-asking. -->
mode: {{new | one-shot | feature}}

## Collaboration
<!-- Written by /akios:init. One of: solo | team.
     solo → just-vibes merges + pushes the default branch; no claim etiquette.
     team → just-vibes pushes feature/<spec> + opens a PR; claim-before-work + Akios-Instance
            signatures are in force (see AGENTS.md "Working alongside teammates"). -->
collaboration: {{solo | team}}

## Specs
<!-- status: designed → planned → in-progress → done
     (matches the `roadmap:` field of each phase in workflow.yml)
     Two extra demotion side-states exist outside the forward chain: `needs-revision`
     (deep-brainstorm's R-W-W audit flagged the spec weak — revise back to `designed`) and
     `blocked` (task-execution's fix loop gave up — needs human intervention before resuming).
     Full monotonic order for merge-conflict resolution (higher status wins, a done spec is
     never demoted): needs-revision < designed < planned < in-progress < blocked < done.
     Multi-instance: edit ONLY your spec's line, never reorder. In team mode an `owner:`
     annotation on a line is a claim; don't take a line owned by another Akios-Instance signature. -->

| Spec | Domain | Status | Owner (team) |
|---|---|---|---|
| (none yet) | | | |

<!-- Empty state: a freshly init-ed repo has only the mode line and this empty
     table — the valid "nothing designed yet" state. A bare /akios:brainstorm is offered. -->
