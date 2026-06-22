---
description: Write a handoff document for another agent session to continue the work, or return results to the originating session.
argument-hint: "What the next session will focus on (prefix with 'return:' to write a results report back)"
---

# /akios:handoff — Cross-session Handoff

Load the `handoff` skill and write the handoff document to `tasks/handoffs/`.

**Argument:** `$ARGUMENTS`

- No argument → summarize current session state and write `tasks/handoffs/<inferred-topic>.md`
- With topic → tailor the doc to that focus and write `tasks/handoffs/<topic>.md`
- `return: <topic>` → write `tasks/handoffs/<topic>-return.md` as a results report for the originating session
