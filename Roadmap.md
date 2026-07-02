# Roadmap

> Spec-level state for the akios plugin repo. One line per spec. The agent reads this to know
> what already exists and which phase each spec is in (see `workflow.yml`).
> **Single source of truth** — do not duplicate the `## Specs` table elsewhere.

## Mode

mode: feature

## Collaboration

collaboration: solo

## Posture

<!-- learning | delivery (default: delivery); see AGENTS.md "Operating posture" / specs/operating-modes.md -->
posture: delivery

## Autonomy

<!-- manual | auto (default: manual); see AGENTS.md "Delivery autonomy" / specs/collaboration-autonomy.md
     Independent of `collaboration` above — not inferred from it. This repo has run `collaboration: solo`
     the whole v0.8.0 arc; every session has built + committed locally and deliberately never pushed
     (solo + manual in this flag's terms) — autonomy: manual makes that the formal default instead of a
     discipline each session re-derives by hand. -->
autonomy: manual

## Project type

<!-- IMPORTANT for just-vibes and task-execution: this is a PLUGIN/DOCS REPO, not an iOS app.
     - No Swift source files, no Xcode project, no xcodebuild.
     - Artifacts are: .md, .yml, .sh, .json files (skills, commands, templates, scripts).
     - "Tests" = DoD audits (grep for orphaned refs, YAML validation, skill install smoke-test).
     - TDD posture: verify each task's DoD by inspection and grep — not by running a test suite.
     - Branches: feature/<spec> per spec, same as for iOS projects.
     - align-ui gate: N/A (no SwiftUI screens). Skip it for all tasks here. -->

type: plugin-docs

## Specs

<!-- status: designed → planned → in-progress → done
     Two extra demotion side-states exist outside the forward chain: `needs-revision`
     (R-W-W audit flagged the spec weak — revise back to `designed`) and `blocked`
     (fix loop gave up — needs human intervention before resuming).
     Full monotonic order for merge-conflict resolution (higher status wins, a done spec is
     never demoted): needs-revision < designed < planned < in-progress < blocked < done.
     Multi-instance: edit ONLY your spec's line, never reorder. -->

| Spec | Domain | Status | Notes |
|---|---|---|---|
| pipeline.md | Core pipeline contract (workflow.yml + phases) | done | shipped in v0.7.0 refactor |
| plugin-architecture.md | Plugin structure, skill routing, install | done | shipped in v0.7.0 refactor |
| preferences-and-priority.md | Priority chain + preferences.seed.md | done | shipped in v0.7.0 refactor |
| deep-brainstorm-rww-audit.md | R-W-W post-burst audit phase + just-vibes fuel filter | done | shipped in v0.7.3; Vision wishlist #1 |
| prototype-first-workflow.md | Prototype-first visual workflow: multi-variant SwiftUI `#Preview` generation + remix, direct-to-code (no HTML/translation); new `design` phase | done | UI overhaul, spec 1 of 3 (C→A→B); v2.0 pivot (2026-07-01) — Figma/Stitch/HTML parked; realized via ui-overhaul-implementation.md's T012/T014/T025 (v0.8.0 session 2); version bump deferred to the v0.8.0 closeout |
| ui-first-architecture.md | UI-first ordering + structure: per-feature folders, layer split, build-order law, dumb-component `init` rule, factory/router DI | designed | UI overhaul, spec 2 of 3 (C→A→B) — §1/§2 folder shape SUPERSEDED (confirmed 2026-07-01) by ALVA §4/§6, see alva-adoption.md D1/D2; §3–§8 behavioral laws survive, re-homed into `presentation/<View>/` |
| swiftui-design-doctrine.md | Visual craft: unified `DesignSystem` token struct, native-over-custom budget, Nielsen heuristics backbone, text/image role ViewModifiers, `containerRelativeFrame` adaptivity | done | UI overhaul, spec 3 of 3 (C→A→B); realized via ui-overhaul-implementation.md's T015/T021-T023 (v0.8.0 session 2); version bump deferred to the v0.8.0 closeout |
| ui-overhaul-implementation.md | Ordered build backlog consolidating the C→A→B family onto ALVA (7 phases: pipeline → Foundation/scaffold → `ui-variations` → reshape skills → doctrine → coordinator → release) | done | UI overhaul, execution plan — v2.0 (2026-07-01), re-homed onto ALVA per alva-adoption.md §7; T012-T026 all shipped (v0.8.0 session 2); version bump deferred to the v0.8.0 closeout |
| akios-backlog-map.md | AKIOS backlog synthesis (index — routes the whole family) | designed | read FIRST; maps every backlog item B1–B29 → covering spec |
| alva-architecture-doctrine.md | Agent-Legible Vertical Architecture — portable doctrine (Part I) + akios impl (Part II) | done | backlog B7–B12; publishable standalone; realized via alva-adoption.md's T001–T011 (v0.8.0 session 1); version bump deferred to the v0.8.0 closeout |
| alva-adoption.md | ALVA adoption + reconciliation with the UI family; ordered build backlog | done | backlog B7–B12,B14,B10; v1.1 — fork resolved 2026-07-01, ALVA confirmed; T001–T011 all shipped (v0.8.0 session 1); version bump deferred to the v0.8.0 closeout |
| knowledge-architecture.md | Meta-prompt/knowledge split + knowledge packs + ingestion (code/PDF/image/book/doc) | done | backlog B4–B6,B12; generalizes code-references + swift-dev-as-a-pack; realized via T027–T031 (v0.8.0 session 2); within-tier pack precedence and ingested-pack audit deliberately left open (§9); version bump deferred to the v0.8.0 closeout |
| snippet-library.md | Factory code snippets seed (extends knowledge-architecture packs with `kind: snippet`, user-global, copy-and-adapt) | done | backlog B30; realized via T033-T034 (v0.8.0 session 3a); skeletons promoted to skeleton-library.md, deliberately not built here; version bump deferred to the v0.8.0 closeout |
| skeleton-library.md | Architecture-keyed project skeletons for `/akios:setup` greenfield path (promoted from snippet-library.md §7) | done | backlog B31; realized via T036 (v0.8.0 session 3a); no ingestion path yet (deliberately open, §11); version bump deferred to the v0.8.0 closeout |
| skill-authoring.md | `skill-author` + `/akios:new-skill` — scaffold skills/packs + self-register | done | backlog B1; realized via T038-T040 (v0.8.0 session 3a); `--from <transcript>` distillation mode deliberately deferred (§7); version bump deferred to the v0.8.0 closeout |
| operating-modes.md | Learning vs delivery posture — 3rd Roadmap flag | done | backlog B3; teaches the *why* as it builds; realized via T042-T043 (v0.8.0 session 3b); version bump deferred to the v0.8.0 closeout |
| verification-and-learning-loop.md | Post-exec divergence audit + three proofs + hurdles ledger | done | backlog B2,B19; realizes Vision wishlist #3 (auto build/test hook); realized via T045-T047 (v0.8.0 session 3b); hurdles.md content + the 2nd-occurrence threshold tuning deliberately left empty/open (§7,§8); version bump deferred to the v0.8.0 closeout |
| code-review-doctrine.md | Principled review: SOLID/DRY/ACID (honest) + ALVA/UI conformance + folder drift | done | backlog B10,B11,B12; DRY defers to ledger, ACID scoped to persistence; realized via T049-T050 (v0.8.0 session 3b); the block/warn line for slice-shape drift deliberately left open to tune after real-repo use (§8); version bump deferred to the v0.8.0 closeout |
| parallel-execution-scheduling.md | Cross-spec parallel/sequential scheduling — generalizes spec-to-tasks' `[P]` collision check to whole specs, so multi-spec batches know which pairs are safe for concurrent agent delegation | designed | backlog B37; self-surfaced during v0.8.0 Session 2; self-referential — not on the critical path, build whenever a future multi-spec batch benefits |
| collaboration-autonomy.md | 4th Roadmap flag — `autonomy: manual/auto`, splits delivery-authorization from headcount | done | backlog B32; realized via T052-T053 (v0.8.0 session 3c); version bump deferred to the v0.8.0 closeout |
| init-reliability-and-ux.md | `/akios:setup` narration, per-action verification, per-file chmod policy, bounded retry, footprint consolidation | done | backlog B33-B35; realized via T055-T056 (v0.8.0 session 3c); durable manifest-file idea deliberately left open (§11); version bump deferred to the v0.8.0 closeout |
