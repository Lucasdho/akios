# akios — ALVA Adoption & Reconciliation
**Working spec · v1.1 · architecture family · 2026-06-30**

Turns the `alva-architecture-doctrine.md` draft into an **adopted, executable** part of akios. It does
three things: (1) reconciles ALVA's folder law with the `designed` UI-overhaul family so they stop
disagreeing, (2) decides the akios-specific realizations ALVA left open (the Foundation ledger tool, the
module-boundary posture, the coordinator add), and (3) produces the ordered build backlog. Complements
`alva-architecture-doctrine.md` (the *why* — read it for every principle), `ui-first-architecture.md`
(whose §1/§2 this reconciles), and `ui-overhaul-implementation.md` (whose build plan this re-homes onto a
slice). Answers backlog **B7–B12, B14, and fixes B10** (`akios-backlog-map.md`).

> **State:** designed

> **v1.1 changelog (2026-07-01):** the human fork (§10, was blocking) is **resolved — ALVA wins,
> confirmed**. Two refinements land: components nest **per-view** inside `presentation/`
> (`presentation/<View>/components/<Component>/`, not a flat `presentation/Components/`); and the
> reconciled tree + worked example are re-synced to `prototype-first-workflow.md` v2.0 (the
> `ui-variations` skill + `./scratchs/` archive replace the retired `prototypes/`/`visual-grounding`
> mechanics referenced here previously).

> **The shift:** ALVA already *is* the architecture answer — this spec stops it from being a lonely draft.
> It resolves the one real conflict (ALVA vertical slices vs. the UI family's shared layers) in ALVA's
> favor, keeps every *behavioral* law the UI family settled, and hands the whole thing to
> `spec-to-tasks → task-execution` as a normal build. The original architecture ideas in ALVA (§8) are
> preserved verbatim; this spec is pure operationalization.

Worked example: **futebol-manager** (the same app the UI family uses), so the two families compose.

---

## 1. The reconciliation (D1) — ALVA's structure wins; the UI family's laws re-home into the slice

**Decision:** the folder law is **ALVA §4** (feature-vertical slices). `ui-first-architecture` §1 (shared
`DomainLayer/DataLayer/PresentationLayer`) and §2 (the rule-of-two promotion table) are **superseded** —
their *behavioral* content moves into a slice; their *layout* content is dropped in favor of ALVA's.

The reconciled tree (ALVA §4, annotated with where the UI family lands):

```
Project/
  Router/                    → navigation + custom-flow coordinators (UI family A5 + B14)
  Container/                 → DI: composition root + factories (UI family A5)
  Foundation/
    Design-tokens/           → DesignSystem struct, role ViewModifiers, native-first components (UI family B1–B5)
    Code-tokens/             → shared protocols + helpers (behind a contract; ALVA §6.2)
    usage-ledger.json        → deterministic promotion/demotion counts (ALVA §6.4)
  Features/
    Squad/
      domain/                → Player, Squad entities + use cases (the slice owns them)
      data/                  → PlayerRepository protocol + SwiftData/Store concretes
      presentation/          → per-view folders + Models/ (the ENTIRE UI family A1/A3/A4 lives here)
        SquadList/            { SquadListView.swift, SquadListViewModel.swift, components/PlayerRow/, components/FormBadge/ }
        Models/               { SquadRowData.swift }              ← JIT view-state DTOs, A2 (now slice-local)
      contract/              → public facade: protocol + DTOs other slices import (ALVA §5)
      tests/                 → co-located TDD (ALVA P7)
      Feature-spec.md        → SDD: intention + declared contract/Foundation consumption
  scratchs/                  → rejected `ui-variations` rounds, compilable + previewable, out of the app
                                target (prototype-first-workflow.md v2.0 §3; top-level, per-view/-component)
```

**Components nest per-view, not in a flat `presentation/Components/`.** A component is born inside the
view/screen that first needed it — `presentation/<View>/components/<Component>/`. It promotes to
`Foundation/Design-tokens/` through the ledger (D3) on its 2nd distinct use, **wherever that use comes
from** (no intermediate feature-wide tier) — the same two-stop shape ALVA already uses for every other
leaf, just with the birth point one level deeper than the original UI-family A2 assumed. Once promoted,
other views consult `Foundation/Design-tokens/` before building something similar (ALVA P6) rather than
re-authoring it. *(Refines D2's carry-over row for the dumb-component law — see §2.)*

**Decision & reason:** ALVA's cost function — minimize tokens-to-a-correct-verifiable-change — is a
*stronger* organizing principle than the UI family's layer split, and ALVA explicitly rejects
package-by-layer (ALVA D2). Keeping *both* structures (rejected) is incoherent — an agent can't follow two
folder laws. Keeping the UI family's shared layers and demoting ALVA to "just design tokens" (rejected)
throws away ALVA's whole contribution (contracts, bounded contexts, evidence-based DRY) to preserve the
weaker layout. The reconciliation is nearly loss-free because the UI family's value was always
*behavioral* (how components are built and wired), not *where the folders sit* — and every behavioral law
survives, re-homed inside `presentation/`.

> **[RESOLVED — superseded 2026-07-01 by `prototype-first-workflow.md` v2.0]** the old `prototypes/`
> HTML/manifest storage question is moot — there is no separate reference artifact anymore. What
> survives is the same *posture*: rejected `ui-variations` rounds live **top-level**, outside the Xcode
> app target, at `scratchs/<Component-or-View>.swift` — still per-slice-adjacent, still out of the
> compile graph, still lets `design` run before a slice's screen exists.

---

## 2. What survives from the UI family (D2) — the explicit carry-over list

So nothing is lost in the reconciliation, this is the exhaustive map of UI-family laws → their ALVA home.
`ui-overhaul-implementation.md` is re-pointed at these homes; **no UI decision is reopened.**

| UI-family law | Source | New home in ALVA |
|---|---|---|
| Build-order (components → dumb screen → make-it-live) | A3 | `Features/<F>/presentation/<View>/` — unchanged, per screen |
| Dumb-component law (data + closures via `init`) | A4 | `presentation/<View>/components/` — **refined 2026-07-01**: nests per-view, not a flat `presentation/Components/`; promotes to `Foundation/Design-tokens/` via the ledger on 2nd use, no intermediate feature-wide tier (§1) |
| Few-screens-many-components / VM-per-screen | A4.1 | `presentation/<View>/` — unchanged |
| JIT view-state DTOs | A2 | `presentation/Models/` — now **slice-local** (was `Feature/Models/`); promotion to shared is via ALVA's Foundation ledger, not rule-of-two |
| Domain entity home | A2 | `Features/<F>/domain/` — **the slice owns its entities** (ALVA), *not* a shared `DomainLayer/` |
| Repository protocol + concretes | A5 | `Features/<F>/data/` — slice-local; a repo shared by 2+ slices graduates to `Foundation/Code-tokens` behind a contract |
| Composition root → factories → router | A5 | `Container/` + `Router/` — unchanged, still the single composition seam |
| DesignSystem token struct | B1 | `Foundation/Design-tokens/` — shared by nature (ALVA §6.2: promote leaf visuals liberally) |
| Native-over-custom budget | B2 | doctrine, enforced at review + grounding — unchanged |
| Nielsen heuristics backbone | B3 | `align-ui` design phase — unchanged |
| Text/image role modifiers | B4 | `Foundation/Design-tokens/` — unchanged |
| `containerRelativeFrame` adaptivity | B5 | doctrine — unchanged |
| Explore + remix + graduate (`ui-variations`) | Block C v2.0 | orthogonal to structure — approved variation graduates directly into `presentation/<View>/`; rejects archive to top-level `scratchs/` (§1) |

**Decision & reason:** the one *substantive* change is entity/DTO/repo homing — they move from shared
app-wide layers into the slice, and cross-slice sharing routes through `contract/` (for domain) or the
Foundation ledger (for leaf code). This is exactly ALVA's §5 (bounded context) vs §6 (leaf promotion)
split, and it is *better* than the UI family's rule-of-two because it distinguishes "Feature A needs
Feature B's domain" (a contract) from "a formatter is repeated" (a Foundation graduation) — a distinction
the flat rule-of-two collapsed.

---

## 3. The Foundation ledger — akios realization (D3)

ALVA §6.4 specifies a deterministic usage ledger and lists four counting strategies (A ripgrep → B
compiler index → C module graph → D declared consumption). This decides how akios *ships* it.

- **Ship strategy A first (ripgrep + git-hook), as an `oss-first` candidate.** A pre-commit hook counts
  Foundation symbol occurrences across `Features/*/` and rewrites `Foundation/usage-ledger.json`. It is
  imprecise (name collisions) but trivial, deterministic, and proves the concept. `oss-first` runs first —
  if a maintained dead-code/index tool (which already walks the compiler index) can be repurposed to count,
  use it instead of hand-rolling.
- **Evolve to strategy B (compiler index) when the app is large enough to warrant it.** Same hook,
  precise counts (and, for protocols, *conformance* counts — ALVA §6.3). Cross-check with D (each
  `Feature-spec.md` declares what it consumes; divergence = a lint finding).
- **The agent never counts.** `task-execution` **reads** `usage-ledger.json` and, before writing any new
  helper/protocol, consults **only** `Foundation/` (a bounded, indexed search) — never the whole repo
  (ALVA P6). Each `candidates_promote` / `candidates_demote` entry becomes a **task** in `tasks/todo/`
  (the akios-only link, ALVA §12) — promotion stays *suggested*, never a silent mutation.

**Decision & reason:** starting at A honors akios's "no external dependencies by default" Vision and gets
a working lifecycle immediately; B is a drop-in upgrade behind the same JSON contract, so nothing
downstream changes when precision improves. Auto-promotion (rejected) is high-blast-radius and nearly
irreversible (ALVA D11) — the ledger's value is that it turns abstraction from a *judgment* the agent is
bad at into a *reviewable task* the agent is good at executing.

---

## 4. Module-boundary posture (D4) — folder-first, graduate to SPM modules on evidence

ALVA P3 wants the feature boundary *enforced by the toolchain* (the build refuses illegal cross-slice
imports). In Swift that realization is "one local SPM module per feature" (ALVA §10). This decides akios's
**default**, given the user's own caveat that these practices are "engineering overkill for simple things."

- **Default: folder-first + architecture lint.** A new project's slices are *folders*, and the boundary
  (P3: import only another slice's `contract/`, never its internals) is enforced by a **lint check** in
  `code-review` (G6) and the pre-commit hook — not yet by the compiler. Cheap; fits small/intermediate apps.
- **Graduate to SPM-module-per-feature** when *evidence* says the app has outgrown lint: a boundary
  violation recurs, the app crosses a size threshold, or the user asks. Graduation is a task (scaffold a
  local package for the slice), not a day-one tax.

**Decision & reason:** ALVA's *principle* (physical wall > discipline) is right, but ALVA also says the
concept lives in Layer 1 and the *realization* descends to akios (§9 golden rule). Forcing local SPM
packages on every feature of a 3-screen app is precisely the "engineering overkill" the backlog warns
against — the honest degradé (ALVA Appendix B) is architecture-lint until the app earns compiler
enforcement. Mandatory-SPM-from-day-one (rejected) taxes small apps; never-enforce (rejected) lets the
agent fur the boundary, which is the exact failure P3 exists to prevent — lint is the middle that keeps
the principle alive at low cost.

---

## 5. Coordinator for custom flows (D5) — closes backlog B14

B14 (coordinator for highly custom flows already on DI + injection) is the one UI-family gap
(`akios-backlog-map.md` §2.1). ALVA gives it a home: **`Router/` owns both plain navigation and named
coordinators.**

- A simple push/present is a `navigationDestination` the Router resolves (UI family A5).
- A **multi-step custom flow** (onboarding, a purchase wizard spanning several screens and slices) gets a
  named **coordinator** object in `Router/` that owns the flow's state machine and draws slice screens via
  the Container's factories. It consumes slices only through their `contract/` (ALVA §5) — a coordinator is
  a *composition-root citizen*, so it is the one place allowed to know several slices.

**Decision & reason:** coordinators are cross-feature by nature, so they belong at the composition top
(ALVA P4) beside the Router, not inside any slice. A coordinator *inside* a slice (rejected) would force
that slice to know the others — the coupling ALVA §5 exists to prevent. Kept small: a coordinator appears
only for genuinely multi-step custom flows; the default remains plain Router navigation.

---

## 6. Roadmap registration (D6)

- `alva-architecture-doctrine.md` is added to `Roadmap.md` under domain **Architecture doctrine**, status
  **designed**.
- This spec (`alva-adoption.md`) is added under **Architecture adoption**, status **designed → planned**
  once its backlog (§7) is written to `tasks/todo/`.
- `ui-first-architecture.md`'s Notes column is annotated: *"§1/§2 superseded by ALVA §4/§6 (confirmed
  2026-07-01) — see alva-adoption.md D1/D2; §3–§8 behavioral laws survive."* Status is unchanged (still
  `designed`); it is not archived, because most of it is still live.

**Decision & reason:** the doctrine and its adoption are two specs because ALVA Part I is *publishable
independently of akios* (ALVA D15) — keeping the portable doctrine separate from the akios operationalization
preserves that. Folding the annotation into `ui-first-architecture` rather than rewriting it keeps the
reconciliation auditable (a future reader sees exactly what changed and why).

---

## 7. Implementation backlog (ordered)

Consolidates ALVA §13 with the reconciliation deltas. This is the `spec-to-tasks` input; each item traces
to a decision above or an ALVA principle. Sequenced so each depends only on earlier ones.

- [ ] **7.1 — Import the doctrine.** Register `alva-architecture-doctrine.md` in `Roadmap.md`; have the
  installed `AGENTS.md`/`Context.md` templates import it as ground-truth (ALVA §11 row 1). *DoD:* Roadmap
  row exists; templates reference the doctrine; grep finds no "layer-first" contradiction left unqualified.
- [ ] **7.2 — `swift-dev` architecture guide.** A new bundled guide encoding the slice shape (§1), the
  carry-over laws (§2), the contract/bounded-context rule (ALVA §5), and "consult only `Foundation/` before
  writing a helper" (ALVA P6). Replaces the `swift-dev` architecture reference that `ui-overhaul-
  implementation` 3.4 was going to write — it now encodes the *reconciled* structure. *DoD:* guide exists;
  `swift-dev` router points to it; it shows the slice tree, the contract rule, and the Foundation-first rule.
- [ ] **7.3 — Foundation ledger PoC (§3).** `oss-first` check → ripgrep+git-hook writing
  `Foundation/usage-ledger.json`; the JSON schema from ALVA §6.4. *DoD:* hook runs on commit; ledger
  regenerates; a seeded 3-feature symbol shows up as a `candidates_promote` entry.
- [ ] **7.4 — `spec-to-tasks` slice shape.** UI/feature tasks emit on the ALVA slice
  (`domain/data/presentation/contract/tests`), and every feature task includes the step "consult
  `Foundation/` before creating a helper." Keep the A3 stage shape *inside* `presentation/`. *DoD:* a feature
  spec decomposes into slice-shaped tasks; the Foundation-consult step is present; A3 stages nest under
  `presentation/`.
- [ ] **7.5 — `task-execution` ledger read + promotion tasks.** Execution **reads**
  `Foundation/usage-ledger.json`, never counts; each promote/demote candidate becomes a `tasks/todo/` task
  (ALVA §12). The boundary lint (§4) runs in the checkpoint audit. *DoD:* SKILL.md describes reading the
  ledger, generating promotion tasks, and the boundary-lint audit; it never instructs counting by grep.
- [ ] **7.6 — `idea-to-spec` / `Feature-spec.md` contract header.** A feature spec declares its `contract/`
  surface and the Foundation symbols it consumes (ALVA §4 note, §6.4 alt-D). *DoD:* the feature-spec template
  has the declaration header; `spec-to-tasks` reads it.
- [ ] **7.7 — `align-ui` design-token discipline.** align-ui (design phase) treats `Foundation/Design-tokens`
  as the visual leaf source and flags un-tokenized literals (composes with §2 B1–B5). *DoD:* SKILL.md notes
  the design-token source and the literal-flag check.
- [ ] **7.8 — `deep-brainstorm` slice cartography.** Whole-app mapping emits features *as slices*, marks
  contract boundaries between them, and seeds `Foundation/` candidates (ALVA §11 last row). *DoD:* a mapping
  run produces slice-shaped spec rows with contract-boundary notes.
- [ ] **7.9 — `/akios:init` + `templates/` scaffold.** Scaffold the reconciled tree (§1): `Router/`,
  `Container/`, `Foundation/{Design-tokens,Code-tokens,usage-ledger.json}`, `Features/<F>/{domain,data,
  presentation/{<View>/components/, Models/},contract,tests,Feature-spec.md}`, top-level `scratchs/`.
  Include the DesignSystem + role-modifier stubs from `ui-overhaul-implementation` 4.1. `Context.md` notes
  `scratchs/` stays out of the target. *DoD:* init produces the tree; the ledger stub + git-hook install;
  the design-token stubs are present.
- [ ] **7.10 — Coordinator reference (§5).** A short `swift-dev` note on the Router coordinator pattern for
  multi-step custom flows. *DoD:* the note exists and cross-links the DI guide (7.2).
- [ ] **7.11 — Release.** `install-skills.sh` (if any new skill dir), `VERSION` + `CHANGELOG.md` +
  `.claude-plugin/plugin.json` bumped in one commit before push (standing memory rule). *DoD:* all three
  version files bumped together.

**Sequence:** 7.1 → 7.2 (base must exist and be loadable) → 7.3 (the ledger is the newest piece; PoC first)
→ 7.4/7.5 (execution follows the ledger) → 7.6/7.7/7.8 (design phases align) → 7.9/7.10 (scaffold + coord)
→ 7.11 (release seam, once).

---

## 8. Worked example — futebol-manager *Squad* slice, reconciled

- **Structure:** `Features/Squad/` owns `domain/{Player,Squad,Match}`, `data/{PlayerRepository (protocol) +
  SwiftData concrete}`, `presentation/{SquadList/{SquadListView.swift, SquadListViewModel.swift,
  components/PlayerRow/, components/FormBadge/}, Models/SquadRowData}`,
  `contract/{SquadContract protocol + Buyer-style DTOs}`, `tests/`, and a `Feature-spec.md` declaring it
  consumes `Foundation.DesignSystem` + (say) `Match.contract`.
- **UI build (unchanged from the UI family, now inside `presentation/`):** `ui-variations` explores 4
  named `#Preview` variations of `SquadListView` (built from `PlayerRow`/`FormBadge`, existing
  `DesignSystem` tokens) with sample data covering an empty squad and a 100+-player roster; the developer
  remixes two liked variations into 3 hybrids and approves one, which graduates directly to
  `presentation/SquadList/SquadListView.swift` — the rest archive to `scratchs/SquadListView-variations.swift`
  → attach `SquadListViewModel(playerRepo:)` via `init`, pull data JIT.
- **DI:** `Container/` registers a `SquadListViewModelFactory`; `Router/` resolves
  `navigationDestination(.squadList)` via that factory. A multi-step "sign a new player" wizard gets a
  `SignPlayerCoordinator` in `Router/` (§5).
- **Foundation:** `DesignSystem` + `.textStyle`/`.imageStyle` live in `Foundation/Design-tokens`. When
  `FormatCurrency` shows up in Squad, Wallet, and Invoice, the ledger flags it → a promotion task moves it to
  `Foundation/Code-tokens` behind a contract. `SquadRowData` stays slice-local until a 2nd slice imports it.
- **Boundary:** `Purchase` importing `Squad`'s internal `PlayerRepository` fails the boundary lint; it must
  import `Squad.contract` instead (ALVA §5).

---

## 9. Empty / edge states

- **A slice needs another slice's domain, not just a leaf:** that's a `contract/` (ALVA §5), not a Foundation
  promotion — the two mechanisms don't substitute (ALVA §5.5). Review flags a slice importing another slice's
  `domain/` directly.
- **Ledger flags a promotion no one wants:** the candidate is a *task*, so it's declined like any task — the
  ledger records the count, the human/agent chooses not to act; demotion later cleans it up (ALVA §6.1).
- **Small app, single slice:** ALVA degrades gracefully — one slice, an almost-empty `Foundation/`, no
  boundary to enforce yet. The structure imposes ~zero tax until a 2nd slice appears (matches the backlog's
  "overkill for simple things" caution).
- **A screen spans two domains** (e.g. "my purchases"): it belongs to the slice that owns the *intention* and
  consumes the other by contract (ALVA §5.4) — resolved by ALVA, not reopened here.

---

## 10. Open / next

- **[RESOLVED 2026-07-01 — see `akios-backlog-map.md` §4]** The human fork is closed: **ALVA structure
  confirmed**, no reversal. D1/D2 stand as written, refined by the per-view component nesting (§1/§2).
- **[CONSEQUENCE — to implement]** Everything in §7 (the backlog) — this spec is `spec-to-tasks`-ready now.
- **[COMPOSES WITH]** `code-review-doctrine.md` (G6) enforces the boundary lint (§4) and the DRY-via-ledger
  posture (§3); `knowledge-architecture.md` (G2) may ship ALVA itself as a loadable "architecture knowledge
  pack" so non-iOS stacks can adopt the portable Part I.
- **[DEFERRED]** SPM-module graduation tooling (the scaffold that turns a slice folder into a local package)
  — designed only when an app first earns it (§4).
