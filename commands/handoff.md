---
description: Write a handoff document for another agent session to continue the work, or return results to the originating session.
argument-hint: "What the next session will focus on (prefix with 'return:' to write a results report back)"
disable-model-invocation: true
---

# /akios:handoff — Cross-session Handoff

Load the `handoff` skill and write the handoff document to `akios/tasks/handoffs/`.

**Works without `/akios:setup`.** Create `akios/tasks/handoffs/` if it doesn't exist and write
there. A handoff is a summary of *this session*, so it needs no kit state at all.

**Argument:** `$ARGUMENTS`

- No argument → summarize current session state and write `akios/tasks/handoffs/<inferred-topic>.md`
- With topic → tailor the doc to that focus and write `akios/tasks/handoffs/<topic>.md`
- `return: <topic>` → write `akios/tasks/handoffs/<topic>-return.md` as a results report for the originating session
