---
id: T005
spec: specs/alva-adoption.md
est_tokens: 8k
runner: orchestrator
parallel: true
area: task-execution
checkpoint: 4
---

# T005 — `task-execution` reads the ledger + boundary lint audit

> **State:** todo

## Description
Execution **reads** `Foundation/usage-ledger.json` (never counts by hand): before writing any
new helper/protocol, it consults only `Foundation/`, and each `candidates_promote` /
`candidates_demote` entry becomes a task in `tasks/todo/` (never a silent mutation). The
boundary lint (alva-adoption §4 — a slice may only import another slice's `contract/`, never
its internals) runs as part of the checkpoint audit. Implements alva-adoption.md §7.5.

## Files
- `skills/task-execution/SKILL.md`

## Definition of Done
- SKILL.md describes reading `Foundation/usage-ledger.json` at an appropriate point in the
  task lifecycle (before creating a helper) and generating promotion/demotion tasks from its
  entries.
- It explicitly states the agent never counts usage by grepping the whole repo — only
  `Foundation/` itself is consulted directly; the ledger supplies the cross-feature counts.
- The checkpoint-barrier audit (`↳ barrier`) includes the boundary lint: a slice importing
  another slice's `domain/`/`data/` (instead of its `contract/`) fails the audit.

## UI states
N/A (docs-only repo)

## Notes
Parallel with T004 — different files, no shared symbols this checkpoint.
