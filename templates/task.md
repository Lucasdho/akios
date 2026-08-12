---
id: T000
spec: akios/specs/{{spec}}.md
est_tokens: {{rough estimate ≈ Σ touched-file sizes + description weight}}
runner: {{orchestrator (≤20k) | subagent-eligible (>20k)}}
parallel: {{true | false}}   # true = [P], shares no files/symbols with siblings in this checkpoint
area: {{the project's own folder/module for this concern (see akios/Context.md "Module boundaries"); same-area tasks serialize}}
checkpoint: {{n}}            # [major] checkpoints run the project's full test battery
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

## States
<!-- User-facing or data-backed task: happy · empty · loading/in-flight · error/offline.
     Delete this section for a task with no user-facing surface. -->

## Notes
<!-- Gotchas; the in-repo file this task should mirror; priority-chain references. -->
