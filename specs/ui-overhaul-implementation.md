# akios — UI Overhaul Implementation Plan
**Build backlog · v1.0 · consolidates the C→A→B design family**

This is the **execution plan** for the 3-spec UI overhaul. The *design* is locked across three
`designed` specs — this doc is the ordered, dependency-aware backlog to *build* them. It is not a
new design; every item traces to a decision already settled. Read the three specs for the *why*;
read this for the *what, in what order*.

> **Status:** not started — all design locked, no implementation yet.
> **Resume here.** A fresh agent can start at Phase 0 and work down; phases are ordered so each
> only depends on earlier ones.

## Source specs (the "why" for every item below)

| Spec | Owns |
|---|---|
| `specs/prototype-first-workflow.md` (Block C) | The `design` phase; prototype → translate → ground loop; the 3 new skills |
| `specs/ui-first-architecture.md` (Block A) | Folder/layer structure; build-order law (A3); dumb-component law (A4); factory/router DI (A5) |
| `specs/swiftui-design-doctrine.md` (Block B) | `DesignSystem` tokens (B1); native-first budget (B2); Nielsen backbone (B3); role ViewModifiers (B4); adaptivity (B5) |

## Conventions

- This is a **plugin/docs repo** (see `Roadmap.md` "Project type"): artifacts are `.md`/`.yml`/`.sh`/
  `.json`. "DoD" = verify by inspection + grep, not by a test suite. No SwiftUI builds here.
- The Swift code shapes (DesignSystem struct, role modifiers, folder layout) are authored as
  **skill guidance + templates**, not as a compiled app. futebol-manager (a separate Developer/
  project) is where they get exercised.

---

## Phase 0 — Pipeline spine (everything routes through this)

- [ ] **0.1 — Add the `design` phase.** `workflow.yml` + `pipeline.md`: insert a 4th phase
  **between `plan` and `execute`**. Per Block C: design phase runs `prototype` (+ ingest) and the
  reshaped `align-ui`; gates on prototype approval before any SwiftUI.
  *DoD:* `workflow.yml` lists `design`; `pipeline.md` describes its inputs (approved spec + plan),
  outputs (approved per-screen prototype + ui-alignment doc), and the hard approval gate; grep for
  stale "3-phase" / "brainstorm → plan → execute" references and update them.

---

## Phase 1 — The three new skills (the new capabilities)

All under `skills/`, each with `SKILL.md` (+ references as needed). Block C §C4.

- [ ] **1.1 — `prototype` skill** (design phase). Generate/iterate HTML+Tailwind prototypes by
  default; `bring-it` path ingests an existing reference (Figma/Stitch/screenshot/HTML). Writes
  `prototypes/<Feature>/<Screen>.{html,png}` + `prototypes/manifest.md`; links from the
  ui-alignment doc. Hard approval gate (no SwiftUI until approved); `[auto]`-approve under
  just-vibes. *DoD:* SKILL.md covers generate / iterate / ingest, the artifact paths, the gate, and
  the just-vibes auto-approve branch.
- [ ] **1.2 — `html-to-swiftui` skill** (execute phase). Translate an approved prototype into
  SwiftUI on the A3 build-order law: components `[P]` → dumb screen (mock data) → make-it-live.
  Extracts components bottom-up during translation. Hands the dumb screen to `visual-grounding`.
  *DoD:* SKILL.md encodes the A3 stages, bottom-up component extraction, and the grounding handoff;
  consumes `DesignSystem` tokens + role modifiers (Block B), not inline literals.
- [ ] **1.3 — `visual-grounding` skill** (execute phase, shared by 1.2 and figma-to-swiftui).
  Agent-driven **structured visual diff** (NOT pixel diff) of the running screen vs the approved
  prototype: screenshot via the iOS debugger/simulator, categorized diff
  (layout/spacing/color/typography/assets/missing), max-iteration cap, human-gated verdict /
  auto-accept when unattended. *DoD:* SKILL.md defines the diff categories, the iteration cap, the
  screenshot mechanism, and both the gated and unattended verdict paths.

---

## Phase 2 — Reshape existing pipeline skills to use Phase 1

- [ ] **2.1 — `align-ui` remodel.** Relocate from "automatic gate inside task-execution" to the
  **design phase**. Shrink visual scope (the prototype owns the look now) to **non-visual gaps:
  states / interactions / navigation + the per-screen JIT DTO-shape declaration** (Block A §7–8).
  Add the **10 Nielsen heuristics checklist** as its backbone (Block B §3 table). Record the
  **native-over-custom flag** (Block B §2) as an align-ui/grounding check. *DoD:* SKILL.md reflects
  design-phase home, shrunk scope, the heuristic→check table, and the native-custom flag; remove the
  old "task-execution gate" framing.
- [ ] **2.2 — `spec-to-tasks` update.** Emit UI tasks on the **A3 stage shape**
  (`components [P] → dumb-screen + grounding → make-it-live`). Add `prototype`, `html-to-swiftui`,
  `visual-grounding` to the routing table. Keep the existing Designer's-eye rule. *DoD:* SKILL.md
  routing table includes the 3 new skills; a UI feature's emitted tasks follow the A3 stages.
- [ ] **2.3 — `task-execution` update.** Drive the A3 stages; **fire `visual-grounding` at the
  dumb-screen stage**; "make-it-live" merges ViewModel wiring + JIT data in one pass (Block A §3).
  *DoD:* SKILL.md describes the A3 execution loop and the grounding trigger point.
- [ ] **2.4 — `figma-to-swiftui` rewire.** Route its Step 7 validation through the shared
  `visual-grounding` skill instead of its bespoke "validate on user request only." Keep the Figma
  MCP ingest path intact. *DoD:* Step 7 delegates to `visual-grounding`; no duplicated diff logic.

---

## Phase 3 — Knowledge / doctrine (the Swift craft guidance)

- [ ] **3.1 — New `swiftui-design-system` reference** (under `swift-dev`'s guides, beside
  `swiftui-design-principles`). The `DesignSystem` static-token-struct convention (B1) + the
  `.textStyle`/`.imageStyle` role-modifier convention (B4) + the static→instance upgrade rule.
  *DoD:* reference shows the `enum DesignSystem` shape, the role-modifier pattern, and the
  "promote to `@Environment` on 2nd theme" clause.
- [ ] **3.2 — `swiftui-design-principles` retrofit.** Keep its spacing-grid / "5 sizes" /
  semantic-color rules as the **source** of the token table; update *examples* to show
  `.textStyle(.hero)` + `DesignSystem.*` refs instead of inline `.font(.system(size:…))` / `Color(.x)`.
  (Vendored, arjitj2, MIT v1.1.1 — preserve values, re-home call sites; bump its internal version.)
  *DoD:* examples reference tokens/roles; the rule values are unchanged.
- [ ] **3.3 — `swiftui-ui-patterns` update.** Record the narrow **VM override** (Block A §4.1:
  "screens get ViewModels, components don't; screens are few") and cross-link the role-modifier
  convention from its "custom view modifiers" guidance. *DoD:* both notes present; doesn't contradict
  the existing "avoid unnecessary view models" line — frames it as the screen-vs-component split.
- [ ] **3.4 — `swift-dev` architecture reference** (Block A §8). Encode the layer structure
  (Domain/Data/Presentation + Features), the dumb-component law, the factory/router DI shape, and
  that components consume `DesignSystem` **static** tokens (never `@Environment`). *DoD:* reference
  exists and `swift-dev` master router points to it.

---

## Phase 4 — Scaffolding & templates

- [ ] **4.1 — `/akios:init` + `templates/`.** Scaffold the new layout:
  `DomainLayer/{Models,UseCases}`, `DataLayer/{Repositories,DI}`,
  `PresentationLayer/{DesignSystem,Components,Navigation}`, `Features/<Feature>/{Components,Models,Screens}`,
  top-level `prototypes/` (+ `manifest.md`). Include a starter `DesignSystem` token enum stub +
  `TextStyle`/`ImageStyle` role-modifier stubs (Block B). `Context.md` notes `prototypes/` stays out
  of the Xcode target. *DoD:* init produces the tree; templates contain the stubs; Context.md note present.

---

## Phase 5 — Plumbing & release (do last, single commit)

- [ ] **5.1 — `install-skills.sh`.** Add `prototype`, `html-to-swiftui`, `visual-grounding` to the
  `SKILLS=()` array. *DoD:* array includes all 3; install smoke-test passes.
- [ ] **5.2 — `commands/` wrappers.** Add command wrappers for the new skills as the other skills have.
  *DoD:* each new skill has a matching command entry.
- [ ] **5.3 — Roadmap statuses.** Flip the three spec rows `designed → done` as each lands (or
  `in-progress` while building). *DoD:* Roadmap reflects real state.
- [ ] **5.4 — Version + changelog + plugin manifest.** Bump `VERSION` + `CHANGELOG.md` +
  `.claude-plugin/plugin.json` **in the same commit, before pushing** (per the repo's standing
  memory rule — marketplace reads the remote). Likely a minor bump (new `design` phase + 3 skills).
  *DoD:* all three files bumped together in one commit.

---

## Suggested branch & sequencing

- One feature branch per phase (or per spec), `feature/ui-overhaul-<phase>`, since phases are
  dependency-ordered. Phase 0 unblocks 1; 1 unblocks 2; 3 and 4 are largely independent of 2 and can
  parallelize; 5 is the release seam, done once at the end.
- This is exactly a `spec-to-tasks` → `task-execution` job: pointing those skills at the three specs
  should regenerate this same backlog as executable tasks. This doc is the human-readable index of it.

## Open questions carried into implementation

- **Encoding homes** marked "(home decided at encoding)" in the specs — e.g. the exact file path for
  the `swift-dev` architecture reference (3.4) — are settled when that item is built, not now.
- **No new design decisions remain.** If implementation surfaces one, it reopens the relevant block
  (dependency-remodel discipline), it is not decided ad hoc in code.
