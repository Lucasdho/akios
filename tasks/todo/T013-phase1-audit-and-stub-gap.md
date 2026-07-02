---
id: T013
spec: specs/ui-overhaul-implementation.md
est_tokens: 6k
runner: orchestrator
parallel: false
area: init-scaffold-stubs
checkpoint: 9
---

# T013 — Phase 1 audit (largely pre-satisfied by Session 1) + close the stub gap

> **State:** todo

## Description
`ui-overhaul-implementation.md` Phase 1 (1.1–1.4) is largely already satisfied by Session 1's
`alva-adoption.md` build. This task is the audit-only paper trail **plus** the one genuine gap
Session 1 left: 1.4 calls for a `DesignSystem` token enum stub + `TextStyle`/`ImageStyle`
role-modifier stubs in the init scaffold ("Block B, Phase 4 below defines their shape — stub
now, fill in when 4.1 lands"). Session 1's T009 scaffolded `Foundation/Design-tokens/` as an
empty folder but did not add these stub files.

## Cross-reference (audit)
- **1.1** (import doctrine into `AGENTS.md`/`Context.md`) ⇄ T001 (`4c910be`) — satisfied.
- **1.2** (`swift-dev` architecture guide) ⇄ T002 (`01d349a`) — satisfied.
- **1.3** (Foundation ledger PoC) ⇄ T003 (`1f0880a`) — satisfied; ledger built as a plain-grep
  script, not a ripgrep pre-commit hook literally, but the spec's *intent* (a working ledger
  generator wired to pre-commit) is met — reconciled, not a gap.
- **1.4** (`/akios:init` scaffold) ⇄ T009+T010 (`b53a03d`) — tree/ledger/hook satisfied;
  **stub files gap identified above, closed by this task.**

## Files
- `templates/foundation/DesignSystem.swift` (new — minimal placeholder stub)
- `templates/foundation/RoleModifiers.swift` (new — minimal placeholder stub)
- `commands/init.md` (ALVA scaffold section: copy the two stub files into
  `Foundation/Design-tokens/` on init)

## Definition of Done
- The two stub files exist, compile-shaped (valid Swift), and carry a comment pointing to
  `skills/swift-dev/skills/swiftui-design-system/GUIDE.md` for the real shape (to be filled in
  when Phase 4.1 lands later in this same backlog).
- `commands/init.md`'s scaffold section copies both stubs into a consumer repo's
  `Foundation/Design-tokens/` alongside the existing ledger/folder scaffold.
- This task file itself stands as the audit paper trail for 1.1–1.4.

## UI states
N/A (docs-only repo)

## Notes
Phase 4.1 (T021 later in this backlog) fills in the real `DesignSystem`/role-modifier shape —
this stub is intentionally minimal, matching the spec's own "stub now, fill in later" instruction.
