---
id: T000
spec: akios/specs/{{spec}}.md
est_tokens: {{rough estimate ≈ Σ touched-file sizes + description weight}}
runner: {{orchestrator (≤20k) | subagent-eligible (>20k)}}
parallel: {{true | false}}   # true = [P], shares no files/symbols with siblings in this checkpoint
area: {{Features/<F>/domain|data|presentation/<View>|contract|tests — slice sub-folder; same-area tasks serialize}}
checkpoint: {{n}}            # [major] checkpoints run the test battery
swift_dev: {{sub-skill}}     # domain sub-skill the cold subagent must load
---

# T000 — {{one-line goal}}

> **State:** todo
<!-- State is the containing folder: akios/tasks/todo → in-progress → review → done.
     Moving the file changes state; this line mirrors it for readability. -->

## Description
<!-- What this task changes and why. Reference the spec section it implements. -->

## Files
- `{{path}}`

## Definition of Done
- {{verifiable bullet}}
- {{verifiable bullet}}

## UI states  (UI / data-backed tasks only — else "N/A")
- happy · empty · loading/in-flight · error/offline

## Notes
<!-- swift-dev sub-skills to load by scope; gotchas; priority-chain references. -->
