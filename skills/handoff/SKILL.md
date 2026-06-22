---
name: handoff
description: Compact the current conversation into a handoff document so another agent session can continue the work — or return results to the originating session. Use when pivoting to a different concern mid-session, when context is growing unwieldy, or when a sub-task should run in isolation and report back.
argument-hint: "What will the next session focus on? (e.g. 'debug the sync bug', 'return: fixed the auth issue')"
license: MIT
metadata:
  author: Lucas Oliveira
  version: "1.0.0"
---

# Handoff — Cross-session Context Transfer

Writes a handoff document so a fresh agent session can continue the work, or so a sub-session
can report results back to the originating session. Designed for the bidirectional pattern:

```
Session 1 ──writes──▶ tasks/handoffs/<topic>.md ──▶ Session 2
Session 1 ◀──reads── tasks/handoffs/<topic>-return.md ◀──writes── Session 2
```

**Invocation:** `/akios:handoff [what the next session will focus on]`

If the argument starts with `return:`, treat this as a returning sub-session writing results
back — write `tasks/handoffs/<topic>-return.md` instead, structured as a results report.

## What to include

- **Current position in the pipeline.** Which phase (brainstorm / plan / execute), which spec,
  which task, which checkpoint.
- **Decisions made this session.** Only the ones not already captured in specs, tasks, commits,
  or `MEMORY.md` — reference those by path, don't duplicate content.
- **Open questions.** Anything unresolved that the next session must answer before proceeding.
- **Risks and tensions.** Flags worth carrying forward even if not yet acted on.
- **Suggested skills.** Which akios skills the next session should invoke, and in what order.

## What NOT to include

- Content already in `specs/`, `tasks/`, `archive/Archive.md`, or `MEMORY.md` — reference by
  path instead (`specs/foo.md §3`).
- Code diffs or full file contents — reference by file path + line range.
- Sensitive information (API keys, credentials, PII).
- The current conversation transcript.

## Output format

Write to `tasks/handoffs/<topic>.md` (or `<topic>-return.md` for a returning session).
Create `tasks/handoffs/` if it doesn't exist.

```markdown
# Handoff — <topic>

> Session: <date + approximate time>
> Phase: <brainstorm | plan | execute>
> Spec: <path or "none">
> Task: <path or "none">

## Context in one paragraph
<What was being worked on and why — enough for a cold agent to orient in 30 seconds.>

## Where we are
- Last action: <what just happened>
- Next action: <exactly what the next session should do first>
- Checkpoint: <which barrier is next, if in execute>

## Decisions made this session (not yet in artifacts)
- <decision>: <rationale>

## Open questions
- <question> — <why it matters>

## Risks / tensions
- <risk> — <what it blocks>

## Suggested skills (in order)
1. `/akios:<skill>` — <why>

## References
- <artifact path> — <what it contains relevant to this handoff>
```

## Return handoff format

When a sub-session writes back (`return:` prefix), the document is a results report:

```markdown
# Handoff Return — <topic>

> Originated from: tasks/handoffs/<topic>.md
> Completed: <date>

## What was done
<Summary of work completed — decisions made, files changed, outcomes.>

## Artifacts produced
- <path> — <what it is>

## What's still open
- <anything the originating session needs to decide or act on>

## Recommended next step for Session 1
<One concrete action to resume from where Session 1 left off.>
```
