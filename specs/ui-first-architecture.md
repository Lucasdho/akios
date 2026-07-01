# akios — UI-First Architecture
**Working spec · v1.0 · UI overhaul annex (spec 2 of 3)**

Defines the *ordering + structure* doctrine for UI-first feature development: the per-feature
folder shape, the `DomainLayer`/`DataLayer`/`PresentationLayer` split, the build-order law
(components → dumb screen → make-it-live), the dumb-component-via-`init` rule, and the
factory/router dependency-injection shape. Second of the 3-spec UI overhaul family
(**`prototype-first-workflow` → `ui-first-architecture` → `swiftui-design-doctrine`**). Complements
`prototype-first-workflow.md` (resolves its two parked items) and feeds `swiftui-design-doctrine.md`
(which defines the `DesignSystem` struct this spec gives a home to). Everything here is settled
unless marked *open*.

> **State:** designed

> **[SUPERSEDED 2026-07-01 — see `alva-adoption.md` D1/D2]** §1 (A1, the shared
> `DomainLayer/DataLayer/PresentationLayer` folder shape) and §2 (A2, the flat rule-of-two promotion
> table) are subsumed by ALVA's vertical-slice structure — the human fork this spec assumed is now
> resolved in ALVA's favor. **§3–§8 remain live**, behaviorally unchanged, re-homed inside a slice's
> `presentation/` (component birth is now per-view — `presentation/<View>/components/` — not the flat
> `Feature/Components/` these sections still describe below; read `alva-adoption.md` §1/§2 for the
> current folder shape).

> **The shift:** from domain-first (models → screens → extract components) to **UI-first,
> feature-by-feature** — gather context via specs → build flexible dumb components → compose dumb
> screens → make them live with ViewModels → create data models just-in-time as development needs
> them. This fits a developer defining the app *as they build*, validates the UI before sinking
> effort into the backend, and surfaces what data each screen needs *before* data modeling is
> consolidated.

Worked example: **futebol-manager** (football-manager iOS app, mapped UI-first via
`deep-brainstorm`, arriving with 3 finished HTML references).

---

## 1. The structure (A1) — `Feature/` wrapper with a `Screens/` subfolder

```
DomainLayer/
  Models/         ← shared domain entities (Player, Match, Club)
  UseCases/       ← shared use cases
DataLayer/
  Repositories/   ← repo protocols + SwiftData base repo + StoreRepository concretes
  DI/             ← composition root + container holding the factories
PresentationLayer/
  DesignSystem/   ← DesignSystem struct + tokens   (defined in swiftui-design-doctrine.md)
  Components/     ← components promoted app-wide (rule-of-two)
  Navigation/     ← Router
Features/
  Squad/
    Components/    ← feature-local components
    Models/        ← feature-local view-state / DTOs
    Screens/
      SquadList/      { SquadListView.swift, SquadListViewModel.swift }
      PlayerDetail/   { PlayerDetailView.swift, PlayerDetailViewModel.swift }
prototypes/
  Squad/ SquadList.html, PlayerDetail.html
  manifest.md
```

**Decision & reason:** a **screen = View + its ViewModel**, nested under `Feature/Screens/`. The
flat one-view-per-feature proposal (rejected) conflates "feature" and "screen" — futebol-manager's
*Squad* feature spans SquadList, PlayerDetail, MatchDay, so a feature must hold several screens. A
screen-as-unit layout with no feature wrapper (rejected) drops the feature grouping. The
`DomainLayer`/`DataLayer`/`PresentationLayer` split is adopted as given.

---

## 2. The promotion rule (A2) — entities by nature, everything else by rule-of-two

| Artifact | Born | Promoted when |
|---|---|---|
| **Domain entity** (the nouns the app models; persisted by DataLayer) | `DomainLayer/Models/` at data-consolidation time | n/a — shared by nature |
| **View-state / feature DTO** (the JIT "shape this screen needs") | `Feature/Models/` (local) | a **2nd feature** consumes it |
| **Design-system primitive + tokens** | `PresentationLayer/DesignSystem/` | n/a — shared by nature |
| **Bespoke UI component** | `Feature/Components/` (local) | a **2nd consumer** uses it → `PresentationLayer/Components/` |

**Decision & reason:** a `Player` entity genuinely differs from a `SquadRow` component — one is
*what the app is about* (DataLayer persists it, many features touch it), the other is *how one
screen looks*. Rule-of-two for everything (rejected) would force a persistence-backed entity to be
born inside a feature folder that DataLayer then imports upward — a smell. Classify-everything-up-
front (rejected) bloats `DomainLayer` with entities one screen uses, against JIT. The split keeps
JIT discipline for UI while letting entities live where persistence needs them. It also fits the
prototype-first flow: a screen first declares a **local DTO shape**; the real domain entity
crystallizes when data modeling consolidates.

---

## 3. The build-order law (A3) — components → dumb screen → make-it-live

Per screen, three stages:

1. **Components `[P]`** — build the dumb, reusable components (parallelizable; share no files).
2. **Dumb screen** — compose the components into the screen with **mock/static data**. Under
   `prototype-first-workflow.md` v2.0, this stage *is* the approved `ui-variations` graduate — there
   is no separate reference to converge against; the last point at which the look is determined is
   the explore/remix round itself, before graduation.
3. **Make-it-live** — attach the screen's `@Observable` ViewModel (injected via `init`) and pull
   **data just-in-time in the same pass** (the viewmodel wiring and the data shape co-emerge).

**Decision & reason:** components get first-class isolated treatment ("build key flexible
components first"); grounding fires at the dumb-screen seam because viewmodel/data stages don't
change appearance. Four strict stages (rejected) over-fragment — stages 3 and 4 are one activity
under JIT. Order-as-doctrine-inside-one-task (rejected) loses the dumb-screen grounding checkpoint
as a first-class stop. **This is the precise resolution of the prototype↔component "tension":** the
prototype is the *design* unit (per screen); the component is the *build* unit (extracted bottom-up
during translation). They never conflict.

`spec-to-tasks` emits UI tasks on this shape; the `design→execute` handoff delivers an already-graduated
per-screen dumb screen — stage 2 is already done by the time `execute` picks it up.

---

## 4. The dumb-component law (A4) — data + closures via `init`

- A component receives **value data + closures** through `init`
  (`init(data: PlayerRowData, onTap: @escaping () -> Void)`). It may hold **ephemeral local
  `@State`** (focus, animation). It **never** owns data/business logic, and **never** accesses
  `@Environment`, a service, a repository, or a global.
- The **screen owns the ViewModel** (`@State private var vm: SquadListViewModel`, `@Observable`,
  iOS 17+), reads from it, and passes plain values + closures down. Components never see the VM —
  they get `vm.derivedValue` and `{ vm.didTap(id) }`.
- **Sanctioned exception:** when a single deeply nested sub-tree would require drilling an
  unreasonable number of closures, inject a *scoped* `@Observable` sub-viewmodel into **that
  section via `init`** (still no environment, no global). Documented as an exception, never the
  default.

**Decision & reason:** this maximizes reuse, previewability, and testability — components are
trivially previewed from data alone. A co-equal escape hatch (rejected) breeds two component kinds
and quietly erodes dumbness. Per-component read protocols (rejected) over-abstract and reintroduce
coupling.

### 4.1 — "Few screens, many components" (VM proliferation control)

ViewModel proliferation is avoided **by minimizing screen count, not by dropping ViewModels.** A
screen is a *fat composition of many dumb components* with **one** screen-level ViewModel.

- This is the narrow, deliberate override of `swiftui-ui-patterns`' "avoid unnecessary view
  models": dumb components stay MV-pure; **screens** get ViewModels, but there aren't many screens.
- **Guard — the pressure-release is the VM, not the view.** A fat screen is fine as long as its
  body is mostly *composition* and logic lives in the VM. The signal to split a screen is when its
  **ViewModel loses cohesion** (unrelated responsibilities), not when the view looks large. This
  keeps "few screens" from degrading into god-screens.

---

## 5. Dependency injection (A5) — composition root → factories → router

```
Composition root  ──builds──▶  DataLayer repos (concretes)
        │
        └──registers──▶  DI container  ──holds──▶  factories (build a screen's VM from repo protocols)
                                                        ▲
Router (PresentationLayer)  ──at navigationDestination──┘  draws the matching factory,
        handles navigation        builds the screen's VM, injects repo protocols via init
```

- **DataLayer** = repo **protocols** + a **SwiftData base repository** + **StoreRepository**
  concretes used when a repo needs store-backed CRUD (`spec-to-tasks` already enforces "protocol +
  defaults; concretes inherit"; reference: `swift-dev`'s `swiftdata-pro/store-repository-pattern.md`).
- **ViewModels depend on repo protocols**, so they're fake-able in tests; factories supply the
  concretes.
- **Construction lives in the factories; navigation lives in the router.** The router doesn't know
  *how* to wire repos into a VM — it asks the container's factory. Only the router (carrying the
  container) is app-wide shared.

**Decision & reason:** pure `init`-injection (the stated preference) without prop-drilling the
container — the router + factories are the single composition seam. `@Environment`-for-shared
(rejected) is idiomatic but makes the dependency channel implicit. A DI framework (rejected) adds
an external dependency, against akios's Vision.

---

## 6. Worked example — futebol-manager *Squad* feature

- **Structure:** `Features/Squad/Screens/{SquadList,PlayerDetail}`, `Features/Squad/Components/`
  (e.g. `PlayerRow`, `FormBadge`), `Features/Squad/Models/` (e.g. `SquadRowData` — a JIT DTO).
- **Entities:** `Player`, `Squad`, `Match` land in `DomainLayer/Models/` when data modeling
  consolidates; `DataLayer/Repositories/PlayerRepository` (protocol) is backed by the SwiftData
  base repo.
- **Build order (SquadList):** build `PlayerRow` + `FormBadge` `[P]` → `ui-variations` explores +
  remixes `SquadListView` with mock players, graduating the approved variation directly →
  attach `SquadListViewModel(playerRepo:)` via `init`, pull real players JIT.
- **DI:** composition root registers a `SquadListViewModelFactory` into the container; the Router's
  `navigationDestination(for: .squadList)` draws it, builds the VM with `PlayerRepository`, injects
  via `init`.
- **Few screens, many components:** the Squad feature is a handful of screens, each composing many
  dumb components — `SquadListViewModel` stays cohesive (roster list + filters); when match-tactics
  responsibilities appear, that's the signal for a separate screen + VM, not a fatter one.

---

## 7. Empty / edge states (architectural)

- **Screen with no data yet (first run / empty entity store):** the dumb screen renders its
  empty-state composition from a `vm.state == .empty` value; `align-ui` (design phase) is where the
  empty/loading/error states are decided, since a static prototype can't express them.
- **A component needs data the screen's DTO doesn't carry:** that's the signal to extend the
  feature-local DTO (JIT) — not to let the component reach for a service. The dumb-component law
  holds.
- **An entity is needed before data consolidation:** create it JIT in `DomainLayer/Models/` (entity
  by nature) and a minimal repository protocol; don't smuggle it into `Feature/Models/`.

---

## 8. Open / next

> **Superseded note:** the items below describe A1/A2's folder shape, which `alva-adoption.md`
> D1/D2 now owns (§1, resolved 2026-07-01). Kept here as a historical record of what this spec
> originally asked for; `alva-adoption.md` §7 is the live implementation backlog.

- **[SUPERSEDED — see `alva-adoption.md` §7.4]** `spec-to-tasks`: emit UI tasks on the A3 stage shape
  (`components [P] → dumb-screen (ui-variations) → make-it-live`), nested under `presentation/<View>/`.
- **[SUPERSEDED — see `alva-adoption.md` §7.5]** `task-execution`: drive the A3 stages inside
  `presentation/<View>/`; "make-it-live" merges VM + JIT data. No `visual-grounding` fire — grounding
  is built into `ui-variations`' graduation (`prototype-first-workflow.md` v2.0 §5).
- **[SUPERSEDED — see `alva-adoption.md` §7.2]** `swift-dev`: gains an architecture reference encoding
  the ALVA slice structure, the dumb-component law, and the factory/router DI shape.
- **[CONSEQUENCE — to implement]** `swiftui-ui-patterns`: record the narrow "screens get
  ViewModels, components don't; screens are few" override.
- **[SUPERSEDED — see `alva-adoption.md` §7.9]** `/akios:init` + `templates/`: scaffold the ALVA slice
  tree + top-level `scratchs/`; `Context.md` notes `scratchs/` stays out of the app target.
- **[CONSEQUENCE — to implement]** `align-ui`: confirmed scope — states/interactions/navigation +
  the per-screen JIT **data-shape (DTO) declaration**.
- **Block B dependency:** the `DesignSystem` struct + tokens that `Foundation/Design-tokens/`
  houses (superseded home, was `PresentationLayer/DesignSystem/`) are defined in
  `swiftui-design-doctrine.md`, along with native-first, reusable ViewModifiers, and
  `containerRelativeFrame` adaptivity.
