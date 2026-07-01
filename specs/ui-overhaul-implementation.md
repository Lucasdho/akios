# akios — UI Overhaul Implementation Plan
**Build backlog · v2.0 · consolidates the C→A→B family, reconciled onto ALVA**

This is the **execution plan** for the UI overhaul. The *design* is locked across `prototype-first-workflow.md`
v2.0 (Block C), `alva-adoption.md` v1.1 (Block A — supersedes `ui-first-architecture.md` §1/§2), and
`swiftui-design-doctrine.md` (Block B) — this doc is the ordered, dependency-aware backlog to *build* them.
It is not a new design; every item traces to a decision already settled. Read the three specs for the
*why*; read this for the *what, in what order*.

> **Status:** not started — all design locked, no implementation yet.
> **v2.0 changelog (2026-07-01):** full rewrite. The old v1.0 backlog built 3 skills
> (`prototype`/`html-to-swiftui`/`visual-grounding`) onto a shared `DomainLayer/DataLayer/PresentationLayer`
> tree — both are retired. This version builds **one skill** (`ui-variations`) onto **ALVA's vertical-slice
> structure** (the architectural fork is resolved, see `akios-backlog-map.md` §4). Consolidates
> `alva-adoption.md` §7's own backlog into this file rather than maintaining two overlapping lists.
> **Resume here.** A fresh agent can start at Phase 0 and work down; phases are ordered so each
> only depends on earlier ones.

## Source specs (the "why" for every item below)

| Spec | Owns |
|---|---|
| `specs/alva-adoption.md` (D1–D6) | The reconciled folder law: `Router/ Container/ Foundation/{Design-tokens,Code-tokens,usage-ledger.json} Features/<F>/{domain,data,presentation,contract,tests}`; the Foundation ledger; module-boundary posture; the coordinator |
| `specs/prototype-first-workflow.md` v2.0 (Block C) | The `design` phase; the `ui-variations` skill (explore → remix → graduate → scratch-archive) |
| `specs/swiftui-design-doctrine.md` (Block B) | `DesignSystem` tokens (B1); native-first budget (B2); Nielsen backbone (B3); role ViewModifiers (B4); adaptivity (B5) |
| `specs/alva-architecture-doctrine.md` | The portable doctrine `alva-adoption.md` operationalizes (principles, not akios-specific) |

`ui-first-architecture.md` is **not** a source spec here — its §1/§2 folder shape is superseded by
`alva-adoption.md`; its §3–§8 behavioral laws are already folded into the `alva-adoption.md` D2
carry-over table, which this backlog builds against directly.

## Conventions

- This is a **plugin/docs repo** (see `Roadmap.md` "Project type"): artifacts are `.md`/`.yml`/`.sh`/
  `.json`. "DoD" = verify by inspection + grep, not by a test suite. No SwiftUI builds here.
- The Swift code shapes (DesignSystem struct, role modifiers, slice layout) are authored as
  **skill guidance + templates**, not as a compiled app. futebol-manager (a separate Developer/
  project) is where they get exercised.

---

## Phase 0 — Pipeline spine

- [ ] **0.1 — Add the `design` phase.** `workflow.yml` + `pipeline.md`: insert a 4th phase
  **between `plan` and `execute`**. Per Block C v2.0, `design` runs `ui-variations` (explore + remix +
  graduate) and the reshaped `align-ui`; there is no separate approval-gate mechanism to build — a
  screen can't reach make-it-live until a variation has graduated, which is `alva-adoption.md`'s A3
  build-order already. *DoD:* `workflow.yml` lists `design`; `pipeline.md` describes its inputs
  (approved spec + plan), outputs (a graduated `presentation/<View>/` screen + ui-alignment doc); grep
  for stale "3-phase" / "HTML prototype" / "visual-grounding" references and update them.

---

## Phase 1 — Foundation + slice scaffold (ALVA base; must exist before anything else builds against it)

Per `alva-adoption.md` §7.1–7.3.

- [ ] **1.1 — Import the doctrine.** Register `alva-architecture-doctrine.md` in `Roadmap.md`; have
  the installed `AGENTS.md`/`Context.md` templates import it as ground-truth. *DoD:* Roadmap row
  exists; templates reference the doctrine; grep finds no unqualified "layer-first" contradiction left.
- [ ] **1.2 — `swift-dev` architecture guide.** New bundled guide encoding the ALVA slice shape
  (`domain/data/presentation/contract/tests`), the carry-over laws (build-order, dumb-component,
  factory/router DI), the contract/bounded-context rule, and "consult only `Foundation/` before
  writing a helper." Replaces the old `DomainLayer/DataLayer/PresentationLayer` reference this plan's
  v1.0 was going to write. *DoD:* guide exists; `swift-dev` router points to it; shows the slice tree,
  the contract rule, the Foundation-first rule, and the per-view component nesting
  (`presentation/<View>/components/`).
- [ ] **1.3 — Foundation ledger PoC.** `oss-first` check first (repurpose a maintained dead-code/index
  tool if one already walks the compiler index); otherwise a pre-commit hook (ripgrep) counting
  `Foundation/` symbol occurrences across `Features/*/` into `Foundation/usage-ledger.json`. *DoD:*
  hook runs on commit; ledger regenerates; a seeded 3-feature symbol shows up as a
  `candidates_promote` entry.
- [ ] **1.4 — `/akios:init` + `templates/` scaffold.** Produce the reconciled tree: `Router/`,
  `Container/`, `Foundation/{Design-tokens,Code-tokens,usage-ledger.json}`,
  `Features/<F>/{domain,data,presentation/{<View>/components/, Models/},contract,tests,Feature-spec.md}`,
  top-level `scratchs/`. Include the `DesignSystem` token enum stub + `TextStyle`/`ImageStyle`
  role-modifier stubs (Block B, Phase 4 below defines their shape — stub now, fill in when 4.1 lands).
  `Context.md` notes `scratchs/` stays out of the Xcode target. *DoD:* init produces the tree; the
  ledger stub + git-hook install; the design-token stubs are present.

---

## Phase 2 — The one new skill

- [ ] **2.1 — `ui-variations` skill** (design phase). Owns the whole loop per
  `prototype-first-workflow.md` v2.0: **explore round** (3–5 named `#Preview`s by default, user-specified
  count wins, warn-don't-block on extreme requests), **remix round** (3 named hybrids from liked
  elements), **sample data with edge cases** (empty / unbounded / long-text) shipped alongside every
  round, **approve-and-graduate** (winner lands directly at `presentation/<View>/<View>View.swift` +
  `components/`, no translation step), **archive-to-scratch** (losers compile + preview at
  `scratchs/<Component-or-View>.swift`, deletable by hand or by agent request). Unattended
  (`just-vibes`): auto-select-and-graduate from the explore round, `[auto]`-marked, rationale recorded.
  *DoD:* SKILL.md covers both rounds with their default/override counts, the edge-case warning, the
  sample-data requirement, the graduation target path, and the scratch-archive mechanism.

---

## Phase 3 — Reshape existing pipeline skills to consume Phase 1+2

Per `alva-adoption.md` §7.4–7.6, §7.8, plus the Block C `align-ui` handoff.

- [ ] **3.1 — `align-ui` remodel.** Confirmed design-phase scope: states / interactions / navigation +
  the per-screen JIT DTO-shape declaration (unchanged from the UI family) + the **10 Nielsen
  heuristics checklist** (Block B §3) + the **native-over-custom flag** (Block B §2) + **the
  post-wiring check** absorbed from the retired `visual-grounding` (does the real-data render still
  hold up against the mock-data-approved `ui-variations` graduate — same-engine, no cross-engine diff).
  Also: treats `Foundation/Design-tokens` as the visual-leaf source and flags un-tokenized literals.
  *DoD:* SKILL.md reflects all four responsibilities; no reference to the retired `visual-grounding`
  skill remains.
- [ ] **3.2 — `spec-to-tasks` update.** Emit UI tasks on the ALVA slice shape
  (`domain/data/presentation/contract/tests`), with the A3 stage shape
  (`components [P] → ui-variations dumb-screen → make-it-live`) nested *inside* `presentation/<View>/`.
  Add `ui-variations` to the routing table (not the three retired skills). Every feature task includes
  "consult `Foundation/` before creating a helper." Keep the existing Designer's-eye rule. *DoD:*
  routing table includes `ui-variations` only; emitted tasks follow the ALVA slice + A3 stage shape.
- [ ] **3.3 — `task-execution` update.** Drive the A3 stages inside `presentation/<View>/`; **reads**
  `Foundation/usage-ledger.json` (never counts) before writing a new helper/component; each
  promote/demote candidate becomes a `tasks/todo/` task; the boundary lint (contract-only cross-slice
  imports) runs in the checkpoint audit; "make-it-live" merges ViewModel wiring + JIT data in one pass.
  *DoD:* SKILL.md describes the ledger-read step, the promotion-task generation, the boundary-lint
  audit, and the A3 execution loop — no `visual-grounding` trigger.
- [ ] **3.4 — `figma-to-swiftui` — no change.** Stays exactly as shipped; **not** added to any routing
  table. Parked per `prototype-first-workflow.md` v2.0 §4/§9 — real asset, revived only if a future
  session wires Figma/Stitch back in as an optional feeder. *DoD:* confirm it's absent from
  `spec-to-tasks`'/`task-execution`'s routing tables (nothing to build here).
- [ ] **3.5 — `deep-brainstorm` slice cartography.** Whole-app mapping emits features *as slices*,
  marks contract boundaries between them, and seeds `Foundation/` candidates. *DoD:* a mapping run
  produces slice-shaped spec rows with contract-boundary notes.
- [ ] **3.6 — `idea-to-spec` / `Feature-spec.md` contract header.** A feature spec declares its
  `contract/` surface and the `Foundation/` symbols it consumes. *DoD:* the feature-spec template has
  the declaration header; `spec-to-tasks` reads it.

---

## Phase 4 — Design-craft doctrine (Block B materialization)

- [ ] **4.1 — New `swiftui-design-system` reference** (under `swift-dev`'s guides, beside
  `swiftui-design-principles`). The `DesignSystem` static-token-struct convention (B1) + the
  `.textStyle`/`.imageStyle` role-modifier convention (B4) + the static→instance upgrade rule. Home:
  `Foundation/Design-tokens/` (not the retired `PresentationLayer/DesignSystem/`). *DoD:* reference
  shows the `enum DesignSystem` shape, the role-modifier pattern, the "promote to `@Environment` on
  2nd theme" clause, and the correct `Foundation/Design-tokens/` home.
- [ ] **4.2 — `swiftui-design-principles` retrofit.** Keep its spacing-grid / "5 sizes" /
  semantic-color rules as the **source** of the token table; update examples to show
  `.textStyle(.hero)` + `DesignSystem.*` token refs instead of inline `.font(.system(size:…))` /
  `Color(.x)` literals. (Vendored guide, arjitj2, MIT v1.1.1 — values preserved, call sites re-homed.)
  *DoD:* examples reference tokens/roles; the rule values are unchanged.
- [ ] **4.3 — `swiftui-ui-patterns` update.** Record the narrow "screens get ViewModels, components
  don't; screens are few" override, and cross-link the role-modifier convention from its "custom view
  modifiers" guidance. *DoD:* both notes present; doesn't contradict the existing "avoid unnecessary
  view models" line — frames it as the screen-vs-component split.

---

## Phase 5 — Coordinator (closes backlog B14)

- [ ] **5.1 — Coordinator reference.** A short `swift-dev` note on the `Router/` coordinator pattern
  for multi-step custom flows (onboarding, a purchase wizard spanning several screens/slices) —
  consumes other slices only through `contract/`. *DoD:* the note exists and cross-links the DI guide
  (1.2/4.1).

---

## Phase 6 — Plumbing & release (do last, single commit)

- [ ] **6.1 — `install-skills.sh`.** Add `ui-variations` to the `SKILLS=()` array. *(Not the three
  retired skills — they were never built.)* *DoD:* array includes `ui-variations`; install smoke-test
  passes.
- [ ] **6.2 — `commands/` wrapper.** Add a command wrapper for `ui-variations`, matching the other
  skills' pattern. *DoD:* the skill has a matching command entry.
- [ ] **6.3 — Roadmap statuses.** Flip `alva-adoption.md`, `prototype-first-workflow.md`,
  `swiftui-design-doctrine.md` rows `designed → done` as each lands (or `in-progress` while building).
  *DoD:* Roadmap reflects real state.
- [ ] **6.4 — Version + changelog + plugin manifest.** Bump `VERSION` + `CHANGELOG.md` +
  `.claude-plugin/plugin.json` **in the same commit, before pushing** (per the repo's standing memory
  rule — marketplace reads the remote). Likely a minor bump (new `design` phase + 1 skill + reconciled
  architecture). *DoD:* all three files bumped together in one commit.

---

## Suggested branch & sequencing

- One feature branch per phase, `feature/ui-overhaul-<phase>`, since phases are dependency-ordered.
  Phase 0 unblocks 1; 1 unblocks 2 and 3; 4 and 5 are largely independent of 2/3 and can parallelize
  once 1 is done; 6 is the release seam, done once at the end.
- This is exactly a `spec-to-tasks` → `task-execution` job: pointing those skills at the source specs
  should regenerate this same backlog as executable tasks. This doc is the human-readable index of it.

## Open questions carried into implementation

- **Encoding homes** marked "(home decided at encoding)" in the source specs are settled when that
  item is built, not now.
- **`./scratchs/` cleanup UX** (`prototype-first-workflow.md` v2.0 §8) is an open question for a
  future `init`/hygiene pass — not blocking this backlog.
- **No new design decisions remain.** If implementation surfaces one, it reopens the relevant block
  (dependency-remodel discipline), it is not decided ad hoc in code.
