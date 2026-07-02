---
name: swiftui-design-system
description: The DesignSystem static-token-struct convention and the .textStyle/.imageStyle role-modifier convention. Load when creating or consuming design tokens, adding a text/image treatment, or deciding whether a value belongs in Foundation/Design-tokens/.
license: MIT
metadata:
  author: Lucas Oliveira
  version: "1.0.0"
---

# SwiftUI Design System — tokens + role modifiers

Home: `Foundation/Design-tokens/` (ALVA). This guide is the akios-specific realization of
`swiftui-design-doctrine.md` §1 (B1) and §4 (B4) — read it before creating a new token or a new
role modifier, and before touching `templates/foundation/DesignSystem.swift` /
`RoleModifiers.swift` (the `/akios:init` stubs this guide fills in, ui-overhaul-implementation.md
Phase 4.1).

## The `DesignSystem` struct

A single `enum DesignSystem` of `static let` constants:

```swift
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
  `.secondary`) plus brand colors from the **asset catalog** — light/dark/accessibility adapt for
  free, brand colors stay in one place.
- **Spacing/Radius/Typography** are the named form of `swiftui-design-principles`'s base-4/8 grid
  and type scale — same values, referenced by name instead of inline literals. That guide stays
  the *source* of the rule values; this one is the *convention* for naming and consuming them.
- **Static, not injected.** A compile-time constant table is not a runtime dependency — reading
  `DesignSystem.Spacing.md` doesn't violate the dumb-component law (a component never accesses
  `@Environment`/a service). Static-over-injected is a deliberate choice, not an oversight.

## The static → instance upgrade rule

Promote `DesignSystem` from a static namespace to an instance behind
`@Environment(\.designSystem)` **only when a second theme actually appears** — not preemptively.
Until then, the static struct is strictly simpler and keeps every component dumb-component-pure.
This is a documented tripwire: don't build the `@Environment` plumbing speculatively "for later."

## Role modifiers: `.textStyle` / `.imageStyle`

A small, **closed set of role-named modifiers** that read `DesignSystem` tokens internally,
exposed as `View` extensions wrapping a `ViewModifier`:

- **Text:** `.textStyle(.hero / .statValue / .body / .sectionLabel / .caption)` — each maps to
  one `DesignSystem.Typography` token (size + weight + design + tracking). Inline
  `.font(.system(size: 42, weight: .light, design: .monospaced))` literals collapse into
  `.textStyle(.hero)`.
- **Image:** `.imageStyle(.avatar / .thumbnail / .badge / .hero)` — encapsulates
  `resizable().scaledToFill()` + frame + `clipShape` + content-mode per role. When an image needs
  fixed chrome, a thin component (`AvatarView`) may *wrap* the modifier — the modifier stays the
  source of truth.

```swift
Text(player.name).textStyle(.body)
AsyncImage(url: player.photo) { $0.imageStyle(.avatar) } placeholder: { … }
```

**The role is the vocabulary, the token table is the implementation** — change the hero size
once and every hero updates. The closed role set structurally enforces the "5 sizes max"
restraint rule `swiftui-design-principles` enforces by checklist — the compiler helps now.
Modifiers reference static tokens only, so they stay dumb-component-pure.

A genuinely one-off treatment either **adds a role** to the closed set, or takes a **justified
raw fallback** (same posture as the native-over-custom budget: a one-line comment, not silent
inline literals).

## Where this fits in ALVA

`Foundation/Design-tokens/` is the visual leaf source `align-ui` checks before proposing a
color/spacing/type-style/component (see `align-ui`'s Nielsen/native-over-custom checks). A
component or ViewModel consumes `DesignSystem` statically — never through DI — even when it's
drawn by a `Router/` coordinator across several slices (see the coordinator note in
`alva-architecture/GUIDE.md`); design tokens are leaf, promoted liberally, with near-zero blast
radius (2-use threshold, unlike `Foundation/Code-tokens/`'s much higher bar).

## Anti-patterns

- Freeform parameterized modifiers like `.appText(size:weight:)` — re-opens the door to
  arbitrary sizes, the exact inline-literal problem with extra steps.
- Raw token references with no modifiers — repeats multi-line image treatment at every call
  site and doesn't satisfy "treatment as reusable modifiers."
- Promoting `DesignSystem` to an `@Environment` instance before a second theme exists.
- A component reading a service or `@Environment` value instead of a static `DesignSystem`
  token — breaks the dumb-component law.
