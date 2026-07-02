---
id: T029
spec: specs/knowledge-architecture.md
est_tokens: 10k
runner: orchestrator
parallel: false
area: pack-manifest
checkpoint: 17
---

# T029 — Pack format + `swift-dev` re-manifested as the `ios` baseline pack

> **State:** done

## Description
Ship the knowledge-pack format (`knowledge-architecture.md` §2) and re-manifest `swift-dev` as
`knowledge/ios/` conceptually — **without moving any guide file**: add a `pack.yml` manifest
inside `skills/swift-dev/` marking it `baseline: true`, and add a lightweight pack-discovery
step to the SessionStart hook so a session notices any `knowledge/*/pack.yml` present in the
repo (or `~/.claude/akios/knowledge/*/pack.yml` for user-global packs).

## Files
- `skills/swift-dev/pack.yml` (new — the compat manifest)
- `skills/swift-dev/SKILL.md` (a short compatibility note: "this skill == the `ios` pack")
- `scripts/hook/agentic-kit-inject.sh` (pack-discovery line)

## Definition of Done
- `skills/swift-dev/pack.yml` exists with `name: ios`, `domain_tags`, `triggers`, `version`,
  `baseline: true` — matching the format `knowledge-architecture.md` §2 defines.
- `swift-dev/SKILL.md` has a short note near the top: "this skill is the shipped `ios` knowledge
  pack (`baseline: true`) — the router and guides are not rewritten, only re-manifested."
- `agentic-kit-inject.sh`'s SessionStart output gains one short line noting any discovered
  `knowledge/*/pack.yml` (repo-local) or `~/.claude/akios/knowledge/*/pack.yml` (user-global) —
  cheap (manifest-only scan), not a full pack load.
- No guide file under `skills/swift-dev/skills/` is moved or renamed.

## UI states
N/A (docs-only repo)

## Notes
Source: `specs/knowledge-architecture.md` §2 (D2 — pack format), §5 (D5 — "swift-dev refactored
into knowledge/ios/ conceptually... re-manifested, not rewritten"). This is the PoC-scale
discovery mechanism, same spirit as the Foundation ledger PoC (T003) — a working, minimal
realization, not a full pack-loader system.
