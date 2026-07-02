// RoleModifiers.swift — starter stub, scaffolded by /akios:init into Foundation/Design-tokens/.
//
// MINIMAL placeholder (ui-overhaul-implementation.md Phase 1.4) for the closed `.textStyle` /
// `.imageStyle` role-modifier vocabulary. The full role set and the ViewModifier bodies (reading
// DesignSystem.swift's tokens, never a raw literal) are defined by `swift-dev`'s
// `swiftui-design-system` guide (skills/swift-dev/skills/swiftui-design-system/GUIDE.md) — fill
// this in from there rather than inventing new roles ad hoc.
//
// Rule: a role modifier reads static DesignSystem tokens only — it stays dumb-component-pure
// (no @Environment, no service lookups).

import SwiftUI

enum TextStyle {
    case body
    // More roles (.hero, .statValue, .sectionLabel, .caption) land with Phase 4.1.
}

enum ImageStyle {
    case avatar
    // More roles (.thumbnail, .badge, .hero) land with Phase 4.1.
}

extension View {
    func textStyle(_ style: TextStyle) -> some View {
        switch style {
        case .body:
            return self.font(.body)
        }
    }
}
