# Roadmap

> Spec-level state for the akios plugin repo. One line per spec. The agent reads this to know
> what already exists and which phase each spec is in (see `workflow.yml`).
> **Single source of truth** — do not duplicate the `## Specs` table elsewhere.

## Mode

mode: feature

## Collaboration

collaboration: solo

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
| prototype-first-workflow.md | Prototype-first visual workflow: multi-variant SwiftUI `#Preview` generation + remix, direct-to-code (no HTML/translation); new `design` phase | designed | UI overhaul, spec 1 of 3 (C→A→B); v2.0 pivot (2026-07-01) — Figma/Stitch/HTML parked, `ui-variations` is the only active skill |
| ui-first-architecture.md | UI-first ordering + structure: per-feature folders, layer split, build-order law, dumb-component `init` rule, factory/router DI | designed | UI overhaul, spec 2 of 3 (C→A→B) — §1/§2 folder shape SUPERSEDED (confirmed 2026-07-01) by ALVA §4/§6, see alva-adoption.md D1/D2; §3–§8 behavioral laws survive, re-homed into `presentation/<View>/` |
| swiftui-design-doctrine.md | Visual craft: unified `DesignSystem` token struct, native-over-custom budget, Nielsen heuristics backbone, text/image role ViewModifiers, `containerRelativeFrame` adaptivity | designed | UI overhaul, spec 3 of 3 (C→A→B) |
| ui-overhaul-implementation.md | Ordered build backlog consolidating the C→A→B family onto ALVA (7 phases: pipeline → Foundation/scaffold → `ui-variations` → reshape skills → doctrine → coordinator → release) | planned | UI overhaul, execution plan — v2.0 (2026-07-01), re-homed onto ALVA per alva-adoption.md §7; consolidates that spec's own backlog into one file |
| akios-backlog-map.md | AKIOS backlog synthesis (index — routes the whole family) | designed | read FIRST; maps every backlog item B1–B29 → covering spec |
| alva-architecture-doctrine.md | Agent-Legible Vertical Architecture — portable doctrine (Part I) + akios impl (Part II) | done | backlog B7–B12; publishable standalone; realized via alva-adoption.md's T001–T011 (v0.8.0 session 1); version bump deferred to the v0.8.0 closeout |
| alva-adoption.md | ALVA adoption + reconciliation with the UI family; ordered build backlog | done | backlog B7–B12,B14,B10; v1.1 — fork resolved 2026-07-01, ALVA confirmed; T001–T011 all shipped (v0.8.0 session 1); version bump deferred to the v0.8.0 closeout |
| knowledge-architecture.md | Meta-prompt/knowledge split + knowledge packs + ingestion (code/PDF/image/book/doc) | designed | backlog B4–B6,B12; generalizes code-references + swift-dev-as-a-pack |
| snippet-library.md | Factory code snippets seed (extends knowledge-architecture packs with `kind: snippet`, user-global, copy-and-adapt) | designed | backlog B30; depends on knowledge-architecture.md; skeletons promoted to skeleton-library.md |
| skeleton-library.md | Architecture-keyed project skeletons for `/akios:init` greenfield path (promoted from snippet-library.md §7) | designed | backlog B31; sibling to snippet-library.md, no shared build dependency between the two |
| skill-authoring.md | `skill-author` + `/akios:new-skill` — scaffold skills/packs + self-register | designed | backlog B1; fixes the install-skills.sh gotcha structurally |
| operating-modes.md | Learning vs delivery posture — 3rd Roadmap flag | designed | backlog B3; teaches the *why* as it builds |
| verification-and-learning-loop.md | Post-exec divergence audit + three proofs + hurdles ledger | designed | backlog B2,B19; realizes Vision wishlist #3 (auto build/test hook) |
| code-review-doctrine.md | Principled review: SOLID/DRY/ACID (honest) + ALVA/UI conformance + folder drift | designed | backlog B10,B11,B12; DRY defers to ledger, ACID scoped to persistence |
