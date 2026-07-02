// DesignSystem.swift — starter stub, scaffolded by /akios:init into Foundation/Design-tokens/.
//
// This is a MINIMAL placeholder (ui-overhaul-implementation.md Phase 1.4): it exists so a
// fresh repo has a `Foundation/Design-tokens/` symbol to import from day one. The real shape
// (Spacing/Radius/Typography/Color, semantic-vs-asset-catalog color rules, the static->instance
// upgrade path) is defined in full by `swift-dev`'s `swiftui-design-system` guide
// (skills/swift-dev/skills/swiftui-design-system/GUIDE.md) — read it before extending this file.
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
        // Filled in by swiftui-design-system (Phase 4.1) with the full role table.
    }

    enum Color {
        static let cardBackground = SwiftUI.Color(.secondarySystemBackground)
    }
}
