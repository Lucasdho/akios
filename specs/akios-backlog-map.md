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
**B30–B36 are exceptions** — added in later sessions (2026-07-01), not from the original raw
list; kept in the same table/ID scheme so the rest of the family can reference them identically.
B32–B35 come from a friend's ("Julio") first `/akios:init` run — real onboarding friction, not
self-generated backlog. B36 comes from a self-audit of the kit's own shipped contract (commands,
skills, templates, `workflow.yml`) — see `specs-review-2026-07-01.md` on branch
`claude/inspiring-rubin-3vksm6` (not yet merged into this branch).

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
| **B30** | Load the user's own "factory" Swift code (components, repository CRUD templates, use cases, gateway protocols, design-system files) into akios as copy-and-adapt seed content, separate from skeletons | Knowledge / starter content |
| **B31** | Architecture-keyed whole-project skeletons — different starter trees for different architectures; the oneshot picks an architecture and gets that architecture's skeleton if one is registered | Knowledge / starter content |
| **B32** | just-vibes push/merge automation must be asked as its own question, separate from `collaboration: solo/team` — a repo can be worked on by a group while the user is the only one running akios on it | Collaboration & autonomy posture |
| **B33** | `/akios:init` must narrate what it's doing while it runs, not execute long steps silently | Init UX |
| **B34** | `/akios:init`'s file-materialization step must survive tool-call errors (failed `cp`, an auto-mode-blocked batched `chmod +x` forcing a fallback to per-file calls that then also error) without leaving the agent stuck in an ambiguous "did it land or not" state | Init reliability |
| **B35** | Consolidate every akios-generated file under one folder, and offer the user an option to gitignore all of it, so `/akios:init` doesn't pollute the person's repo | Init footprint / repo hygiene |
| **B36** | Self-review of the shipped kit contract found real drift: `align-ui` "skip vs run under just-vibes" stated three contradictory ways, `runner: subagent` per-task routing conflicts with `AGENTS.md`'s session-pressure subagent-economy rule, `AGENTS.md` misquotes task-execution's 110k context-warn line as 120k, plus number/enum drift (`objectVersion` 77 vs 90, two divergent R-W-W rubrics claiming to be the same one, 3 conflicting skill counts, `needs-revision`/`blocked` missing from the status enum) and dangling refs (`specs/pipeline.md`, `founderlens-sim`, `/ios-feature-pipeline` as a command). Needs a reconciliation pass against `workflow.yml` + `AGENTS.md` as the two authorities. Full detail: `specs-review-2026-07-01.md`, branch `claude/inspiring-rubin-3vksm6`. | Kit self-consistency / contract drift |

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
| B29 Figma/Stitch load → compare → iterate | **no longer covered** — `prototype-first-workflow` v2.0 (2026-07-01) parked Figma/Stitch/HTML ingestion in favor of direct-to-SwiftUI `ui-variations`; `figma-to-swiftui` still exists but is unrouted. See that spec's §1 and §9 "FUTURE — parked" items if this is reactivated. |

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
| G7 | `snippet-library.md` | B30 | Extend the pack format with literal, copy-and-adapt Swift snippets (components, repository templates, use cases, gateway protocols, design-system files), user-global, separate from skeletons. |
| G8 | `skeleton-library.md` | B31 | Architecture-keyed whole-project starter trees for `/akios:init`'s greenfield path — user picks an architecture, gets that architecture's skeleton if one is registered, else today's default scaffold. |
| G9 | `collaboration-autonomy.md` *(not yet written)* | B32 | Split "who else works on this repo" (`collaboration: solo/team`) from "should just-vibes auto-push/merge" — two independent questions, not one flag standing in for both. |
| G10 | `init-reliability-and-ux.md` *(not yet written)* | B33, B34, B35 | `/akios:init` narrates its steps as it runs, verifies each materialization step actually landed instead of assuming, avoids batched calls that trip the auto-mode classifier, and keeps its footprint in one gitignore-able folder. |
| G11 | `contract-consistency-reconciliation.md` *(not yet written)* | B36 | Reconcile the ~17 drift points from the 2026-07-01 self-review against `workflow.yml`/`AGENTS.md` as the two authorities: fix the 3 outright contradictions first (align-ui skip/run, runner routing vs. subagent economy, 110k/120k), then number/enum drift, then dangling refs. |

---

## 4. The architectural fork — RESOLVED 2026-07-01

**ALVA vs. ui-first-architecture folder law.** Both were `designed`; they disagreed on structure:

- **ui-first-architecture §1:** shared, app-wide `DomainLayer/`, `DataLayer/`, `PresentationLayer/`, with
  `Features/<F>/` holding only presentation (`Components/Models/Screens`). *Layer-first.*
- **ALVA §4:** each `Features/<F>/` is a full vertical slice owning `domain/ data/ presentation/ contract/
  tests/`; sharing happens only through a graduated `Foundation/` and composition at the top
  (`Router/`, `Container/`). *Feature-first vertical slices.*

**Confirmed by the human: ALVA's structure wins.** Its cost function (minimize tokens-to-a-correct-
verifiable-change) is the stronger principle and it *explicitly* supersedes package-by-layer (ALVA D2).
The UI family's structural sections (`ui-first-architecture` §1 A1, §2 A2) are **subsumed** by ALVA §4/§6.
Everything *behavioral* in the UI family survives and re-homes inside a slice's `presentation/`:

- the build-order law (A3: components → dumb screen → make-it-live),
- the dumb-component law (A4: data + closures via `init`) — **refined**: components nest per-view
  (`presentation/<View>/components/`), promoting to `Foundation/Design-tokens/` via the ledger on 2nd use,
- the factory/router DI shape (A5 → ALVA's `Container/` + `Router/`),
- the whole design doctrine (B1–B5: DesignSystem tokens, native-over-custom, Nielsen, role modifiers,
  `containerRelativeFrame`) → ALVA's `Foundation/Design-tokens`,
- the design-phase explore/remix loop (`prototype-first-workflow.md` v2.0, `ui-variations`) → orthogonal
  to structure; graduates directly into `presentation/<View>/`.

> This was the only fork that changed what gets built. It no longer blocks anything — `alva-adoption.md`
> is `spec-to-tasks`-ready. Full detail: `alva-adoption.md` D1/D2 (v1.1).

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
5. **`snippet-library.md` → build (G7).** Adds `kind: snippet` to the pack format from step 4 — the
   user's own factory code (components, repository templates, use cases, gateways) as a user-global,
   copy-and-adapt pack. Lands B30. Depends only on step 4 existing; independent of steps 6–8 below.
6. **`skeleton-library.md` → build (G8).** Architecture-keyed whole-project starters for
   `/akios:init`'s greenfield path. Lands B31. No dependency on step 5 (snippets and skeletons ship
   independently); only needs the user-global storage convention from step 4.
7. **`skill-authoring.md` → build (G3).** Now that packs exist, one authoring path scaffolds both skills
   and packs. Lands B1.
8. **`operating-modes.md` (G4)** + **`verification-and-learning-loop.md` (G5)** + **`code-review-doctrine.md`
   (G6).** The three discipline layers; independent of each other, each plugs into `task-execution` +
   `just-vibes`. Land B2, B3, B11, B19, and reinforce B10.

Steps 2–3 are the biggest and highest-value (they discharge ~20 of 29 backlog lines). Steps 4–8 are the
new capabilities that make akios *extensible and self-correcting* rather than just disciplined.

**G9/G10/G11 — registered, not yet sequenced.** G9/G10 surfaced from real `/akios:init` onboarding
friction (2026-07-01); G11 surfaced from a self-audit of the shipped kit contract (2026-07-01, see
`specs-review-2026-07-01.md` on branch `claude/inspiring-rubin-3vksm6`). None are yet designed or
placed in the ordering above. G11 is a special case worth flagging: unlike G1–G10, it isn't new
surface area — it's **fixing drift in what's already shipped**, so it could reasonably jump the queue
(cheap, no design phase needed for most items — mostly find-and-replace against `workflow.yml`/
`AGENTS.md`) rather than wait its turn behind the build-order above.

---

## 6. What this map is not

- **Not a design.** Every decision lives in the spec it points to; this file only routes.
- **Not a status board.** `Roadmap.md` remains the single source of truth for per-spec status. When a spec
  here ships, flip its Roadmap row — do not annotate status in this map.
- **Not exhaustive of akios's own Vision.** The Vision wishlist (`Vision.md`) still leads for items *not*
  in this backlog (e.g. team-mode polish). This map is scoped to the AKIOS backlog list only.
