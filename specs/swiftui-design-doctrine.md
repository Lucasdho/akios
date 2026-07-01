# akios — SwiftUI Design Doctrine
**Working spec · v1.0 · UI overhaul annex (spec 3 of 3)**

Defines the *visual craft* doctrine for UI-first feature development: the unified `DesignSystem`
token struct, the native-over-custom budget, Nielsen's heuristics as the interaction backbone,
text/image treatment as reusable ViewModifiers, and the `containerRelativeFrame` adaptivity rule.
Third and final of the 3-spec UI overhaul family
(**`prototype-first-workflow` → `ui-first-architecture` → `swiftui-design-doctrine`**). Closes the
loop: `ui-first-architecture.md` gave the `DesignSystem` a home (`PresentationLayer/DesignSystem/`)
and a dumb-component law; this spec defines what lives there and how components consume it without
breaking that law. Mostly *adds connective doctrine* and lightly retrofits the two existing guides
(`swiftui-design-principles`, `swiftui-ui-patterns`) to consume it. Everything here is settled
unless marked *open*.

> **State:** designed

> **The shift (visual layer):** agents can build complex logic but cannot *infer* what a beautiful
> interface is. The remedy is twofold — the prototype-first loop (Block C) makes humans the taste
> oracle, and this doctrine makes the *named, enforceable* craft rules so the translation target is
> consistent: one token table, native-first components, a closed type/image vocabulary, and a
> usability backbone. Restraint and consistency are made structural, not left to per-screen judgment.

Worked example: **futebol-manager** (football-manager iOS app; `Squad` feature screens
`SquadList` / `PlayerDetail`).

---

## 1. The `DesignSystem` struct (B1) — static token namespace

A single `enum DesignSystem` of `static let` constants, in `PresentationLayer/DesignSystem/`:

```
enum DesignSystem {
  enum Spacing    { static let xs = 4.0; static let sm = 8.0; static let md = 16.0; … }   // base-4/8 grid
  enum Radius     { static let card = 10.0; … }
  enum Typography { static let hero: Font = …; static let body: Font = …; … }             // size+weight+design+tracking
  enum Color      { static let cardBackground = SwiftUI.Color(.secondarySystemBackground)  // semantic system
                    static let brandPrimary  = SwiftUI.Color("BrandPrimary")               // asset catalog
                    … }
}
```

- **Colors** return **semantic system colors** (`Color(.secondarySystemBackground)`, `.primary`,
  `.secondary`) plus brand colors from the **asset catalog** — so light/dark/accessibility adapt for
  free and brand colors stay in one place.
- **Spacing/Radius/Typography** are the named form of the grid + type scale already in
  `swiftui-design-principles` (§1, §2) — same values, now referenced by name.

**Decision & reason:** a compile-time constant table is **not a runtime dependency**, so reading
`DesignSystem.Spacing.md` is referencing a constant — it does **not** violate the dumb-component law
(`ui-first-architecture.md` §4, "components never access `@Environment`/a service"). Static-over-
injected was chosen *because* of A4. An `@Environment(\.designSystem)` instance (rejected) would
enable runtime themes but force an A4 exception or token prop-drilling — heavyweight for a one-theme
app. A system-leaning hybrid with no single struct (rejected) isn't the "one unified struct"
(unificar cores + interface) the overhaul asked for; colors and tokens would live in different
mechanisms. The cost — runtime theming needs a refactor — is **a documented upgrade path**: promote
`DesignSystem` to an instance behind `@Environment(\.designSystem)` when (and only when) a *second*
theme appears.

---

## 2. The native-over-custom budget (B2) — default-native + justified-exception log

- **Reach for the native component first:** `List`, `Form`, `Toggle`, `Gauge`, `NavigationStack`,
  `Menu`, `.searchable`, `SF Symbols`, system materials, `Divider()`.
- **Building custom requires a one-line justification** recorded at the component:
  `// custom: native <X> can't do <Y>`. The **exception log is the artifact**, not a percentage.
- The **`align-ui` checkpoint flags un-justified custom controls** (a hand-rolled toggle, a
  `GeometryReader` progress bar where `Gauge` fits) — during the `ui-variations` explore round and
  again at its post-wiring check (`prototype-first-workflow.md` v2.0 §5–§6).

**Decision & reason:** "~97% native" is a vibe, not a measurable metric — but "did you try native
first, and if not, why" is checkable by a human or agent. The ~97% survives as the **spirit in
prose**; the enforceable artifact is the justification note + the grounding check. A hard budget
(rejected) is theater nobody can honestly compute, and it both rubber-stamps lazy sub-3% screens and
penalizes legitimately custom-heavy ones (a bespoke pitch/tactics visualization). Pure principle with
no gate (rejected) is toothless — exactly the AI-slop failure mode. This promotes the native-vs-custom
pairs already shown in `swiftui-design-principles` (Gauge vs hand-drawn ring; system `Divider` vs
custom struct; `Toggle` label vs `.labelsHidden()`) from *examples* to a *standing rule*.

---

## 3. Nielsen's heuristics (B3) — the align-ui checklist, fired in the design phase

The 10 usability heuristics become a **reference checklist owned by `align-ui`**, run during the
`design` phase (where states/interactions/navigation/DTO-shape are already decided —
`ui-first-architecture.md` §7–8, Block C's align-ui relocation). Each heuristic maps to a concrete
SwiftUI check:

| Heuristic | Concrete check |
|---|---|
| Visibility of system status | loading / progress / refresh states exist (not a frozen screen) |
| Match system & real world | domain language in copy; SF Symbols that mean what they show |
| User control & freedom | back / cancel / undo paths; non-trapping flows; `.sheet` dismissal |
| Consistency & standards | native components + `DesignSystem` tokens (no bespoke one-offs) |
| Error prevention | destructive actions confirmed; `.sheet(item:)` from payload state (not `Bool`+data) |
| Recognition over recall | no hidden gestures without an affordance; visible options |
| Flexibility & efficiency | sensible defaults; shortcuts (swipe actions, `Menu`) where they help |
| Aesthetic & minimalist | the restraint rule — cross-refs `swiftui-design-principles` Core Philosophy |
| Help users with errors | plain-language error states with a recovery action |
| Help & documentation | empty-state guidance where a screen needs orientation |

**Decision & reason:** the heuristics are about *interaction & flow completeness*, which is precisely
align-ui's job and precisely what a **static prototype can't express** — so they belong to align-ui in
the design phase, giving it the named backbone it currently lacks. Making them the backbone of
`visual-grounding` (rejected at the time; the skill itself is retired as of `prototype-first-workflow.md`
v2.0) muddied a sharp tool: grounding was a *visual diff against the approved prototype* (Block C v1.0)
and most heuristics (undo, error prevention) aren't visible in a screenshot — the reasoning holds even
though the tool it warned against no longer exists. Parking them as a section in
`swiftui-design-principles` (rejected) gives them no firing moment — that guide is pixel craft, not flow
completeness, so they'd sit unread.

---

## 4. Text/image treatment (B4) — semantic role modifiers over the tokens

A small, **closed set of role-named modifiers** that read B1 tokens internally, exposed as `View`
extensions wrapping a `ViewModifier`, living in `PresentationLayer/DesignSystem/`:

- **Text:** `.textStyle(.hero / .statValue / .body / .sectionLabel / .caption)` — each maps to one
  `DesignSystem.Typography` token (size + weight + design + tracking). The inline
  `.font(.system(size: 42, weight: .light, design: .monospaced))` literals in
  `swiftui-design-principles` collapse into `.textStyle(.hero)`.
- **Image:** `.imageStyle(.avatar / .thumbnail / .badge / .hero)` — encapsulates
  `resizable().scaledToFill()` + frame + `clipShape` + content-mode per role. When an image needs
  fixed chrome, a thin component (`AvatarView`) may *wrap the modifier* — the modifier stays the
  source of truth.

```swift
Text(player.name).textStyle(.body)
AsyncImage(url: player.photo) { $0.imageStyle(.avatar) } placeholder: { … }
```

**Decision & reason:** the **role is the vocabulary, the token table is the implementation** — change
the hero size once and every hero updates. A closed role set *structurally* enforces the "5 sizes max"
restraint rule that `swiftui-design-principles` enforces by checklist — now the compiler helps.
Modifiers reference static tokens only, so they stay dumb-component-pure. Freeform parameterized
modifiers like `.appText(size:weight:)` (rejected) re-open the door to 7 arbitrary sizes — the
inline-literal problem with extra steps. Raw token refs with no modifiers (rejected) don't satisfy
"treatment as reusable modifiers" and repeat multi-line image treatment at every call site. A
genuinely one-off treatment **adds a role** or uses a **justified raw fallback** (same posture as B2).

---

## 5. Adaptivity (B5) — native-adaptive-first; `containerRelativeFrame` for proportional sizing

- **Adapt through native flexible containers first:** `Spacer`, `.frame(maxWidth: .infinity)`,
  `Grid` / `LazyVGrid` with adaptive columns, `ViewThatFits`, Dynamic Type.
- **Reach for `containerRelativeFrame` for proportional sizing against the container** — carousel
  cards at a fraction of width, paged horizontal scrollers, count-based grids:
  ```swift
  card.containerRelativeFrame(.horizontal) { width, _ in width * 0.8 }
  ```
  It is a **precision tool for "this should be N% of its container," not a general layout primitive.**
- **Size class is a different axis:** iPad / landscape *restructuring* (split views, two-column) is
  handled by `@Environment(\.horizontalSizeClass)` — layout *restructuring*, distinct from proportional
  *sizing*. Don't conflate the two.

**Decision & reason:** this is what `containerRelativeFrame` is *for*; using it as a general layout
hammer (rejected) over-manualizes layout, hardcodes proportions where `Spacer`/`maxWidth` would flow,
and breaks Dynamic Type and accessibility sizes — the brittle-UI failure mode. Listing it with no
when-to-use rule (rejected) leaves the easy-to-misuse part unguided. This ties into the
`ui-first-architecture.md` adaptive-component goal: a dumb component **sizes off the container it's
dropped into**, not a hardcoded width — so the same component is reusable across a list cell, a sheet,
and an iPad split.

---

## 6. Worked example — futebol-manager *Squad* feature

- **Tokens:** `DesignSystem.Color.cardBackground` (semantic), `DesignSystem.Color.brandPrimary`
  (asset catalog, the club accent), `DesignSystem.Spacing.md`, `DesignSystem.Typography.hero`.
- **Native-first:** `SquadList` is a `List` with swipe actions, not a hand-built scroll; `PlayerRow`
  uses a `Gauge` for form/fitness, not a drawn ring. A bespoke pitch-position diagram in
  `PlayerDetail` carries `// custom: no native control renders an XI on a pitch` — a justified
  exception that grounding accepts.
- **Heuristics (align-ui, design phase):** SquadList declares loading / empty (`no players signed`) /
  error states; the transfer-out action is destructive → confirmed; filters are visible, not hidden.
- **Role modifiers:** `PlayerRow` renders `Text(player.name).textStyle(.body)`,
  `Text(player.rating).textStyle(.statValue)`, `AsyncImage { $0.imageStyle(.avatar) }`. No inline
  `.font(.system(size:…))` anywhere in the feature.
- **Adaptivity:** the form-trend carousel on `PlayerDetail` uses
  `containerRelativeFrame(.horizontal) { w, _ in w * 0.85 }`; the iPad layout splits SquadList +
  PlayerDetail via `horizontalSizeClass`.

---

## 7. Empty / edge states (design-token layer)

- **A needed treatment has no role yet:** add a role to the closed `.textStyle` / `.imageStyle` set
  (or take a *justified* raw fallback, B2-style) — never reintroduce a freeform `size:weight:` modifier.
- **A color must adapt to a state (success/warning/destructive):** add a **semantic** entry to
  `DesignSystem.Color` (system or asset-catalog), not an inline `Color.red.opacity(…)` at the call site.
- **A second theme appears:** that is the trigger to promote `DesignSystem` from a static namespace to
  an instance behind `@Environment(\.designSystem)` (B1 upgrade path) — and only then.
- **The interaction-completeness empty states** (first run, cleared data, loading, error) are owned by
  `align-ui` via the B3 heuristics checklist, not by this token layer.

---

## 8. Open / next

- **[CONSEQUENCE — to implement]** New `swiftui-design-system` reference (home: under `swift-dev`'s
  guides, beside `swiftui-design-principles`): the `DesignSystem` token-struct convention + the
  `.textStyle`/`.imageStyle` role-modifier convention + the static-vs-instance upgrade rule.
- **[CONSEQUENCE — to implement]** `swiftui-design-principles` retrofit: keep its spacing-grid /
  "5 sizes" / semantic-color rules as the **source** of the token table; update examples to show
  `.textStyle(.hero)` + `DesignSystem.*` token refs instead of inline `.font(.system(size:…))` /
  `Color(.x)` literals. (Vendored guide, arjitj2, MIT v1.1.1 — values preserved, call sites re-homed.)
- **[CONSEQUENCE — to implement]** `swiftui-ui-patterns`: cross-link the role-modifier convention from
  its "custom view modifiers" guidance.
- **[CONSEQUENCE — to implement]** `align-ui`: add the 10-heuristic checklist (§3 table) as its
  design-phase backbone; record the native-over-custom flag (B2) as a grounding/align-ui check.
- **[CONSEQUENCE — to implement]** `/akios:init` + `templates/`: scaffold a starter
  `PresentationLayer/DesignSystem/` (`DesignSystem` token enum stub + `TextStyle`/`ImageStyle`
  role-modifier stubs).
- **[CONSEQUENCE — to implement]** `swift-dev` architecture reference (the one A8 introduces): note
  that components consume `DesignSystem` static tokens — never `@Environment` — preserving the
  dumb-component law.
- **Family closure:** locking B closes the C→A→B overhaul. All three specs are `designed`; the full
  implementation backlog is the union of the open sections in `prototype-first-workflow.md`,
  `ui-first-architecture.md`, and this spec.
