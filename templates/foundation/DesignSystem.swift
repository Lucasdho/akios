// DesignSystem.swift — starter scaffold, copied by /akios:init into Foundation/Design-tokens/.
//
// Shape defined by `swift-dev`'s `swiftui-design-system` guide
// (skills/swift-dev/skills/swiftui-design-system/GUIDE.md, ui-overhaul-implementation.md Phase
// 4.1) and by `swiftui-design-doctrine.md` §1 (B1). Extend the enums as the app grows — never
// add a raw literal at a call site where one of these tokens (or a new one added here) applies.
//
// Static namespace only. Do NOT make this an `@Environment`-injected instance until a second
// theme actually exists (see the guide's upgrade rule) — that is a deliberate, documented
// tripwire, not an oversight.

import SwiftUI

enum DesignSystem {
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Radius {
        static let card: CGFloat = 10
    }

    enum Typography {
        // size + weight + design + tracking per role — consumed only via .textStyle(_:)
        // (RoleModifiers.swift), never referenced directly at a view call site.
        static let hero: Font = .system(size: 34, weight: .bold, design: .rounded)
        static let body: Font = .system(size: 17, weight: .regular, design: .default)
    }

    enum Color {
        // Semantic system colors adapt to light/dark/accessibility for free.
        static let cardBackground = SwiftUI.Color(.secondarySystemBackground)
        // Brand colors come from the asset catalog, not an inline hex/RGB literal.
        // static let brandPrimary = SwiftUI.Color("BrandPrimary")
    }
}
