# ALVA integration — `task-execution`

`task-execution` is self-sufficient standalone; this file is its ALVA-architecture bridge. Read it
only when `akios/Context.md` declares `architecture: alva`. Without it, the SKILL.md body already
states the architecture-neutral fallback. Depth lives in `swift-dev`'s `alva-architecture` GUIDE
(`skills/swift-dev/skills/alva-architecture/GUIDE.md`) and `akios/specs/alva-adoption.md` — this
file does not restate the doctrine.

## Foundation ledger (read, never count)
Before creating any new helper, protocol, or shared component, consult **only**
`Foundation/Design-tokens/` and `Foundation/Code-tokens/` — a small, bounded search — never the
whole repo (`swift-dev`'s `alva-architecture` guide, doctrine P6). If nothing there fits, the code
is born inside the current feature; it is not shared preemptively.

- **You read `Foundation/usage-ledger.json`; you never count.** The count is produced by a
  deterministic tool (`.claude/scripts/alva-usage-ledger.sh` or its consumer-repo git-hook installation) —
  investigating usage across features is not something you do by grepping the repo per-run.
- **Each ledger entry becomes a task, not a silent move.** Every `candidates_promote` /
  `candidates_demote` entry in the ledger gets written as a new `akios/tasks/todo/T<NNN>-*.md` (promote:
  move the symbol to its `target` behind a contract if it's a Code-token; demote: return it to its
  sole remaining feature). Promotion is **suggested**, reviewed like any other task — never mutate
  `Foundation/` because the ledger said so without a task and a DoD.
- **Boundary lint runs at the checkpoint barrier.** A feature importing another feature's
  `domain/`/`data/` internals (instead of its `contract/`) fails the barrier audit — fix the import
  or extend the contract before the checkpoint commits. This is the lint realization of doctrine
  P3 (folder-first + lint by default; compiler-enforced local SPM modules only once the app has
  earned it — a recurring violation, or the user asks).
