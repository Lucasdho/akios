# akios — Backlog Map (the AKIOS demands, synthesized)
**Index spec · v1.0 · 2026-06-30**

This is the **reading of the AKIOS backlog** — every demand from the raw list, itemized, mapped to
what already covers it and what still needs designing. It is the orientation document for the spec
family that answers the backlog. Read this first; it is the table of contents for everything else.

> **State:** designed (index — never planned/executed directly; it routes to the specs that are)

> **The finding:** roughly 60% of the backlog is *already designed* in two in-flight families (the
> UI overhaul and ALVA) that are `designed` but unbuilt. The remaining ~40% is genuine new surface
> area — knowledge extensibility, skill authoring, operating modes, a verification/learning loop, and
> a code-review doctrine — captured as six new specs. Nothing here is built yet; this map is the plan
> to build the right things without re-designing what exists.

---

## 1. The backlog, itemized

Every line of the raw AKIOS backlog, given a stable ID so the rest of the family can reference it.

| ID | Demand (raw) | Theme |
|---|---|---|
| **B1** | Criar Skill | Kit authoring |
| **B2** | Post-execution: compare what the task *suggested* vs what was *done*; on divergence, save to the project context so the error isn't repeated — or keep a "common hurdles & how to solve them" file | Verification / learning |
| **B3** | Modo aprendizado e modo entrega (learning mode / delivery mode) | Operating posture |
| **B4** | Abstract the meta-prompts away from specific knowledge domains | Knowledge architecture |
| **B5** | Let the user upload skills, code, and `.md` docs about a specific knowledge area | Knowledge ingestion |
| **B6** | Build knowledge `.md` from code, PDFs, images, books, documents | Knowledge ingestion |
| **B7** | Architecture for agents: TDD | Architecture |
| **B8** | Architecture for agents: Vertical Slice Architecture (Jimmy Bogard) | Architecture |
| **B9** | Architecture for agents: package-by-feature | Architecture |
| **B10** | The skill is NOT organizing the repo folder structure — files with >1 model/component/responsibility; no folders per domain/feature | Architecture / review |
| **B11** | Apply ACID, DRY, SOLID and other established frameworks in code-review | Code-review doctrine |
| **B12** | Feed the repository with good practices | Knowledge / review |
| **B13** | DIContainer `@Environment` + dependency injection + factories (advanced) | UI architecture |
| **B14** | Coordinator for highly custom flows already on DI container + injection | UI architecture |
| **B15** | Static mocks for previews (easy) | UI architecture |
| **B16** | Create previews for the user (easy) | UI architecture |
| **B17** | Pass functions-with-parameters into components; very dumb components (medium) | UI architecture |
| **B18** | Components size to the given screen; parent view manages sizes with `relativeFrame` (advanced) | UI architecture |
| **B19** | "Did it really implement it correctly?" (verification anxiety) | Verification |
| **B20** | Nielsen heuristics for design principles | UI craft |
| **B21** | Componentization | UI craft |
| **B22** | Component reuse | UI craft |
| **B23** | Dumb components (receive functions from outside) | UI craft |
| **B24** | Native components over custom (97% of the time) | UI craft |
| **B25** | RelativeFrame container in views + adaptable components | UI craft |
| **B26** | Design-system file → `DesignSystem` struct (unify colors + interface) | UI craft |
| **B27** | Turn text/image treatment into reusable view modifiers | UI craft |
| **B28** | Agents can code complexity but can't *infer* a beautiful UI; needs visual inspiration + supervision | UI grounding |
| **B29** | Robust system to load designs from Figma/Stitch, compare to the app's design, and re-iterate | UI grounding |

---

## 2. Coverage — what already answers each demand

Two families designed in prior sessions cover the majority. **Both are `designed` and unbuilt.**

### 2.1 The UI-overhaul family (C→A→B) — covers the UI backlog

`prototype-first-workflow.md` (C) · `ui-first-architecture.md` (A) · `swiftui-design-doctrine.md` (B) ·
`ui-overhaul-implementation.md` (the build plan).

| Backlog | Covered by |
|---|---|
| B13 DI container + factories | `ui-first-architecture` §5 (composition root → factories → router) |
| B14 Coordinator for custom flows | `ui-first-architecture` §5 (Router) — *thin; see gap note below* |
| B15 Static mocks for previews | `ui-first-architecture` §4 (components previewable from data alone) |
| B16 Previews for the user | `ui-first-architecture` §4 / `task-execution` TDD posture (Preview is the bar for views) |
| B17 Dumb components via closures | `ui-first-architecture` §4 (the dumb-component law: data + closures via `init`) |
| B18 Components size to screen; parent manages | `swiftui-design-doctrine` §5 (`containerRelativeFrame`) |
| B20 Nielsen heuristics | `swiftui-design-doctrine` §3 (10-heuristic align-ui checklist) |
| B21 Componentization | `ui-first-architecture` §3 (build-order: components first) |
| B22 Component reuse | `ui-first-architecture` §2 (rule-of-two promotion) |
| B23 Dumb components | `ui-first-architecture` §4 |
| B24 Native over custom | `swiftui-design-doctrine` §2 (native-over-custom budget + justification log) |
| B25 RelativeFrame + adaptable | `swiftui-design-doctrine` §5 |
| B26 DesignSystem struct | `swiftui-design-doctrine` §1 (`enum DesignSystem` token namespace) |
| B27 Text/image reusable modifiers | `swiftui-design-doctrine` §4 (`.textStyle`/`.imageStyle` role modifiers) |
| B28 Beautiful-UI needs inspiration + supervision | `prototype-first-workflow` (the whole thesis) |
| B29 Figma/Stitch load → compare → iterate | `prototype-first-workflow` §1/§5 + `visual-grounding` + `figma-to-swiftui` |

**Gap note:** B14 (coordinator) is only lightly served — `ui-first-architecture` §5 gives a Router but
not a coordinator pattern for multi-step custom flows. This folds into **ALVA adoption** (§4 below), which
gives the Router/Container a firmer home; a dedicated coordinator reference is a small add there.

### 2.2 The ALVA doctrine — covers the architecture backlog

`alva-architecture-doctrine.md` (Agent-Legible Vertical Architecture) — **uncommitted, not yet in the
Roadmap.** It is the strongest single answer in the whole backlog.

| Backlog | Covered by |
|---|---|
| B7 TDD | ALVA P7 / §7 (tests co-located per slice) |
| B8 Vertical Slice Architecture (Bogard) | ALVA §0.1, §3 (named and adopted) |
| B9 package-by-feature | ALVA §0.1, §4 (the slice folder shape) |
| B10 Folder structure not organized | ALVA §4 (one directory per feature; Clean *within* the slice) — **the direct fix** |
| B11 DRY in review | ALVA §6 (DRY-by-evidence: the Foundation promotion ledger) — *reframes DRY, see §4* |
| B12 Feed repo with good practices | ALVA §11 (doctrine as versioned ground-truth imported by `AGENTS.md`) |

**Reconciliation required (see §4):** ALVA's folder shape (per-feature *vertical slices*, each owning its
own `domain/data/presentation/contract/tests`) **conflicts** with `ui-first-architecture` §1 (shared
app-wide `DomainLayer/DataLayer/PresentationLayer`). These cannot both be the folder law. ALVA is the
newer, more complete thinking and should win the structure; the UI family's *behavioral* laws survive intact.

---

## 3. The gaps — six new specs

What the two families do **not** cover. Each becomes a spec in this family.

| # | New spec | Answers | One-line thesis |
|---|---|---|---|
| G1 | `alva-adoption.md` | B7–B12, B14, B10 | Reconcile ALVA with the UI family, register it, and give it an ordered build plan. |
| G2 | `knowledge-architecture.md` | B4, B5, B6, B12 | Split akios into a domain-agnostic **meta-prompt layer** + pluggable **knowledge packs**; ingest code/PDF/image/book/doc into packs. |
| G3 | `skill-authoring.md` | B1 | A `skill-author` skill + `/akios:new-skill` that scaffolds skills *and* knowledge packs, and self-registers (kills the install-skills.sh gotcha). |
| G4 | `operating-modes.md` | B3 | A third posture flag `learning \| delivery` that decides whether akios teaches the *why* as it builds or just ships. |
| G5 | `verification-and-learning-loop.md` | B2, B19 | Post-execution: **prove** it works (build/test/spec/visual) and **learn** from divergence (a hurdles ledger the next run reads). |
| G6 | `code-review-doctrine.md` | B10, B11, B12 | A principled review reference — SOLID/DRY/ACID + ALVA & UI conformance + folder-drift — that the "claiming done" gate loads. |

---

## 4. The one architectural decision the family turns on

**ALVA vs. ui-first-architecture folder law.** Both are `designed`; they disagree on structure:

- **ui-first-architecture §1:** shared, app-wide `DomainLayer/`, `DataLayer/`, `PresentationLayer/`, with
  `Features/<F>/` holding only presentation (`Components/Models/Screens`). *Layer-first.*
- **ALVA §4:** each `Features/<F>/` is a full vertical slice owning `domain/ data/ presentation/ contract/
  tests/`; sharing happens only through a graduated `Foundation/` and composition at the top
  (`Router/`, `Container/`). *Feature-first vertical slices.*

**Recommendation (settled in `alva-adoption.md`, flagged here for the human):** **ALVA's structure wins.**
Its cost function (minimize tokens-to-a-correct-verifiable-change) is the stronger principle and it
*explicitly* supersedes package-by-layer (ALVA D2). The UI family's structural sections
(`ui-first-architecture` §1 A1, §2 A2) are **subsumed** by ALVA §4/§6. Everything *behavioral* in the UI
family survives unchanged and re-homes inside a slice's `presentation/`:

- the build-order law (A3: components → dumb screen → make-it-live),
- the dumb-component law (A4: data + closures via `init`),
- the factory/router DI shape (A5 → ALVA's `Container/` + `Router/`),
- the whole design doctrine (B1–B5: DesignSystem tokens, native-over-custom, Nielsen, role modifiers,
  `containerRelativeFrame`) → ALVA's `Foundation/Design-tokens`,
- the prototype→translate→ground loop (Block C) → orthogonal to structure; untouched.

> This is the only fork that changes what gets built. If the human prefers to keep layer-first structure,
> reopen `alva-adoption.md` D1 — everything downstream keys off it.

---

## 5. Recommended build order

Dependency-ordered. Each phase only depends on earlier ones.

1. **Decide the fork (§4).** Confirm ALVA-structure-wins (or reopen). One human decision unblocks the rest.
2. **`alva-adoption.md` → build.** Reconcile + register ALVA, then run its implementation backlog
   (doctrine import → `swift-dev` guide → Foundation ledger PoC → slice-shape in `spec-to-tasks` →
   ledger read in `task-execution` → scaffold in `/akios:init`). This lands B7–B12 and fixes B10 for real.
3. **`ui-overhaul-implementation.md` → build**, now re-homed onto ALVA's slice (`presentation/` inside a
   slice instead of a shared `PresentationLayer/`). Lands the entire UI backlog (B13–B29).
4. **`knowledge-architecture.md` → build (G2).** The foundational extensibility layer; `code-references/`
   generalizes into knowledge packs; `swift-dev` becomes "the iOS pack." Lands B4–B6, B12.
5. **`skill-authoring.md` → build (G3).** Now that packs exist, one authoring path scaffolds both skills
   and packs. Lands B1.
6. **`operating-modes.md` (G4)** + **`verification-and-learning-loop.md` (G5)** + **`code-review-doctrine.md`
   (G6).** The three discipline layers; independent of each other, each plugs into `task-execution` +
   `just-vibes`. Land B2, B3, B11, B19, and reinforce B10.

Steps 2–3 are the biggest and highest-value (they discharge ~20 of 29 backlog lines). Steps 4–6 are the
new capabilities that make akios *extensible and self-correcting* rather than just disciplined.

---

## 6. What this map is not

- **Not a design.** Every decision lives in the spec it points to; this file only routes.
- **Not a status board.** `Roadmap.md` remains the single source of truth for per-spec status. When a spec
  here ships, flip its Roadmap row — do not annotate status in this map.
- **Not exhaustive of akios's own Vision.** The Vision wishlist (`Vision.md`) still leads for items *not*
  in this backlog (e.g. team-mode polish). This map is scoped to the AKIOS backlog list only.
