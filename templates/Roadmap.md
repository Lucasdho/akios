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

## Posture
<!-- Written by /akios:init (default: delivery); overridable per session via a command flag
     (--learning / --delivery) or a spoken switch — the override wins for that session only and
     does NOT rewrite this line. Orthogonal to mode/collaboration — any combination is valid.
     learning  → akios narrates the *why* behind decisions as it builds (principle citations,
                 alternatives shown, eager capture proposals, an end-of-unit "what you learned"
                 digest); under just-vibes the digest is written to the journal's Lessons
                 section instead of spoken.
     delivery  → decisions are recorded to the artifact but not narrated live (today's default
                 behavior). See AGENTS.md "Operating posture" for the full teaching-surface. -->
posture: {{learning | delivery}}   # default: delivery

## Autonomy
<!-- Written by /akios:init (default: manual); overridable per run via a command flag
     (--autonomy=auto / --autonomy=manual) or a spoken switch — the override wins for that run
     only and does NOT rewrite this line. Independent of `collaboration` — NOT inferred from it:
     `collaboration` answers "who else works on this repo" (solo/team); `autonomy` answers "is
     just-vibes authorized to auto-push/merge at all." Every mode×collaboration×posture×autonomy
     combination is valid.
     manual → just-vibes never pushes/merges/opens a PR, even under --force; a green unit's
              branch stays local and is reported in the run's "Built (undelivered)" bucket,
              awaiting a human push/merge. Team-mode claim-coordination pushes are unaffected —
              only the delivery action is withheld.
     auto   → just-vibes auto-delivers a green unit per `collaboration` (solo → merge + push the
              default branch; team → push feature/<spec> + open a PR), exactly as documented in
              task-execution's Finish gate's just-vibes exception.
     See specs/collaboration-autonomy.md and AGENTS.md "Delivery autonomy" for the full design. -->
autonomy: {{manual | auto}}   # default: manual

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
